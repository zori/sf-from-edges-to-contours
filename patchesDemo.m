function patchesDemo(model,T)
assert(~isempty(model) && ~isempty(T));

% an image from BSDS500 validation subset
imFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/detect/Images/101085.jpg';
% gtFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/detect/Groundtruth/101085.mat';
I=imread(imFile);
opts=model.opts;

while (true)
  % get user input and crop patch TODO crop patch from Ipadded
  imFigure=figure(101); im(I); title('Choose a patch to crop');
  [x,y]=ginput;
  % if no patch or more than one patch is selected, stop the interactive demo
  if (length(x)~= 1), close(imFigure); break; end
  x_ind=uint32(floor(x/2)); y_ind=uint32(floor(y/2));
  x=uint32(floor(x)); y=uint32(floor(y));
  figure(102); r0=opts.imWidth/2; % patch radius r=16
  im(cropPatch(I,x,y,r0)); title('Cropped image patch');
  
  Im=I;
  % pad image, making divisible by 4
  szOrig=size(Im); r=opts.imWidth/2; p=[r r r r]; % r=16
  p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*r,4),4);
  IPadded=imPad(Im,p,'symmetric');
  % compute feature channels
  [chnsReg,chnsSim]=edgesChns(IPadded,model.opts);
  
  % apply forest to image
  [Es,ind]=fooMex(model,chnsReg,chnsSim); % mex-file was private edgesDetectMex(...)
  % normalize and finalize edge maps
  t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval; r=opts.gtWidth/2; % r=8
  Es_=Es(1+r:szOrig(1)+r,1+r:szOrig(2)+r,:)*t; EsDetected=convTri(Es_,1);
  
  % patch detected with the decision forest; result based on 16x16x4/4 trees
  % that vote for each pixel
  figure(103); im(cropPatch(EsDetected,x,y,r0)); title('SRF decision patch');
  % Superpixelization (over-segmentation patch)
  figure(104); im(cropPatch(watershed(EsDetected),x,y,r0)); title('Superpixels patch');
  
  nTreeNodes=length(model.fids);
  nTreesEval=opts.nTreesEval;
  ids=double(ind(y_ind,x_ind,:)); % indices come from cpp and are 0-based; for tree_set=2 ??
  treeIds=uint32(floor(ids./nTreeNodes)+1);
  leafIds=uint32(mod(ids,nTreeNodes)+1);
  
  for k=1:nTreesEval
    treeId=treeIds(:,:,k); leafId=leafIds(:,:,k);
    assert(~model.child(leafId,treeId) && ~isempty(model.patches{leafId,treeId}));
    figure(k); montage2(cat(3,T{treeId}.hs(:,:,leafId),cell2array(T{treeId}.patches{leafId}))); % model.patches{leafId,treeId}
  end
  % TODO get the "intermediate" patch - decision made only based on the 4
  % groups of patches shown here; don't use the result ind of the private mex
  % function, rather work within it
end % while(true)
end % patchesDemo

% ----------------------------------------------------------------------
function patch = cropPatch(I,x,y,r)
% crop a patch with radius r from an image I at location [x y]
% output patch has dimensions [2r x 2r]
patch=I(y-r+1:y+r,x-r+1:x+r,:);
end