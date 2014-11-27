% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function B = compress_labels(A)
% this helper function is useful when visualising segmentation patches
% segmentation labels are defined up to a permutation
% if you don't apply it to the patches, there is a risk that the labels are so
% vaying that the visualisation doesn't correctly show different segments
[~,~,t]=unique(A);
B=reshape(t,size(A));
end
