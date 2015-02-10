% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
model_name='modelBSDS500_patches';
load_model_and_trees;
model.opts.multiscale=0;

names=im_gt_filenames; % load real images filenames

im_example_ucm2_file='100039.mat'; % the bear on the tree example, see im_gt_filenames for more choice
I=imread(names.bear.im);
gts=load_segmentations(names.bear.gt);
clear names;

voting='line_centre_VPR_normalised_ws'; % the name of the option in get_voting_fcn
voting_folder_name='line_centre_VPR_normalised_ws';
path_precomp='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/';

% how the thresholds are chosen - based on the optimal ones when benchmarking
%
% 1) ours_experiment - line_centre_VPR_normalised_ws
% % Boundary PR global
% %    G-ODS: F( R 0.70, P 0.67 ) = 0.69   [th = 0.38]            <- threshold
% %    G-OIS: F( R 0.74, P 0.68 ) = 0.71
% %    Area_PR = 0.73
% % Volume PR global
% %    G-ODS: F( R 0.70, P 0.71 ) = 0.70   [th = 0.33]
% %    G-OSS: F( R 0.71, P 0.74 ) = 0.72
% %    G-Area_PR = 0.73
% % Region
% %    GT covering: ODS = 0.56 [th = 0.42]. OSS = 0.60. Best = 0.68
% % Region
% %    Rand Index: ODS = 0.81 [th = 0.23]. OSS = 0.84.
% %    Var. Info.: ODS = 1.84 [th = 0.71]. OSS = 1.68.
%
% 2) baseline - SE_UCM % for SE: SS, non-nms
% % Boundary PR global
% %    G-ODS: F( R 0.69, P 0.72 ) = 0.70   [th = 0.19]            <- threshold
% %    G-OIS: F( R 0.73, P 0.72 ) = 0.73
% %    Area_PR = 0.76
% % Volume PR global
% %    G-ODS: F( R 0.72, P 0.73 ) = 0.72   [th = 0.17]
% %    G-OSS: F( R 0.73, P 0.77 ) = 0.75
% %    G-Area_PR = 0.77
% % Region
% %    GT covering: ODS = 0.58 [th = 0.19]. OSS = 0.64. Best = 0.73
% % Region
% %    Rand Index: ODS = 0.82 [th = 0.12]. OSS = 0.85.
% %    Var. Info.: ODS = 1.75 [th = 0.37]. OSS = 1.56.
%
% 3) ours oracle - oracle_line_centre_VPR_normalised_ws
% % Boundary PR global
% %    G-ODS: F( R 0.81, P 0.84 ) = 0.83   [th = 0.58]            <- threshold
% %    G-OIS: F( R 0.85, P 0.83 ) = 0.84
% %    Area_PR = 0.91
% % Volume PR global
% %    G-ODS: F( R 0.84, P 0.81 ) = 0.82   [th = 0.58]
% %    G-OSS: F( R 0.85, P 0.83 ) = 0.84
% %    G-Area_PR = 0.85
% % Region
% %    GT covering: ODS = 0.74 [th = 0.69]. OSS = 0.76. Best = 0.85
% % Region
% %    Rand Index: ODS = 0.89 [th = 0.60]. OSS = 0.90.
% %    Var. Info.: ODS = 1.14 [th = 0.90]. OSS = 1.09.
%
% data=struct(...
%   'file',...
%   {'/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/Ucm2_line_centre_VPR_normalised_ws/100039.mat',...
%   '/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/Ucm2_SE_ucm_repeat/100039.mat',...
%   '/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/Ucm2_oracle_line_centre_VPR_normalised_ws/100039.mat'},...
%   'threshold',{0.38, 0.19, 0.58}...
%   );

data=struct(...
  'file',...
  {sprintf('%sUcm2_%s/%s',path_precomp,voting_folder_name,im_example_ucm2_file),...
  [path_precomp 'Ucm2_SE_ucm_repeat/' im_example_ucm2_file],... % 'SE ucm SS' - what should have been the real baseline
  sprintf('%sUcm2_oracle_%s/%s',path_precomp,voting_folder_name,im_example_ucm2_file)},...
  'threshold',{0.38, 0.19, 0.58}... % thresholds for (ours_experiment baseline ours_oracle)
  );
dsz=numel(data);

for k=1:dsz
  uc=load(data(k).file);
  % make the ucms imageSize
  data(k).precomputed_ucm2=ucm2_doubleSize_to_imageSize(uc.ucm2); % UPDATE(2015-02-10) - used to be (3:2:end, 3:2:end);
  data(k).precomputed_seg=threshold_ucm2(data(k).precomputed_ucm2,data(k).threshold);
end

% vote indices - bpr3 and oracle
vi=[1 3];
data(1).varargin={T};
data(3).varargin={T,gts};
dbg=false;
is_hard_negative_mining=true; % will not reinitialise with the bear image when displaying the images in hard_negatives_mining_oracle
for k=vi
  [cfp_fcn,E]=get_voting_fcn(I,model,voting,dbg,is_hard_negative_mining,data(k).varargin{:});
  [data(k).sf_wt,data(k).votes,data(k).vote_fcn,c]=cfp_fcn(E); % E == edgesDetect(I,model));
  data(k).ucm2=contours2ucm(E,'imageSize',cfp_fcn);
  data(k).seg=threshold_ucm2(data(k).ucm2,data(k).threshold);
  % assert(all(data(k).ucm2(:)==data(k).ucm2_precomputed(:))); % no, because
  % the bpr3 is an approximation, results will be slightly different
end
for k=vi, data(k).mean=cellfun(@mean,data(k).votes); end

for k=1:dsz, u{k}=unique(data(k).ucm2); end
for k=1:dsz, l(k)=length(u{k}); end
% "see" that values are roughly on the same scale
% for k=1:sz, disp(u{k}(1:5)); end
% for k=1:sz, disp(u{k}(end-5:end)); end

d_oracle=abs(data(1).ucm2-data(3).ucm2); % diff with oracle
assert(all(size(E)==size(d_oracle)));
% TODO
data(2).ucm2=data(2).precomputed_ucm2;
d_baseline=abs(data(1).ucm2-data(2).ucm2); % diff with baseline
assert(all(size(E)==size(d_baseline)));

% d=d .* ~(isnan(data(1).mean) | isnan(data(3).mean)); % TODO why isnan when we have voted there - fishy...
r=8;
[~,oracle_sort_ind]=sort(d_oracle(:),'descend'); % TODO instead, do top 5 unique

maxIndex=oracle_sort_ind(1:555);  % linear index of the largest values
sz=size(d_oracle);
[ys,xs]=ind2sub(sz,maxIndex);
inds=find(r<=ys & ys+r<=sz(1) & r<=xs & xs+r<=sz(2));

% clear E uc d_oracle sort_ind maxIndex;
