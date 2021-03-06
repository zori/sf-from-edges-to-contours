% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function seg_patch = create_seg_patch(x,y,r,l)
% create a square segmentation patch with radius r, as if its center is at
% (x,y) and a line l was fit through it
%
% INPUTS
%  x, y         - coordinates of the patch
%  r            - radius of the patch
%  l            - 1-by-4 row vector containing parametric representation of
%                 the line (in the format [x0 y0 dx dy], see the function
%                 'createLine' for details).
%
% OUTPUTS
%  seg_patch    - the created segmentation patch of size 2r x 2r, containing
%                 two segments labeled '1' and '2' respectively
%
% these are the 4 end pnts of the 2r x 2r patch
% note the y axis is pointing "down":
%  -------> x
%  |
%  |
%  V
%  y
bdry_patch=create_bdry_patch(x,y,r,l);
% the patch is now a boundary, transform to a segmentation
seg_patch=thin_bdry2seg(bdry_patch);
end
