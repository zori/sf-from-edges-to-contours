% wrapper for patchesDemo to allow to use pre-loaded parameters - learnt model
% and decision trees

if (~all(ismember({'model','T'},who)))
  load('/BS/kostadinova/work/video_segm/models/forest/modelBSDS500_patches.mat'); % model
  % load('/BS/kostadinova/work/video_segm/models/forest/modelVSB100_40_patches.mat'); % model
  nTrees=8; T=cell(nTrees,1);
  for k=1:nTrees
    treeStr=['/BS/kostadinova/work/video_segm/models/tree/modelBSDS500_patches_tree00' num2str(k) '.mat'];
    % treeStr=['/BS/kostadinova/work/video_segm/models/tree/modelVSB100_40_patches_tree00' num2str(k) '.mat'];
    T{k}=load(treeStr); T{k}=T{k}.tree;
  end
end
clear k nTrees treeStr;

% patchesDemo(model,T);

% l=zeros(16,16); l(:,8)=1;
% L=repmat(l,1,1,3); clear l;
% ucmL=ucm_weighted(L,model,'doubleSize',T);

bw=repmat(eye(260),1,1,3);
bw_ucm=ucm_weighted(bw,model,'doubleSize',T);
bw_gt=watershed(bw(:,:,1),4); bw_gt(bw_gt==0)=1;
bw_ucm_oracle=ucm_weighted(bw,model,'doubleSize',T,{bw_gt});

imFile='/BS/kostadinova/work/BSR/BSDS500/data/images/val/101085.jpg';
gtFile='/BS/kostadinova/work/BSR/BSDS500/data/groundTruth/val/101085.mat';
I=imread(imFile);
ucm=ucm_weighted(I,model,'doubleSize',T);
ucm_oracle=ucm_weighted(I,model,'doubleSize',T,load_segmentations(gtFile));
