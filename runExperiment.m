function runExperiment()
% SRF training and evaluation (using the VSB100 benchmark)

close_parpool=false;
to_log=false;

% example log files:
% video_segm_evaluation/VSB100_40/test/recordings/2014-06-05_13-37-46/_recordings.txt - git version, runtimes
% video_segm_evaluation/VSB100_40/test/recordings/2014-06-05_13-37-46/_recordings.mat - training, detection and benchmark options; benchmark output

log_.dsFolder='VSB100_40';
log_.model_name=[log_.dsFolder ''];
log_.dsDir=fullfile('/BS/kostadinova/work/video_segm_evaluation', log_.dsFolder); % '/BS/kostadinova/work/BSR/BSDS500/data/';
log_.recordings_dir=fullfile(log_.dsDir, 'test', 'recordings');
log_.timestamp=datestr(clock,'yyyy-mm-dd_HH-MM-SS');
log_.timestamp_dir=fullfile(log_.recordings_dir, log_.timestamp);
log_.file=fullfile(log_.timestamp_dir, '_recordings.txt');
log_.fid=1; % default is stdout

if (to_log)
  disp(log_.timestamp);
  if (~exist(log_.recordings_dir, 'dir')), mkdir(log_.recordings_dir), end
  mkdir(log_.timestamp_dir), log_.fid=fopen(log_.file, 'w');
end
cd(fileparts(mfilename('fullpath')));
[status, git_commit_id]=system('git --no-pager log --format="%H" -n 1');
if (status), warning('no git repository in %s', pwd); end
fprintf(log_.fid, 'Last git commit %s \n', git_commit_id);

%% Training

% set opts for training (see edgesTrain.m)
tr_opts=edgesTrain();                       % default options (good settings)
tr_opts.modelDir='models/';                 % model will be in models/forest
tr_opts.modelFnm=['model' log_.model_name]; % model name
tr_opts.nPos=5e5;                           % decrease to speedup training
tr_opts.nNeg=5e5;                           % decrease to speedup training
tr_opts.useParfor=to_log;                   % parallelize if sufficient memory; true iff benchmarking
tr_opts.dsDir=fullfile(log_.dsDir, 'train', filesep);

% train edge detector (~30m/15Gb per tree, proportional to nPos/nNeg)
if (tr_opts.useParfor && isempty(gcp('nocreate')))
  pool=parpool(12);
  addAttachedFiles(pool,'/BS/kostadinova/work/video_segm/private/edgesDetectMex.mexw64');
end

timeEdgesTrain=tic;
model=edgesTrain(tr_opts); % will load model if already trained
training_time=toc(timeEdgesTrain);

%% Detection

% set detection parameters (can set after training)
model.opts.multiscale=false;      % for top accuracy set multiscale=true
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=false;             % set to true to enable nms (fairly slow)

% run edge/segment detector
det_opts={
  'imgDir', fullfile(log_.dsDir, 'test/Images/'),...
  'gtDir',  fullfile(log_.dsDir, 'test/Groundtruth/'),...
  'resDir', fullfile(log_.dsDir, 'test/Ucm2/')};

timeSegmDetect=tic;
segmDetect(model, det_opts);
detection_time=toc(timeSegmDetect);

%% Benchmark

bm_opts.path=[log_.dsDir];         % path to bm_opts.dir
bm_opts.dir='test';                % contains the directories `Images', `Groundtruth' and `Ucm2' (computed results of the algorithm of Dollar)
bm_opts.nthresh=51;                % number of hierarchical levels to include
bm_opts.superposeGraph=false;      % true - new curves are added to the same graph; false - a new graph is initialized
bm_opts.testTempConsistency=true;  % false for images
% possible benchmark metrics
metrics={
  'bdry',...       % BPR - Boundary Precision-Recall
  'regpr',...      % VPR - Volumetric Precision-Recall
  'sc',...         % SC  - Segmentation Covering
  'pri',...        % PRI - Probabilistic Rand Index
  'vi',...         % VI  - Variation of Information
  'lengthsncl',... % length statistics and number of clusters
  'all'};          % computes all available
bm_opts.metric=metrics{end};
bm_opts.outDir=fullfile('recordings', log_.timestamp);

timeBenchmark=tic;
% Computerpimvid computes the Precision-Recall curves
output=Computerpimvid(bm_opts.path, bm_opts.nthresh, bm_opts.dir,...
  false, 0, 'r', bm_opts.superposeGraph, bm_opts.testTempConsistency,...
  bm_opts.metric, [], bm_opts.outDir); %#ok<NASGU>
benchmark_time=toc(timeBenchmark);

fprintf(log_.fid, 'Training %s \nDetection %s \nBenchmark %s\n\n',...
  seconds2human(training_time),...
  seconds2human(detection_time),...
  seconds2human(benchmark_time));

if (close_parpool && ~isempty(gcp('nocreate'))), delete(gcp('nocreate')); end

if (to_log)
  fclose(log_.fid);
  save(fullfile(log_.timestamp_dir, '_recordings'),...
    'tr_opts', 'det_opts', 'bm_opts', 'output');
end
end
