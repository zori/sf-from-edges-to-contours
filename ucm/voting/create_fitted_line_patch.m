% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function patch = create_fitted_line_patch(px,py,rg,c,e)
persistent cache;
if ~isempty(cache) && cache{1}==e, [~,l]=deal(cache{:}); else
  l=fit_line(c,e,2*rg); cache={e,l};
end
patch=create_bdry_patch(px,py,rg,l);
end

% ----------------------------------------------------------------------
function l = fit_line(c,e,patch_side)
% fit a line
v1=c.vertices(c.edges(e,1),:); % fst coord is y - row ind
v2=c.vertices(c.edges(e,2),:);
% adjust indices for the padded superpixelised image
v1=v1+patch_side;v2=v2+patch_side;
l=createLine([v1(2),v1(1)],[v2(2),v2(1)]);
end
