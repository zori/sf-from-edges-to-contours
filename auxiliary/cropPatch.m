% Zornitsa Kostadinova
% Jul 2014
% 8.3.0.532 (R2014a)
function patch = cropPatch(I,x,y,r)
% crop a patch with radius r from an image I at location [x y]
% output patch has dimensions [2r x 2r]
x=uint32(floor(x)); y=uint32(floor(y));
% SZ=size(I); Y=SZ(1); X=SZ(2);
% if Y<y+r ||X < x+r
%   disp({x,y});
% end
patch=I(y-r+1:y+r,x-r+1:x+r,:);
end
