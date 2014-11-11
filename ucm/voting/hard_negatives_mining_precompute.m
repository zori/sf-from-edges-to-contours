% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
model_name='modelBSDS500_patches';
load_model_and_trees;
model.opts.multiscale=0;

imFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Images/100039.jpg';
gtFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Groundtruth/100039.mat';

% how the thresholds are chosen - based on the optimal ones when benchmarking
%
% bpr
% Boundary PR global
%    G-ODS: F( R 0.67, P 0.67 ) = 0.67   [th = 0.46]
%    G-OIS: F( R 0.72, P 0.66 ) = 0.69
%    Area_PR = 0.70
% Volume PR global
%    G-ODS: F( R 0.69, P 0.69 ) = 0.69   [th = 0.35]
%
% baseline
% Boundary PR global
%    G-ODS: F( R 0.70, P 0.69 ) = 0.69   [th = 0.27]
%    G-OIS: F( R 0.73, P 0.73 ) = 0.73
%    Area_PR = 0.75
% Volume PR global
%    G-ODS: F( R 0.71, P 0.73 ) = 0.72   [th = 0.25]
%
% oracle
% Boundary PR global
%    G-ODS: F( R 0.80, P 0.85 ) = 0.83   [th = 0.68]
%    G-OIS: F( R 0.84, P 0.84 ) = 0.84
%    Area_PR = 0.91
% Volume PR global
%    G-ODS: F( R 0.82, P 0.79 ) = 0.81   [th = 0.60]

data=struct(...
  'file',...
  {'/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/Ucm2_bpr_3/100039.mat',...
  '/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/Ucm2_sf_ucm/100039.mat',...
  '/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/Ucm2_oracle_bpr_3/100039.mat'},...
  'threshold',{0.46, 0.27, 0.68}...
  );
dsz=numel(data);

I=imread(imFile); clear imFile;
gts=load_segmentations(gtFile); clear gtFile;

for k=1:dsz
  uc=load(data(k).file); data(k).precomputed_ucm2=uc.ucm2(3:2:end, 3:2:end); % make the ucms imageSize
  data(k).precomputed_seg=threshold_ucm2(data(k).precomputed_ucm2,data(k).threshold);
end

% vote indices - bpr3 and oracle
vi=[1 3];
data(1).varargin={T};
data(3).varargin={T,gts};
for k=vi
  [cfp_fcn,E]=get_voting_fcn(I,model,'bpr',false,data(k).varargin{:});
  [sf_wt{k},votes{k},vote_fcn{k},c{k}]=cfp_fcn(E); % E == edgesDetect(I,model));
  data(k).ucm2=contours2ucm(E,'imageSize',cfp_fcn);
  data(k).seg=threshold_ucm2(data(k).ucm2,data(k).threshold);
  % assert(all(data(k).ucm2(:)==data(k).ucm2_precomputed(:))); % no, because
  % the bpr3 is an approximation, results will be slightly different
end
for k=vi, data(k).mean=cellfun(@mean,votes{k}); end

for k=1:dsz, u{k}=unique(data(k).ucm2); end
for k=1:dsz, l(k)=length(u{k}); end
% "see" that values are roughly on the same scale
% for k=1:sz, disp(u{k}(1:5)); end
% for k=1:sz, disp(u{k}(end-5:end)); end

d=abs(data(1).ucm2-data(3).ucm2); % diff with oracle
% TODO diff with baseline
% d=d .* ~(isnan(data(1).mean) | isnan(data(3).mean)); % TODO why isnan when we have voted there - fishy...
r=8;
[~,sort_ind]=sort(d(:),'descend'); % TODO instead, do top 5 unique
maxIndex=sort_ind(1:555);  % linear index of the 5 largest values
sz=size(E);
[ys,xs]=ind2sub(sz,maxIndex);
inds=find(r<=ys & ys+r<=sz(1) & r<=xs & xs+r<=sz(2));

clear imFile I E uc d sort_ind maxIndex;
