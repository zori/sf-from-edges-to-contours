% Zornitsa Kostadinova
% Aug 2014
% 8.3.0.532 (R2014a)
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
% Q? Why these apparent off-by-ones when cropping the patch; to visualise properly, cropping 1px bigger radius; check rounding errors
% A. The actual boundary is between two pixels; can't do any better
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
function montage2Title(mTitle)
% adds a title to a figure drawn using the montage2 function
set(gca,'Visible','on'); set(gca,'xtick',[]); set(gca,'ytick',[]);
title(mTitle);
end
