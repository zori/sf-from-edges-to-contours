% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function imcc(seg)
% imcc - image colour-coded - shows a segmentation with its regions in different
% colours to increase contrast between them
imagesc(label2rgb(seg,'jet',[1 1 1],'shuffle'));
title(inputname(1));
axis('image');
end
