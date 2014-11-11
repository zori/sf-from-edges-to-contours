% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function w = vote(x,y,rg,ws_fcn,ws_args,hs_fcn,patch_score_fcn,process_location_fcn,dbg)
if ~exist('dbg','var') || isempty(dbg), dbg=false; end
px=x+2*rg; py=y+2*rg; % adjust patch dimensions TODO: should be p(3) and p(1)
[ws_patch,ws_patch_init]=ws_fcn(px,py,ws_args{:});
[hs,hs_init]=hs_fcn(x,y); % a few 16x16 segmentation patches
assert(size(hs,1)==size(ws_patch,1));
% assert(size(hs,1)==rg*2);
w=compute_weights(ws_patch,hs,patch_score_fcn);
if dbg
  rgb_patch_init=label2rgb(ws_patch_init,'jet',[1 1 1],'shuffle');
  rgb_patch=label2rgb(ws_patch,'jet',[1 1 1],'shuffle');
  pshow(rgb_patch_init); title('ws patch - initial');
  pshow(rgb_patch); title('ws patch - processed');
  if numel(hs)~=numel(hs_init) || ~all(hs(:)==hs_init(:))
    for k=1:size(hs,3), pshow(hs(:,:,k)); title('a ''G'' patch - processed'); end
  end
  process_location_fcn(x,y,w);
  keyboard; % this is like putting a breakpoint here
  close all;
end
end

% ----------------------------------------------------------------------
function w = compute_weights(ws_patch,hs,patch_score_fcn)
hsz=size(hs,3); % number of ground truth patches
w=zeros(hsz,1);
for k=1:hsz
  w(k)=patch_score_fcn(double(ws_patch),double(hs(:,:,k))); % could work with uint8, but not desirable in case some of the segments have labels bigger than 255
end
end % computeWeights
