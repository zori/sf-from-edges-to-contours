% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function w = greedy_merge(fst,snd)
% compare two equaly-sized segmentation patches and return a similarity score
% in [0,1]

% That seems to be a source of bugs
% if max(fst(:))<max(snd(:)), tmp=fst; fst=snd; snd=tmp; end

% TODO just for debugging purposes
fstOrig=fst;
f_nsegs=max(fst(:));
s_nsegs=max(snd(:));
% assert(min(fst(:))==1);
% assert(f_nsegs==numel(unique(fst)));
% assert(min(snd(:))==1);
% assert(s_nsegs==numel(unique(snd)));

if s_nsegs==1
  w=double(f_nsegs==1);
else
  if f_nsegs>s_nsegs
    % TODO - how to move that to process_ws_patch and process_hs if it depends on both patches
    groundTruth={struct('Segmentation',fst)}; % a cell containing a structure with a field .Segmentation
    confcounts=Getconfcounts(snd,groundTruth,f_nsegs);
    % assert(size(confcounts,1) < size(confcounts,2));
    confcounts=confcounts(2:end,2:end);
    [~,I]=max(confcounts,[],1);
    u=unique(fst(7:9,7:9));
    assert(length(u)>1);
    % TODO do better in case length(u)>2
    if I(u(1)) == I(u(2))
      m=max(I);
      I(u(1))=m+1;
      I(u(2))=m+2;
    end
    fst=I(fst);
  end
  p=false; 
  if p
    initFig(1); im(fstOrig);
    initFig(); im(fst);
    initFig(); im(snd);
  end
  w=RSRI(fst,snd);
end
end
