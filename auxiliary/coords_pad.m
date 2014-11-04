% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function [px,py] = coords_pad(x,y,p)
% pad x and y dimensions
px=x+p(3);
py=y+p(1);
end
