% Zornitsa Kostadinova
% Jul 2014
function fhs=benchmarkWrapper(LOG)
bmOpts={'path',LOG.dsDir,'dirR','test',...
  'outDirR',fullfile('recordings', LOG.timestamp),...
  'tempConsistency',LOG.ds.isVideo,'nthresh',51,'useParfor',true};

timerBm=tic;
[output,fhs]=ComputeRP(bmOpts);  %#ok<ASGLU>
benchmarkTime=toc(timerBm);

fprintf(LOG.fid, 'Benchmark %s \n', seconds2human(benchmarkTime));
save(LOG.matFile,'bmOpts','output','-append');
end
