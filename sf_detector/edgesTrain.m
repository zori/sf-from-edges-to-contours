function model = edgesTrain( varargin )
% Train structured edge detector.
%
% For an introductory tutorial please see edgesDemo.m.
%
% USAGE
%  opts = edgesTrain()
%  model = edgesTrain( opts )
%
% INPUTS
%  opts       - parameters (struct or name/value pairs)
%   (1) model parameters:
%   .imWidth    - [32] width of image patches, i.e. x
%   .gtWidth    - [16] width of ground truth patches, i.e. labels; y
%   .nEdgeBins  - [1] number of edge orientation bins for output
%   (2) tree parameters:
%   .nPos       - [1e5] number of positive patches per tree
%   .nNeg       - [1e5] number of negative patches per tree
%   .nImgs      - [inf] maximum number of images to use for training
%   .nTrees     - [8] number of trees in forest to train
%   .fracFtrs   - [1/2] fraction of features to use to train each tree
%   .minCount   - [1] minimum number of data points to allow split
%   .minChild   - [8] minimum number of data points allowed at child nodes
%   .maxDepth   - [64] maximum depth of tree
%   .discretize - ['pca'] options include 'pca' and 'kmeans', i.e.
%                         discretization type
%   .nSamples   - [256] number of samples for clustering structured labels, i.e.
%                       m (size of intermediate space Z in the reduced mapping Y->Z)
%   .nClasses   - [2] number of classes (clusters) for binary splits
%   .split      - ['gini'] options include 'gini', 'entropy' and 'twoing',
%                          i.e. information gain
%   (3) feature parameters:
%   .nOrients   - [4] number of orientations per gradient scale
%   .grdSmooth  - [0] radius for image gradient smoothing (using convTri)
%                     TODO find in paper
%   .chnSmooth  - [2] radius for reg channel smoothing (using convTri), i.e.
%                     channel blur - triangle filter; for pixel lookups;
%                     'reg' stands for 'regular'
%   .simSmooth  - [8] radius for sim channel smoothing (using convTri),
%                     i.e. self-similarity blur (large traingle blur to
%                     each channel); for computing pairwise differences
%                     later;
%                     'sim' stands for 'similarity'
%   .normRad    - [4] gradient normalization radius (see gradientMag)
%   .shrink     - [2] amount to shrink channels, i.e. channel downsample
%   .nCells     - [5] number of self similarity cells, i.e. grid cells
%   (4) detection parameters (can be altered after training):
%   TODO Detection parameters are not used here; figure out how to
%       incorporate these options in detection instead and remove them from here.
%   .stride     - [2] stride at which to compute edges
%   .multiscale - [1] if true run multiscale edge detector
%   .nTreesEval - [4] number of trees to evaluate per location, i.e. nTrees/2
%   .nThreads   - [4] number of threads for evaluation of trees
%   .nms        - [0] if true apply non-maximum suppression to edges
%   (5) other parameters:
%   .seed       - [1] seed for random stream (for reproducibility)
%   .useParfor  - [0] if true train trees in parallel (memory intensive)
%   .modelDir   - ['models/'] target directory for storing models
%   .modelFnm   - ['model'] model filename
%   .dsDir      - [] location of training dataset, default is BSDS500
%   .savePs     - [false] whether to save the patches in the leaves
%
% OUTPUTS
%  model      - trained structured edge detector w the following fields
%   .opts       - input parameters and constants
%   .thrs       - [nNodes x nTrees] threshold corresponding to each fid
%   .fids       - [nNodes x nTrees] feature ids for each node
%   .child      - [nNodes x nTrees] index of child for each node
%   .count      - [nNodes x nTrees] number of data points at each node
%   .depth      - [nNodes x nTrees] depth of each node
%   .eBins      - data structure for storing all node edge maps;
%                 0-based "flattened" patch [16 x 16] index of the location of
%                 boundaries;
%                 [5947957 <= nNodes*nTrees*gtWidth*gtWidth x 1 uint16],
%                 values in [0;255]
%   .eBnds      - data structure for storing all node edge maps;
%                 for every node of every tree, index of beginning of boundary
%                 in model.eBins;
%                 [642489x1 uint32], ascendingly sorted values in [0;5947957]
%
% EXAMPLE
%
% See also edgesDemo, edgesChns, edgesDetect, forestTrain
%
% Structured Edge Detection Toolbox      Version 1.0
% Copyright 2013 Piotr Dollar.  [pdollar-at-microsoft.com]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the MSR-LA Full Rights License [see license.txt]

% get default parameters
dfs={'imWidth',32, 'gtWidth',16, 'nEdgeBins',1, 'nPos',1e5, 'nNeg',1e5, ...
  'nImgs',inf, 'nTrees',8, 'fracFtrs',1/2, 'minCount',1, 'minChild',8, ...
  'maxDepth',64, 'discretize','pca', 'nSamples',256, 'nClasses',2, ...
  'split','gini', 'nOrients',4, 'grdSmooth',0, 'chnSmooth',2, ...
  'simSmooth',8, 'normRad',4, 'shrink',2, 'nCells',5, ...
  'stride',2, 'multiscale',1, 'nTreesEval',4, 'nThreads',4, 'nms',0, ...
  'seed',1, 'useParfor',false, 'modelDir','models/', 'modelFnm','model', ...
  'dsDir','/BS/kostadinova/work/video_segm_evaluation/BSDS500/train/','savePs',false};
opts=getPrmDflt(varargin,dfs,1);
if(nargin==0), model=opts; return; end

% if forest exists load it and return
forestDir=fullfile(opts.modelDir, 'forest/');
forestFn=fullfile(forestDir, opts.modelFnm);
if(exist([forestFn '.mat'], 'file'))
  load([forestFn '.mat']); return; end

% compute constants and store in opts
nTrees=opts.nTrees; nCells=opts.nCells; shrink=opts.shrink;
opts.nPos=round(opts.nPos); opts.nNeg=round(opts.nNeg);
opts.nTreesEval=min(opts.nTreesEval,nTrees);
opts.stride=max(opts.stride,shrink);
imWidth=opts.imWidth; gtWidth=opts.gtWidth;
imWidth=round(max(gtWidth,imWidth)/shrink/2)*shrink*2;
opts.imWidth=imWidth; opts.gtWidth=gtWidth;
nChnsGrad=(opts.nOrients+1)*2; nChnsColor=3;
nChns=nChnsGrad+nChnsColor; opts.nChns=nChns;
opts.nChnFtrs=imWidth*imWidth*nChns/shrink/shrink; % 3328=32x32x13/4
opts.nSimFtrs=(nCells*nCells)*(nCells*nCells-1)/2*nChns; % 3900=13x300
opts.nTotFtrs=opts.nChnFtrs + opts.nSimFtrs; % 7228
disp(opts);

% generate stream for reproducibility of model
stream=RandStream('mrg32k3a','Seed',opts.seed);

% train nTrees random trees (can be trained with parfor if enough memory)
if(opts.useParfor), parfor i=1:nTrees, trainTree(opts,stream,i); end
else for i=1:nTrees, trainTree(opts,stream,i); end; end

% accumulate trees and merge into final model
treeFn=fullfile(opts.modelDir, 'tree', [opts.modelFnm '_tree']);
for i=1:nTrees
  t=load([treeFn int2str2(i,3) '.mat'],'tree'); t=t.tree;
  if(i==1), trees=t(ones(1,nTrees)); else trees(i)=t; end
end
nNodes=0; % max number of nodes in the trees
for i=1:nTrees, nNodes=max(nNodes,size(trees(i).fids,1)); end
model.opts=opts;
model.thrs=zeros(nNodes,nTrees,'single');
Z=zeros(nNodes,nTrees,'uint32');
model.fids=Z; model.child=Z; model.count=Z; model.depth=Z;
model.seg=ones(gtWidth,gtWidth,nNodes,nTrees,'uint8');
% model.patches=cell(nNodes,nTrees); % this is equivalent to model.seg and
% therefore not needed
model.eBins=zeros(nNodes*nTrees*gtWidth*gtWidth,1,'uint16');
model.eBnds=Z; nEdgeBins=opts.nEdgeBins; k=0;
for i=1:nTrees, tree=trees(i); nNodes1=size(tree.fids,1);
  model.fids(1:nNodes1,i)=tree.fids; model.thrs(1:nNodes1,i)=tree.thrs;
  model.child(1:nNodes1,i)=tree.child; model.count(1:nNodes1,i)=tree.count;
  model.depth(1:nNodes1,i)=tree.depth;
  % model.patches(1:nNodes1,i)=tree.hs(1:nNodes1); % TODO add this when
  % saving the patches in the forest (will I need to use them?)
  model.seg(:,:,1:nNodes1,i)=tree.hs;
  % store compact representation of sparse binary edge patches
  for j=1:nNodes
    if(j>nNodes1 || tree.child(j)), E=0; else
      E=seg2bdry_edge_bins(tree.hs(:,:,j),nEdgeBins); E=E(1:4,1:4); end % nEdgeBins=1 % change here: only store if the upper left corner is a bdry
    eBins=uint32(find(E)-1); k1=k+length(eBins);
    model.eBins(k+1:k1)=eBins; k=k1; model.eBnds(j,i)=k; % (nodeNumber,treeIndex)=eBinsIndex of beginning of boundary
  end
end
if(0), model.segMax=squeeze(max(max(model.seg))); end
model.eBnds=[0; model.eBnds(:)]; % add sentinel value to begin indexing and "flatten" eBnds matrix to a vector % (model.eBnds-1)/8 is nNodes 
model.eBins=model.eBins(1:k); % here k is the total amount of boundary pixels in the segmentation of every node of every tree in the model
% save model
if(~exist(forestDir,'dir')), mkdir(forestDir); end
save([forestFn '.mat'], 'model', '-v7.3');
end % edgesTrain

% ----------------------------------------------------------------------
function E = seg2bdry_edge_bins( S, nEdgeBins )
% Convert segmentation to binary edge map (optionally quantized by angle).
E=gradientMag(single(S))>.01; if(nEdgeBins==1), return; end
% if (# orientation bins) > 1, quantize by angle
[~,O]=gradientMag(convTri(single(S),2));
O=mod(round(O/pi*nEdgeBins)/nEdgeBins*pi,pi);
p=2; O=imPad(O(1+p:end-p,1+p:end-p),p,'replicate');
E=gradientHist(single(E),O,1,nEdgeBins)>.01; % spatial bin size=1, number of orientation bins=nEdgeBins
end

% ----------------------------------------------------------------------
function trainTree( opts, stream, treeInd )
% Train a single tree in forest model.

% location of ground truth
trnImDir=fullfile(opts.dsDir, 'Images/');
trnGtDir=fullfile(opts.dsDir, 'Groundtruth/');
imIds=Listacrossfolders(trnImDir, 'jpg', 1); imIds={imIds.name};
nIms=length(imIds); for i=1:nIms, imIds{i}=imIds{i}(1:end-4); end

% extract commonly used options
savePs=opts.savePs;
imWidth=opts.imWidth; imRadius=imWidth/2;
gtWidth=opts.gtWidth; gtRadius=gtWidth/2;
nChns=opts.nChns; nTotFtrs=opts.nTotFtrs;
nPos=opts.nPos; nNeg=opts.nNeg; shrink=opts.shrink;

% finalize setup
treeDir=fullfile(opts.modelDir, 'tree/');
treeFn=fullfile(treeDir, [opts.modelFnm '_tree']);
if(exist([treeFn int2str2(treeInd,3) '.mat'],'file')), return; end
fprintf('\n-------------------------------------------\n');
fprintf('Training tree %d of %d\n',treeInd,opts.nTrees); tStart=clock;

% set global stream to stream with given substream (will undo at end)
streamOrig=RandStream.getGlobalStream();
set(stream,'Substream',treeInd);
RandStream.setGlobalStream( stream );

% collect positive and negative patches and compute features
fids=sort(randperm(nTotFtrs,round(nTotFtrs*opts.fracFtrs))); % for this tree, sample half (3614) out of nTotFtrs possible features
nTrainPatches=nPos+nNeg; % 10^6
nIms=min(nIms,opts.nImgs);
ftrs=zeros(nTrainPatches,length(fids),'single');
if savePs, patches=zeros(imWidth,imWidth,3,nTrainPatches,'uint8'); end % images patches at locations sampled for training
labels=zeros(gtWidth,gtWidth,nTrainPatches,'uint8');
k=0; % # total samples (features and labels) sampled and computed; k<=nTrainPatches
tid=ticStatus('Collecting data',1,1);
for i=1:nIms
  % get image and compute channels
  gt=load([trnGtDir imIds{i} '.mat']); gt=gt.groundTruth;
  I=imread([trnImDir imIds{i} '.jpg']); sz=size(I);
  p=zeros(1,4); p([2 4])=mod(4-mod(sz(1:2),4),4);
  if(any(p)), I=imPad(I,p,'symmetric'); end
  [chnsReg,chnsSim]=edgesChns(I,opts); % regular and self-similarity channels, downsampled to 180x320
  % sample positive and negative locations
  nGt=length(gt);
  k1=0; % # locations sampled from all gt segs for this image
  k1_ub=ceil(nTrainPatches/nIms/nGt)*nGt; % upper bound of k1, for preallocation
  % xy is k1 x 3 matrix with the locations samples for the image
  % each row is [x y gtId], gtId - id of the gt for the sample
  xy=zeros(k1_ub,3);
  B=false(sz(1),sz(2)); % mask for sampling locations
  B(shrink:shrink:end,shrink:shrink:end)=1;
  B([1:imRadius end-imRadius:end],:)=0; B(:,[1:imRadius end-imRadius:end])=0;
  for j=1:nGt
    M=gt{j}.Boundaries; M(bwdist(M)<gtRadius)=1; % TODO why is the mask called B and the boundary M
    % sample positive locations
    [y,x]=find(M.*B); k2=min(length(y),ceil(nPos/nIms/nGt)); % k2 - # positive locations sampled for this gt seg
    rp=randperm(length(y),k2); y=y(rp); x=x(rp);
    xy(k1+1:k1+k2,:)=[x y ones(k2,1)*j]; k1=k1+k2;
    % sample negative locations
    [y,x]=find(~M.*B); k2=min(length(y),ceil(nNeg/nIms/nGt));
    rp=randperm(length(y),k2); y=y(rp); x=x(rp);
    xy(k1+1:k1+k2,:)=[x y ones(k2,1)*j]; k1=k1+k2;
  end
  if(k1>size(ftrs,1)-k), k1=size(ftrs,1)-k; xy=xy(1:k1,:); end
  % crop patches and ground truth labels
  % psReg - regular patches, psSim - similarity patches
  % 'image' patches are cropped from chnsReg and chnsSim
  % gt label patches are cropped from the gt seg that the location was sampled from
  psReg=zeros(imWidth/shrink,imWidth/shrink,nChns,k1,'single'); psSim=psReg;
  lbls=zeros(gtWidth,gtWidth,k1,'uint8');
  if savePs, ptchs=zeros(imWidth,imWidth,3,k1,'uint8'); end
  ri=imRadius; rs=imRadius/shrink; rg=gtRadius;
  for j=1:k1, xy1=xy(j,:); xy2=xy1/shrink;
    % for every sample location crop all the regular and self-similarity channels
    psReg(:,:,:,j)=chnsReg(xy2(2)-rs+1:xy2(2)+rs,xy2(1)-rs+1:xy2(1)+rs,:);
    psSim(:,:,:,j)=chnsSim(xy2(2)-rs+1:xy2(2)+rs,xy2(1)-rs+1:xy2(1)+rs,:);
    t=gt{xy1(3)}.Segmentation(xy1(2)-rg+1:xy1(2)+rg,xy1(1)-rg+1:xy1(1)+rg); % 16x16 gt seg
    % labels are unique up to a permutation, so relabel, e.g. a segment with
    % labels '3' and '6' to have the labels '1' and '2' (use smallest
    % integers) - more compact representation
    [~,~,t]=unique(t); lbls(:,:,j)=reshape(t,gtWidth,gtWidth);
    if savePs, ptchs(:,:,:,j)=I(xy1(2)-ri+1:xy1(2)+ri,xy1(1)-ri+1:xy1(1)+ri,:); end % 32x32 rgb img patch
  end
  if(0), figure(1); montage2(squeeze(psReg(:,:,1,:))); drawnow; end % visualize the first output channel of the regular patches
  if(0), figure(2); montage2(lbls(:,:,:)); drawnow; end % visualize gt labels
  % compute features and store features and labels
  ftrs1=[reshape(psReg,[],k1)' stComputeSimFtrs(psSim,opts)];
  ftrs(k+1:k+k1,:)=ftrs1(:,fids);
  labels(:,:,k+1:k+k1)=lbls;
  if savePs, patches(:,:,:,k+1:k+k1)=ptchs; end
  k=k+k1; if(k==size(ftrs,1)), tocStatus(tid,1); break; end
  tocStatus(tid,i/nIms);
end % for i=1:nImgs
if(k<size(ftrs,1))
  ftrs=ftrs(1:k,:);
  labels=labels(:,:,1:k);
  if savePs, patches=patches(:,:,:,1:k); end
end

% train structured edge classifier (random decision tree)
pTree=struct('minCount',opts.minCount, 'minChild',opts.minChild, ...
  'maxDepth',opts.maxDepth, 'H',opts.nClasses, 'split',opts.split);
% labels as a 16 x 16 x k matrix, where k=10^6, (256MB); as a cell 368MB
labels=mat2cell2(labels,[1 1 k]);
pTree.discretize=@(hs,H) discretize(hs,H,opts.nSamples,opts.discretize);
tree=forestTrain(ftrs,labels,pTree); % train each tree separately
if savePs
  % get the data indices and record the image and segmentation ground truth
  % patches in the tree
  K=length(tree.fids);
  imgPs=cell(K,1); % img patches
  segPs=cell(K,1); % seg patches; the indices that correspond to internal (non-leaf) nodes will be empty % keep intermediate segs (previously discarded as only a best seg is chosen)
  
  % only saving patches at "small" leaves
  leavesIds=find(~tree.child)';
  for l=leavesIds
    if tree.count(l) > 40, continue; end
    imgPs{l}=patches(:,:,:,tree.dids{l});
    segPs{l}=labels(tree.dids{l});
    if(0)
      figure(1); montage2(imgPs{l},struct('hasChn', true));
      figure(2); montage2(cell2array(segPs{l}));
    end
  end
  tree.imgPs=imgPs; tree.segPs=segPs;
  tree=rmfield(tree,'dids');
end % if savePs
tree.hs=cell2array(tree.hs);
% fids are in [1;7228], 'adjust' them so tree.fids are in [0;7227] because mex
% (cpp) code works with 0-based indices
tree.fids(tree.child>0)=fids(tree.fids(tree.child>0)+1)-1;
if(~exist(treeDir,'dir')), mkdir(treeDir); end
save([treeFn int2str2(treeInd,3) '.mat'],'tree', '-v7.3'); e=etime(clock,tStart);
fprintf('Training of tree %d complete (time=%.1fs).\n',treeInd,e);
RandStream.setGlobalStream( streamOrig );
end % trainTree

% ----------------------------------------------------------------------
function ftrs = stComputeSimFtrs( chns, opts )
% Compute self-similarity features (order must be compatible w mex file).
w=opts.imWidth/opts.shrink; n=opts.nCells; if(n==0), ftrs=[]; return; end
nSimFtrs=opts.nSimFtrs; nChns=opts.nChns; m=size(chns,4);
inds=round(w/n/2); inds=round((1:n)*(w+2*inds-1)/(n+1)-inds+1);
chns=reshape(chns(inds,inds,:,:),n*n,nChns,m);
ftrs=zeros(nSimFtrs/nChns,nChns,m,'single');
k=0; for i=1:n*n-1, k1=n*n-i; i1=ones(1,k1)*i;
  ftrs(k+1:k+k1,:,:)=chns(i1,:,:)-chns((1:k1)+i,:,:); k=k+k1; end
ftrs=reshape(ftrs,nSimFtrs,m)';
end

% ----------------------------------------------------------------------
function [hs,seg,inds] = discretize( segs, nClasses, nSamples, type )
% Convert a set of segmentations into a set of labels in [1,nClasses].
% % function mapping structured to class labels
% % this function will have nSamples and type injected (currying):
% % [hsClass,hBest] = discretize(hsStructured,H)
%
% INPUTS
%   segs       - 1 x 1 x nSegs a set of segs (structured labels)
%   nClasses   - [2] number of classes ('k' in paper)
%   nSamples   - [256] size of intermediate space Z ('m' in paper)
%   type       - ['pca'] string, type of discretization, 'pca' or 'kmeans'
%
% OUTPUTS
%   hs         - nSegs x 1 a set of class labels
%   seg        - most representative (closest to mean) seg among the input ones segs
%   inds       - indices of segments sorted in decreasing distance from the
%                medoid (most representative segment)
%

persistent cache; w=size(segs{1},1); assert(size(segs{1},2)==w); % w=16
% is1, is2 - indices for simultaneous lookup in the seg patch
if (~isempty(cache) && cache{1}==w), [~,is1,is2]=deal(cache{:}); else
  % compute all possible lookup inds for w x w patches
  is=1:w^4; is1=floor((is-1)/w/w); is2=is-is1*w*w; is1=is1+1;
  mask=is2>is1; is1=is1(mask); is2=is2(mask); cache={w,is1,is2};
end
% compute nSegs binary codes zs of length nSamples
nSegs=length(segs); nSamples=min(nSamples,length(is1));
% sample 256 of the 32640 unique pixel pairs in a 16 x 16 seg mask
kp=randperm(length(is1),nSamples); is1=is1(kp); is2=is2(kp);
zs=false(nSegs,nSamples); % for root node 10^6 x 256
for i=1:nSegs, zs(i,:)=segs{i}(is1)==segs{i}(is2); end
% keep only those columns (sampled pairwise pixel lookup results) in which some of the seg patches differ
zs=bsxfun(@minus,zs,sum(zs,1)/nSegs); zs=zs(:,any(zs,1));
if(isempty(zs)), hs=ones(nSegs,1,'uint32'); seg=segs{1}; inds=1:nSegs; return; end % all segs identical (up to a perm)
% find most representative seg (closest to mean)
[~,inds]=sort(sum(zs.*zs,2)); seg=segs{inds(1)};
% apply PCA to reduce dimensionality of zs
U=pca(zs'); d=min(5,size(U,2)); zs=zs*U(:,1:d);
% discretize zs by clustering or discretizing pca dimensions
d=min(d,floor(log2(nClasses))); hs=zeros(nSegs,1);
for i=1:d, hs=hs+(zs(:,i)<0)*2^(i-1); end
[~,~,hs]=unique(hs); hs=uint32(hs);
if(strcmpi(type,'kmeans'))
  nClasses1=max(hs); C=zs(1:nClasses1,:);
  for i=1:nClasses1, C(i,:)=mean(zs(hs==i,:),1); end
  hs=uint32(kmeans2(zs,nClasses,'C0',C,'nIter',1));
end
% optionally display different types of hs
for i=1:0, figure(i); montage2(cell2array(segs(hs==i))); end % displays all seg patches from class i
end % discretize
