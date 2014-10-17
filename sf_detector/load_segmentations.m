% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function gts = load_segmentations(gtFile)
gts=load(gtFile); gts=gts.groundTruth;
for k=1:length(gts), gts{k}=gts{k}.Segmentation; end
end
