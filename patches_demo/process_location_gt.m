% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function process_location_gt(x,y,w,gts,p,r)
gtsz=length(gts);
assert(gtsz==length(w));
[coordsPad_fcn,imPad_fcn]=get_pad_fcns(p);
[px,py]=coordsPad_fcn(x,y);
for k=1:length(gts)
  show_patch(gts{k},imPad_fcn,px,py,r,['ground truth ' num2str(k), ' score ' num2str(w(k))]);
end
end
