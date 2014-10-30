% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function process_location_gt(x,y,w,gts,r)
gtsz=length(gts);
assert(gtsz==length(w));
for k=1:length(gts)
  gt_crop=cropPatch(gts{k},x,y,r);
  initFig(); im(gt_crop); title(['ground truth ' num2str(k), ' score ' num2str(w(k))]);
end
end
