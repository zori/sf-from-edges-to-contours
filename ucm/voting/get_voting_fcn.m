% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function [cfp_fcn,E] = get_voting_fcn(I,model,voting,DBG,is_hard_negative_mining,T,gts)
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
  process_location_fcn=@(x,y,w) process_location_gt_helper(I,x,y,p,w,gts,rg);
else
  % voting on the watershed contour
  coords2forest_location_fcn=@(x,y) coords2forestLocation(x,y,ind,opts,p,length(model.fids));
  get_hs_fcn=@(x,y) get_tree_patches(x,y,coords2forest_location_fcn,model);
  if exist('T','var') && ~isempty(T)  % needs to have the patches saved
    process_location_fcn=@(x,y,w) processLocation(x,y,model,T,I,~is_hard_negative_mining,rg,p,chnsReg,chnsSim,ind,E,contours2ucm(E),w);
  else
    process_location_fcn=@(varargin) disp([]); % NO-OP function, in case there is no T input
  end
end

% clear functions; % clears the persistent vars AND :( all breakpoints
clear create_contour_patch create_ws_patch create_fitted_line_patch ...
 create_fitted_poly_patch create_fitted_conic_patch;

% for debugging purposes
crop_ws_patch_fcn=@(px,py,varargin) create_ws_patch(px,py,rg,E,p);

% patch_score_fcn -  function for the similarity between the watershed and the
%                    segmentation patch
%                    score in [0,1]; 0 - no similarity; 1 - maximal similarity
%                    function could be: bpr vpr_s vpr_gt RI RSRI greedy_merge
switch voting
  % % bpr
  case 'bpr'
    px_max_dist=3;
    patch_score_fcn=@(S,G) bpr(S,G,px_max_dist);
    % % varargin is {c,e,size(pb)}
    % get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_patch(px,py,rg,varargin{1:2});
    get_ws_patch_fcn=crop_ws_patch_fcn;
    % get_ws_patch_fcn=@(px,py,varargin) create_contour_patch(px,py,rg,varargin{:}); % TODO wish to be able to write create_contour_patch(px,py,rg,c,e,size(pb));
    
    % process_ws_patch_fcn=@(x) (x); % the identity function
    % process_ws_patch_fcn=@thin_bdry2seg;
    % process_ws_patch_fcn=@(x) spx2seg(x);  % when not fitting a line
    process_ws_patch_fcn=@(x) seg2bdry(spx2seg(x));  % output: doubleSize
    % process_hs_fcn=@(x) (x); % id
    % There are two options to do the seg2bdry imageSize
    % (3:2:end,3:2:end); or (1:2:end-2,1:2:end-2);
    % process_hs_fcn=@(G) seg2bdry(G,'imageSize'); % for when the ws output is boundary
    process_hs_fcn=@(G) seg2bdry(G); % output: doubleSize
  case {'line_bpr_3' 'line_bpr_4'}
    px_max_dist=str2double(voting(end)); % maximal pixel distance for BPR matching
    assert(px_max_dist==3||px_max_dist==4);
    patch_score_fcn=@(S,G) bpr(S,G,px_max_dist);
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_patch(px,py,rg,varargin{1:2});
    process_ws_patch_fcn=@(x) (x); % the identity function
    process_hs_fcn=@(G) seg2bdry(G,'imageSize'); % for when the ws output is boundary
  case {'line_centre_bpr_3' 'line_centre_bpr_4'}
    px_max_dist=str2double(voting(end)); % maximal pixel distance for BPR matching
    assert(px_max_dist==3||px_max_dist==4);
    patch_score_fcn=@(S,G) bpr(S,G,px_max_dist);
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_centre_patch(px,py,rg,varargin{1:2});
    process_ws_patch_fcn=@(x) (x); % the identity function
    process_hs_fcn=@(G) seg2bdry(G,'imageSize'); % for when the ws output is boundary
  case 'contour_bpr_3'
    px_max_dist=3;
    patch_score_fcn=@(S,G) bpr(S,G,px_max_dist);
    get_ws_patch_fcn=@(px,py,varargin) create_contour_patch(px,py,rg,varargin{:});
    process_ws_patch_fcn=@(x) (x); % the identity function
    process_hs_fcn=@(G) seg2bdry(G,'imageSize'); % for when the ws output is boundary

  % % vpr
    % % the 'greedy merge' voting option is deprecated - same settings, more
    % descriptive name: 'fairer_merge_VPR_normalised_ws'
    %   case 'greedy_merge' % a.k.a. "fair segments merge"
    %     patch_score_fcn=@(S,G) greedy_merge_patch_score(greedy_merge(S,G),G,@vpr_s);
    %     get_ws_patch_fcn=crop_ws_patch_fcn;
    %     process_ws_patch_fcn=@spx2seg;
    %     process_hs_fcn=@(x) (x);
  case 'fairer_merge_VPR_normalised_ws'
    patch_score_fcn=@(S,G) greedy_merge_patch_score(greedy_merge(S,G),G,@vpr_s);
    get_ws_patch_fcn=crop_ws_patch_fcn;
    process_ws_patch_fcn=@spx2seg;
    process_hs_fcn=@(x) (x);
  case 'fairer_merge_VPR_normalised_trees'
    patch_score_fcn=@(S,G) greedy_merge_patch_score(greedy_merge(S,G),G,@vpr_gt);
    get_ws_patch_fcn=crop_ws_patch_fcn;
    process_ws_patch_fcn=@spx2seg;
    process_hs_fcn=@(x) (x);
  case 'line_VPR_normalised_ws'
    patch_score_fcn=@vpr_s;
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_patch(px,py,rg,varargin{1:2});
    process_ws_patch_fcn=@thin_bdry2seg;
    process_hs_fcn=@(x) (x);
  case 'line_centre_VPR_normalised_ws' % line fitting for proper region boundaries
    patch_score_fcn=@vpr_s;
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_centre_patch(px,py,rg,varargin{1:2});
    process_ws_patch_fcn=@thin_bdry2seg;
    process_hs_fcn=@(x) (x);
  case 'line_lls_VPR_normalised_ws' % linear least squares fit (minimisation); based on conic_VPR_normalised_ws
    patch_score_fcn=@vpr_s;
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_lls_patch(px,py,rg,varargin{1:2});
    process_ws_patch_fcn=@thin_bdry2seg;
    process_hs_fcn=@(x) (x);
  case 'conic_VPR_normalised_ws'
    patch_score_fcn=@vpr_s;
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_conic_patch(px,py,rg,varargin{1:2});
    process_ws_patch_fcn=@thin_bdry2seg;
    process_hs_fcn=@(x) (x);
  % TODO debug
  case {'poly_VPR_normalised_ws_1' 'poly_VPR_normalised_ws_2'}
    patch_score_fcn=@vpr_s;
    n=str2double(voting(end)); % degree of polynomial to fit to data
    assert(n==1||n==2);
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_poly_patch(px,py,n,rg,varargin{1:2});
    process_ws_patch_fcn=@thin_bdry2seg;
    process_hs_fcn=@(x) (x);
  % % ri
  case 'line_RI'
    patch_score_fcn=@RI;
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_patch(px,py,rg,varargin{1:2});
    process_ws_patch_fcn=@thin_bdry2seg;
    process_hs_fcn=@(x) (x);
  case 'line_centre_RI'
    patch_score_fcn=@RI;
    get_ws_patch_fcn=@(px,py,varargin) create_fitted_line_centre_patch(px,py,rg,varargin{1:2});
    process_ws_patch_fcn=@thin_bdry2seg;
    process_hs_fcn=@(x) (x);
  case 'fairer_merge_RI'
    patch_score_fcn=@(S,G) greedy_merge_patch_score(greedy_merge(S,G),G,@RI);
    get_ws_patch_fcn=crop_ws_patch_fcn;
    process_ws_patch_fcn=@spx2seg;
    process_hs_fcn=@(x) (x);
  case 'fairer_merge_RIMC' % Rand Index Monte Carlo
    patch_score_fcn=@(S,G) greedy_merge_patch_score(greedy_merge(S,G),G,@RSRI);
    get_ws_patch_fcn=crop_ws_patch_fcn;
    process_ws_patch_fcn=@spx2seg;
    process_hs_fcn=@(x) (x);
  otherwise
    error('not implemented %s',voting);
end

ws_fcn=@(px,py,varargin) process_ws(px,py,varargin,get_ws_patch_fcn,process_ws_patch_fcn);
hs_fcn=@(x,y) process_hs(x,y,get_hs_fcn,process_hs_fcn);
vote_fcn=@(x,y,ws_args,dbg) vote(x,y,rg,ws_fcn,ws_args,hs_fcn,patch_score_fcn,process_location_fcn,crop_ws_patch_fcn,dbg);
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

% ----------------------------------------------------------------------
function process_location_gt_helper(I,x,y,p,w,gts,rg)
show_I_location(I,x,y);
process_location_gt(x+p(3),y+p(1),w,gts,rg);
end
