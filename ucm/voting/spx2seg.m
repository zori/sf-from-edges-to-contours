% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
function seg_patch = spx2seg(spx_patch)
% convert the superpixels patch that comes from the watershed to be a
% segmentation labeling (starting from 1)
% the input has the boundary denoted by 0
% see pb2ucm
bdry_patch=spx2bdry01(spx_patch);
seg_patch=thick_bdry2seg(bdry_patch);
end

% ----------------------------------------------------------------------
function bdry_patch = spx2bdry01(spx_patch)
% convert the superpixels patch to be a 0-1 boundary location
% the input has the boundary denoted by 0
% the output has the boundary denoted by 1, non-boundary by 0
bdry_patch=spx_patch==0;
end

% TODO review the following and get rid of, perhaps
% ----------------------------------------------------------------------
function patch = seg2bdry01(patch)
% NOTE: keep that for now, but also note seg2bdry (Arbelaez implementation)
% convert the seg to be 0-1 boundary location
patch=gradientMag(single(patch))>.01;
end
