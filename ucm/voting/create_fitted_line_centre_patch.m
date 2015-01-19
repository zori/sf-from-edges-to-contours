% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
function patch = create_fitted_line_centre_patch(px,py,rg,c,e)
% fitted line passes through the centre of the patch
l=fit_line(px,py,c,e,2*rg);
patch=create_bdry_patch(px,py,rg,l);
end

% ----------------------------------------------------------------------
function l = fit_line(px,py,c,e,patch_side)
% fit a line
v1=c.vertices(c.edges(e,1),:); % fst coord is y - row ind
v2=c.vertices(c.edges(e,2),:);
% adjust indices for the padded superpixelised image
v1=v1+patch_side;v2=v2+patch_side;
% l=createLine([v1(2),v1(1)],[v2(2),v2(1)]);
% createLine(x0,y0,dx,dy)
l=createLine(px,py,v2(2)-v1(2),v2(1)-v1(1));
end
