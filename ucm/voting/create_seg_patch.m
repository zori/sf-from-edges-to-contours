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
%  seg_patch    - the created segmentation patch of size r x r, containing two
%                 segments labeled '1' and '2' respectively
%
% these are the 4 end pnts of the r x r patch
ul=[x-r+1 y-r+1]; ur=[x+r y-r+1]; % fst the x coords, then the y
ll=[x-r+1 y+r];   lr=[x+r y+r];
sq=[ul; ll; lr; ur];
ints=intersectLinePolygon(l, sq);
assert(all(size(ints)==[2 2]));
ints=ints-[ul;ul]; % go to the coord system of a r x r patch
ints=floor(ints')+1; % TODO correct?
ints=num2cell(ints);
[lx,ly]=bresenham(ints{:});
seg_patch=zeros(2*r);
idx=sub2ind(size(seg_patch),ly,lx);
seg_patch(idx)=1;
% the patch is now a boundary, transform to a segmentation
seg_patch=watershed(seg_patch,4);
seg_patch(seg_patch==0)=1; % TODO fix, rather than arbitrarily assign to the one class
end
