% Zornitsa Kostadinova
% Jul 2014
% 8.3.0.532 (R2014a)
function [ucmF,ucmS] = ucmWeighted(I,model,T)
% creates a ucm of an image, that is weighted based on the patches in the leaves of a
% decision forest
%
% INPUTS
%  I            - image
%  model        - structured decision forest (SF)
%  T            - individual trees of the SF (for visualisation only - processLocation)
%
% OUTPUTS
%  ucm          - Ultrametric Contour Map
%
% See also contours2ucm
opts=model.opts;
ri=opts.imWidth/2; % patch radius 16
rg=opts.gtWidth/2; % patch radius 8
nTreeNodes=length(model.fids);
nTreesEval=opts.nTreesEval;
% pad image, making divisible by 4
szOrig=size(I); p=[ri ri ri ri];
p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*ri,4),4);
IPadded=imPad(I,p,'symmetric');
% compute feature channels
[chnsReg,chnsSim]=edgesChns(IPadded,model.opts);
% apply forest to image
[Es,ind]=fooMex(model,chnsReg,chnsSim); % mex-file was private edgesDetectMex(...)
% normalize and finalize edge maps
t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval;
Es_=Es(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:)*t; E=convTri(Es_,1);
wsPadded=watershed(Es);
computeWeightFun=@(x,y,spxPatch) computeWeights(x,y,spxPatch,model,opts,rg,nTreeNodes,nTreesEval,p,ind);
processLocationFun=@(x,y) processLocation(x,y,model,T,I,opts,ri,rg,nTreeNodes,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,watershed(E),contours2ucm(E));

cFP=@(pb) create_finest_partition(pb,wsPadded,rg,computeWeightFun,processLocationFun);
% TODO fixme: here there are two outputs for comparison - first and second
[ucmF,ucmS]=weightedContours2ucm(E,'doubleSize',cFP);
end

% ----------------------------------------------------------------------
function [ws_wt,sf_wt] = create_finest_partition(pb,wsPadded,rg,computeWeightFun, processLocationFun)
ws_bw=(watershed(pb)==0);

c=fit_contour(double(ws_bw));
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
nEdges=numel(c.edge_x_coords);
c.edge_weights=zeros(nEdges,2); % tuples of accumulated weights and number of pixels per edge

ws_wt=zeros(size(ws_bw)); % weight
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
  for p=1:numel(c.edge_x_coords{e})
    % NOTE x and y are swapped here (in the output from fit_contour)
    % the correct way is (for an image of dimensions h x w x 3)
    % first coord, in [1,h], is y, second coord, in [1,w], is x
    ey=c.edge_x_coords{e}(p); ex=c.edge_y_coords{e}(p);
    ws_wt(ey,ex)=max(pb(ey,ex), ws_wt(ey,ex));
    
    % adjust indices for the padded superpixelised image
    spxPatch=cropPatch(wsPadded,ex+rg,ey+rg,rg); % crop from the padded watershed, to make sure a superpixels patch can always be cropped
    w=computeWeightFun(ex,ey,spxPatch); w=sum(w)/numel(w);
    f=false;
    % TODO inspect pixel values at (47,89) in pb, and in the two finest partitions:
    % ws_wt(47,89) and sf_wt(47,89)
    if f
      % close all;
      initFig(1); im(wsPadded(1+rg:241+rg,1+rg:161+rg)); hold on;
      processLocationFun(ex,ey); % this needs a model with the patches saved
    end
    c.edge_weights(e,:)=c.edge_weights(e,:)+[w 1];
  end
  v1=c.vertices(c.edges(e,1),:);
  v2=c.vertices(c.edges(e,2),:);
  ws_wt(v1(1),v1(2))=max(pb(v1(1),v1(2)),ws_wt(v1(1),v1(2)));
  ws_wt(v2(1),v2(2))=max(pb(v2(1),v2(2)),ws_wt(v2(1),v2(2)));
end % for e - edge index

% apply weights to ucm
sf_wt=zeros(size(ws_bw));
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
  W=c.edge_weights(e,1)/c.edge_weights(e,2); % avg weight on edge e
  for p=1:numel(c.edge_x_coords{e})
    ey=c.edge_x_coords{e}(p); ex=c.edge_y_coords{e}(p);
    if ey==3 && ex==10
      disp(e); % hold on; plot(10,3,'x');
    end
    sf_wt(ey,ex)=max(W,sf_wt(ey,ex));
  end
  v1=c.vertices(c.edges(e,1),:);
  v2=c.vertices(c.edges(e,2),:);
  sf_wt(v1(1),v1(2))=max(W,sf_wt(v1(1),v1(2)));
  sf_wt(v2(1),v2(2))=max(W,sf_wt(v2(1),v2(2)));
end % for e - edge index
end % create_finest_partition

% ----------------------------------------------------------------------
function w = computeWeights(x,y,spxPatch,model,opts,rg,nTreeNodes,nTreesEval,p,ind)
% get 4 patches in leaves using .ind
x1=ceil(((x+p(3))-opts.imWidth)/opts.stride)+rg; % rg<=x1<=w1, for w1 see edgesDetectMex.cpp
y1=ceil(((y+p(1))-opts.imWidth)/opts.stride)+rg; % rg<=y1<=h1
assert((x1==ceil(x/2)) && (y1==ceil(y/2)));
indSz=size(ind);
if y1 > indSz(1) || x1 > indSz(2)
  disp({y1,x1});
end
ids=double(ind(y1,x1,:)); % indices come from cpp and are 0-based
treeIds=uint32(floor(ids./nTreeNodes)+1);
leafIds=uint32(mod(ids,nTreeNodes)+1);
w=zeros(nTreesEval,1);
for k=1:nTreesEval
  treeId=treeIds(:,:,k); leafId=leafIds(:,:,k);
  assert(~model.child(leafId,treeId)); % TODO add this to assertion (when also saving patches in forest) && ~isempty(model.patches{leafId,treeId}));
  hs=model.seg(:,:,leafId,treeId); %T{treeId}.hs(:,:,leafId); % best segmentation
  w(k)=patchDistance(spxPatch,hs);
end
end % computeWeights

% ----------------------------------------------------------------------
function d = patchDistance(spx,seg)
p=false;
if p
  initFig(); im(spx);
  initFig(); im(seg);
end
% 2 options for inputs - bdry or seg
% 2 options for distance metric - the original "crude" approximation or VPR
% d=VPR(spx2bdry01(spx),seg2bdry01(seg));
d=VPR(spx2seg(spx),seg);
% d=CPD(spx2bdry01(spx),seg2bdry01(seg));
% d=CPD(spx2seg(spx),seg);
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
bdry=spx2bdry01(patch);
labels2=bwlabel(clean_watersheds(super_contour_4c(bdry))==0,8);
patch=uint8(labels2(2:2:end, 2:2:end));
end

% ----------------------------------------------------------------------
function patch = seg2bdry01(patch)
% convert the seg to be 0-1 boundary location
patch=gradientMag(single(patch))>.01;
end

% ----------------------------------------------------------------------
function d = CPD(patch1,patch2)
% CPD - a crude patch distance metric
% after Dollar patch comparison while training a structured decision tree
nSamples=256;
persistent cache; w=size(patch1,1); assert(size(patch1,2)==w); % w=16
% is1, is2 - indices for simultaneous lookup in the segm patch
if (~isempty(cache) && cache{1}==w), [~,is1,is2]=deal(cache{:}); else
  % compute all possible lookup inds for w x w patches
  is=1:w^4; is1=floor((is-1)/w/w); is2=is-is1*w*w; is1=is1+1;
  mask=is2>is1; is1=is1(mask); is2=is2(mask); cache={w,is1,is2};
end
% compute nSegs binary codes zs of length nSamples
nSamples=min(nSamples,length(is1));
% sample 256 of the 32640 unique pixel pairs in a 16 x 16 seg mask
kp=randperm(length(is1),nSamples); is1=is1(kp); is2=is2(kp);
ps={patch1,patch2};
nPs=length(ps);
ms=false(nPs,nSamples);
for k=1:nPs, ms(k,:)=ps{k}(is1)==ps{k}(is2); end;
% assert(nPs==2);
d=sum(~xor(ms(1,:),ms(2,:)))/nSamples;
end % patchDistance

% ----------------------------------------------------------------------
function [ucmF,ucmS] = weightedContours2ucm(pb, fmt, finestPartFun)
% TODO copy-pasted from contours2ucm.m
if nargin<2, fmt = 'imageSize'; end;

if ~strcmp(fmt,'imageSize') && ~strcmp(fmt,'doubleSize'),
  error('possible values for fmt are: imageSize and doubleSize');
end

% create finest partition and transfer contour strength
[ws_wt,sf_wt] = finestPartFun(pb);
% TODO inspect pixel values at (47,89) in pb, and in the two finest partitions:
% ws_wt(47,89) and sf_wt(47,89)
[ucmF,ucmS]=pb2ucm(ws_wt,sf_wt,fmt);
end

% ----------------------------------------------------------------------
function [ucmF, ucmS] = pb2ucm(ws_wt,sf_wt,fmt)
% prepare pb for ucm
ws_wt2 = double(super_contour_4c(ws_wt)); sf_wt2 = double(super_contour_4c(sf_wt));
ws_wt2 = clean_watersheds(ws_wt2);
labels2 = bwlabel(ws_wt2 == 0, 8);
labels = labels2(2:2:end, 2:2:end) - 1; % labels begin at 0 in mex file.

ws_wt2=hedge(ws_wt2); sf_wt2=hedge(sf_wt2);

% compute ucm with mean pb.
ucmF=pb2ucmDo(ws_wt2,labels,fmt);
ucmS=pb2ucmDo(sf_wt2,labels,fmt);
end

% ----------------------------------------------------------------------
function a = hedge(a)
a(end+1, :) = a(end, :);
a(:, end+1) = a(:, end);
end

% ----------------------------------------------------------------------
function ucm = pb2ucmDo(wt2, labels, fmt)
try
  super_ucm = double(ucm_mean_pb(wt2,labels));
catch err
  rethrow(err);
end

% output
super_ucm = normalize_output(super_ucm); % ojo

if strcmp(fmt,'doubleSize'),
  ucm = super_ucm;
else
  ucm = super_ucm(3:2:end, 3:2:end);
end
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

% ----------------------------------------------------------------------
function [ws_clean] = clean_watersheds(ws)
% remove artifacts created by non-thin watersheds (2x2 blocks) that produce
% isolated pixels in super_contour

ws_clean = ws;

c = bwmorph(ws_clean == 0, 'clean', inf);

artifacts = ( c==0 & ws_clean==0 );
R = regionprops(bwlabel(artifacts), 'PixelList');

for r = 1 : numel(R),
  xc = R(r).PixelList(1,2);
  yc = R(r).PixelList(1,1);
  
  vec = [ max(ws_clean(xc-2, yc-1), ws_clean(xc-1, yc-2)) ...
    max(ws_clean(xc+2, yc-1), ws_clean(xc+1, yc-2)) ...
    max(ws_clean(xc+2, yc+1), ws_clean(xc+1, yc+2)) ...
    max(ws_clean(xc-2, yc+1), ws_clean(xc-1, yc+2)) ];
  
  [nd,id] = min(vec);
  switch id,
    case 1,
      if ws_clean(xc-2, yc-1) < ws_clean(xc-1, yc-2),
        ws_clean(xc, yc-1) = 0;
        ws_clean(xc-1, yc) = vec(1);
      else
        ws_clean(xc, yc-1) = vec(1);
        ws_clean(xc-1, yc) = 0;
        
      end
      ws_clean(xc-1, yc-1) = vec(1);
    case 2,
      if ws_clean(xc+2, yc-1) < ws_clean(xc+1, yc-2),
        ws_clean(xc, yc-1) = 0;
        ws_clean(xc+1, yc) = vec(2);
      else
        ws_clean(xc, yc-1) = vec(2);
        ws_clean(xc+1, yc) = 0;
      end
      ws_clean(xc+1, yc-1) = vec(2);
      
    case 3,
      if ws_clean(xc+2, yc+1) < ws_clean(xc+1, yc+2),
        ws_clean(xc, yc+1) = 0;
        ws_clean(xc+1, yc) = vec(3);
      else
        ws_clean(xc, yc+1) = vec(3);
        ws_clean(xc+1, yc) = 0;
      end
      ws_clean(xc+1, yc+1) = vec(3);
    case 4,
      if ws_clean(xc-2, yc+1) < ws_clean(xc-1, yc+2),
        ws_clean(xc, yc+1) = 0;
        ws_clean(xc-1, yc) = vec(4);
      else
        ws_clean(xc, yc+1) = vec(4);
        ws_clean(xc-1, yc) = 0;
      end
      ws_clean(xc-1, yc+1) = vec(4);
  end
end
end

% ----------------------------------------------------------------------
function [pb_norm] = normalize_output(pb)
% map ucm values to [0 1] with sigmoid
% learned on BSDS
[tx, ty] = size(pb);
beta = [-2.7487; 11.1189];
pb_norm = pb(:);
x = [ones(size(pb_norm)) pb_norm]';
pb_norm = 1 ./ (1 + (exp(-x'*beta)));
pb_norm = (pb_norm - 0.0602) / (1 - 0.0602);
pb_norm=min(1,max(0,pb_norm));
pb_norm = reshape(pb_norm, [tx ty]);
end
