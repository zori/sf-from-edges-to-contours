% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
if ~exist('model_name','var'), model_name='modelBSDS500'; end
model_path='/BS/kostadinova/work/video_segm/models';
if ~all(ismember({'model','T'},who))
  model=load(fullfile(model_path,'forest',model_name)); % .mat file with model
  model=model.model;
  nTrees=8; T=cell(nTrees,1);
  for k=1:nTrees
    treeStr=fullfile(model_path,'tree',[model_name '_tree00' num2str(k)]); % .mat file with k-th tree
    T{k}=load(treeStr); T{k}=T{k}.tree;
  end
end
clear model_name model_path;
clear k nTrees treeStr;
