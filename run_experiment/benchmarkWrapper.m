% Zornitsa Kostadinova
% Jul 2014
function fhs=benchmarkWrapper(LOG)
bmOpts.path=LOG.dsDir;
bmOpts.dirR='test';
bmOpts.outDirR=fullfile('recordings', LOG.timestamp);
bmOpts.tempConsistency=LOG.ds.isVideo;
bmOpts.nthresh=51;
bmOpts.useParfor=true;
bmOpts.imDirR=LOG.imDirR;
bmOpts.gtDirR=LOG.gtDirR;
bmOpts.inDirR=LOG.resDirR;

timerBm=tic;
[output,fhs]=ComputeRP(bmOpts);  %#ok<ASGLU>
benchmarkTime=toc(timerBm);

fprintf(LOG.fid, 'Benchmark %s \n', seconds2human(benchmarkTime));
save(LOG.matFile,'bmOpts','output','-append');
end
