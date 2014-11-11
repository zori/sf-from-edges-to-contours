% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
model_name='modelBSDS500_patches';
load_model_and_trees;
fmt='doubleSize';
dbg=true;
% strings describing all possible types of vote to weigh the watershed
votings={'bpr','greedy_merge','line_VPR_normalised_ws'}; % RSRI RI vpr_s vpr_gt

%% 16x16 vertical line
l=zeros(16,16); l(:,8)=1;
L=repmat(l,1,1,3); clear l;
L_ucm=ucm_weighted(L,model,'line_VPR_normalised_ws',fmt,true,T); % interactive, pause when computing

merge_L_ucm=ucm_weighted(L,model,'greedy_merge',fmt,false,T); % don't pause, just compute

%% bw diagonal
bw=repmat(eye(260),1,1,3);
bw_gt=watershed(bw(:,:,1),4); bw_gt(bw_gt==0)=1;
for k=1:length(votings)
  bw_res{k}=ucm_weighted(bw,model,votings{k},fmt,dbg,T);
  bw_oracle{k}=ucm_weighted(bw,model,votings{k},fmt,T,dbg,{bw_gt});
end

%% real image
imFile='/BS/kostadinova/work/BSR/BSDS500/data/images/val/101085.jpg';
gtFile='/BS/kostadinova/work/BSR/BSDS500/data/groundTruth/val/101085.mat';
I=imread(imFile);
% ucm=ucm_weighted(I,model,'RI',fmt,T);
% ucm_oracle=ucm_weighted(I,model,'greedy_merge',fmt,T,load_segmentations(gtFile));
