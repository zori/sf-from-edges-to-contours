function runExperiment()
% SRF training and evaluation (using the VSB100 benchmark)

closeParpool=false;
logging=false;

% example log files:
% video_segm_evaluation/VSB100_40/test/recordings/2014-06-05_13-37-46/_recordings.txt - git version, runtimes
% video_segm_evaluation/VSB100_40/test/recordings/2014-06-05_13-37-46/_recordings.mat - training, detection and benchmark options; benchmark output

LOG.dsFolder='VSB100_40';
LOG.modelName=[LOG.dsFolder ''];
LOG.dsDir=fullfile('/BS/kostadinova/work/video_segm_evaluation', LOG.dsFolder);
LOG.recordingsDir=fullfile(LOG.dsDir, 'test', 'recordings');
LOG.timestamp=datestr(clock,'yyyy-mm-dd_HH-MM-SS');
LOG.timestampDir=fullfile(LOG.recordingsDir, LOG.timestamp);
LOG.file=fullfile(LOG.timestampDir, '_recordings.txt');
LOG.fid=1; % default is stdout

if (logging)
  disp(LOG.timestamp);
  if (~exist(LOG.recordingsDir, 'dir')), mkdir(LOG.recordingsDir), end
  mkdir(LOG.timestampDir), LOG.fid=fopen(LOG.file, 'w');
end
cd(fileparts(mfilename('fullpath')));
[status, gitCommitId]=system('git --no-pager log --format="%H" -n 1');
if (status), warning('no git repository in %s', pwd); end
fprintf(LOG.fid, 'Last git commit %s \n', gitCommitId);

%% Training

% set opts for training (see edgesTrain.m)
trOpts=edgesTrain();                       % default options (good settings)
trOpts.modelDir='models/';                 % model will be in models/forest
trOpts.modelFnm=['model' LOG.modelName];   % model name
trOpts.nPos=5e5;                           % decrease to speedup training
trOpts.nNeg=5e5;                           % decrease to speedup training
trOpts.useParfor=logging;                  % parallelize if sufficient memory; true iff benchmarking
trOpts.dsDir=fullfile(LOG.dsDir, 'train', filesep);

% train edge detector (~30m/15Gb per tree, proportional to nPos/nNeg)
if (trOpts.useParfor && isempty(gcp('nocreate')))
  pool=parpool(12);
  addAttachedFiles(pool,'/BS/kostadinova/work/video_segm/private/edgesDetectMex.mexw64');
end

timerTr=tic;
model=edgesTrain(trOpts); % will load model if already trained
trainingTime=toc(timerTr);

%% Detection

% set detection parameters (can set after training)
model.opts.multiscale=false;      % for top accuracy set multiscale=true
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation; used in edgesDetectMex
model.opts.nms=false;             % set to true to enable nms (fairly slow)

% run edge/segment detector
detOpts={
  'imDir',  fullfile(LOG.dsDir, 'test/Images/'),...
  'gtDir',  fullfile(LOG.dsDir, 'test/Groundtruth/'),...
  'resDir', fullfile(LOG.dsDir, 'test/Ucm2/')};

timerDet=tic;
segmDetect(model, detOpts);
detectionTime=toc(timerDet);

%% Benchmark

bmOpts.path=[LOG.dsDir];                      % path to bmOpts.dir
bmOpts.dir='test';                            % contains the directories `Images', `Groundtruth' and `Ucm2' (computed results of the algorithm of Dollar)
bmOpts.nthresh=51;                            % number of hierarchical levels to include
bmOpts.superposeGraph=false;                  % true - new curves are added to the same graph; false - a new graph is initialized
bmOpts.testTempConsistency=true;  % false for images
% possible benchmark metrics
metrics={
  'bdry',...       % BPR - Boundary Precision-Recall
  'regpr',...      % VPR - Volumetric Precision-Recall
  'sc',...         % SC  - Segmentation Covering
  'pri',...        % PRI - Probabilistic Rand Index
  'vi',...         % VI  - Variation of Information
  'lengthsncl',... % length statistics and number of clusters
  'all'};          % computes all available
bmOpts.metric=metrics{end};
bmOpts.outDir=fullfile('recordings', LOG.timestamp);

timerBm=tic;
% Computerpimvid computes the Precision-Recall curves
output=Computerpimvid(bmOpts.path, bmOpts.nthresh, bmOpts.dir,...
  false, 0, 'r', bmOpts.superposeGraph, bmOpts.testTempConsistency,...
  bmOpts.metric, [], bmOpts.outDir); %#ok<NASGU>
benchmarkTime=toc(timerBm);

fprintf(LOG.fid, 'Training %s \nDetection %s \nBenchmark %s\n\n',...
  seconds2human(trainingTime),...
  seconds2human(detectionTime),...
  seconds2human(benchmarkTime));

if (closeParpool && ~isempty(gcp('nocreate'))), delete(gcp('nocreate')); end

if (logging)
  fclose(LOG.fid);
  save(fullfile(LOG.timestampDir, '_recordings'),...
    'trOpts', 'detOpts', 'bmOpts', 'output');
end
end
