% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function w = compareSegs(fst,snd)
% compare two equaly-sized segmentation patches and return a similarity score
% in [0,1]
if max(fst(:))<max(snd(:)), tmp=fst; fst=snd; snd=tmp; end

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
    groundTruth={struct('Segmentation',fst)}; % a cell containing a structure with a field .Segmentation
    confcounts=Getconfcounts(snd,groundTruth,f_nsegs);
    % assert(size(confcounts,1) < size(confcounts,2));
    confcounts=confcounts(2:end,2:end);
    [~,I]=max(confcounts,[],1);
    fst=I(fst);
  end
  p=false; 
  if p
    initFig(1); im(fstOrig);
    initFig(); im(fst);
    initFig(); im(snd);
  end
  w=CPD(fst,snd);
end
end
