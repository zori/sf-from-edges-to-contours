% Zornitsa Kostadinova
% Jul 2014
% 8.3.0.532 (R2014a)
function ucm = ucm_weighted(I,model,patch_score_fcn,fmt,T,gts)
% function ucm = ucm_weighted(I,model,patch_score_fcn,fmt,T,gts)
% creates a ucm of an image, that is weighted based on the patches in the leaves of a
% decision forest
%
% INPUTS
%  I            - image
%  model        - structured decision forest (SF)
%  patch_score_fcn - function for the similarity between the watershed and the
%                    segmentation patch
%                    score in [0,1]; 0 - no similarity; 1 - maximal similarity
%                    function could be: bpr vpr_s vpr_gt RI RSRI compareSegs
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

ws2seg_fcn=@(x) (x); % the identity function
% ws2seg_fcn=@(x) spx2seg(x);  % when not fitting a line

ws_padded=imPad(double(watershed(E)),p,'symmetric');
process_location_fcn=@(x,y,w) processLocation(x,y,model,T,IPadded,opts,ri,rg,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,ws_padded,contours2ucm(E),w);
cfp=@(pb) create_finest_partition_voting(pb,ws_padded,ri,get_hs_fcn,process_location_fcn,patch_score_fcn,ws2seg_fcn);
ucm=contours2ucm(E,fmt,cfp);
end

% ----------------------------------------------------------------------
function sf_wt = create_finest_partition_voting(pb,ws_padded,ri,get_hs_fcn,process_location_fcn,patch_score_fcn,ws2seg_fcn)
ws=watershed(pb);
% assert(all(all(ws==ws_padded(1+ri:size(pb,1)+ri,1+ri:size(pb,2)+ri))));

c=fit_contour(double(ws==0));
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
nEdges=numel(c.edge_x_coords);
c.edge_weights=zeros(nEdges,2); % tuples of accumulated weights and number of pixels per edge
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
%   if e == 40 || e == 48
%     disp(e);
%   end
  v1=c.vertices(c.edges(e,1),:); % fst coord is y - row ind
  v2=c.vertices(c.edges(e,2),:);
  l=fit_line(v1,v2,ri);
  for p=1:numel(c.edge_x_coords{e})
    % NOTE x and y are swapped here (in the output from fit_contour)
    % the correct way is (for an image of dimensions h x w x 3)
    % first coord, in [1,h], is y, second coord, in [1,w], is x
    y=c.edge_x_coords{e}(p); x=c.edge_y_coords{e}(p);
    px=x+ri; py=y+ri; r=ri/2; % adjust patch dimensions
    ws_patch=cropPatch(ws_padded,px,py,r); % crop from the padded watershed, to make sure a superpixels patch can always be cropped % r=ri/2 == rg
    ws_patch=create_seg_patch(px,py,r,l); % create_bdry_patch and ws2seg_fcn will be bdry2seg() <- TODO write it
    ws_patch=ws2seg_fcn(ws_patch);
    hs=get_hs_fcn(x,y); % a few 16x16 segmentation patches
    w=compute_weights(ws_patch,hs,patch_score_fcn);
    f=false;
    if f
      % close all;
      initFig(1); im(ws_padded); hold on; plot(x+ri,y+ri,'rx','MarkerSize',12);
      initFig(); im(ws_patch);
      process_location_fcn(x,y,w); % this needs a model with the patches saved
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
    y=c.edge_x_coords{e}(p); x=c.edge_y_coords{e}(p);
    sf_wt(y,x)=W;
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
function w = compute_weights(ws_patch,hs,patch_score_fcn)
hsz=size(hs,3); % number of ground truth patches
w=zeros(hsz,1);
for k=1:hsz
  w(k)=patch_score_fcn(double(ws_patch),double(hs(:,:,k))); % could work with uint8, but not desirable in case some of the segments have labels bigger than 255
end
end % computeWeights

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
% NOTE: keep that for now, but also note seg2bdry (Arbelaez implementation)
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
assert(all(pb2(:,end)==0));
pb2(:,end) = max(pb2(:,end), pb2(:,end-1));
end
