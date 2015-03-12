% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function w = vote(x,y,rg,ws_fcn,ws_args,hs_fcn,patch_score_fcn,process_location_fcn,crop_ws_patch_fcn,dbg)
if ~exist('dbg','var') || isempty(dbg), dbg=false; end
px=x+2*rg; py=y+2*rg; % adjust patch dimensions TODO: should be p(3) and p(1)
[ws_patch_processed,ws_patch_init]=ws_fcn(px,py,ws_args{:});
[hs,hs_init]=hs_fcn(x,y); % a few 16x16 segmentation patches
assert(size(hs,1)==size(ws_patch_processed,1));
% assert(size(hs,1)==rg*2);
w=compute_weights(ws_patch_processed,hs,patch_score_fcn);

% compute fitted line patch
% 1) line ends
fitted_line_patch=create_fitted_line_patch(px,py,rg,ws_args{1:2});
% 2) line centre
fitted_line_centre_patch=create_fitted_line_centre_patch(px,py,rg,ws_args{1:2});
% 3) line linear least squares (lls)
fitted_line_lls_patch=create_fitted_line_lls_patch(px,py,rg,ws_args{1:2});

% % check if they are different
% flp=fitted_line_patch(:);
% flcp=fitted_line_centre_patch(:);
% fllp=fitted_line_lls_patch(:);
% if dbg && ~(any(flp~=flcp) && any(flp~=fllp) && any(flcp~=fllp))
%   dbg=false;
% end

if dbg
  process_location_fcn(x,y,w);
  % show greedy merge patch(es) % copied from 'compute_weights'
%   hsz=size(hs_init,3);
%   for k=1:hsz
%     hs_k=double(hs_init(:,:,k));
%     if length(unique(hs_k(:)))~=1
%       ws_patch_segs=spx2seg(crop_ws_patch_fcn(px,py));
%       initFig; im(hs_k); title(['hs ' num2str(k)]);
%       naive_greedy_merge(double(ws_patch_segs),hs_k,dbg,k);
%       greedy_merge(double(ws_patch_segs),hs_k,dbg,k); % could work with uint8, but not desirable in case some of the segments have labels bigger than 255
%     end
%   end
  % show contour patch
  contour_patch=create_contour_patch(px,py,rg,ws_args{:});
  pshow(contour_patch);
  % also mark the end vertices
  hold on; c=ws_args{1}; e=ws_args{2};
  v1=c.vertices(c.edges(e,1),:); % fst coord is y - row ind
  v2=c.vertices(c.edges(e,2),:);
  plot(v1(2)-x+rg,v1(1)-y+rg,'g*'); % fst end point is green
  plot(v2(2)-x+rg,v2(1)-y+rg,'r*'); % snd is red
  % screenshot-friendly versions of the end points:
  hold on; plot(v1(2)-x+rg,v1(1)-y+rg,'LineWidth',8,'Marker','*','MarkerSize',36,'MarkerFaceColor',[0.5,0.5,0.5],'MarkerEdgeColor','g');
  plot(v2(2)-x+rg,v2(1)-y+rg,'LineWidth',8,'Marker','*','MarkerSize',36,'MarkerFaceColor',[0.5,0.5,0.5],'MarkerEdgeColor','r');
  
  title('WS patch - contour'); % or region boundary
  %
  % show fitted line patch
  pshow(fitted_line_patch); title('WS patch - fitted line ends');
%   pshow(fitted_line_centre_patch); title('WS patch - fitted line centre');
%   pshow(fitted_line_lls_patch); title('WS patch - fitted LINE lls');

  % show fitted polynomial patch
  % polynomial using quadratic lls fitting (previously: conic)
  fitted_quadratic_lls_patch=create_fitted_conic_patch(px,py,rg,ws_args{1:2});
  pshow(fitted_quadratic_lls_patch); title('WS patch - fitted QUADRATIC lls');
  % the following function was 'buggy' - not trivial to set the threshold to
  % find an edge
  %   fitted_poly1_patch=create_fitted_poly_patch(px,py,1,rg,ws_args{1:2});
  %   pshow(fitted_poly1_patch); title('WS patch - fitted poly n=1');
  %   fitted_poly2_patch=create_fitted_poly_patch(px,py,2,rg,ws_args{1:2});
  %   pshow(fitted_poly2_patch); title('WS patch - fitted poly n=2');
  % show processed patch by current algorithm
  initFig; imcc(ws_patch_init); title('WS patch - initial');
  initFig; imcc(ws_patch_processed); title('WS patch - processed');
  % show processed hs if any difference
  if numel(hs)~=numel(hs_init) || ~all(hs(:)==hs_init(:))
    for k=1:size(hs,3), pshow(hs(:,:,k)); title('a ''G'' patch - processed'); end
  end
  keyboard; % this is like putting a breakpoint here
  close all; % reset the counter and close all figures
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
