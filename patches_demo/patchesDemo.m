% Zornitsa Kostadinova
% Jun 2014
function patchesDemo(model,T)
assert(~isempty(model) && ~isempty(T));

% an image from BSDS500 validation subset
% imFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/detect/Images/101085.jpg';
imFile='/BS/kostadinova/work/BSR/grouping/data/101087_small.jpg';
% gtFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/detect/Groundtruth/101085.mat';
I=imread(imFile);
opts=model.opts;
ri=opts.imWidth/2; % patch radius 16
rg=opts.gtWidth/2; % patch radius 8
nTreeNodes=length(model.fids);
nTreesEval=opts.nTreesEval;
% pad image, making divisible by 4
szOrig=size(I); p=[ri ri ri ri];
p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*ri,4),4);
IPadded=imPad(I,p,'symmetric');
% compute feature channels
[chnsReg,chnsSim]=edgesChns(IPadded,model.opts);
% apply forest to image
[Es,ind]=fooMex(model,chnsReg,chnsSim); % mex-file was private edgesDetectMex(...)
% normalize and finalize edge maps
t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval;
Es_=Es(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:)*t; E=convTri(Es_,1);
% E=Es(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:);
% Superpixelization (over-segmentation)
ws=watershed(E);
ws_bw=(ws==0);
c=fit_contour(double(ws_bw));
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
% Ultrametric Contour Map
ucm=contours2ucm(double(E)/255);
computeWeightFun=@(x,y,spxPatch) computeWeights(x,y,spxPatch,model,T,I,opts,ri,rg,nTreeNodes,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,ws,ucm);
processLocationFun=@(x,y) processLocation(x,y,model,T,I,opts,ri,rg,nTreeNodes,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,ws,ucm);

%% processing SPX edges
c.edge_weights=cell(size(c.edges,1),1);
x=58; y=28;
assert(isequal(1,c.is_e(x,y))); % it is an edge
assert(isequal(0,c.is_v(x,y))); % it is not a vertex
edgeInd=c.assign(x,y); % 48 the index of the edge % or 40
vInds=c.edges(edgeInd,:); % [42 44] the two indices of the end vertices
v1Coords=c.vertices(vInds(1),:); % [56    29]
v2Coords=c.vertices(vInds(2),:); % [60    28]
X=c.edge_x_coords(edgeInd); X=X{1}; % X'  [57    57    58    59]
Y=c.edge_y_coords(edgeInd); Y=Y{1}; % Y'  [29    28    28    28]

r=rg; % patch radius 8
for k=1:length(X)
  ex=X(k); ey=Y(k);
  % TODO patch should be cropped from ws or from ucm?
  spxPatch=cropPatch(ws,ex,ey,r); % superpixels patch
  w=computeWeightFun(ex,ey,spxPatch);
  c.edge_weights{edgeInd}=[w c.edge_weights{edgeInd}];
end

if 0
%% interactive demo loop
while (true)
  clear functions; % clear the persistent vars in getFigPos
  % get user input
  initFig(1); imagesc(I); axis('image'); title('Choose a patch to crop');
  if exist('x','var'), hold on; plot(x,y,'rx','MarkerSize',20); end
  [x,y]=ginput;
  % if no or more than one location is clicked, stop the interactive demo
  if (length(x)~= 1), close all; return; end
  [x,y]=fixInput(x,y,ri,szOrig(1:2));
  imagesc(I); axis('image'); title('Choose a patch to crop');
  hold on;
  processLocationFun(x,y);
end % while(true)
end
end % patchesDemo

% ----------------------------------------------------------------------
function [w] = computeWeights(x,y,spxPatch,model,T,I,opts,ri,rg,nTreeNodes,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,ws,ucm)
% get 4 patches in leaves using .ind
x1=ceil(((x+p(3))-opts.imWidth)/opts.stride)+rg; % rg<=x1<=w1, for w1 see edgesDetectMex.cpp
y1=ceil(((y+p(1))-opts.imWidth)/opts.stride)+rg; % rg<=y1<=h1
assert((x1==ceil(x/2)) && (y1==ceil(y/2)));
ids=double(ind(y1,x1,:)); % indices come from cpp and are 0-based
treeIds=uint32(floor(ids./nTreeNodes)+1);
leafIds=uint32(mod(ids,nTreeNodes)+1);
w=zeros(nTreesEval,1);
for k=1:nTreesEval
  treeId=treeIds(:,:,k); leafId=leafIds(:,:,k);
  assert(~model.child(leafId,treeId)); % TODO add this to assertion (when also saving patches in forest) && ~isempty(model.patches{leafId,treeId}));
  hs=T{treeId}.hs(:,:,leafId); % best segmentation
  w(k)=patchDistance(spxPatch,hs);
end
end % computeWeights

% ----------------------------------------------------------------------
function d = patchDistance(patch1,patch2)
% initFig(); im(patch1);
% initFig(); im(patch2);
% TODO compute distance
d=0.75;
end

% ----------------------------------------------------------------------
function processLocation(x,y,model,T,I,opts,ri,rg,nTreeNodes,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,ws,ucm)
plot(x,y,'rx','MarkerSize',20);
% display image patch
initFig(); imagesc(cropPatch(I,x,y,ri)); axis('image'); title('Selected image patch');

x1=ceil(((x+p(3))-opts.imWidth)/opts.stride)+rg; % rg<=x1<=w1, for w1 see edgesDetectMex.cpp
y1=ceil(((y+p(1))-opts.imWidth)/opts.stride)+rg; % rg<=y1<=h1
assert((x1==ceil(x/2)) && (y1==ceil(y/2)));
ids=double(ind(y1,x1,:)); % indices come from cpp and are 0-based
treeIds=uint32(floor(ids./nTreeNodes)+1);
leafIds=uint32(mod(ids,nTreeNodes)+1);
for k=1:nTreesEval
  treeId=treeIds(:,:,k); leafId=leafIds(:,:,k);
  assert(~model.child(leafId,treeId)); % TODO add this to assertion (when also saving patches in forest) && ~isempty(model.patches{leafId,treeId}));
  segPs=T{treeId}.segPs{leafId}; % model.patches{leafId,treeId}
  imgPs=T{treeId}.imgPs{leafId};
  assert(~xor(isempty(segPs),isempty(imgPs)));
  treeStr=num2str(treeId);
  if ~isempty(segPs) % only leaves with no more than 40 samples have the patches stored
    initFig(); montage2(cell2array(segPs));
    montage2Title(['Segmentations; tree ' treeStr]);
    initFig(); montage2(imgPs,struct('hasChn', true));
    montage2Title(['Image patches; tree ' treeStr]);
  else
    initFig(); im(T{treeId}.hs(:,:,leafId)); title(['Best segmentation; tree ' treeStr]);
  end
end

% Compute the intermediate decision at the given pixel location (of 4 trees)
Es4=fooMex(model,chnsReg,chnsSim,x1,y1); % mex-file was private edgesDetectMex(...)
E4=Es4(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:);
% initFig(); im(E4); hold on; plot(x,y,'rx','MarkerSize',20);
% TODO why these apparent off-by-ones when cropping the patch; to "remedy" cropping 1px bigger radius; check rounding errors
initFig(); im(cropPatch(E4,x,y,rg+1)); title('Intermediate decision patch (4 trees voted)');

% patch detected with the decision forest; result based on 16x16x4/4 trees
% that vote for each pixel
initFig(); im(cropPatch(E,x,y,rg)); title('SRF decision patch');
% Superpixelization (over-segmentation patch)
initFig(); imagesc(label2rgb(cropPatch(ws,x,y,rg),'jet',[1 1 1],'shuffle')); axis('image'); title('Superpixels patch');
% Ultrametric Contour Map patch
h=initFig(); im(cropPatch(ucm,x,y,rg)); title('UCM patch');

% TODO use a global var 'h' and a function cleanUpFigs to close old figs
% remove all figures that were not created on this iteration
figHandles=findobj('Type','figure');
oldFigures=figHandles(figHandles>h); % h is the last handle used
close(oldFigures);
end % processLocation

% ----------------------------------------------------------------------
function [x,y] = fixInput(x,y,r,szI)
% return x y coordinates within the inside (not a band with width r) of the original image
if y<r, y=r; else if y>szI(1)-r, y=szI(1)-r; end; end
if x<r, x=r; else if x>szI(2)-r, x=szI(2)-r; end; end
end

function h = initFig(figureHandle)
% creates and positions a figure on a 3 x 4 grid layout for convenient viewing
%
% INPUTS
%  figureHandle - (optional) handle/index for the figure
%
% OUTPUTS
%  h            - figure handle
%
persistent cache figCnt;
if isempty(figCnt), figCnt=1; end
if nargin, figCnt=figureHandle; end
if (~isempty(cache)), [scrSz,figSz,nFigs]=deal(cache{:}); else
  set(0,'Units','pixels');
  scrSz=get(0,'ScreenSize'); scrSz=scrSz(3:4);
  figSz=[4 3]; nFigs=figSz(1)*figSz(2); cache={scrSz,figSz,nFigs};
end
h=figure(figCnt); clf;
ind=figCnt;
if figCnt>1, ind=mod(figCnt-2,nFigs-1)+2; end
[x,y]=ind2sub(figSz,ind);
position=[...
  (x-1)*scrSz(1)/figSz(1),... % left
  (3-y)*scrSz(2)/figSz(2),... % bottom
  scrSz(1)/figSz(1),...       % width
  scrSz(2)/figSz(2)];         % height
set(h,'OuterPosition',position);
figCnt=figCnt+1;
end % initFig

% ----------------------------------------------------------------------
function montage2Title(mTitle)
% adds a title to a figure drawn using the montage2 function
set(gca,'Visible','on'); set(gca,'xtick',[]); set(gca,'ytick',[]);
title(mTitle);
end
