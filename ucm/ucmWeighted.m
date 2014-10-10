% Zornitsa Kostadinova
% Jul 2014
% 8.3.0.532 (R2014a)
function ucm = ucmWeighted(I,model,fmt,T)
% function ucm = ucmWeighted(I,model,fmt,T)
% creates a ucm of an image, that is weighted based on the patches in the leaves of a
% decision forest
%
% INPUTS
%  I            - image
%  model        - structured decision forest (SF)
%  fmt          - output format; 'imageSize' (default) or 'doubleSize'
%  T            - individual trees of the SF (for visualisation only - processLocation)
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
wsPadded=imPad(double(watershed(E)),p,'symmetric');
coords2forestLocationFun=@(x,y) coords2forestLocation(x,y,ind,opts,p,length(model.fids));
getTreePatchesFun=@(x,y) getTreePatches(x,y,coords2forestLocationFun,model,nTreesEval);
processLocationFun=@(x,y,w) processLocation(x,y,model,T,IPadded,opts,ri,rg,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,wsPadded,contours2ucm(E),w);
cfp=@(pb) create_finest_partition_voting(pb,wsPadded,ri,getTreePatchesFun,processLocationFun);
ucm=contours2ucm(E,fmt,cfp);
end

% ----------------------------------------------------------------------
function sf_wt = create_finest_partition_voting(pb,wsPadded,ri,getTreePatchesFun, processLocationFun)
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
  l=fitLine(v1,v2,ri);
  for p=1:numel(c.edge_x_coords{e})
    % NOTE x and y are swapped here (in the output from fit_contour)
    % the correct way is (for an image of dimensions h x w x 3)
    % first coord, in [1,h], is y, second coord, in [1,w], is x
    ey=c.edge_x_coords{e}(p); ex=c.edge_y_coords{e}(p);
    x=ex+ri; y=ey+ri; r=ri/2; % adjust patch dimensions
    % wsPatch=cropPatch(wsPadded,x,y,r); % crop from the padded watershed, to make sure a superpixels patch can always be cropped % ri/2 == rg
    wsPatch=createWsPatch(x,y,r,l);
    hs=getTreePatchesFun(ex,ey);
    w=computeWeights(wsPatch,hs);
    f=false;
    if f
      % close all;
      initFig(1); im(wsPadded); hold on; plot(ex+ri,ey+ri,'rx','MarkerSize',12);
      initFig(); im(wsPatch);
      processLocationFun(ex,ey,w); % this needs a model with the patches saved
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
function l = fitLine(v1,v2,ri)
% adjust indices for the padded superpixelised image
v1=v1+ri;v2=v2+ri;
l=createLine([v1(2),v1(1)],[v2(2),v2(1)]);
end

% ----------------------------------------------------------------------
function wsPatch = createWsPatch(x,y,r,l)
% these are the 4 end pnts of the (previously cropped) ri x ri patch
ul=[x-r+1 y-r+1]; ur=[x+r y-r+1]; % fst the x coords, then the y
ll=[x-r+1 y+r];   lr=[x+r y+r];
sq=[ul; ll; lr; ur];
ints=intersectLinePolygon(l, sq);
%     if ~all(size(ints)==[2 2])
%       disp(ints);
%     end
% assert(all(size(ints)==[2 2]));
ints=ints-[ul;ul]; % go to the coord system of a ri x ri patch
ints=floor(ints')+1; % TODO correct?
ints=num2cell(ints);
[lx,ly]=bresenham(ints{:});
wsPatch=zeros(2*r);
idx=sub2ind(size(wsPatch),ly,lx);
wsPatch(idx)=1;
% TODO fst=bdry2seg(spx);
% spx is a bdry
wsPatch=watershed(wsPatch,4);
wsPatch(wsPatch==0)=1; % TODO fix
end

% ----------------------------------------------------------------------
function hs = getTreePatches(x,y,coords2forestLocationFun,model,nTreesEval)
% get 4 patches in leaves using ind
[treeIds,leafIds]=coords2forestLocationFun(x,y);
segs=model.seg;
hs=uint8(zeros(size(segs,1),size(segs,2),nTreesEval));
for k=1:nTreesEval
  treeId=treeIds(:,:,k); leafId=leafIds(:,:,k);
  % assert(~model.child(leafId,treeId));
  hs(:,:,k)=segs(:,:,leafId,treeId); %T{treeId}.hs(:,:,leafId); % best segmentation
end
end

% ----------------------------------------------------------------------
function w = computeWeights(wsPatch,hs)
nTreesEval=size(hs,3);
w=zeros(nTreesEval,1);
for k=1:nTreesEval
  w(k)=patchScore(wsPatch,hs(:,:,k));
end
end % computeWeights

% ----------------------------------------------------------------------
function w = patchScore(spx,seg)
% return a score in [0,1] for the similarity of the superpixel and the
% segmentation patch; 0 - no similarity; 1 - maximal similarity
% fst=spx2seg(spx); % type: uint8
fst=spx;
snd=seg; % type uint8
w=VPR(fst,snd);
% w=compareSegs(fst,snd);
end

% ----------------------------------------------------------------------
function w = patchScoreDeprecated(spx,seg)
% 2 options for inputs - bdry or seg
% bdrys01={spx2bdry01(spx) seg2bdry01(seg)}; % type: logical
% bdrys12={spx2bdry01(spx)+1 seg2bdry01(seg)+1}; % type: double
segs={spx2seg(spx) seg}; % type: uint8
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
patch=uint8(reshape(patch,sz));
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
