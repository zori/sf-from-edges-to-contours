% Zornitsa Kostadinova
% Jul 2014
% 8.3.0.532 (R2014a)
function patch = cropPatch(I,x,y,r)
% crop a patch with radius r from an image I at location [x y]
% output patch has dimensions [2r x 2r]
x=uint32(floor(x)); y=uint32(floor(y));
% to see the location from where we're going to crop
% figure; im(I);
% hold on; plot(x,y,'rx','MarkerSize',20);
patch=I(y-r+1:y+r,x-r+1:x+r,:);
end
