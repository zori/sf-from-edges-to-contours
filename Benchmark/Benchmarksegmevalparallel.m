function Benchmarksegmevalparallel(varargin)
%
% Run boundary and region benchmarks on dataset.
%
% INPUT
%   imgDir: folder containing original images
%   gtDir:  folder containing ground truth data.
%   inDir:  folder containing segmentation results for all the images in imgDir.
%           Format can be one of the following:
%             - a collection of segmentations in a cell 'segs' stored in a mat file
%             - an ultrametric contour map in 'doubleSize' format, 'ucm2' stored in a mat file with values in [0 1].
%   outDirA:  folder where evaluation results will be stored
%	  nthresh	: Number of points in precision/recall curve.
%   MaxDist : For computing Precision / Recall.
%   thinpb  : option to apply morphological thinning on segmentation
%             boundaries before benchmarking.
%
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
%
% metrics specifies which benchmark metrics should be computed
% metrics={'bdry','3dbdry','regpr','sc','pri','vi','all'}
% all requires computation of all metrics
%
% modified by Fabio Galasso
% August 2014
%
% modified by Zornitsa Kostadinova
% Sep 2014

bms=benchmarkMetrics();
dfs={...
  'imgDir','REQ'...
  'gtDir','REQ'...
  'inDir','REQ'...
  'outDirA','REQ'...
  'nthresh',99,...              % number of thresholds (hierarchical levels to include) for evaluating the ucm
  'maxDist',0.0075...
  'thinpb',true...
  'metrics',bms{end},...
  'tempConsistency',true,...    % true for videos TODO do this automatically - we know whether a dataset is images or videos
  'justavideo',[],...
  'useParfor',false...          % parallelize if sufficient memory
  };

opts=getPrmDflt(varargin,dfs);
gtDir=opts.gtDir;
inDir=opts.inDir;
outDirA=opts.outDirA;
nthresh=opts.nthresh;
maxDist=opts.maxDist;
thinpb=opts.thinpb;
metrics=opts.metrics;
justavideo=opts.justavideo;

%Check if the requested metrics are already computed
yettoprocess=false;
if ( (any(strcmp(metrics,'bdry'))) || (any(strcmp(metrics,'all'))) )
  fname = fullfile(outDirA, 'eval_bdry_globossods.txt');
  yettoprocess=yettoprocess|(~(length(dir(fname))==1));
end
if ( (any(strcmp(metrics,'sc'))) || (any(strcmp(metrics,'all'))) )
  fname = fullfile(outDirA, 'eval_cover.txt');
  yettoprocess=yettoprocess|(~(length(dir(fname))==1));
end
if ( (any(strcmp(metrics,'pri'))) || (any(strcmp(metrics,'vi'))) || (any(strcmp(metrics,'all'))) )
  fname = fullfile(outDirA, 'eval_RI_VOI.txt');
  yettoprocess=yettoprocess|(~(length(dir(fname))==1));
end
if ( (any(strcmp(metrics,'regpr'))) || (any(strcmp(metrics,'all'))) )
  fname = fullfile(outDirA, 'eval_regpr_globalthr.txt');
  yettoprocess=yettoprocess|(~(length(dir(fname))==1));
end
if (~yettoprocess)
  fprintf('Image/video benchmarks already processed\n');
  return
end

[encimagevideo,encisvideo]=Collectimagevideowithnames(Listacrossfolders(opts.imgDir,'jpg',Inf),opts.tempConsistency);
nImgVideo=numel(encimagevideo);
fprintf('Encountered %d videos / images\n',nImgVideo);
fprintf('Evaluating images/frames length statistics (out of %d):',nImgVideo);

% evaluate (can be done with parfor if enough memory)
if opts.useParfor, parfor i=1:nImgVideo, evaluate(i,encimagevideo,encisvideo,gtDir,inDir,outDirA,nthresh,maxDist,thinpb,metrics,justavideo); end
else for i=1:nImgVideo, evaluate(i,encimagevideo,encisvideo,gtDir,inDir,outDirA,nthresh,maxDist,thinpb,metrics,justavideo); end; end
fprintf('\n');

% collect results
if any(strcmp(metrics,'bdry')) || any(strcmp(metrics,'all'))
  Collectevalaluatebdry(outDirA);
end
% if any(strcmp(metrics,'3dbdry')) || any(strcmp(metrics,'all'))
%     Collectevalaluatebdry(outDirA,'5');
% end
if any(strcmp(metrics,'regpr')) || any(strcmp(metrics,'sc')) || any(strcmp(metrics,'pri')) || any(strcmp(metrics,'vi')) || any(strcmp(metrics,'all'))
  Collectevalaluatereg(outDirA);
end

% clean up
delete(sprintf('%s/*_ev1.txt', outDirA));
delete(sprintf('%s/*_ev2.txt', outDirA));
delete(sprintf('%s/*_ev3.txt', outDirA));
delete(sprintf('%s/*_ev4.txt', outDirA));
delete(sprintf('%s/*_ev5.txt', outDirA));
delete(sprintf('%s/*_ev6.txt', outDirA));
end % Benchmarksegmevalparallel

% ----------------------------------------------------------------------
function evaluate(i,encimagevideo,encisvideo,gtDir,inDir,outDirA,nthresh,maxDist,thinpb,metrics,justavideo)
fprintf(' %d', i);
% if analyze one video
if ~isempty(justavideo) && ~strcmp(encimagevideo{i}.videoimagenamewithunderscores,justavideo) % A policy for images may be introduced based on (tempConsistency)
  return;
end

%Retrieve image / video variables
videodetected=encisvideo(i);
videoimagename=encimagevideo{i}.videoimagename;
nframes=encimagevideo{i}.nframes;
fnames=encimagevideo{i}.fnames;
videoimagenamewithunderscores=encimagevideo{i}.videoimagenamewithunderscores;

evFile1 = fullfile(outDirA, strcat(videoimagenamewithunderscores, '_ev1.txt')); %bdry
evFile2 = fullfile(outDirA, strcat(videoimagenamewithunderscores, '_ev2.txt')); %sc
evFile3 = fullfile(outDirA, strcat(videoimagenamewithunderscores, '_ev3.txt')); %sc
evFile4 = fullfile(outDirA, strcat(videoimagenamewithunderscores, '_ev4.txt')); %pri,vi
% evFile5 = fullfile(outDirA, strcat(videoimagenamewithunderscores, '_ev5.txt')); %3dbdry
evFile6 = fullfile(outDirA, strcat(videoimagenamewithunderscores, '_ev6.txt')); %regpr

%Check if the requested metrics for the image/video are already computed
yettoprocess=false;
if ( (any(strcmp(metrics,'bdry'))) || (any(strcmp(metrics,'all'))) )
  yettoprocess=yettoprocess|(isempty(dir(evFile1)));
end
if ( (any(strcmp(metrics,'sc'))) || (any(strcmp(metrics,'all'))) )
  yettoprocess=yettoprocess|(isempty(dir(evFile3)));
end
if ( (any(strcmp(metrics,'pri'))) || (any(strcmp(metrics,'vi'))) || (any(strcmp(metrics,'all'))) )
  yettoprocess=yettoprocess|(isempty(dir(evFile4)));
end
if ( (any(strcmp(metrics,'regpr'))) || (any(strcmp(metrics,'all'))) )
  yettoprocess=yettoprocess|(isempty(dir(evFile6)));
end
if (~yettoprocess), return; end

if (videodetected)
  inFile=cell(1,nframes); %inFile and gtFile are cell arrays in the case of videos
  gtFile=cell(1,nframes);
  for k=1:nframes
    inFile{k} = fullfile(inDir, strcat(fnames{k}, 'segs.mat')); %For backward compatibility the file segs is checked first
    if (exist(inFile{k},'file')==0)
      inFile{k} = fullfile(inDir, strcat(fnames{k}, '.mat'));
    end
    gtFile{k} = fullfile(gtDir, strcat(fnames{k}, '.mat'));
  end
else
  inFile = fullfile(inDir, strcat(videoimagename, 'segs.mat')); %For backward compatibility the file segs is checked first
  if (exist(inFile,'file')==0)
    inFile = fullfile(inDir, strcat(videoimagename, '.mat'));
  end
  gtFile = fullfile(gtDir, strcat(videoimagename, '.mat'));
end

%Exclude some levels from the segs cells
excludeth=[];
if (~isempty(excludeth))
  excludeth %#ok<NOPRT>
end

%Align for ODS metric
ALIGNGT=false;
if (ALIGNGT) %Define this with a search over GT to generalize to all dataset
  offsetgt.min=2; offsetgt.max=6; %offset introduced for the number of GT objects, level two is replicated nGT-offsetgt.max times, level penultimate offsetgt.min-nGT times
else
  offsetgt=[];
end
if (~isempty(offsetgt)), offsetgt, end%#ok<NOPRT>

%Evaluate boundary benchmark
if any(strcmp(metrics,'bdry')) || any(strcmp(metrics,'all'))
  use3dbdry=false;
  Evaluatesegmbdry(inFile,gtFile,evFile1,nthresh,maxDist,thinpb,use3dbdry,excludeth,offsetgt);
end
%Evaluate 3D boundary benchmark
%     if any(strcmp(metrics,'3dbdry')) || any(strcmp(metrics,'all'))
%         use3dbdry=true;
%         Evaluatesegmbdry(inFile,gtFile, evFile5,nthresh,maxDist,thinpb,use3dbdry,excludeth,offsetgt);
%     end
%Evaluate region benchmarks
if any(strcmp(metrics,'regpr')) || any(strcmp(metrics,'sc')) || any(strcmp(metrics,'pri')) || any(strcmp(metrics,'vi')) || any(strcmp(metrics,'all'))
  Evaluatesegmregion(inFile, gtFile, evFile2, evFile3, evFile4, evFile6, nthresh, metrics, excludeth, offsetgt);
end
end
