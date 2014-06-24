% wrapper for patchesDemo to allow to use pre-loaded parameters - learnt model
% and decision trees

if (~all(ismember({'model','T'},who)))
  load('/BS/kostadinova/work/video_segm/models/forest/modelBSDS500.mat'); % model
  nTrees=8; T=cell(nTrees,1);
  for k=1:nTrees
    treeStr=['/BS/kostadinova/work/video_segm/models/tree/modelBSDS500_tree00' num2str(k) '.mat'];
    T{k}=load(treeStr); T{k}=T{k}.tree;
  end
end
clear k nTrees treeStr;
patchesDemo(model,T);
