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
  'nThresh',99, 'imDir','REQ', 'gtDir', 'REQ', ...
  'resDir', 'REQ', 'stride',[], ...
  'nTreesEval',[], 'multiscale',[], 'pDistr',{{'type','parfor'}}
  };
p=getPrmDflt(varargin,dfs,1);
if( ischar(model) ), model=load(model); model=model.model; end
if( ~isempty(p.stride) ), model.opts.stride=p.stride; end
if( ~isempty(p.nTreesEval) ), model.opts.nTreesEval=p.nTreesEval; end
if( ~isempty(p.multiscale) ), model.opts.multiscale=p.multiscale; end

imDir=p.imDir; assert(exist(imDir,'dir')==7);
gtDir=p.gtDir; assert(exist(gtDir,'dir')==7);
resDir=p.resDir;

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
if(~exist(resDir,'dir')), mkdir(resDir); end; do=false(1,n);
for i=1:n, do(i)=~exist([resDir ids(i).video filesep ids(i).name '.png'],'file'); end
do=find(do);
detect('sPb', model,imDir,resDir,ids,do);
end

function detect(outType, model, imDir, resDir, ids, do)
switch outType
  case 'edge'
    detectEdge(model,imDir,resDir,ids,do);
  case 'segs'
    detectSegs(model,imDir,resDir,ids,do);
  case 'ucm'
    detectUcm(model,imDir,resDir,ids,do);
  case 'sPb'
    detectSPb(model,imDir,resDir,ids,do);
  otherwise
    warning('Unexpected output type. No output created.');
end
end

% ----------------------------------------------------------------------
function detectEdge(model, imDir, resDir, ids, do)
m=length(do);
model.opts.nms=1;
parfor i=1:m, id=ids(do(i)); %#ok<PFBNS>
  imFile=fullfile(imDir,id.video,[id.name '.jpg']);
  I=imread(imFile);
  E=edgesDetect(I,model);
  if (~exist(fullfile(resDir,id.video),'dir')), mkdir(fullfile(resDir,id.video)); end;
  imwrite(uint8(E*255),fullfile(resDir,id.video,[id.name '.png'])); % save probability of boundary (pb)
end
end

% ----------------------------------------------------------------------
function detectSegs(model, imDir, resDir, ids, do)
m=length(do);
% TODO why non-maximum suppression breaks the watershed?
% model.opts.nms=1;
outCell=cell(1,m);
parfor i=1:m, id=ids(do(i)); %#ok<PFBNS>
  imFile=fullfile(imDir,id.video,[id.name '.jpg']);
  I=imread(imFile);
  E=edgesDetect(I,model);
  if (~exist(fullfile(resDir,id.video),'dir')), mkdir(fullfile(resDir,id.video)); end;
  % run vanilla watershed and save the (over-)seg
  ws=watershed(E);  
  outCell{i}=struct( ...
    'file', fullfile(resDir,id.video,[id.name '.mat']), ...
    'segs', Uintconv(ws));
end

% TODO can this be done inside the above parfor loop
for i=1:m
	segs{1}=outCell{i}.segs; %#ok<NASGU>
  save(outCell{i}.file,'segs');
end
end

% ----------------------------------------------------------------------
function detectUcm(model, imDir, resDir, ids, do)
% ucm on top of the watershed
m=length(do);
% TODO why non-maximum suppression breaks the watershed?
% model.opts.nms=1;
outCell=cell(1,m);
parfor i=1:m, id=ids(do(i)); %#ok<PFBNS>
  imFile=fullfile(imDir,id.video,[id.name '.jpg']);
  I=imread(imFile);
  E=edgesDetect(I,model);
  if (~exist(fullfile(resDir,id.video),'dir')), mkdir(fullfile(resDir,id.video)); end;
  % compute a (double-sized) ucm - as we will use it for regions benchmark
  ucm2=contours2ucm(double(E)/max(E(:)),'doubleSize');
  outCell{i}=struct( ...
    'file', fullfile(resDir,id.video,[id.name '.mat']), ...
    'ucm2', ucm2);
end

for i=1:m
  ucm2=outCell{i}.ucm2; %#ok<NASGU>
  save(outCell{i}.file,'ucm2');
end
end

% ----------------------------------------------------------------------
function detectSPb(model, imDir, resDir, ids, do)
% detection is done using the SF output as an input to the sPb globalization
% step from Arbelaez et. al.
% slow detection
m=length(do);
% TODO why non-maximum suppression breaks the watershed?
% model.opts.nms=1;
outCell=cell(1,m);
parfor i=1:m, id=ids(do(i)); %#ok<PFBNS>
  imFile=fullfile(imDir,id.video,[id.name '.jpg']);
  I=imread(imFile);
  E=edgesDetect(I,model);
  if (~exist(fullfile(resDir,id.video),'dir')), mkdir(fullfile(resDir,id.video)); end;
  ucm=contours2ucm(double(E)/max(E(:)),'imageSize');
  [SF_gPb_orient, ~, ~] = globalPb(imFile,'',1.0,ucm);
  SF_S=max(SF_gPb_orient,[],3);
  % compute a (double-sized) ucm - as we will use it for regions benchmark
  ucm2=contours2ucm(SF_S,'doubleSize');
  outCell{i}=struct( ...
    'file', fullfile(resDir,id.video,[id.name '.mat']), ...
    'ucm2', ucm2);
end

for i=1:m
  ucm2=outCell{i}.ucm2; %#ok<NASGU>
  save(outCell{i}.file,'ucm2');
end
end
