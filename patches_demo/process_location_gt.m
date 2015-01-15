% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function process_location_gt(px,py,w,gts_padded,r)
gtsz=length(gts_padded);
assert(gtsz==length(w));
gt_patches=cell(1,5);
for k=1:length(gts_padded)
  gt_patches{k}=compress_labels(cropPatch(gts_padded{k},px,py,r));
end
for k=1:length(gts_padded)
  pshow(gt_patches{k});
  title(['ground truth ' num2str(k), ' score ' num2str(w(k))]);
end
% alternatively, just 'montage' the five gt patches together (no scores)
initFig; montage2(cell2array(gt_patches)); montage2title('the 5 ground truths');
end
