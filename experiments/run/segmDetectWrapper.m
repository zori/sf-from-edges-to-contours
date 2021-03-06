% Zornitsa Kostadinova
% Jul 2014
function model = segmDetectWrapper(model,LOG)
% set detection parameters (can set after training)
model.opts.multiscale=false;      % for top accuracy set multiscale=true
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation; used in edgesDetectMex
model.opts.nms=false;             % set to true to enable nms (fairly slow)

% attach mex file needed for detection to parallel pool
addAttachedFiles(gcp(),...
  {fullfile('sf_detector','edgesDetectMex.mexa64'),...
   fullfile('ucm','ucm_mean_pb.mexa64')});

% run edge/segment detector
detOpts.imDir=fullfile(LOG.dsDir,'test',LOG.imDirR);
detOpts.gtDir=fullfile(LOG.dsDir,'test',LOG.gtDirR); % for the oracle
detOpts.resDir=fullfile(LOG.dsDir,'test',LOG.resDirR);
detOpts.is_voting=true;
detOpts.outType=LOG.detOutputType; % edge, edgeContours, seg, ucm, sPb, voteUcm, oracle

if any(strcmp(detOpts.outType,{'seg','ucm'}))
  % non-maximum suppression "breaks" the watershed; here is why:
  %
  % Non-maximum suppression considers only the maxima in the gradient
  % direction. As a consequence, the final output of the SE often has only
  % single regional minimum. In the presence of a unique lake, the watershed
  % is empty. To circumvent this problem, we use the SE detector before
  % non-maxima suppression as topographic surface for the flooding.
  if model.opts.nms
    warning('non-maximum suppression ''breaks'' the watershed; unsetting');
    model.opts.nms=false;
  end
end
  
timerDet=tic;
segmDetect(model,detOpts);
detectionTime=toc(timerDet);

fprintf(LOG.fid, 'Detection %s \n', seconds2human(detectionTime));
save(LOG.matFile,'detOpts','-append');
end
