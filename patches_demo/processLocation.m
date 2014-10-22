% Zornitsa Kostadinova
% Aug 2014
% 8.3.0.532 (R2014a)
function processLocation(x,y,model,T,IPadded,ri,rg,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,wsPadded,ucm,w)
% plot(x,y,'rx','MarkerSize',20);
% display image patch
px=x+p(3); py=y+p(1); % pad x and y dimensions
initFig(); imagesc(cropPatch(IPadded,px,py,ri)); axis('image'); title('Selected image patch');

[treeIds,leafIds,x1,y1]=coords2forestLocation(x,y,ind,model.opts,p,length(model.fids));
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
    montage2title(['Segmentations; tree ' treeStr]);
    if ~exist('w','var')
      % if we have the weights, don't show the image patches to reduce clutter
      initFig(); montage2(imgPs,struct('hasChn', true));
      montage2title(['Image patches; tree ' treeStr]);
    end
  else
    initFig(); im(T{treeId}.hs(:,:,leafId)); title(['Best segmentation; tree ' treeStr]);
  end
end

show_patch_fcn=@(src,src_title) show_patch(src,src_title,p,px,py,rg);
% Compute the intermediate decision at the given pixel location (of 4 trees)
Es4=edgesDetectMex(model,chnsReg,chnsSim,x1,y1);
E4=Es4(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:);
% Q? Why these apparent off-by-ones when cropping the patch; to visualise properly, cropping 1px bigger radius; check rounding errors
% A. The actual boundary is between two pixels; can't do any better
h=show_patch(E4,'Intermediate decision patch (4 trees voted)',p,px,py,rg+1);

% patch detected with the decision forest; result based on 16x16x4/4 trees
% that vote for each pixel
h=show_patch_fcn(E,'SRF decision patch');
% Superpixelization (over-segmentation patch)
% initFig(); im(wsPadded); hold on; plot(px,py,'rx');
h=show_patch_fcn(wsPadded,'WS patch'); % watershed, superpixels patch
% that was a coloured representation of the watershed patch
% spxPatch=cropPatch(wsPadded,px,py,rg);
% initFig(); imagesc(label2rgb(spxPatch,'jet',[1 1 1],'shuffle')); axis('image'); title('Superpixels patch');

% Ultrametric Contour Map patch
h=show_patch_fcn(ucm,'UCM patch');

% TODO use a global var 'h' and a function cleanUpFigs to close old figs
% remove all figures that were not created on this iteration
figHandles=findobj('Type','figure');
oldFigures=figHandles(figHandles>h); % h is the last handle used
close(oldFigures);
end % processLocation

% ----------------------------------------------------------------------
function montage2title(mTitle)
% adds a title to a figure drawn using the montage2 function
set(gca,'Visible','on'); set(gca,'xtick',[]); set(gca,'ytick',[]);
title(mTitle);
end

% ----------------------------------------------------------------------
function h = show_patch(src,src_title,p,px,py,rg)
srcPadded=imPad(src,p,'symmetric');
h=initFig(); im(cropPatch(srcPadded,px,py,rg)); title(src_title);
end
