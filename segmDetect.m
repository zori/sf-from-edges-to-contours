function [] = segmDetect( model, varargin )
% Evaluate structured forest edge detector on VSB100.
%
% For an introductory tutorial please see edgesDemo.m.
% 
% USAGE
%  [] = segmDetect( model, parameters )
%
% INPUTS
%  model      - structured edge model trained with edgesTrain
%  parameters - parameters (struct or name/value pairs)
%   .nThresh    - [99] number of thresholds for evaluation
%   .imgDir     - [] directory of dataset - images
%   .gtDir      - [] directory of dataset - groundtruth
%   .stride     - [] stride at which to compute edges
%   .nTreesEval - [] number of trees to evaluate per location
%   .multiscale - [] if true run multiscale edge detector
%   .pDistr     - [{'type','parfor'}] parameters for fevalDistr
%
% OUTPUTS
%
% EXAMPLE
%
% See also edgesDemo, edgesDetect, edgesTrain
% 
% Structured Edge Detection Toolbox      Version 1.0
% Copyright 2013 Piotr Dollar.  [pdollar-at-microsoft.com]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the MSR-LA Full Rights License [see license.txt]

% get default parameters
dfs={
    'nThresh',99, 'imgDir','REQ', 'gtDir', 'REQ', ...
    'resDir', 'REQ', 'stride',[], ...
    'nTreesEval',[], 'multiscale',[], 'pDistr',{{'type','parfor'}}
    };
p=getPrmDflt(varargin,dfs,1);
if( ischar(model) ), model=load(model); model=model.model; end
if( ~isempty(p.stride) ), model.opts.stride=p.stride; end
if( ~isempty(p.nTreesEval) ), model.opts.nTreesEval=p.nTreesEval; end
if( ~isempty(p.multiscale) ), model.opts.multiscale=p.multiscale; end

imgDir = p.imgDir; assert(exist(imgDir,'dir')==7);
gtDir = p.gtDir; assert(exist(gtDir,'dir')==7);
resDir = p.resDir;

% get video frames ids
ids_=Listacrossfolders(imgDir, 'jpg', 1); ids_={ids_.name}; n=length(ids_);
ids = repmat(struct('video', '', 'name', ''), 1, n);
for i=1:n
    str = strsplit(ids_{i}, filesep);
    ids(i).video = str{1};
    ids(i).name = str{2}(1:end-4); 
end

% detect edges
if(~exist(resDir,'dir')), mkdir(resDir); end; do=false(1,n);
for i=1:n, do(i)=~exist([resDir ids(i).video filesep ids(i).name '.png'],'file'); end
do=find(do); m=length(do);
%TODO: why non-maximum suppression breaks the watershed?
%parfor i=1:m, id=ids(do(i)); %#ok<PFBNS>
for i=1:m, id=ids(do(i)); %#ok<PFBNS>
  I = imread([imgDir id.video filesep id.name '.jpg']);
  E = edgesDetect(I,model);
  ws = watershed(E);
  % TODO run watershed here, or within the edgesDetect
  if (~exist([resDir id.video], 'dir')), mkdir([resDir id.video]); end;
  segs{1} = Uintconv(ws);
  save(fullfile(resDir, id.video, [id.name '.mat']),'segs');
  % % save probability of boundary (pb) as a .png file:
  % imwrite(uint8(E*255),[resDir id.video filesep id.name '.png']);
end

end
