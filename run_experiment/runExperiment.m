% Zornitsa Kostadinova
% Jun 2014
function runExperiment()
% SRF training and evaluation (using the VSB100 benchmark)

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

%% Optionally, plot additionally precomputed results from other algorithms
plotContext(LOG);

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
bmOpts={'path',LOG.dsDir,'dirR','test',...
  'outDirR',fullfile('recordings', LOG.timestamp),...
  'tempConsistency',LOG.dss(LOG.dsId).isVideo,'nthresh',51};

timerBm=tic;
output=ComputeRP(bmOpts); %#ok<NASGU>
benchmarkTime=toc(timerBm);

fprintf(LOG.fid, 'Benchmark %s \n', seconds2human(benchmarkTime));
save(LOG.matFile,'bmOpts','output','-append');
end

% ----------------------------------------------------------------------
function plotContext(LOG)
plotOpts=struct('path',fullfile(LOG.dsDir,'test'),'dirR','precomputed',...
  'outDirR',fullfile('recordings', LOG.timestamp),...
  'tempConsistency',LOG.dss(LOG.dsId).isVideo,...
  'nthresh',51,'superposePlot',true);

% TODO add avg human agreement ComputeRP(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'k',false,[],'all',[],'Output_general_human');
% directories, labels and colors for the precomputed results
data=struct('outDir',{'Output_srf_dollar','Output_df_vanilla_watershed_over-seg','Output_df_ucm','Output_df_and_sPb'},...
  'legend',{'DF structured edge','DF Watershed Over-segmentation','UCM','DF + sPb'},...
  'color',{'g','b','m','r.'});

for k=1:length(data)
  plotOpts.curveColor=data(k).color;
  plotOpts.outDirR=data(k).outDir;
  [~,fhs]=ComputeRP(plotOpts);
end
for k=1:length(fhs)
  figure(fhs(k));
  legend(data.legend,'Location','NorthEastOutside');
  figTitle=get(get(gca,'Title'),'String');
  fileName=strrep(figTitle,' ','_');
  saveas(gcf,fullfile(plotOpts.path,plotOpts.dirR,['_',fileName]),'jpg');
end
end
