% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function seg = threshold_ucm2(ucm2,threshold)
% Thresholds the ucm and returns a segmentation. Makes use of the fact that in
% the ucm2 the odd locations contain the probability of boundary (contour).
%
% INPUTS
%  ucm2         - UCM, double resolution (w.r.t the image size); to allow for
%                 correct border placement
%  threshold    - a threshold, in (0,1)
%
% OUTPUTS
%  seg          - the segmentation corresponding to threshold for the UCM
labels2 = bwlabel(ucm2 <= threshold);
seg = labels2(2:2:end, 2:2:end);
end
