% Zornitsa Kostadinova
% Jul 2014
function model = edgesTrainWrapper(LOG)
% Set opts for training (see edgesTrain.m)
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
