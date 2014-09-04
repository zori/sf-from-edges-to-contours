function Benchmarkevalstatsparallel(varargin)
% Fabio Galasso
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
  'metrics',bms{end},...
  'tempConsistency',true,...    % true for videos TODO do this automatically - we know whether a dataset is images or videos
  'justavideo',[],...
  };

opts=getPrmDflt(varargin,dfs,1);
gtDir=opts.gtDir;
inDir=opts.inDir;
outDirA=opts.outDirA;
metrics=opts.metrics;
tempConsistency=opts.tempConsistency;
justavideo=opts.justavideo;

%Check if the requested metrics are already computed
yettoprocess=false;
if ( (any(strcmp(metrics,'lengthsncl'))) || (any(strcmp(metrics,'all'))) )
    fname = fullfile(outDirA, 'eval_nclustersstats_thr.txt');
    yettoprocess=yettoprocess|(~(length(dir(fname))==1));
end
if (~yettoprocess)
    fprintf('Image/video benchmarks already processed\n');
    return
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



inds=Listacrossfolders(inDir,'mat',Inf); %List .mat files in Ucm2
iids=Listacrossfolders(opts.imgDir,'jpg',Inf);

[encimagevideo,encisvideo]=Collectimagevideowithnames(iids,tempConsistency);
fprintf('Encountered %d videos / images\n',numel(encimagevideo));
fprintf('Evaluating images/frames length statistics (out of %d):',numel(encimagevideo));
parfor i = 1:numel(encimagevideo)
    fprintf(' %d', i);
    % if analyze one video
    if ~isempty(justavideo) && ~strcmp(encimagevideo{i}.videoimagenamewithunderscores,justavideo) % A policy for images may be introduced based on (tempConsistency)
        continue;
    end
 
    %Retrieve image / video variables
    videodetected=encisvideo(i);
    videoimagename=encimagevideo{i}.videoimagename;
    nframes=encimagevideo{i}.nframes;
    fnames=encimagevideo{i}.fnames;
    videoimagenamewithunderscores=encimagevideo{i}.videoimagenamewithunderscores;

    evFile8 = fullfile(outDirA, strcat(videoimagenamewithunderscores, '_ev8.txt')); %length and nclusters
    if (~isempty(dir(evFile8))), continue; end
    

    
    %Prepare gtFile
    if (videodetected)
        gtFile=cell(1,nframes); for k=1:nframes, gtFile{k} = fullfile(gtDir, strcat(fnames{k}, '.mat')); end %Not currently used
    else
        gtFile = fullfile(gtDir, strcat(videoimagename, '.mat'));
    end
    %Prepare inFile (either all segs or the single files)
    inFile=Prepareinfile(videodetected,videoimagename,inDir,inds);
    
    
    
    %Evaluate video statistics
    if ( (any(strcmp(metrics,'lengthsncl'))) || (any(strcmp(metrics,'all'))) )
        Evaluatesegmstat(inFile, gtFile, evFile8, opts.nthresh, metrics, excludeth, offsetgt);
    end
end
fprintf('\n');



%% collect results
if ( (any(strcmp(metrics,'lengthsncl'))) || (any(strcmp(metrics,'all'))) )
    Collectevalaluatestat(outDirA);
end



%% clean up
delete(sprintf('%s/*_ev8.txt', outDirA));



