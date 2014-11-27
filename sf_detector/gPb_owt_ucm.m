% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function ucm2 = gPb_owt_ucm(I,fmt)
% the original algorithm that uses oriented gradient (in 8 angular directions)
if nargin<2, fmt='imageSize'; end % to comply with default in contours2ucm
gPb_orient=globalPb(I);
ucm2=contours2ucm(gPb_orient,fmt);
end
