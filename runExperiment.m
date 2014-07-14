function runExperiment()
% SRF training and evaluation (using the VSB100 benchmark)

LOG.logging=false;

LOG.repoDir='/BS/kostadinova/work/video_segm';
LOG.evalDir='/BS/kostadinova/work/video_segm_evaluation';
LOG.dss=struct('name', {'BSDS500' 'VSB100_40' 'VSB100_full' 'VSB100_tiny'},...
  'isVideo', {false true true true});
LOG.dsId=1;
LOG.modelName=[LOG.dss(LOG.dsId).name '_patches'];
% log directories
LOG.dsDir=fullfile(LOG.evalDir, LOG.dss(LOG.dsId).name);
LOG.recordingsDir=fullfile(LOG.dsDir, 'test', 'recordings');
if (~exist(LOG.recordingsDir, 'dir')), mkdir(LOG.recordingsDir), end
LOG.timestamp=datestr(clock,'yyyy-mm-dd_HH-MM-SS'); disp(LOG.timestamp);
LOG.timestampDir=fullfile(LOG.recordingsDir, LOG.timestamp);
mkdir(LOG.timestampDir);
% example log files:
% video_segm_evaluation/VSB100_40/test/recordings/2014-06-05_13-37-46/_recordings.txt - git version, runtimes
% video_segm_evaluation/VSB100_40/test/recordings/2014-06-05_13-37-46/_recordings.mat - training, detection and benchmark options; benchmark output
LOG.txtFile=fullfile(LOG.timestampDir, '_recordings.txt');
LOG.matFile=fullfile(LOG.timestampDir, '_recordings.mat');
LOG.fid=fopen(LOG.txtFile, 'w');
save(LOG.matFile,'LOG');

cd(LOG.repoDir);
[status, gitCommitId]=system('git --no-pager log --format="%H" -n 1');
if (status), warning('no git repository in %s', pwd); else
  fprintf(LOG.fid, 'Last git commit %s \n', gitCommitId); end
cd(fileparts(mfilename('fullpath')));

%% Training
model=edgesTrainWrapper(LOG);

%% Detection
segmDetectWrapper(model,LOG);

%% Benchmark
benchmarkWrapper(LOG);

%%
if (~isempty(gcp('nocreate'))), delete(gcp('nocreate')); end
fprintf(LOG.fid, '\n'); fclose(LOG.fid);
end

% ----------------------------------------------------------------------
function model = edgesTrainWrapper(LOG)
% set opts for training (see edgesTrain.m)
trOpts=edgesTrain();                         % default options (good settings)
trOpts.modelDir=fullfile(LOG.repoDir,'models/'); % model will be in models/forest
trOpts.modelFnm=['model' LOG.modelName];     % model name
trOpts.nPos=5e5;                             % decrease to speedup training
trOpts.nNeg=5e5;                             % decrease to speedup training
trOpts.useParfor=true;                       % parallelize if sufficient memory
trOpts.dsDir=fullfile(LOG.dsDir, 'train', filesep);

% train edge detector (~30m/15Gb per tree, proportional to nPos/nNeg)
if (trOpts.useParfor && isempty(gcp('nocreate')))
  addAttachedFiles(parpool(12),fullfile(LOG.repoDir,'private/edgesDetectMex.mexw64'));
end

timerTr=tic;
model=edgesTrain(trOpts); % will load model if already trained
trainingTime=toc(timerTr);

fprintf(LOG.fid, 'Training %s \n', seconds2human(trainingTime));
save(LOG.matFile,'trOpts','-append');
end

% ----------------------------------------------------------------------
function model = segmDetectWrapper(model,LOG)
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
segmDetect(model,detOpts);
detectionTime=toc(timerDet);

fprintf(LOG.fid, 'Detection %s \n', seconds2human(detectionTime));
save(LOG.matFile,'detOpts','-append');
end

% ----------------------------------------------------------------------
function benchmarkWrapper(LOG)
bmOpts.path=LOG.dsDir;                                % path to bmOpts.dir
bmOpts.dir='test';                                    % contains the directories `Images', `Groundtruth' and `Ucm2' (computed results of the algorithm of Dollar)
bmOpts.nthresh=51;                                    % number of hierarchical levels to include
bmOpts.superposeGraph=false;                          % true - new curves are added to the same graph; false - a new graph is initialized
bmOpts.testTempConsistency=LOG.dss(LOG.dsId).isVideo; % true iff test set consists of videos
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

plotContext(LOG);

fprintf(LOG.fid, 'Benchmark %s \n', seconds2human(benchmarkTime));
save(LOG.matFile,'bmOpts','output','-append');
end

% ----------------------------------------------------------------------
function plotContext(LOG)
plotOpts.path=fullfile(LOG.dsDir, 'test');
plotOpts.dir='precomputed';
plotOpts.nthresh=51; % Number of hierarchical levels to include when benchmarking image segmentation

Computerpimvid(plotOpts.path,plotOpts.nthresh,plotOpts.dir,false,0,'r',true,[],'all',[],'Output_df_vanilla_watershed_over-seg');
Computerpimvid(plotOpts.path,plotOpts.nthresh,plotOpts.dir,false,0,'b',true,[],'all',[],'Output_df_ucm');

% Computerpimvid(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'k',false,[],'all',[],'Output_general_human');
% Computerpimvid(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'r',true,[],'all',[],'Output_general_corsoetal');
% Computerpimvid(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'b',true,[],'all',[],'Output_general_galassoetal');
% Computerpimvid(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'g',true,[],'all',[],'Output_general_grundmannetal');
end
