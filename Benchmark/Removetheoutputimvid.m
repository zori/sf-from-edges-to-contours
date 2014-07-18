function Removetheoutputimvid(path_,dirR,outDirR)

if (~exist('outDirR','var'))
  outDirR=[]; %The default directory in dirR is defined in the function Benchmarkcreateoutimvid
end

[~,outDirA,isvalid] = Benchmarkcreateoutimvid(path_, dirR, true, outDirR);

if (isvalid)
  rmdir(outDirA,'s')
  fprintf('Dir %s removed\n',outDirA);
else
  fprintf('Dir %s not removed (non existing)\n',outDirA);
end

