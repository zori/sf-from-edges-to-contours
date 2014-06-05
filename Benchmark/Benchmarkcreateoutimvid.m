function [sbenchmarkdir,outDir,isvalid] = Benchmarkcreateoutimvid(filenames, additionalmasname, onlyassignnames, outputdir)
%imgDir images (for name listing), gtDir ground truth, inDir ucm2, outDir output

if ( (~exist('outputdir','var')) || (isempty(outputdir)) )
    outputdir='Output';
end
if ( (~exist('onlyassignnames','var')) || (isempty(onlyassignnames)) )
    onlyassignnames=false;
end

isvalid=true;
if (onlyassignnames)
    
    [sbenchmarkdir,isvalidbench] = Checkadir([filenames.benchmark,additionalmasname,filesep]); isvalid=isvalid&isvalidbench;
                                                                                              
    [outDir,isvalidtmp] = Checkadir([sbenchmarkdir,outputdir,filesep]);                    isvalid=isvalid&isvalidtmp;
    
    %outDir does not to exist
else
    
    Createadir(filenames.benchmark);
    
    sbenchmarkdir = Createadir([filenames.benchmark,additionalmasname,filesep]);

    outDir = Createadir([sbenchmarkdir,outputdir,filesep]);
    
    %Additionally isvalid could be generated in Createdir
end

