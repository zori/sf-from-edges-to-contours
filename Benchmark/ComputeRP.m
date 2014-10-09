function [output,fhs]=ComputeRP(varargin)
% Computes recall and precision for images or videos and plots the curves for
% the corresponding metrics
%
% OUTPUTS
%  output         - structure summarising the evaluation results
%  fhs            - array of figure handles to the plots
%
% Fabio Galasso
% February 2014
%
% modified by Zornitsa Kostadinova
% Jun 2014

bms=benchmarkMetrics();
dfs={...
  'path',pwd...                 % path to `dirR'
  'dirR','tttttSegm',...        % directory (relative) that contains the directories `Images', `Groundtruth' and `Ucm2' (computed results)
  'outDirR',[],...              % The default directory in dirR is defined in the function Benchmarkcreateoutimvid
  'tempConsistency',true,...    % true for videos TODO do this automatically - we know whether a dataset is images or videos
  'justavideo',[],...
  'metrics',bms{end},...        % could be a cell, e.g. {'bdry','regpr'}
  'nthresh',5,...               % number of thresholds (hierarchical levels to include) for evaluating the ucm
  'plotStyle',{'r'},...         % plot style of curves (color, marker, line width, etc.)
  'superposePlot',false,...     % superpose RP curves; true - new curves are added to the same graph; false - a new graph is initialized
  'confirmDel',false,...        % TODO is this interactive (if true) form useful
  'minNumIms',0,...             % number of images to wait for starting computation (0 means no wait)
  'useParfor',false...          % parallelize if sufficient memory
  };

opts=getPrmDflt(varargin,dfs,1);
path_=opts.path;
dirR=opts.dirR;
outDirR=opts.outDirR;
minNumIms=opts.minNumIms;

if (~isstruct(path_))
    tmp=path_; clear path_; path_.benchmark=tmp; clear tmp;
end

%Assign input directory names and check existance of folders
onlyassignnames=true;
[~,imgDir,gtDir,inDir,isvalid] = Benchmarkcreatedirsimvid(path_, dirR, onlyassignnames);
%imgDir images (for name listing), gtDir ground truth, inDir ucm2, outDirR output
if (~isvalid)
    fprintf('Some Directories are not existing\n');
    return;
end

%Check existance of output directory and request confirmation of deletion
onlyassignnames=true;
[dirA,outDirA,isvalid] = Benchmarkcreateoutimvid(path_, dirR, onlyassignnames, outDirR); %#ok<ASGLU>
if ( isvalid )
    if (opts.confirmDel)
        theanswer = input('Remove previous output? [ 1 , 0 (default) ] ');
    else
        theanswer=0;
    end
    if ( (~isempty(theanswer)) && (theanswer==1) )
        Removetheoutputimvid(path_,dirR,outDirR);
        isvalid=false;
    end
end
iids=Listacrossfolders(imgDir,'jpg',Inf);
if ~isvalid && ~isempty(iids)
    [dirA,outDirA,isvalid] = Benchmarkcreateoutimvid(path_, dirR, [], outDirR); %#ok<ASGLU>
end

%Wait minNumIms for processing
if (minNumIms>0)
    while(numel(iids)<minNumIms)
        pause(10);
        iids=Listacrossfolders(imgDir,'jpg',Inf);
    end
    fprintf('All images are in the directory\n');
end
fprintf('%d images are in the folder (and first-level subfolders)\n',numel(iids));

bmOpts=opts; % used are nthresh, metrics, tempConsistency, justavideo, useParfor
bmOpts.imgDir=imgDir;
bmOpts.gtDir=gtDir;
bmOpts.inDir=inDir;
bmOpts.outDirA=outDirA;

timeBmSegmEval = tic;
if (isvalid)
    Benchmarksegmevalparallel(bmOpts);
end
toc(timeBmSegmEval);

timeBmEvalStats = tic;
if (isvalid)
    Benchmarkevalstatsparallel(bmOpts);
end
toc(timeBmEvalStats);

[output,fhs]=Plotsegmeval(outDirA,opts.superposePlot,opts.plotStyle);

% rmdir(dirA,'s')
% rmdir(outDirA,'s')
