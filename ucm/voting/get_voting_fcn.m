% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function [cfp_fcn,E] = get_voting_fcn(I,model,voting,DBG,T,gts)
opts=model.opts;
ri=opts.imWidth/2; % patch radius 16
rg=opts.gtWidth/2; % patch radius 8
% pad image, making divisible by 4
szOrig=size(I); p=[ri ri ri ri];
p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*ri,4),4);
IPadded=imPadSym(I,p);
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
  get_hs_fcn=@(x,y) get_groundtruth_patches(x+p(3),y+p(1),rg,gts); % coords are offset for padded ground truth images
  process_location_fcn=@(x,y,w) process_location_gt(x,y,w,gts,p,rg);
else
  % voting on the watershed contour
  coords2forest_location_fcn=@(x,y) coords2forestLocation(x,y,ind,opts,p,length(model.fids));
  get_hs_fcn=@(x,y) get_tree_patches(x,y,coords2forest_location_fcn,model);
  if exist('T','var') && ~isempty(T)  % needs to have the patches saved
    process_location_fcn=@(x,y,w) processLocation(x,y,model,T,I,rg,p,chnsReg,chnsSim,ind,E,contours2ucm(E),w);
  else
    process_location_fcn=@(varargin) disp([]); % NO-OP function, in case there is no T input
  end
end

% clear functions; % clears the persistent vars AND :( all breakpoints
clear create_fitted_line_patch create_ws_patch create_contour_patch;

% patch_score_fcn -  function for the similarity between the watershed and the
%                    segmentation patch
%                    score in [0,1]; 0 - no similarity; 1 - maximal similarity
%                    function could be: bpr vpr_s vpr_gt RI RSRI greedy_merge
switch voting
  case 'bpr'
    px_max_dist=3;
    patch_score_fcn=@(S,G) bpr(S,G,px_max_dist);
    % % varargin is {c,e,size(pb)}
    % get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_patch(px,py,rg,varargin{1:2});
    get_ws_patch_fcn=@(px,py,varargin) create_ws_patch(px,py,rg,E,p);
    % get_ws_patch_fcn=@(px,py,varargin) create_contour_patch(px,py,rg,varargin{:}); % TODO wish to be able to write create_contour_patch(px,py,rg,c,e,size(pb));
    
    % process_ws_patch_fcn=@(x) (x); % the identity function
    % process_ws_patch_fcn=@bdry2seg;
    % process_ws_patch_fcn=@(x) spx2seg(x);  % when not fitting a line
    process_ws_patch_fcn=@(x) seg2bdry(spx2seg(x));  % output: doubleSize
    % process_hs_fcn=@(x) (x); % id
    % There are two options to do the seg2bdry imageSize
    % (3:2:end,3:2:end); or (1:2:end-2,1:2:end-2);
    % process_hs_fcn=@(G) seg2bdry(G,'imageSize'); % for when the ws output is boundary
    process_hs_fcn=@(G) seg2bdry(G); % output: doubleSize
  case 'greedy_merge'
    patch_score_fcn=@(S,G) greedy_merge_patch_score(greedy_merge(S,G),G,@RI);
    get_ws_patch_fcn=@(px,py,varargin) create_ws_patch(px,py,rg,E,p);
    process_ws_patch_fcn=@spx2seg;
    process_hs_fcn=@(x) (x);
  case 'line_VPR_normalised_ws'
    patch_score_fcn=@vpr_s;
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_patch(px,py,rg,varargin{1:2});
    process_ws_patch_fcn=@bdry2seg;
    process_hs_fcn=@(x) (x);
%   case 'vpr'
  otherwise
    error('not implemented %s',voting);
end

ws_fcn=@(px,py,varargin) process_ws(px,py,varargin,get_ws_patch_fcn,process_ws_patch_fcn);
hs_fcn=@(x,y) process_hs(x,y,get_hs_fcn,process_hs_fcn);
vote_fcn=@(x,y,ws_args,dbg) vote(x,y,rg,ws_fcn,ws_args,hs_fcn,patch_score_fcn,process_location_fcn,dbg);
cfp_fcn=@(pb) create_finest_partition_voting(pb,vote_fcn,DBG);
end

% ----------------------------------------------------------------------
function [ws_patch_processed,ws_patch] = process_ws(px,py,get_ws_patch_args,get_ws_patch_fcn,process_ws_patch_fcn)
ws_patch=get_ws_patch_fcn(px,py,get_ws_patch_args{:});
ws_patch_processed=process_ws_patch_fcn(ws_patch);
end

% ----------------------------------------------------------------------
function [hs_processed,hs] = process_hs(x,y,get_hs_fcn,process_hs_fcn)
hs=get_hs_fcn(x,y);
hs_processed=cell(1,size(hs,3));
for k=1:size(hs,3)
  hs_processed{k}=process_hs_fcn(hs(:,:,k));
end
hs_processed=cell2array(hs_processed);
end

% ----------------------------------------------------------------------
function hs = get_tree_patches(x,y,coords2forest_location_fcn,model)
% get 4 patches in leaves using ind
[treeIds,leafIds]=coords2forest_location_fcn(x,y);
segs=model.seg;
nTreesEval=size(treeIds,3);
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

% TODO review the following and get rid of accordingly
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
patch=labels2(2:2:end,2:2:end); % labels should start from 1
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
