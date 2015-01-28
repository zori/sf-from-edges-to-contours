% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
function [x,y] = edge_coords_in_patch_space(c,e,patch_side)
% x,y - column vectors
esz=numel(c.edge_x_coords{e});
x=zeros(esz,1); y=x;
for k=1:esz
  y(k)=c.edge_x_coords{e}(k)+patch_side; % adjust indices for the padded superpixelised image (+patch_side)
  x(k)=c.edge_y_coords{e}(k)+patch_side;
end

% also consider the end vertices
v1=c.vertices(c.edges(e,1),:)+patch_side; % fst coord is y - row ind
v2=c.vertices(c.edges(e,2),:)+patch_side;
x=[v1(2); x; v2(2)];
y=[v1(1); y; v2(1)];
end
