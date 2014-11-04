% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function [coordsPad_fcn,imPad_fcn] = get_pad_fcns(p)
coordsPad_fcn=@(x,y) coords_pad(x,y,p);
imPad_fcn=@(src) imPadSym(double(src),p);
end
