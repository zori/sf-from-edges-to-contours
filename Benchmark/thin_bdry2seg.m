% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function seg_patch = thin_bdry2seg(bdry_patch)
% transforms a thin, crisp bdry patch to a segmentation patch
% such boundary is considered a boundary even when the connection between two
% pixels is only diagonal, i.e. neighbouring pixels are allowed in the
% 8-neighborhood

seg_patch=watershed(bdry_patch,4);
% seg_patch(seg_patch==0)=1; % this arbitrarily assigns to the class '1'
% % instead, do sth fairer:

max_label=max(seg_patch(:));
seg_patch(seg_patch==0)=max_label+1;
SC=super_contour_4c(seg_patch);

% SCmid=SC(2:end-1,2:end-1);
% initFig;im(SC);
% initFig;im(SCmid);

lr=min(SC(1:end-2,2:end-1),SC(2:end-1,1:end-2));
ud=min(SC(3:end,2:end-1),SC(2:end-1,3:end));
SCmid=min(lr,ud);
% initFig;im(lr);
% initFig;im(ud);
% initFig;im(SCmid);
SC(2:end-1,2:end-1)=SCmid;
% initFig;im(SC);
seg_patch=SC(2:2:end,2:2:end);
% initFig; im(seg_patch);
assert(~any(seg_patch(:)==0));
end
