function [dirA,imDir,gtDir,inDir,isvalid] = Benchmarkcreatedirsimvid(path_, dirR, onlyassignnames)
% imDir images (for name listing), gtDir ground truth, inDir ucm2, outDir output

if ( (~exist('onlyassignnames','var')) || (isempty(onlyassignnames)) )
  onlyassignnames=false;
end

isvalid=true;
if (onlyassignnames)
  [dirA,isvalidtmp] = Checkadir(fullfile(path_.benchmark,dirR)); isvalid=isvalid&isvalidtmp;
  [imDir,isvalidtmp] = Checkadir(fullfile(dirA,'Images')); isvalid=isvalid&isvalidtmp;
  [gtDir,isvalidtmp] = Checkadir(fullfile(dirA,'Groundtruth')); isvalid=isvalid&isvalidtmp;
  [inDir,isvalidtmp] = Checkadir(fullfile(dirA,'Ucm2')); isvalid=isvalid&isvalidtmp;
else
  Createadir(path_.benchmark);
  dirA = Createadir(fullfile(path_.benchmark,dirR));
  imDir = Createadir(fullfile(dirA,'Images'));
  gtDir = Createadir(fullfile(dirA,'Groundtruth'));
  inDir = Createadir(fullfile(dirA,'Ucm2'));
  %Additionally isvalid could be generated in Createadir
end
