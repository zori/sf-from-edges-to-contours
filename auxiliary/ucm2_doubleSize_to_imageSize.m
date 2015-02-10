% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)
function ucm = ucm2_doubleSize_to_imageSize(ucm2)
  % TODO in original Arbelaez code in contours2ucm - getting the imageSize by subindexing this way (3:2:end, 3:2:end);
  % figure out was this really a bug
  ucm=ucm2(1:2:end-2,1:2:end-2);
end
