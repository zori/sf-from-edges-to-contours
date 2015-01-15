% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
function names = im_gt_filenames()
% the following images are from the BSDS500 dataset

% tikis (statues)
names.tikis.im='/BS/kostadinova/work/BSR/BSDS500/data/images/val/101085.jpg';
names.tikis.gt='/BS/kostadinova/work/BSR/BSDS500/data/groundTruth/val/101085.mat';

% hawaiian guy with a stick
names.hawaii.im='/BS/kostadinova/work/BSR/BSDS500/data/images/val/101087.jpg';
names.hawaii.gt='/BS/kostadinova/work/BSR/BSDS500/data/groundTruth/val/101087.mat';

% bear
names.bear.im='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Images/100039.jpg';
names.bear.gt='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Groundtruth/100039.mat';

% zebra
names.zebra.im='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Images/16068.jpg';
names.zebra.gt='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Groundtruth/16068.jpg';
end
