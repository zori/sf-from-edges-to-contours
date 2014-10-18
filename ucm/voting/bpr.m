% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
% from Benchmark/Evaluatesegmbdry.m
function F = bpr(S,G)
% input: two boundary maps
% algorithm is, of course, very sensitive to the value of maxDist
maxDist=0.0075; %3px for a 320x240 image
% maxDist=0.3375; % ??? px for a 320x240 image
% should I code for gts - many ground truths?
cntR=0;
sumR=0;
cntP=0;
sumP=0;

bmap=S;
groundTruth={G}; % boundaries
% % TIP: how to process the input - S:
% if (~exist('segs', 'var'))
%   bmap = (pb>=thresh(t)); % ucm
% else
%   bmap = logical(seg2bdry(segs{thresh(t)},'imageSize')); %Doublebackconv(segs{thresh(t)}); is not necessary, as just a value difference matter
% end
% 
% TODO(1)
% % thin the thresholded pb to make sure boundaries are standard thickness
% if (thinpb)
%   bmap = double(bwmorph(bmap, 'thin', inf));    % OJO
% else
%   bmap=double(bmap);
% end
% TODO(2) Offsetthesegs  -- for the segs corresponding to the boundaries

% accumulate machine matches, since the machine pixels are
% allowed to match with any segmentation
accP = zeros(size(bmap));

% compare to each seg in turn
for i = 1:numel(groundTruth)
  % compute the correspondence
  [match1,match2] = correspondPixels(bmap, double(groundTruth{i}), maxDist);
  % accumulate machine matches
  accP = accP | match1;
  % compute recall
  sumR = sumR + sum(groundTruth{i}(:));
  cntR = cntR + sum(match2(:)>0);
end
%sumR: the sum of the all boundary pixels from all the ground truth images
%cntR: the sum of the ground truth boundary pixels which can be matched to the computed segmentation pixels, over the available ground truths

% compute precision
sumP = sumP + sum(bmap(:));
cntP = cntP + sum(accP(:));
%sumP: the sum of boundary pixels from the computed segmentation
%cntP: the sum of the boundary pixels from the computed segmentation which can be matched to any boundary from any of the ground truth

F=calculate_R_P_F(cntR,sumR,cntP,sumP);
end
