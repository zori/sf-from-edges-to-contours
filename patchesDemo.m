% load('/BS/kostadinova/work/video_segm/models/forest/modelBSDS500.mat'); % model
% nTrees=8;
% T=cell(nTrees,1);
% for i=1:nTrees
%   treeStr=['/BS/kostadinova/work/video_segm/models/tree/modelBSDS500_tree00' num2str(i) '.mat'];
%   T{i}=load(treeStr); T{i}=T{i}.tree;
% end

%% Load img
% an image from BSDS500 validation subset
imFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/detect/Images/101085.jpg';
% gtFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/detect/Groundtruth/101085.mat';
I=imread(imFile);
opts=model.opts;

mainFig=figure(101);  im(I);
uiCtrl=uicontrol('Style','PushButton','String','Break','Callback','delete(gcbf)');
while (ishandle(uiCtrl))
  %% Get user input and crop patch TODO crop patch from Ipadded
  figure(mainFig);
  [x,y]=ginput;
  x_ind=uint32(floor(x/2)); y_ind=uint32(floor(y/2));
  x=uint32(floor(x)); y=uint32(floor(y));
  r0=16; % patch radius
  imPatch=I(y-r0+1:y+r0,x-r0+1:x+r0,:);
  figure(102); im(imPatch);
  
  %%
  Im=I;
  %% Pad im, get channels
  % pad image, making divisible by 4
  szOrig=size(Im); r=opts.imWidth/2; p=[r r r r];
  p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*r,4),4);
  IPadded=imPad(Im,p,'symmetric');
  % compute features
  [chnsReg,chnsSim]=edgesChns( IPadded, model.opts );
  
  %% Get a few leaf indices and display the patches
  % apply forest to image
  [Es,ind]=fooMex(model,chnsReg,chnsSim); % mex-file was private
  t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval; r=opts.gtWidth/2;
  O=[]; Es_=Es(1+r:szOrig(1)+r,1+r:szOrig(2)+r,:)*t; Es__=convTri(Es_,1);
  
  r1=16; % patch radius
  gtPatch=Es__(y-r1+1:y+r1,x-r1+1:x+r1,:);
  figure(103); im(gtPatch);
  
  nTreeNodes=length(model.fids);
  nTreesEval=opts.nTreesEval;
  ids=ind(y_ind,x_ind,:); % indices come from cpp and are 0-based; for tree_set=2 ??
  idsD=double(ids);
  treeIds=uint32(floor(idsD./nTreeNodes)+1);
  leafIds=uint32(mod(idsD,nTreeNodes)+1);
  
  for k=1:nTreesEval
    treeId=treeIds(:,:,k); leafId=leafIds(:,:,k);
    assert(~model.child(leafId,treeId) && ~isempty(model.patches{leafId,treeId}));
    figure(k); montage2(cat(3,T{treeId}.hs(:,:,leafId),cell2array(T{treeId}.patches{leafId}))); % model.patches{leafId,treeId}
  end

  pause(0.5);
end % while(isHandle)