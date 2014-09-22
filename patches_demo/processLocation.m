% Zornitsa Kostadinova
% Aug 2014
% 8.3.0.532 (R2014a)
function processLocation(x,y,model,T,I,opts,ri,rg,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,wsPadded,ucm,w)
% plot(x,y,'rx','MarkerSize',20);
% display image patch
initFig(); imagesc(cropPatch(I,x,y,ri)); axis('image'); title('Selected image patch');

[treeIds,leafIds,x1,y1]=coords2forestLocation(x,y,ind,opts,p,length(model.fids));
for k=1:nTreesEval
  treeId=treeIds(:,:,k); leafId=leafIds(:,:,k);
  assert(~model.child(leafId,treeId)); % TODO add this to assertion (when also saving patches in forest) && ~isempty(model.patches{leafId,treeId}));
  segPs=T{treeId}.segPs{leafId}; % model.patches{leafId,treeId}
  imgPs=T{treeId}.imgPs{leafId};
  assert(~xor(isempty(segPs),isempty(imgPs)));
  treeStr=num2str(treeId);
  if exist('w','var'), treeStr=[treeStr ' - dist ' num2str(w(k))]; end
  if ~isempty(segPs) % only leaves with no more than 40 samples have the patches stored
    initFig(); montage2(cell2array(segPs));
    montage2Title(['Segmentations; tree ' treeStr]);
    if ~exist('w','var')
      % if we have the weights, don't show the image patches to reduce clutter
      initFig(); montage2(imgPs,struct('hasChn', true));
      montage2Title(['Image patches; tree ' treeStr]);
    end
  else
    initFig(); im(T{treeId}.hs(:,:,leafId)); title(['Best segmentation; tree ' treeStr]);
  end
end

% Compute the intermediate decision at the given pixel location (of 4 trees)
Es4=edgesDetectMex(model,chnsReg,chnsSim,x1,y1);
E4=Es4(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:);
% initFig(); im(E4); hold on; plot(x,y,'rx','MarkerSize',20);
% Q? Why these apparent off-by-ones when cropping the patch; to visualise properly, cropping 1px bigger radius; check rounding errors
% A. The actual boundary is between two pixels; can't do any better
% TODO this was a quick fix
% szOrig=size(I); p=[ri ri ri ri];
% p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*ri,4),4);
E4Padded=imPad(E4,p,'symmetric');
initFig(); im(cropPatch(E4Padded,x+ri,y+ri,rg+1)); title('Intermediate decision patch (4 trees voted)');

% patch detected with the decision forest; result based on 16x16x4/4 trees
% that vote for each pixel
EPadded=imPad(E,p,'symmetric');
initFig(); im(cropPatch(EPadded,x+ri,y+ri,rg)); title('SRF decision patch');
% Superpixelization (over-segmentation patch)
% initFig(); im(wsPadded); hold on; plot(x+ri,y+ri,'rx');
spxPatch=cropPatch(wsPadded,x+ri,y+ri,rg); % ri/2 == rg
initFig(); imagesc(label2rgb(spxPatch,'jet',[1 1 1],'shuffle')); axis('image'); title('Superpixels patch');
% Ultrametric Contour Map patch
ucmPadded=imPad(ucm,p,'symmetric');
h=initFig(); im(cropPatch(ucmPadded,x+ri,y+ri,rg)); title('UCM patch');

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
