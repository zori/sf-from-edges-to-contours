% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function ucm2 = SE_ucm(I,model,fmt)
if nargin<3, fmt='imageSize'; end % to comply with default in contours2ucm
E=edgesDetect(I,model);
ucm2=contours2ucm(E,fmt);
end
