% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function merged_ws_patch = greedy_merge(spx_ws_patch,hs,dbg,k)
% Don't switch over the watershed and the hs (tree or oracle patch)!
% Distinction is important.
% if max(ws_patch(:))<max(hs(:)), tmp=ws_patch; ws_patch=hs; hs=tmp; end

if ~exist('dbg','var'), dbg=false; end

ws_nsegs=max(spx_ws_patch(:));
hs_nsegs=max(hs(:));
assert(min(spx_ws_patch(:))==1);
assert(ws_nsegs==numel(unique(spx_ws_patch)));
% assert(min(hs(:))==1); % TODO do we only fail here in the 'oracle' case?
% assert(hs_nsegs==numel(unique(hs)));

if hs_nsegs~=1 && ws_nsegs>hs_nsegs % hs_nsegs>=2; ws_nsegs>=3
  % TODO - how to move that to process_ws_patch and process_hs if it depends on both patches
  % TODO hs should be groundTruth (since matching, as Fabio says, is not symmetric)
  % however, there doesn't seem to be a difference in practice
  groundTruth={struct('Segmentation',spx_ws_patch)}; % a cell containing a structure with a field .Segmentation
  confcounts=Getconfcounts(hs,groundTruth,ws_nsegs);
  % assert(size(confcounts,1) < size(confcounts,2));
  confcounts=confcounts(2:end,2:end);
  [~,I]=max(confcounts,[],1);
  u=unique(spx_ws_patch(7:9,7:9));
  assert(length(u)>1);
  % 'fair' segments merge - make sure there remain at least two different segment labels around the central pixel
  if length(unique(I(u)))==1
    m=max(I);
    % randomly choose to which segment (out of those around the centre pixel)
    % to re-assign a new label
    
    % I1=I;I2=I;I3=I;
    % I1(u(1))=3; merged_ws_patch_opt1=I1(spx_ws_patch); initFig;imcc(merged_ws_patch_opt1);
    % I2(u(2))=3; merged_ws_patch_opt2=I2(spx_ws_patch); initFig;imcc(merged_ws_patch_opt2);
    % I3(u(3))=3; merged_ws_patch_opt3=I3(spx_ws_patch); initFig;imcc(merged_ws_patch_opt3);
    u_ix=randi(length(u));
    I(u(u_ix))=m+1;
  end
  merged_ws_patch=I(spx_ws_patch);
else
  merged_ws_patch=spx_ws_patch;
end
if dbg % for debug output, plot the greedily merged patches
  assert(~~exist('k','var'));
  % initFig;imcc(spx_ws_patch);
  initFig; im(hs); title(['hs ' num2str(k)]);
  initFig; imcc(merged_ws_patch); title(['WS patch - greedy merge with hs ' num2str(k)]);
end
end
