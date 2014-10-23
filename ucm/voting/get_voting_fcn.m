% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function [cfp_fcn,E] = get_voting_fcn(I,model,patch_score_fcn,T,gts)
opts=model.opts;
ri=opts.imWidth/2; % patch radius 16
rg=opts.gtWidth/2; % patch radius 8
nTreesEval=opts.nTreesEval;
% pad image, making divisible by 4
szOrig=size(I); p=[ri ri ri ri];
p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*ri,4),4);
IPadded=imPad(I,p,'symmetric');
% compute feature channels
[chnsReg,chnsSim]=edgesChns(IPadded,model.opts);
% apply forest to image
[Es,ind]=edgesDetectMex(model,chnsReg,chnsSim);
% normalize and finalize edge maps
t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval;
Es_=Es(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg)*t;
E=convTri(Es_,1);
if exist('T','var') && ~isempty(T)
  process_location_fcn=@(x,y,w) processLocation(x,y,model,T,IPadded,ri,rg,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,ws_padded,contours2ucm(E),w);
else
  process_location_fcn=@(varargin) disp([]); % NO-OP function, in case there is no T input
end
if exist('gts','var')
  % oracle, use ground truth segmentations corresponding to I
  for k=1:length(gts)
    % pad similarly the gts
    gts{k}=imPad(double(gts{k}),p,'symmetric'); % ground truths were uint16, which can't be padded
  end
  get_hs_fcn=@(x,y) get_groundtruth_patches(x+p(3),y+p(1),rg,gts); % coords are offset for padded ground truth images
else
  % voting on the watershed contour
  coords2forest_location_fcn=@(x,y) coords2forestLocation(x,y,ind,opts,p,length(model.fids));
  get_hs_fcn=@(x,y) get_tree_patches(x,y,coords2forest_location_fcn,model,nTreesEval);
end

ws2seg_fcn=@(x) (x); % the identity function
% ws2seg_fcn=@(x) spx2seg(x);  % when not fitting a line

ws_padded=imPad(double(watershed(E)),p,'symmetric');
cfp_fcn=@(pb) create_finest_partition_voting(pb,ws_padded,rg,get_hs_fcn,process_location_fcn,patch_score_fcn,ws2seg_fcn);
end

% ----------------------------------------------------------------------
function hs = get_tree_patches(x,y,coords2forest_location_fcn,model,nTreesEval)
% get 4 patches in leaves using ind
[treeIds,leafIds]=coords2forest_location_fcn(x,y);
segs=model.seg;
hs=zeros(size(segs,1),size(segs,2),nTreesEval);
for k=1:nTreesEval
  treeId=treeIds(:,:,k); leafId=leafIds(:,:,k);
  % assert(~model.child(leafId,treeId));
  hs(:,:,k)=segs(:,:,leafId,treeId); %T{treeId}.hs(:,:,leafId); % best segmentation
end
end

% ----------------------------------------------------------------------
function hs = get_groundtruth_patches(x,y,r,gts)
gtsz=length(gts);
hs=zeros(2*r,2*r,gtsz);
for k=1:gtsz
  hs(:,:,k)=cropPatch(gts{k},x,y,r);
end
end
