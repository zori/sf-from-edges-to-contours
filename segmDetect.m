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

imDir=p.imgDir; assert(exist(imDir,'dir')==7);
gtDir=p.gtDir; assert(exist(gtDir,'dir')==7);
resDir=p.resDir;

% get video frames ids
ids_=Listacrossfolders(imDir, 'jpg', 1); ids_={ids_.name}; n=length(ids_);
ids=repmat(struct('video', '', 'name', ''), 1, n);
for i=1:n
  str=strsplit(ids_{i}, filesep);
  ids(i).video=str{1};
  ids(i).name=str{2}(1:end-4);
end

% detect edges (and output a seg)
if(~exist(resDir,'dir')), mkdir(resDir); end; do=false(1,n);
for i=1:n, do(i)=~exist([resDir ids(i).video filesep ids(i).name '.png'],'file'); end
do=find(do); m=length(do);
% % TODO: why non-maximum suppression breaks the watershed?
% model.opts.nms=1;
segsCell=cell(1,m);
parfor i=1:m, id=ids(do(i)); %#ok<PFBNS>
  I=imread([imDir id.video filesep id.name '.jpg']);
  E=edgesDetect(I,model);
  if (~exist([resDir id.video], 'dir')), mkdir([resDir id.video]); end;
  % run vanilla watershed and save the (over-)seg
  ws=watershed(E);
  segsCell{i}=struct( ...
    'file', fullfile(resDir,id.video,[id.name '.mat']), ...
    'segs', Uintconv(ws));
%   imwrite(uint8(E*255), fullfile(resDir, id.video, [id.name '.png'])); % save probability of boundary (pb)
end

% TODO: can this be done inside the above parfor loop
for i=1:m
  segs{1}=segsCell{i}.segs; %#ok<NASGU>
  save(segsCell{i}.file,'segs');
end

end
