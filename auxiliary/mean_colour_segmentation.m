% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)
function mean_colour_segmentation = mean_colour_segmentation(I,labels)
% given an input image and its segmentation labeling, constructs an image in
% which each segment is coloured in its mean colour
assert(size(I,1)==size(labels,1));
assert(size(I,2)==size(labels,2));
assert(size(I,3)==3);

num_labels=length(unique(labels));
mean_colour_segmentation=I;
for l=1:num_labels
  m=labels==l;
  for c=1:3 % each channel - r,g,b
    ic=I(:,:,c);
    mean_colour=mean(ic(m)); % in [0;255]
    mean_colour_segmentation(:,:,c)=uint8(~m).*mean_colour_segmentation(:,:,c) + uint8(m)*mean_colour;
  end
end
% initFig; im(mean_colour_segmentation);
end
