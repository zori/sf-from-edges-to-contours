% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
% from Benchmark/Evaluatesegmbdry.m
function F = bpr(S,G,px_max_dist)
% ? symmetric w.r.t. S and G
% also, output is non-deterministic (uses randomisation inside)
%
% INPUTS
%  S            - w x w boundary map of test segmentation patch
%  G            - w x w boundary map of ground truth patch
%  px_max_dist  - [3] the maximal distance in pixels for corresponding the boundary
%                 maps; should be set with w (the size of the input) in mind
%
% OUTPUTS
%  F            - (an approximation to) the F-value of the BPR (similarity score in [0;1])
if ~exist('px_max_dist','var'), px_max_dist=3; end % for a 16x16 image patch values larger than 7 pixels are pointless
sz=size(S,1);
assert(sz==size(S,2));
assert(all(size(S)==size(G)));
d=sqrt(2*16.^2);
max_dist=px_max_dist./d; % the algorithm is very sensitive to this value

gts={G};
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
%   bmap=double(bwmorph(bmap,'thin',inf)); % OJO
% else
%   bmap=double(bmap);
% end
% TODO(2) Offsetthesegs  -- for the segs corresponding to the boundaries

% accumulate machine matches, since the machine pixels are allowed to match with any segmentation
accP=zeros(size(S));
cntR=0; sumR=0;

% compare to each seg in turn
for k=1:numel(gts)
  % compute the correspondence
  % this procedure apparently contains some kind of randomization, as matches are not guaranteed to be the same for the same input
  [match1,match2]=correspondPixels(S,double(gts{k}),max_dist);
  % accumulate machine matches
  accP=accP|match1;
  % compute recall
  sumR=sumR+sum(gts{k}(:)); % the sum of the all boundary pixels from all the ground truth images
  cntR=cntR+sum(match2(:)>0); % the sum of the ground truth boundary pixels which can be matched to the computed segmentation pixels, over the available ground truths
end

% compute precision
sumP=sum(S(:)); % the sum of boundary pixels from the computed segmentation
cntP=sum(accP(:)); % the sum of the boundary pixels from the computed segmentation which can be matched to any boundary from any of the ground truth

F=calculate_R_P_F(cntR,sumR,cntP,sumP);
end
