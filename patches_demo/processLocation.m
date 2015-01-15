% Zornitsa Kostadinova
% Aug 2014
% 8.3.0.532 (R2014a)
function processLocation(x,y,model,T,I,show_I,rg,p,chnsReg,chnsSim,ind,E,ucm,w)
if show_I, initFig(1); im(I); hold on; plot(x,y,'rx','MarkerSize',20); end
% display image patch
[coordsPad_fcn,imPad_fcn]=get_pad_fcns(p);
[px,py]=coordsPad_fcn(x,y);
IPadded=imPadSym(I,p);
initFig; imagesc(cropPatch(IPadded,px,py,rg)); hold on; plot(rg,rg,'x'); axis('image'); title('Selected image patch');

[treeIds,leafIds,x1,y1]=coords2forestLocation(x,y,ind,model.opts,p,length(model.fids));
nTreesEval=size(treeIds,3);
hs=cell(nTreesEval,1);
for k=1:nTreesEval
  treeId=treeIds(:,:,k); leafId=leafIds(:,:,k);
  hs{k}=T{treeId}.hs(:,:,leafId);
  assert(~model.child(leafId,treeId)); % TODO add this to assertion (when also saving patches in forest) && ~isempty(model.patches{leafId,treeId}));
  segPs=T{treeId}.segPs{leafId}; % model.patches{leafId,treeId}
  imgPs=T{treeId}.imgPs{leafId};
  assert(~xor(isempty(segPs),isempty(imgPs)));
  treeStr=num2str(treeId);
  if exist('w','var'), assert(nTreesEval==length(w)); treeStr=[treeStr ' - score ' num2str(w(k))]; end
  if ~isempty(segPs) % only leaves with no more than 40 samples have the patches stored
    initFig; montage2(cell2array(segPs));
    montage2title(['Segmentations; tree ' treeStr]);
    if ~exist('w','var')
      % to reduce clutter, only show the image patches if we don't have the weights
      initFig; montage2(imgPs,struct('hasChn', true));
      montage2title(['Image patches; tree ' treeStr]);
    end
  else
    initFig; im(hs{k}); title(['Best segmentation; tree ' treeStr]);
  end
end

% % alternatively, just 'montage' the nTreesEval medoid patches together (no scores)
% initFig; montage2(cell2array(hs)); montage2title('the medoid patches');

show_patch_fcn=@(src,src_title) pad_show_patch(src,imPad_fcn,px,py,rg,src_title);
% Compute the intermediate decision at the given pixel location (of 4 trees)
Es4=edgesDetectMex(model,chnsReg,chnsSim,x1,y1);
[szOrig(1),szOrig(2)]=size(E);
E4=Es4(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:);
% Q? Why these apparent off-by-ones when cropping the patch; to visualise properly, cropping 1px bigger radius; check rounding errors
% A. The actual boundary is between two pixels; can't do any better
% h=pad_show_patch(E4,imPad_fcn,px,py,rg+1,'Intermediate decision patch (4 trees voted)');

% patch detected with the decision forest; result based on 16x16x4/4 trees
% that vote for each pixel
% h=show_patch_fcn(E,'SRF decision patch');
% Superpixelization (over-segmentation patch)
h=show_patch_fcn(watershed(E),'WS patch'); % watershed, superpixels patch
% % that was a coloured representation of the watershed patch
% spxPatch=cropPatch(ws_padded,px,py,rg);
% h=initFig; imcc(spxPatch); title('Superpixels patch');

% Ultrametric Contour Map patch
h=show_patch_fcn(ucm,'UCM patch');

ws_bw=(watershed(E)==0);
ucm_bw=(ucm~=0);
% TODO in hard_negative_demo all the following is yellow (overlap) on the bear img
% what is going on here in patchesDemo (when input is the zebra image) - no
% overlap, messy red, green; might explain why the WS patch is wrong, i.e. BUG in patchesDemo?
rgb_loc=cat(3,ws_bw,ucm_bw,zeros(size(ws_bw)));
h=initFig; im(rgb_loc);

% TODO use a global var 'h' and a function cleanUpFigs to close old figs
% remove all figures that were not created on this iteration
figHandles=findobj('Type','figure');
oldFigures=figHandles(figHandles>h); % h is the last handle used
close(oldFigures);
end
