%load('/BS/kostadinova/work/video_segm/models/forest/modelBSDS500.mat'); % model
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
%%
% E=edgesDetect(I,model);
% % ws=Uintconv(watershed(E));
% figure(1); im(I);
% figure(2); im(1-E);

%% Get user input and crop patch TODO crop patch from Ipadded
figure(101); im(I);
[x,y]=ginput;
x_ind=uint32(floor(x/2)); y_ind=uint32(floor(y/2));
x=uint32(floor(x)); y=uint32(floor(y));
r0=16; % patch radius
imPatch=I(y-r0+1:y+r0,x-r0+1:x+r0,:);
figure(102); im(imPatch);

%%
opts=model.opts;
Im=I;
%% Pad im, get channels
% pad image, making divisible by 4
szOrig=size(Im); r=opts.imWidth/2; p=[r r r r];
p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*r,4),4);
IPadded=imPad(Im,p,'symmetric');
% compute features
[chnsReg,chnsSim]=edgesChns( IPadded, model.opts );
% take a patch coordinates [x y] (don't allow to click near the boundary)

% compute ftrs for the patch centered at [x y]
% see edgesTrain.m psReg and psSim and sth like ftrs1=[reshape(psReg,[],k1)' stComputeSimFtrs(psSim,opts)];

% using the model, walk the forest (all 8 trees) until reach a leaf in all of
% them (at different levels); then:
%  1) save index of leaf node, or
%  2) record (visualize) patches at the leaves

% !! careful with the difference in dimensions (padded / cropped image)

% Es,ind]=edgesDetectMex(model,chnsReg,chnsSim);

% TODO how can ind be useful?; look at such function call [Es,ind]=edgesDetectMex(model,chnsReg,chnsSim); where edgesDetectMex is
% called fooMex :)
% maybe?       // store leaf index and update edge maps
%      ind[ r + c*h1 + t*h1*w1 ] = k;

%% Get a few leaf indices and display the patches
% apply forest to image
[Es,ind]=fooMex(model,chnsReg,chnsSim); % mex-file was private % TODO: use Es - the detected edge map
% normalize and finalize edge maps
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
  %figure(k); montage2(cell2array(model.patches{leafId,treeId}));
  figure(k); montage2(cat(3,T{treeId}.hs(:,:,leafId),cell2array(T{treeId}.patches{leafId})));
end
