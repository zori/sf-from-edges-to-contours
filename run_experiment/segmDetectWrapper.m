% Zornitsa Kostadinova
% Jul 2014
function model = segmDetectWrapper(model,LOG)
% set detection parameters (can set after training)
model.opts.multiscale=false;      % for top accuracy set multiscale=true
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation; used in edgesDetectMex
model.opts.nms=false;             % set to true to enable nms (fairly slow)

% run edge/segment detector
detOpts={
  'imDir',  fullfile(LOG.dsDir, 'test/Images'),...
  'resDir', fullfile(LOG.dsDir, 'test/Ucm2')...
  'outType', 'seg'... % edge, seg, ucm, sPb, voteUcm
  };

timerDet=tic;
segmDetect(model,detOpts);
detectionTime=toc(timerDet);

fprintf(LOG.fid, 'Detection %s \n', seconds2human(detectionTime));
save(LOG.matFile,'detOpts','-append');
end
