% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
function seg_patch = thick_bdry2seg(bdry_patch)
% transforms a thick bdry patch to a segmentation patch
% such boundary is only considered a boundary if the pixel has a neighbouring
% boundary pixel in the 4-neighbourhood
% initFig; im(bdry_patch);

% observe the difference
ws4=watershed(bdry_patch,4); % eats away the corners of the boundaries (making them thin and crisp)
ws8=watershed(bdry_patch,8);
% initFig; im(ws4)
% initFig; im(ws8)

bwl4=bwlabel(bdry_patch==0,4);
bwl8=bwlabel(bdry_patch==0,8);
% those two are the same for thick boundary
% initFig; im(bwl4)
% initFig; im(bwl8)

SC=super_contour_4c(bdry_patch);
% initFig; im(SC);
% % labels2=bwlabel(clean_watersheds(SC)==0,8); % TODO don't
% % clean the watersheds for speed
% labels2=bwlabel(SC==0,8); % type: double; 0 indicates boundary

labels2=double(watershed(SC,8));
seg_patch=labels2(2:2:end,2:2:end); % labels should start from 1
% initFig; im(seg_patch);
% unfortunately, this assertion still fails sometimes
% assert(~any(seg_patch(:)==0));

% labels sometimes start from 0; this artifacts is due to the fact that a crop
% from the watershed is not a natural image (and can have 0 label - boundary,
% at the patch border, without the corresponding segment being in the patch
%
% as a workaround, relabel the remaining isolated boundary pixels (based on
% connected component):
isolated_bdry=bwlabel(seg_patch==0);
seg_patch=(isolated_bdry~=0)*max(seg_patch(:))+isolated_bdry+seg_patch;
% initFig; im(seg_patch);
end
