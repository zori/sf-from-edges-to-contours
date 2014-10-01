% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
% from Benchmark/Evaluatesegmregion.m
function F = VPR(fst,snd)
% returns F-value of the VPR
seg=fst;  % machine segmentation; output of algorithm; first patch
groundTruth={struct('Segmentation',snd)}; % a cell with a structure with a field .Segmentation
maxGtLabel=max(snd(:));  % maximum label in the second patch

%Volume precision and recall
EXCZEROFORMS=true; % see Evaluatesegmregion.m line 50
EXCZEROFORGT=false;
NORMALISE=true;

confcounts=Getconfcounts(seg, groundTruth, maxGtLabel);

if NORMALISE
  if (EXCZEROFORMS)
    seg(seg>0)=1; %Normalization respects possible excluded areas (-1) and excludes also 0 values, as these would not be counted to judge precision
  else
    seg(seg>=0)=1; %Normalization respects possible excluded areas (-1) but inlcude 0 values, as these would be counted to judge precision
  end
  % confcounts to normalize the count
  % The count takes into account and exclude the -1 pixels in the machine segmentation
  normconfcounts=Getconfcounts(seg, groundTruth, maxGtLabel);  % [2 ngts+1]; seg for normalization only has 1 label (1) apart from -1 parts
end

[~,~,volumes]=Gettheaccuracies(confcounts,maxGtLabel,[false,false,true],EXCZEROFORMS,EXCZEROFORGT);
if NORMALISE
  [~,~,normvolumes]=Gettheaccuracies(normconfcounts,maxGtLabel,[false,false,true],EXCZEROFORMS,EXCZEROFORGT);
else
  normvolumes=struct('cntprect',0,'nofusedgts',0);
end

% Precision % Normalise precision (in case the biggest object is a zero the normalization is null)
cntP=volumes.cntprect-normvolumes.cntprect; % Normalise: by definition seg only has 1 label and max is not necesary max(normoverlapseg,[],1)
sumP=volumes.sumprect-normvolumes.cntprect; % Zeros labels are counted for the areas, -1 labels are not counted at all (regions of frames are ignored)
% Recall % Normalise
cntR=volumes.cntrect-normvolumes.nofusedgts; % Normalise: the whole frame is used to take -1 into account and exclude gts with 0 areas
sumR=volumes.sumrect-normvolumes.nofusedgts; % Zeros labels are counted for the areas, -1 labels are not counted at all (regions of frames are ignored)

% Benchmark/Collectevalaluatereg.m line 292
% Precision recall and F measure for the considered segmentation
R=cntR./(sumR+(sumR==0));
P=cntP./(sumP+(sumP==0));
F=fmeasure(R,P);
end
