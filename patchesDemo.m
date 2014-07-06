function patchesDemo(model,T)
assert(~isempty(model) && ~isempty(T));

% an image from BSDS500 validation subset
imFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/detect/Images/101085.jpg';
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
% t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval;
% Es_=Es(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:)*t; EsDetected=convTri(Es_,1);
EsDetected=Es(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:);

while (true)
  clear functions; % clear the persistent vars in getFigPos
  % get user input and crop patch
  initFig(1); imagesc(I); axis('image'); title('Choose a patch to crop');
  if exist('x','var'), hold on; plot(x,y,'rx','MarkerSize',20); end
  [x,y]=ginput;
  % if no patch or more than one patch is selected, stop the interactive demo
  if (length(x)~= 1), close all; return; end
  [x,y]=fixInput(x,y,ri,szOrig(1:2));
  imagesc(I); axis('image'); title('Choose a patch to crop');
  hold on; plot(x,y,'rx','MarkerSize',20);
  x_ind=uint32(floor(x/2)); y_ind=uint32(floor(y/2));
  x=uint32(floor(x)); y=uint32(floor(y));
  initFig(); r0=opts.imWidth/2; % patch radius r=16
  imagesc(cropPatch(I,x,y,r0)); axis('image'); title('Cropped image patch');

  ids=double(ind(y_ind,x_ind,:)); % indices come from cpp and are 0-based
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
      h=initFig(); montage2(imgPs,struct('hasChn', true));
      montage2Title(['Image patches; tree ' treeStr]);
    else
      h=initFig(); im(T{treeId}.hs(:,:,leafId)); title(['Best segmentation; tree ' treeStr]);
    end
  end
  % TODO get the "intermediate" patch - decision made only based on the 4
  % groups of patches shown here; don't use the result ind of the private mex
  % function, rather work within it

  % patch detected with the decision forest; result based on 16x16x4/4 trees
  % that vote for each pixel
  initFig(); im(cropPatch(EsDetected,x,y,rg)); title('SRF decision patch');
  % Superpixelization (over-segmentation patch)
  ws=label2rgb(watershed(EsDetected),'jet',[1 1 1],'shuffle');
  h=initFig(); imagesc(cropPatch(ws,x,y,rg)); axis('image'); title('Superpixels patch');

  % remove all figures that were not created on this iteration
  figHandles=findobj('Type','figure');
  oldFigures=figHandles(figHandles>h); % h is the last handle used
  close(oldFigures);
end % while(true)
end % patchesDemo

% ----------------------------------------------------------------------
function patch = cropPatch(I,x,y,r)
% crop a patch with radius r from an image I at location [x y]
% output patch has dimensions [2r x 2r]
patch=I(y-r+1:y+r,x-r+1:x+r,:);
end

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
end

% ----------------------------------------------------------------------
function montage2Title(mTitle)
% adds a title to a figure drawn using the montage2 function
set(gca,'Visible','on'); set(gca,'xtick',[]); set(gca,'ytick',[]);
title(mTitle);
end
