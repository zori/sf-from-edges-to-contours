function [dirA,imDir,gtDir,inDir,isvalid] = Benchmarkcreatedirsimvid(path_, dirR, onlyassignnames, names)
% imDir images (for name listing), gtDir ground truth, inDir ucm2, outDir output

if ( (~exist('onlyassignnames','var')) || (isempty(onlyassignnames)) )
  onlyassignnames=false;
end
isvalid=true;
if (onlyassignnames)
  [dirA,isvalidtmp] = Checkadir(fullfile(path_.benchmark,dirR)); isvalid=isvalid&isvalidtmp;
  [imDir,isvalidtmp] = Checkadir(fullfile(dirA,names.imDirR)); isvalid=isvalid&isvalidtmp;
  [gtDir,isvalidtmp] = Checkadir(fullfile(dirA,names.gtDirR)); isvalid=isvalid&isvalidtmp;
  [inDir,isvalidtmp] = Checkadir(fullfile(dirA,names.inDirR)); isvalid=isvalid&isvalidtmp;
else
  Createadir(path_.benchmark);
  dirA = Createadir(fullfile(path_.benchmark,dirR));
  imDir = Createadir(fullfile(dirA,names.imDirR));
  gtDir = Createadir(fullfile(dirA,names.gtDirR));
  inDir = Createadir(fullfile(dirA,names.inDirR));
  %Additionally isvalid could be generated in Createadir
end
