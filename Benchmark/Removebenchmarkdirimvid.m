function Removebenchmarkdirimvid(path_,dirR,names)

[dirA,~,~,~,isvalid] = Benchmarkcreatedirsimvid(path_, dirR, true,names);

if (isvalid)
  rmdir(dirA,'s')
  fprintf('Dir %s removed\n',dirA);
else
  fprintf('Dir %s not removed (non existing)\n',dirA);
end

