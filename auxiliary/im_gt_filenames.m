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

% bear on tree (difficult image)
names.bear.im='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Images/100039.jpg';
names.bear.gt='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Groundtruth/100039.mat';

% zebra
names.zebra.im='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Images/16068.jpg';
names.zebra.gt='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Groundtruth/16068.mat';

% other zebras
names.zebras2.im='/BS/kostadinova/work/BSR/BSDS500/data/images/val/253027.jpg';
names.zebras2.gt='/BS/kostadinova/work/BSR/BSDS500/data/groundTruth/val/253027.mat';

% starfish
names.starfish.im='/BS/kostadinova/work/BSR/BSDS500/data/images/train/12003.jpg';
names.starfish.gt='/BS/kostadinova/work/BSR/BSDS500/data/groundTruth/train/12003.mat';

% elephants
names.elephants.im='/BS/kostadinova/work/BSR/BSDS500/data/images/val/296059.jpg';
names.elephants.gt='/BS/kostadinova/work/BSR/BSDS500/data/groundTruth/val/296059.mat';

% a head of a statue among greenery - example of (only discovered) very weak edges; "difficult" image
names.head.im='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Images/101084.jpg';
names.head.gt='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Groundtruth/101084.mat';

% polar bear - example of normal, strong edges; "easy" image
names.polar_bear.im='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Images/100007.jpg';
names.polar_bear.gt='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Groundtruth/100007.mat';
end
