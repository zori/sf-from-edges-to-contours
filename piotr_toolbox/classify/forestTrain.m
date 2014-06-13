function forest = forestTrain( data, hs, varargin )
% Train random forest classifier.
%
% Dimensions:
%  M - number trees
%  F - number features
%  N - number input vectors
%  H - number classes
%
% USAGE
%  forest = forestTrain( data, hs, [varargin] )
%
% INPUTS
%  data     - [NxF] N feature vectors, each of length F
%  hs       - [Nx1] or {Nx1} target output labels in [1,H]
%  varargin - additional params (struct or name/value pairs)
%   .M          - [1] number of trees to train
%   .H          - [max(hs)] number of classes
%   .N1         - [5*N/M] number of data points for training each tree
%   .F1         - [sqrt(F)] number features to sample for each node split
%   .split      - ['gini'] options include 'gini', 'entropy' and 'twoing'
%   .minCount   - [1] minimum number of data points to allow split
%   .minChild   - [1] minimum number of data points allowed at child nodes
%   .maxDepth   - [64] maximum depth of tree
%   .dWts       - [] weights used for sampling and weighing each data point
%   .fWts       - [] weights used for sampling features
%   .discretize - [] optional function mapping structured to class labels
%                    format: [hsClass,hBest] = discretize(hsStructured,H);
%
% OUTPUTS
% Dimensions:
%  K - number of nodes in the tree
%
%  forest   - learned forest model struct array w the following fields
%             ('tree' has the same structure)
%   .fids     - [Kx1] feature ids for each node, in [0;7227]
%   .thrs     - [Kx1] threshold corresponding to each fid
%   .child    - [Kx1] index of left child for each node, in [0;K-1];
%                     0 - no children
%   .distr    - [KxH] prob distribution at each node
%   .hs       - [Kx1] or {Kx1} most likely label at each node
%   .count    - [Kx1] number of data points at each node
%   .depth    - [Kx1] depth of each node; root has depth 0
%
% EXAMPLE
%  N=10000; H=5; d=2; [xs0,hs0,xs1,hs1]=demoGenData(N,N,H,d,1,1);
%  xs0=single(xs0); xs1=single(xs1);
%  pTrain={'maxDepth',50,'F1',2,'M',150,'minChild',5};
%  tic, forest=forestTrain(xs0,hs0,pTrain{:}); toc
%  hsPr0 = forestApply(xs0,forest);
%  hsPr1 = forestApply(xs1,forest);
%  e0=mean(hsPr0~=hs0); e1=mean(hsPr1~=hs1);
%  fprintf('errors trn=%f tst=%f\n',e0,e1); figure(1);
%  subplot(2,2,1); visualizeData(xs0,2,hs0);
%  subplot(2,2,2); visualizeData(xs0,2,hsPr0);
%  subplot(2,2,3); visualizeData(xs1,2,hs1);
%  subplot(2,2,4); visualizeData(xs1,2,hsPr1);
%
% See also forestApply, fernsClfTrain
%
% Piotr's Image&Video Toolbox      Version 3.24
% Copyright 2013 Piotr Dollar.  [pdollar-at-caltech.edu]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the Simplified BSD License [see external/bsd.txt]

% get additional parameters and fill in remaining parameters
dfs={ 'M',1, 'H',[], 'N1',[], 'F1',[], 'split','gini', 'minCount',1, ...
  'minChild',1, 'maxDepth',64, 'dWts',[], 'fWts',[], 'discretize','' };
[M,H,N1,F1,splitStr,minCount,minChild,maxDepth,dWts,fWts,discretize] = ...
  getPrmDflt(varargin,dfs,1);
[N,F]=size(data); assert(length(hs)==N); discr=~isempty(discretize);
minChild=max(1,minChild); minCount=max([1 minCount minChild]);
if(isempty(H)), H=max(hs); end; assert(discr || all(hs>0 & hs<=H));
if(isempty(N1)), N1=round(5*N/M); end; N1=min(N,N1);
if(isempty(F1)), F1=round(sqrt(F)); end; F1=min(F,F1);
if(isempty(dWts)), dWts=ones(1,N,'single'); end; dWts=dWts/sum(dWts);
if(isempty(fWts)), fWts=ones(1,F,'single'); end; fWts=fWts/sum(fWts);
split=find(strcmpi(splitStr,{'gini','entropy','twoing'}))-1;
if(isempty(split)), error('unknown splitting criteria: %s',splitStr); end

% make sure data has correct types
if(~isa(data,'single')), data=single(data); end
if(~isa(hs,'uint32') && ~discr), hs=uint32(hs); end
if(~isa(fWts,'single')), fWts=single(fWts); end
if(~isa(dWts,'single')), dWts=single(dWts); end

% train M random trees on different subsets of data
prmTree = {H,F1,minCount,minChild,maxDepth,fWts,split,discretize};
for i=1:M
  if(N==N1), data1=data; hs1=hs; dWts1=dWts; else
    d=wswor(dWts,N1,4); data1=data(d,:); hs1=hs(d);
    dWts1=dWts(d); dWts1=dWts1/sum(dWts1);
  end
  tree = treeTrain(data1,hs1,dWts1,prmTree);
  if(i==1), forest=tree(ones(M,1)); else forest(i)=tree; end
end

end

% ----------------------------------------------------------------------
function tree = treeTrain( data, hs, dWts, prmTree )
% Train single random tree.
[H,F1,minCount,minChild,maxDepth,fWts,split,discretize]=deal(prmTree{:});
N=size(data,1); discr=~isempty(discretize);
K_UB=2*N-1; % upper bound of the number of nodes K
thrs=zeros(K_UB,1,'single'); distr=zeros(K_UB,H,'single');
fids=zeros(K_UB,1,'uint32'); child=fids; count=fids; depth=fids;
hsn=cell(K_UB,1); % n stands for 'new'; the (best) seg for each node
dids=cell(K_UB,1); dids{1}=uint32(1:N); % data ids; the root node has all the data
k=1; % current node
K=2; % left child of current node; right child is K+1
while( k < K )
  % get node data and store distribution
  dids1=dids{k}; % dids{k}=[]; % don't delete the ids of data/label for each child
  hs1Segs=hs(dids1); n1=length(hs1Segs); count(k)=n1;
  % discretization is performed independently when training each node and
  % depends on the distribution of labels at a given node
  % hs1 is the set of classes corresponding to hs1Segs
  % hsn{k} - the most representative seg
  if(discr), [hs1,hsn{k}]=feval(discretize,hs1Segs,H); hs1=uint32(hs1); end
  if(discr), assert(all(hs1>0 & hs1<=H)); end; pure=all(hs1(1)==hs1); % pure nodes have all labels the same
  if(~discr), if(pure), distr(k,hs1(1))=1; hsn{k}=hs1(1); else
      distr(k,:)=histc(hs1,1:H)/n1; [~,hsn{k}]=max(distr(k,:)); end; end
  % if pure node or insufficient data don't train split
  if( pure || n1<=minCount || depth(k)>maxDepth ), k=k+1; continue; end
  % train split and continue
  fids1=wswor(fWts,F1,4); % F1 ~ 60, only sample sqrt of the 3614 features
  data1=data(dids1,fids1); [~,order1]=sort(data1); order1=uint32(order1-1);
  [fid,thr,gain]=forestFindThr(data1,hs1,dWts(dids1),order1,H,split); % mex function, see cpp code, split=0 is gini
  fid=fids1(fid); % learnt feature id
  left=data(dids1,fid)<thr; countLeft=nnz(left);
  if( gain>1e-10 && countLeft>=minChild && (n1-countLeft)>=minChild )
    child(k)=K; fids(k)=fid-1; thrs(k)=thr;
    dids{K}=dids1(left); dids{K+1}=dids1(~left); % data ids of left and right child, respectively
    depth(K:K+1)=depth(k)+1; K=K+2;
  end; k=k+1;
end
% create output model struct
Ks=1:K-1;
if(discr), hsn={hsn(Ks)}; else hsn=[hsn{Ks}]'; end
% TODO: only save patches at the leaves
hsAll=cell(K,1); %K_UB,1);
leavesIds=find(~child(Ks));
for l=leavesIds' %k=Ks
  hsAll{l}=hs(dids{l});
  %hsAll{k}=hs(dids{k}); % hsAll 7.5GB
end
% optionally display a few segs
for i=1:0 % K-9:4:K-1
  figure(i); montage2(cell2array(hsAll{i})); % displays all segs from class i
end
tree=struct('fids',fids(Ks),'thrs',thrs(Ks),'child',child(Ks),...
  'distr',distr(Ks,:),'hs',hsn,'patches',{hsAll(Ks)},'count',count(Ks),'depth',depth(Ks));
end % treeTrain

% ----------------------------------------------------------------------
function ids = wswor( prob, N, trials )
% Fast weighted sample without replacement. Alternative to:
%  ids=datasample(1:length(prob),N,'weights',prob,'replace',false);
M=length(prob); assert(N<=M); if(N==M), ids=1:N; return; end
if(all(prob(1)==prob)), ids=randperm(M,N); return; end
cumprob=min([0 cumsum(prob)],1); assert(abs(cumprob(end)-1)<.01);
cumprob(end)=1; [~,ids]=histc(rand(N*trials,1),cumprob);
[s,ord]=sort(ids); K(ord)=[1; diff(s)]~=0; ids=ids(K);
if(length(ids)<N), ids=wswor(cumprob,N,trials*2); end
ids=ids(1:N)';
end
