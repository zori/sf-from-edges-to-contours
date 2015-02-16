% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)
function merged_ws_patch = naive_greedy_merge(spx_ws_patch,hs,dbg,k)
% that was the original way to do greedy merge, which was overly greedy -
% adapts itself excessively to the tree leaf segmentation (hs)

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
    ; % here the "fair greedy merge would have kicked-in; a good place for breakpoints to compare the two "flavours" of the patch segments merge algorithm
  end
  merged_ws_patch=I(spx_ws_patch);
else
  merged_ws_patch=spx_ws_patch;
end
if dbg % for debug output, plot the greedily merged patches
  assert(~~exist('k','var'));
  % initFig;imcc(spx_ws_patch);
  initFig; imcc(merged_ws_patch); title(['WS patch - naive greedy merge with hs ' num2str(k)]);
end
end
