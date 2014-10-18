% Zornitsa Kostadinova
% Jul 2014
% 8.3.0.532 (R2014a)
function ucm = ucm_weighted(I,model,fmt,T,gts)
% function ucm = ucm_weighted(I,model,fmt,T)
% creates a ucm of an image, that is weighted based on the patches in the leaves of a
% decision forest
%
% INPUTS
%  I            - image
%  model        - structured decision forest (SF)
%  fmt          - output format; 'imageSize' (default) or 'doubleSize'
%  T            - individual trees of the SF (for visualisation only - processLocation)
%  gts          - (optional) ground truth segmentations; for oracle only; used
%                 to analyse the performance of similarity scoring functions on
%                 patches
%
% OUTPUTS
%  ucm          - Ultrametric Contour Map
%
% See also contours2ucm
if ~exist('fmt','var'), fmt='imageSize'; end;
if ~exist('T','var'), T=[]; end;

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
if exist('gts','var')
  % oracle, use ground truth segmentations corresponding to I
  for k=1:length(gts)
    % pad similarly the gts
    gts{k}=imPad(double(gts{k}),p,'symmetric'); % ground truths were uint16, which can't be padded
  end
  get_hs_fcn=@(x,y) get_groundtruth_patches(x+p(3),y+p(1),ri/2,gts); % coords are offset for padded ground truth images
else
  % voting on the watershed contour
  coords2forest_location_fcn=@(x,y) coords2forestLocation(x,y,ind,opts,p,length(model.fids));
  get_hs_fcn=@(x,y) get_tree_patches(x,y,coords2forest_location_fcn,model,nTreesEval);
end
wsPadded=imPad(double(watershed(E)),p,'symmetric');
process_location_fcn=@(x,y,w) processLocation(x,y,model,T,IPadded,opts,ri,rg,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,wsPadded,contours2ucm(E),w);
cfp=@(pb) create_finest_partition_voting(pb,wsPadded,ri,get_hs_fcn,process_location_fcn);
ucm=contours2ucm(E,fmt,cfp);
end

% ----------------------------------------------------------------------
function sf_wt = create_finest_partition_voting(pb,wsPadded,ri,get_hs_fcn,process_location_fcn)
ws=watershed(pb);
% assert(all(all(ws==wsPadded(1+ri:size(pb,1)+ri,1+ri:size(pb,2)+ri))));

c=fit_contour(double(ws==0));
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
nEdges=numel(c.edge_x_coords);
c.edge_weights=zeros(nEdges,2); % tuples of accumulated weights and number of pixels per edge
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
  if e == 40 || e == 48
    disp(e);
  end
  v1=c.vertices(c.edges(e,1),:); % fst coord is y - row ind
  v2=c.vertices(c.edges(e,2),:);
  l=fit_line(v1,v2,ri);
  for p=1:numel(c.edge_x_coords{e})
    % NOTE x and y are swapped here (in the output from fit_contour)
    % the correct way is (for an image of dimensions h x w x 3)
    % first coord, in [1,h], is y, second coord, in [1,w], is x
    ey=c.edge_x_coords{e}(p); ex=c.edge_y_coords{e}(p);
    x=ex+ri; y=ey+ri; r=ri/2; % adjust patch dimensions
    % wsPatch=cropPatch(wsPadded,x,y,r); % crop from the padded watershed, to make sure a superpixels patch can always be cropped % r=ri/2 == rg
    wsPatch=create_seg_patch(x,y,r,l);
    hs=get_hs_fcn(ex,ey);
    w=compute_weights(wsPatch,hs);
    f=false;
    if f
      % close all;
      initFig(1); im(wsPadded); hold on; plot(ex+ri,ey+ri,'rx','MarkerSize',12);
      initFig(); im(wsPatch);
      process_location_fcn(ex,ey,w); % this needs a model with the patches saved
    end
    w=sum(w)/numel(w);
    c.edge_weights(e,:)=c.edge_weights(e,:)+[w 1];
  end
end % for e - edge index

% apply weights to ucm
sf_wt=zeros(size(pb));
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
  W=c.edge_weights(e,1)/c.edge_weights(e,2); % avg weight on edge e
  for p=1:numel(c.edge_x_coords{e})
    ey=c.edge_x_coords{e}(p); ex=c.edge_y_coords{e}(p);
    sf_wt(ey,ex)=W;
  end
  v1=c.vertices(c.edges(e,1),:);
  v2=c.vertices(c.edges(e,2),:);
  sf_wt(v1(1),v1(2))=max(W,sf_wt(v1(1),v1(2)));
  sf_wt(v2(1),v2(2))=max(W,sf_wt(v2(1),v2(2)));
end % for e - edge index
% sf_wt=sf_wt.*create_finest_partition_non_oriented(pb); % VPR .* pb
end % create_finest_partition

% ----------------------------------------------------------------------
function l = fit_line(v1,v2,ri)
% adjust indices for the padded superpixelised image
v1=v1+ri;v2=v2+ri;
l=createLine([v1(2),v1(1)],[v2(2),v2(1)]);
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

% ----------------------------------------------------------------------
function w = compute_weights(wsPatch,hs)
hsz=size(hs,3); % number of ground truth patches
w=zeros(hsz,1);
for k=1:hsz
  w(k)=patch_score(wsPatch,hs(:,:,k));
end
end % computeWeights

% ----------------------------------------------------------------------
function w = patch_score(spx,seg)
% return a score in [0,1] for the similarity of the superpixel and the
% segmentation patch; 0 - no similarity; 1 - maximal similarity
% fst=spx2seg(spx); % important when not fitting a line
fst=spx;
snd=seg;
fst=double(fst); snd=double(snd); % could work with uint8, but not desirable in case some of the segments have labels bigger than 255
w=vpr_s(fst,snd); % normalisation on the watershed side
% w=vpr_gt(fst,snd); % normalisation on the trees side
% w=compareSegs(fst,snd);
end

% ----------------------------------------------------------------------
function w = patch_score_deprecated(spx,seg)
% 2 options for inputs - bdry or seg
% bdrys01={spx2bdry01(spx) seg2bdry01(seg)}; % type: logical
% bdrys12={spx2bdry01(spx)+1 seg2bdry01(seg)+1}; % type: double
segs={spx2seg(spx) seg};
p=false;
if p
  initFig(1); im(spx);
  initFig(); im(seg);
  initFig(); im(bdrys01{1}); %montage2(cell2array(segs));
  initFig(); im(bdrys01{2});
  initFig(); im(bdrys12{1});
  initFig(); im(bdrys12{2});
  initFig(); im(segs{1});
  initFig(); im(segs{2});
end
% 2 options for distance metric - the original "crude" approximation or VPR
% w=VPR(bdrys01{:}); % 0.3169 % 11s -runtimes on a small example 241x161
% w=VPR(bdrys12{:}); % 0.8402 % 11 seconds
% w=VPR(segs{:}); % 17 seconds
% w=RSRI(bdrys01{:}); % 7 seconds
w=RSRI(segs{:}); % 11 seconds
end

% ----------------------------------------------------------------------
function patch = spx2bdry01(patch)
% convert the superpixels patch to be a 0-1 boundary location
% the input has the boundary denoted by 0
% the output has the boundary denoted by 1, non-boundary by 0
patch=patch==0;
end

% ----------------------------------------------------------------------
function patch = spx2seg(patch)
% convert the superpixels patch to be a segmentation labeling (starting from 1)
% the input has the boundary denoted by 0
% see pb2ucm
sz=size(patch);
bdry=spx2bdry01(patch);
% labels2=bwlabel(clean_watersheds(super_contour_4c(bdry))==0,8); % TODO don't
% clean the watersheds for speed
labels2=bwlabel(super_contour_4c(bdry)==0,8); % type: double; 0 indicates boundary
patch=labels2(2:2:end, 2:2:end); % labels should start from 1
% TODO labels sometimes start from 0; bug due to artifacts from the watershed;
% workaround:
[~,~,patch]=unique(patch);
patch=reshape(patch,sz);
end

% ----------------------------------------------------------------------
function patch = seg2bdry01(patch)
% convert the seg to be 0-1 boundary location
patch=gradientMag(single(patch))>.01;
end

% ----------------------------------------------------------------------
function [pb2, V, H] = super_contour_4c(pb)

V = min(pb(1:end-1,:), pb(2:end,:));
H = min(pb(:,1:end-1), pb(:,2:end));

[tx, ty] = size(pb);
pb2 = zeros(2*tx, 2*ty);
pb2(1:2:end, 1:2:end) = pb;
pb2(1:2:end, 2:2:end-2) = H;
pb2(2:2:end-2, 1:2:end) = V;
pb2(end,:) = pb2(end-1, :);
pb2(:,end) = max(pb2(:,end), pb2(:,end-1));
end
