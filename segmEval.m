function [ODS,OIS,AP] = segmEval( model, varargin )
% Evaluate structured forest edge detector on VSB100.
%
% For an introductory tutorial please see edgesDemo.m.
% 
% USAGE
%  [ODS,OIS,AP] = segmEval( model, parameters )
%
% INPUTS
%  model      - structured edge model trained with edgesTrain
%  parameters - parameters (struct or name/value pairs)
%   .nThresh    - [99] number of thresholds for evaluation
%   .cleanup    - [0] if true delete temporary files
%   .show       - [0] figure for displaying results (or 0 - none)
%   .modelDir   - [] directory for storing models
%   .dsDir      - [] directory of dataset
%   .name       - [''] name to append to evaluation
%   .stride     - [] stride at which to compute edges
%   .nTreesEval - [] number of trees to evaluate per location
%   .multiscale - [] if true run multiscale edge detector
%   .pDistr     - [{'type','parfor'}] parameters for fevalDistr
%
% OUTPUTS
%  ODS        - standard error measure on BSDS500
%  OIS        - standard error measure on BSDS500
%  AP         - standard error measure on BSDS500
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
dfs={'nThresh',99, 'cleanup',0, 'show',3, ...
  'modelDir',[], 'dsDir','REQ', 'name','VSB100', 'stride',[], ...
  'nTreesEval',[], 'multiscale',[], 'pDistr',{{'type','parfor'}} };
dataType='test';
p=getPrmDflt(varargin,dfs,1);
if( ischar(model) ), model=load(model); model=model.model; end
if( isempty(p.modelDir )), p.modelDir=model.opts.modelDir; end
% if( isempty(p.dsDir )), p.dsDir=model.opts.dsDir; end % TODO: provide a
% meaningful default
if( ~isempty(p.stride) ), model.opts.stride=p.stride; end
if( ~isempty(p.nTreesEval) ), model.opts.nTreesEval=p.nTreesEval; end
if( ~isempty(p.multiscale) ), model.opts.multiscale=p.multiscale; end
p.modelDir = fullfile(p.modelDir, [dataType filesep]);

% eval on either validation set or test set
imgDir = fullfile(p.dsDir, 'Images/');
depDir = [p.dsDir '/depth/' dataType '/']; % TODO remove
gtDir = fullfile(p.dsDir, 'Groundtruth/');
% evalDir = '/BS/kostadinova/work/video_segm/models/test/modelFinalVSB100-eval';
evalDir = [p.modelDir model.opts.modelFnm p.name '-eval/'];
% resDir = '/BS/kostadinova/work/video_segm/models/test/modelFinalVSB100';
resDir = [p.modelDir model.opts.modelFnm p.name '/'];
assert(exist(imgDir,'dir')==7); assert(exist(gtDir,'dir')==7);

% if evaluation exists collect results and display
if(exist([evalDir '/eval_bdry.txt'],'file'))
  [ODS,~,~,~,OIS,~,~,AP]=collect_eval_bdry(evalDir);
  fprintf('ODS=%.3f OIS=%.3f AP=%.3f\n',ODS,OIS,AP);
  if( p.show ), plot_eval(evalDir,'r'); end; return;
end

% get image ids
ids_=Listacrossfolders(imgDir, 'jpg', 1); ids_={ids_.name}; n=length(ids_);
ids = repmat(struct('video', '', 'name', ''), 1, n);
for i=1:n
    str = strsplit(ids_{i}, filesep);
    ids(i).video=str{1};
    ids(i).name = str{2}(1:end-4); 
end

% % get image ids
% video_ids=dir(imgDir); video_ids={video_ids.name}; vsz=length(video_ids);
% 
% ids=dir([imgDir video_ids filesep '*.jpg']); ids={ids.name}; n=length(ids);
% for i=1:n, ids{i}=ids{i}(1:end-4); end

% detect edges
if(~exist(resDir,'dir')), mkdir(resDir); end; do=false(1,n);
for i=1:n, do(i)=~exist([resDir ids(i).video filesep ids(i).name '.png'],'file'); end
do=find(do); m=length(do); rgbd=model.opts.rgbd; model.opts.nms=1;
parfor i=1:m, id=ids(do(i)); %#ok<PFBNS>
  I = imread([imgDir id.video filesep id.name '.jpg']);
  D=[]; if(rgbd), D=single(imread([depDir id.video filesep id.name '.png']))/1e4; end
  if(rgbd==1), I=D; elseif(rgbd==2), I=cat(3,single(I)/255,D); end
  E = edgesDetect(I,model);
  % TODO run watershed here, or within the edgesDetect
  if (~exist([resDir id.video], 'dir')), mkdir([resDir id.video]); end;
  imwrite(uint8(E*255),[resDir id.video filesep id.name '.png']);
end

% perform evaluation on each image (Linux only, slow)
if(ispc), error('Evaluation code runs on Linux ONLY.'); end
do=false(1,n); jobs=cell(1,n);
for i=1:n, do(i)=~exist([evalDir ids(i).video '_' ids(i).name '_ev1.txt'],'file'); end
for i=1:n, id_=ids(i); id = [id_.video filesep id_.name]; jobs{i}={[resDir id '.png'],...
    [gtDir id '.mat'],[evalDir id_.video '_' id_.name '_ev1.txt'],p.nThresh}; end
if(~exist(evalDir,'dir')), mkdir(evalDir); end
fevalDistr('evaluation_bdry_image',jobs(do),p.pDistr{:});

% collect results and display
[ODS,~,~,~,OIS,~,~,AP]=collect_eval_bdry(evalDir);
fprintf('ODS=%.3f OIS=%.3f AP=%.3f\n',ODS,OIS,AP);
if( p.show ), plot_eval(evalDir,'r'); end
if( p.cleanup ), delete([evalDir '/*_ev1.txt']);
  delete([evalDir '/eval_bdry_img.txt']);
  delete([evalDir '/eval_bdry_thr.txt']);
  delete([resDir '/*.png']); rmdir(resDir);
end

end
