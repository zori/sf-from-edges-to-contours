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
BW=repmat(eye(16),1,1,3);
l=zeros(16,16); l(:,8)=1;
L=repmat(l,1,1,3); clear l;
ucmW=ucmWeighted(L,model,'doubleSize',T);
