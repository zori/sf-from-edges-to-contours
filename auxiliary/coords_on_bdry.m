% Zornitsa Kostadinova
% Dec 2014
% 8.3.0.532 (R2014a)
function on_bdry = coords_on_bdry(x,y,sz,r)
% checks if the coordinates x, and y are close to the boundary of the image
% (with size |sz|)
% r - (optional) thickness of boundary band
if ~exist('r','var'), r=16; end
on_bdry = on_bdry_one(1, x, sz(2), r) || on_bdry_one(1, y, sz(1), r); % note: y indexes into first coordinate, x - into second
end

function on_bdry = on_bdry_one(from, coord, to, r)
on_bdry = coord < from + r || to - r < coord;
end
