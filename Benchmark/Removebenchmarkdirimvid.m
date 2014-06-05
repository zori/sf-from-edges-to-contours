function Removebenchmarkdirimvid(filenames,additionalmasname)

[sbenchmarkdir,imgDir,gtDir,inDir,isvalid] = Benchmarkcreatedirsimvid(filenames, additionalmasname, true); %#ok<ASGLU>

if (isvalid)
    rmdir(sbenchmarkdir,'s')
    fprintf('Dir %s removed\n',sbenchmarkdir);
else
    fprintf('Dir %s not removed (non existing)\n',sbenchmarkdir);
end

