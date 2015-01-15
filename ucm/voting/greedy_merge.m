% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function ws_patch = greedy_merge(ws_patch,hs)
% That seems to be a source of bugs
% if max(ws_patch(:))<max(hs(:)), tmp=ws_patch; ws_patch=hs; hs=tmp; end

% initFig;im(ws_patch);
% initFig;im(hs);
ws_nsegs=max(ws_patch(:));
hs_nsegs=max(hs(:));
assert(min(ws_patch(:))==1);
assert(ws_nsegs==numel(unique(ws_patch)));
% assert(min(hs(:))==1); % TODO do we only fail here in the 'oracle' case?
% assert(hs_nsegs==numel(unique(hs)));

if hs_nsegs~=1
  if ws_nsegs>hs_nsegs
    % TODO - how to move that to process_ws_patch and process_hs if it depends on both patches
    groundTruth={struct('Segmentation',ws_patch)}; % a cell containing a structure with a field .Segmentation
    confcounts=Getconfcounts(hs,groundTruth,ws_nsegs);
    % assert(size(confcounts,1) < size(confcounts,2));
    confcounts=confcounts(2:end,2:end);
    [~,I]=max(confcounts,[],1);
    u=unique(ws_patch(7:9,7:9));
    assert(length(u)>1);
    % TODO do better in case length(u)>2
    if I(u(1)) == I(u(2))
      m=max(I);
      I(u(1))=m+1;
      I(u(2))=m+2;
    end
    ws_patch=I(ws_patch);
  end
end
end
