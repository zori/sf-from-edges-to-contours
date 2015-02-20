% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)
function seg_explicit = mean_colour_segmentation_explicit(I,labels)
% this function provides an explicit mean colour segmentation (i.e.
% segmentation with a white boundary between segments)

% implicit mean colour segmentation, a.k.a. labelling
seg_implicit=mean_colour_segmentation(I,labels);
bdry=seg2bdry(labels,'imageSize');
assert(size(seg_implicit,3)==3);
seg_explicit=uint8(zeros(size(seg_implicit)));
for k=1:3
  seg_explicit(:,:,k)=seg_implicit(:,:,k).*(uint8(1-bdry)) + uint8(bdry.*255);
end
end
