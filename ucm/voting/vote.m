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
  % show contour patch
  contour_patch=create_contour_patch(px,py,rg,ws_args{:});
  pshow(contour_patch);
  % also mark the end vertices
  hold on; c=ws_args{1}; e=ws_args{2};
  v1=c.vertices(c.edges(e,1),:); % fst coord is y - row ind
  v2=c.vertices(c.edges(e,2),:);
  plot(v1(2)-x+rg,v1(1)-y+rg,'g*'); % fst end point is green
  plot(v2(2)-x+rg,v2(1)-y+rg,'r*');
  title('WS patch - contour');
  % show fitted line patch
  fitted_line_patch=create_fitted_line_patch(px,py,rg,ws_args{1:2});
  pshow(fitted_line_patch); title('WS patch - fitted line');
  % show fitted polynomial patch
  fitted_poly1_patch=create_fitted_poly_patch(px,py,1,rg,ws_args{1:2});
  pshow(fitted_poly1_patch); title('WS patch - fitted poly n=1');
  fitted_poly2_patch=create_fitted_poly_patch(px,py,2,rg,ws_args{1:2});
  pshow(fitted_poly2_patch); title('WS patch - fitted poly n=2');
  % TODO visualise a patch from the greedy merge
  % show processed patch by current algorithm
  rgb_patch_init=imcc(ws_patch_init);
  rgb_patch=imcc(ws_patch);
  pshow(rgb_patch_init); title('WS patch - initial');
  pshow(rgb_patch); title('ws patch - processed');
  % show processed hs if any difference
  if numel(hs)~=numel(hs_init) || ~all(hs(:)==hs_init(:))
    for k=1:size(hs,3), pshow(hs(:,:,k)); title('a ''G'' patch - processed'); end
  end
  process_location_fcn(x,y,w);
  keyboard; % this is like putting a breakpoint here
  initFig(1); close all; % reset the counter and close all figures
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
