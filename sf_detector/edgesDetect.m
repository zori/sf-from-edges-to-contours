function [E,Es,O] = edgesDetect( I, model )
% Detect edges in image.
%
% For an introductory tutorial please see edgesDemo.m.
%
% The following model params may be altered prior to detecting edges:
%  prm = stride, multiscale, nTreesEval, nThreads, nms
% Simply alter model.opts.prm. For example, set model.opts.nms=1 to enable
% non-maximum suppression. See edgesTrain for parameter details.
%
% USAGE
%  [E,Es,O] = edgesDetect( I, model )
%
% INPUTS
%  I          - [h x w x 3] color input image
%  model      - structured edge model trained with edgesTrain
%
% OUTPUTS
%  E          - [h x w] edge probability map
%  Es         - [h x w x nEdgeBins] edge probability maps per orientation
%  O          - [h x w] coarse edge normal orientation (0=left, pi/2=up)
%
% EXAMPLE
%
% See also edgesDemo, edgesTrain, edgesChns
%
% Structured Edge Detection Toolbox      Version 1.0
% Copyright 2013 Piotr Dollar.  [pdollar-at-microsoft.com]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the MSR-LA Full Rights License [see license.txt]

% get parameters
opts=model.opts; opts.nTreesEval=min(opts.nTreesEval,opts.nTrees);
opts.stride=max(opts.stride,opts.shrink); model.opts=opts;

if( opts.multiscale )
  % if multiscale run edgesDetect multiple times
  ss=2.^(-1:1); k=length(ss); siz=size(I);
  model.opts.multiscale=0; model.opts.nms=0; Es=0;
  for i=1:k, s=ss(i); I1=imResample(I,s);
    [~,Es1]=edgesDetect(I1,model);
    Es=Es+imResample(Es1,siz(1:2));
  end; Es=Es/k;
  
else
  % pad image, making divisible by 4
  szOrig=size(I); r=opts.imWidth/2; p=[r r r r];
  p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*r,4),4);
  I=imPad(I,p,'symmetric');
  
  % compute features and apply forest to image
  [chnsReg,chnsSim]=edgesChns( I, opts );
  Es=edgesDetectMex(model,chnsReg,chnsSim); % TODO [Es,inds] and pass inds as output % assert(nargsout<=2)
  
  % normalize and finalize edge maps
  t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval; r=opts.gtWidth/2;
  O=[]; Es=Es(1+r:szOrig(1)+r,1+r:szOrig(2)+r,:)*t; Es=convTri(Es,1);
end

% compute E and O and perform nms
nEdgeBins=opts.nEdgeBins; if(nEdgeBins>1), E=sum(Es,3); else E=Es; end
if(nargout>2 || opts.nms), if(nEdgeBins<=2), O=edgeOrient(E,4); else
    [~,O]=max(Es,[],3); O=single(O-1)*(pi/nEdgeBins); end; end
if(opts.nms), E=edgeNms(E,O,1,5); end
end
