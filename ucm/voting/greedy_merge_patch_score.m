% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function w = greedy_merge_patch_score(ws_patch,hs,patch_score_fcn)
% compare two equaly-sized segmentation patches and return a similarity score
% in [0,1]

% initFig;im(ws_patch);
% initFig;im(hs);
ws_nsegs=max(ws_patch(:));
% in if the merge was done using naive_greedy_merge, it would in fact happen
% that the ws_patch has only 1 segment
% assert(ws_nsegs>1);
hs_nsegs=max(hs(:));
if hs_nsegs==1
  w=0; % double(ws_nsegs==1);
else
  w=patch_score_fcn(ws_patch,hs);
end
end
