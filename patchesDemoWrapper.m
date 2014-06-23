% wrapper for patchesDemo to allow to use pre-loaded parameters - learnt model
% and decision trees

if (~all(ismember({'model','T'},who)))
  load('/BS/kostadinova/work/video_segm/models/forest/modelBSDS500.mat'); % model
  nTrees=8; T=cell(nTrees,1);
  for i=1:nTrees
    treeStr=['/BS/kostadinova/work/video_segm/models/tree/modelBSDS500_tree00' num2str(i) '.mat'];
    T{i}=load(treeStr); T{i}=T{i}.tree;
  end
end
clear i nTrees treeStr;
patchesDemo(model,T);
