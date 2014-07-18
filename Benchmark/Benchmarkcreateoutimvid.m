function [dirA,outDirA,isvalid] = Benchmarkcreateoutimvid(path_, dirR, onlyassignnames, outDirR)

if ( (~exist('outDirR','var')) || (isempty(outDirR)) )
  outDirR='Output';
end
if ( (~exist('onlyassignnames','var')) || (isempty(onlyassignnames)) )
  onlyassignnames=false;
end

isvalid=true;
if (onlyassignnames)
  [dirA,isvalidbench] = Checkadir(fullfile(path_.benchmark,dirR)); isvalid=isvalid&isvalidbench;
  [outDirA,isvalidtmp] = Checkadir(fullfile(dirA,outDirR)); isvalid=isvalid&isvalidtmp;
  % outDirR does not to exist
else
  Createadir(path_.benchmark);
  dirA = Createadir(fullfile(path_.benchmark,dirR));
  outDirA = Createadir(fullfile(dirA,outDirR));
  % Additionally isvalid could be generated in Createadir
end
