% Zornitsa Kostadinova
% Jun 2014
function runExperiment()
% SRF training and evaluation (using the VSB100 benchmark)

LOG.repoDir='/BS/kostadinova/work/video_segm';
LOG.evalDir='/BS/kostadinova/work/video_segm_evaluation';
dss=[...
  struct('name','BSDS500','isVideo',false),...
  struct('name','VSB100_40','isVideo',true),...
  struct('name','VSB100_full','isVideo',true),...
  struct('name','VSB100_half','isVideo',true),... % only added so that we can run the memory-greedy "sf + sPb" on VSB100
  struct('name','VSB100_tiny','isVideo',true),...
  ];
dsName='BSDS500';
LOG.ds=dss(strcmp({dss.name},dsName));
LOG.modelName=[LOG.ds.name ''];
% log directories
LOG.dsDir=fullfile(LOG.evalDir, LOG.ds.name);
LOG.recordingsDir=fullfile(LOG.dsDir, 'test', 'recordings');
if (~exist(LOG.recordingsDir, 'dir')), mkdir(LOG.recordingsDir), end
LOG.timestamp=datestr(clock,'yyyy-mm-dd_HH-MM-SS'); disp(LOG.timestamp);
LOG.timestampDir=fullfile(LOG.recordingsDir, LOG.timestamp);
%%
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

% Optionally, plot additionally precomputed results from other algorithms
% plotContext(LOG);

%%
if (~isempty(gcp('nocreate'))), delete(gcp('nocreate')); end
fprintf(LOG.fid, '\n'); fclose(LOG.fid);
end
