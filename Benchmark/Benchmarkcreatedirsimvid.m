function [sbenchmarkdir,imgDir,gtDir,inDir,isvalid] = Benchmarkcreatedirsimvid(filenames, additionalmasname, onlyassignnames)
%imgDir images (for name listing), gtDir ground truth, inDir ucm2, outDir output

if ( (~exist('onlyassignnames','var')) || (isempty(onlyassignnames)) )
    onlyassignnames=false;
end

isvalid=true;
if (onlyassignnames)
    
    [sbenchmarkdir,isvalidtmp] = Checkadir([filenames.benchmark,additionalmasname,filesep]); isvalid=isvalid&isvalidtmp;
    [imgDir,isvalidtmp] = Checkadir([sbenchmarkdir,'Images',filesep]);                    isvalid=isvalid&isvalidtmp;
    [gtDir,isvalidtmp] = Checkadir([sbenchmarkdir,'Groundtruth',filesep]);                isvalid=isvalid&isvalidtmp;
    [inDir,isvalidtmp] = Checkadir([sbenchmarkdir,'Ucm2',filesep]);                       isvalid=isvalid&isvalidtmp;
    
else
    
    Createadir(filenames.benchmark);
    
    sbenchmarkdir = Createadir([filenames.benchmark,additionalmasname,filesep]);
    imgDir = Createadir([sbenchmarkdir,'Images',filesep]);
    gtDir = Createadir([sbenchmarkdir,'Groundtruth',filesep]);
    inDir = Createadir([sbenchmarkdir,'Ucm2',filesep]);
    
    %Additionally isvalid could be generated in Createdir
end

