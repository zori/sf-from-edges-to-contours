% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function hard_negatives_mining()
imFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Images/100039.jpg';
gtFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Groundtruth/100039.mat';
bpr3File='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/Ucm2_bpr_3/100039.mat';
baselineFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/Ucm2_sf_ucm/100039.mat';
oracle_bpr3File='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/Ucm2_oracle_bpr_3/100039.mat';

I=imread(imFile);
gts=load_segmentations(gtFile);
% Boundary PR global
%    G-ODS: F( R 0.67, P 0.67 ) = 0.67   [th = 0.46]
%    G-OIS: F( R 0.72, P 0.66 ) = 0.69
%    Area_PR = 0.70
% Volume PR global
%    G-ODS: F( R 0.69, P 0.69 ) = 0.69   [th = 0.35]
th_bpr3=0.46;
ucm2_bpr3=load(bpr3File); ucm2_bpr3=ucm2_bpr3.ucm2;
bpr3=threshold_ucm2(ucm2_bpr3,th_bpr3);

% Boundary PR global
%    G-ODS: F( R 0.70, P 0.69 ) = 0.69   [th = 0.27]
%    G-OIS: F( R 0.73, P 0.73 ) = 0.73
%    Area_PR = 0.75
% Volume PR global
%    G-ODS: F( R 0.71, P 0.73 ) = 0.72   [th = 0.25]
th_baseline=0.27;
ucm2_baseline=load(baselineFile); ucm2_baseline=ucm2_baseline.ucm2;
baseline=threshold_ucm2(ucm2_baseline,th_baseline);

% Boundary PR global
%    G-ODS: F( R 0.80, P 0.85 ) = 0.83   [th = 0.68]
%    G-OIS: F( R 0.84, P 0.84 ) = 0.84
%    Area_PR = 0.91
% Volume PR global
%    G-ODS: F( R 0.82, P 0.79 ) = 0.81   [th = 0.60]
th_oracle=0.68;
ucm2_oracle=load(oracle_bpr3File); ucm2_oracle=ucm2_oracle.ucm2;
oracle=threshold_ucm2(ucm2_oracle,th_oracle);

ucms={ucm2_bpr3 ucm2_baseline ucm2_oracle};
usz=3;
for k=1:usz, u{k}=unique(ucms{k}); end
for k=1:usz, l(k)=length(u{k}); end
% "see" that values are roughly on the same scale
% for k=1:sz, disp(u{k}(1:5)); end
% for k=1:sz, disp(u{k}(end-5:end)); end

d=abs(ucms{1}-ucms{3}); % diff with oracle
% d=abs(ucms{1}-ucms{2}); % diff with baseline
sz=size(ucms{1});
r=16;
[sortedValues,sortIndex]=sort(d(:),'descend'); % TODO: instead, do top 5 unique
maxIndex=sortIndex(1:155);  % linear index of the 5 largest values
[y,x]=ind2sub(sz,maxIndex);
inds=find(y+r<=sz(1) & x+r<=sz(2));
for ind=inds(1:10:100)'
  initFig(1); im(ucms{3}); hold on; plot(x(ind),y(ind),'x', 'MarkerSize',20);
  % for k=1:usz, initFig(); im(ucms{k}); hold on; plot(x(ind),y(ind),'x', 'MarkerSize',20); end
  for k=1:usz, cps{k}=cropPatch(ucms{k},x(ind),y(ind),r); end
  for k=1:usz, initFig(); im(cps{k}); end
end

for k=1:length(gts), initFig(); im(gts{k}); end
initFig(); im(bpr3);
initFig(); im(baseline);
initFig(); im(oracle);
close all;
end
