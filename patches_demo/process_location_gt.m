% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function process_location_gt(px,py,w,gts_padded,r)
gtsz=length(gts_padded);
assert(gtsz==length(w));
for k=1:length(gts_padded)
  show_patch(gts_padded{k},px,py,r,['ground truth ' num2str(k), ' score ' num2str(w(k))]);
end
end
