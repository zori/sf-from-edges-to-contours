function Removetheoutputimvid(filenames,additionalmasname,outputdir)

if (~exist('outputdir','var'))
    outputdir=[]; %The default directory in additionalmasname is defined in the function Benchmarkcreateoutimvid
end

[sbenchmarkdir,outDir,isvalid] = Benchmarkcreateoutimvid(filenames, additionalmasname, true, outputdir); %#ok<ASGLU>

if (isvalid)
    rmdir(outDir,'s')
    fprintf('Dir %s removed\n',outDir);
else
    fprintf('Dir %s not removed (non existing)\n',outDir);
end

