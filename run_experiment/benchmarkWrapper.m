% Zornitsa Kostadinova
% Jul 2014
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
