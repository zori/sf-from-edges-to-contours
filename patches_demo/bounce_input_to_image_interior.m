% Zornitsa Kostadinova
% Dec 2014
% 8.3.0.532 (R2014a)
function [x,y] = bounce_input_to_image_interior(x,y,r,szI)
% return x y coordinates within the inside (not a band with width r) of the original image
if y<r, y=r; else if y>szI(1)-r, y=szI(1)-r; end; end
if x<r, x=r; else if x>szI(2)-r, x=szI(2)-r; end; end
end
