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
%   .imDir      - [] directory of dataset - images
%   .resDir     . [] directory for the computed output
%   .outType    - ['seg'] type of output; 'edge', 'seg', 'ucm' or 'sPb'
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
  'nThresh',99, 'imDir','REQ', 'gtDir', [], 'resDir','REQ', 'outType','seg',...
  'stride',[], 'nTreesEval',[], 'multiscale',[], 'pDistr',{{'type','parfor'}}
  };
p=getPrmDflt(varargin,dfs,1);
if( ischar(model) ), model=load(model); model=model.model; end
if( ~isempty(p.stride) ), model.opts.stride=p.stride; end
if( ~isempty(p.nTreesEval) ), model.opts.nTreesEval=p.nTreesEval; end
if( ~isempty(p.multiscale) ), model.opts.multiscale=p.multiscale; end

imDir=p.imDir; assert(exist(imDir,'dir')==7);
gtDir=p.gtDir; % only for the oracle case
resDir=p.resDir;
outType=p.outType;

% get input image ids
ids_=Listacrossfolders(imDir,'jpg',1); ids_={ids_.name}; n=length(ids_);
ids=repmat(struct('video','','name',''),1,n);
for i=1:n
  sp=strsplit(ids_{i},filesep); nSp=length(sp);
  if nSp==2 % input is video frames (each video in its own directory)
    ids(i).video=sp{1};
    ids(i).name=sp{2};
  else
    ids(i).video='';
    ids(i).name=ids_{i};
    if nSp>1, warning('Unexpected directory structure.'); end
  end; ids(i).name=ids(i).name(1:end-4); % remove filename extension
end

% detect edges (and output a seg or a ucm)
if ~exist(resDir,'dir'), mkdir(resDir); end; do=false(1,n);
for i=1:n, do(i)=~existOutput(resDir,ids(i)); end
do=find(do); m=length(do);
parfor i=1:m, id=ids(do(i));%#ok<PFBNS>
  if ~exist(fullfile(resDir,id.video),'dir'), mkdir(fullfile(resDir,id.video)); end;
  imFile=fullfile(imDir,id.video,[id.name '.jpg']);
  I=imread(imFile);
  % function for loading the ground truth segmentations in case of 'oracle'
  gt_fcn=@() load_segmentations(get_video_filename(gtDir,id,'.mat'));
  detection=detect(outType,I,model,gt_fcn);
  writeDetection(outType,detection,resDir,id);
end
end

% ----------------------------------------------------------------------
function exists = existOutput(resDir,id)
% check the existance of an output file with an extension .mat, .png or .bmp
exists = exist(get_video_filename(resDir,id,'.mat'),'file') ||...
  exist(get_video_filename(resDir,id,'.png'),'file') ||...
  exist(get_video_filename(resDir,id,'.bmp'),'file');
end

% ----------------------------------------------------------------------
function d = detect(outType,I,model,gt_fcn)
fmt='doubleSize';
switch outType
  case 'edge'
    d=edgesDetect(I,model);
  case 'edgeContours'
    d=edgesDetectOnContours(I,model);
  case 'seg'
    d=detectSeg(I,model);
  case 'ucm'
    d=detectUcm(I,model,fmt);
  case 'sPb'
    d=structuredEdgeSPb(I,model,fmt);
  case 'voteUcm'
    % assert(model.opts.nms); % TODO DRY! .nms option neglected, since I don't use the edgesDetect
    % TODO rather than hardcoding the patch_score_fcn, choose here
    d=ucm_weighted(I,model,'greedy_merge',fmt,false,[]);
  case 'oracle'
    assert(logical(exist('gt_fcn','var')));
    d=ucm_weighted(I,model,'greedy_merge',fmt,false,[],gt_fcn());
  otherwise
    warning('Unexpected output type. No output created.');
end
end

% ----------------------------------------------------------------------
function writeDetection(outType,detection,resDir,id)
switch outType
  case {'edge','edgeContours'}
    % probability of boundary (pb)
    imwrite(uint8(detection*255),get_video_filename(resDir,id,'.png'));
  otherwise
    f=matfile(get_video_filename(resDir,id,'.mat'),'Writable',true);
    switch outType
      case 'seg'
        % watershed - oversegmentation
        f.segs={Uintconv(detection)};
      otherwise
        % super-ucm (double-sized) - as we will use it for regions benchmark
        f.ucm2=detection;
    end
end
end

% ----------------------------------------------------------------------
function ws = detectSeg(I,model)
% TODO why non-maximum suppression breaks the watershed?
E=edgesDetect(I,model);
% run vanilla watershed, which is an (over-)seg
ws=watershed(E);
end

% ----------------------------------------------------------------------
function ucm2 = detectUcm(I,model,fmt)
E=edgesDetect(I,model);
ucm2=contours2ucm(E,fmt);
end

% ----------------------------------------------------------------------
function ucm2 = gPbOwtUcm(I,fmt)
% the original algorithm that uses oriented gradient (in 8 angular directions)
gPb_orient=globalPb(I);
ucm2=contours2ucm(gPb_orient,fmt);
end

% ----------------------------------------------------------------------
function fn = get_video_filename(dirA,id,ext)
fn=fullfile(dirA,id.video,[id.name ext]);
end
