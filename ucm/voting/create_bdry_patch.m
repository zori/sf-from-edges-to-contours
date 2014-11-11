% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function bdry_patch = create_bdry_patch(x,y,r,l)
% create a square boundary patch with radius r, as if its center is at (x,y)
% and a line l was fit through it
%
% INPUTS
%  x, y         - coordinates of the patch
%  r            - radius of the patch
%  l            - 1-by-4 row vector containing parametric representation of
%                 the line (in the format [x0 y0 dx dy], see the function
%                 'createLine' for details).
%
% OUTPUTS
%  bdry_patch   - the created bdry patch of size 2r x 2r, based on fitting the
%                 line l; boundary pixels are 1, background - 0
%
% these are the 4 end pnts of the 2r x 2r patch
% note the y axis is pointing "down":
%  -------> x
%  |
%  |
%  V
%  y
ul=[x-r+1 y-r+1]; ur=[x+r y-r+1]; % fst the x coords, then the y
ll=[x-r+1 y+r];   lr=[x+r y+r];
sq=[ul; ll; lr; ur];
ints=intersectLinePolygon(l, sq);
assert(all(size(ints)==[2 2]));
ints=ints-[ul;ul]; % go to the coord system of a 2r x 2r patch
ints=floor(ints')+1; % TODO correct?
ints=num2cell(ints);
[lx,ly]=bresenham(ints{:});
bdry_patch=zeros(2*r);
idx=sub2ind(size(bdry_patch),ly,lx);
bdry_patch(idx)=1;
end
