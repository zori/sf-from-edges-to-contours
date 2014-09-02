function Benchmarkevalstatsparallel(imgDir, gtDir, inDir, outDir, nthresh, maxDist, thinpb, bmetrics, considervideos, justavideo)
% Fabio Galasso
% August 2014

if (~exist('justavideo','var'))
    justavideo=[];
end
if (isempty(justavideo))
    analyzeonevideo=false;
else
    analyzeonevideo=true;
end
if ( (~exist('considervideos','var')) || (isempty(considervideos)) )
    considervideos=true;
end
if ( (~exist('bmetrics','var')) || (isempty(bmetrics)) )
    bmetrics={'all'}; %bmetrics={'lengthsncl','all'}
end
if ( (~exist('thinpb','var')) || (isempty(thinpb)) )
    thinpb=true;
end
if ( (~exist('maxDist','var')) || (isempty(maxDist)) )
    maxDist=0.0075;
end
if ( (~exist('nthresh','var')) || (isempty(nthresh)) )
    nthresh=99;
end



%Check if the requested metrics are already computed
yettoprocess=false;
if ( (any(strcmp(bmetrics,'lengthsncl'))) || (any(strcmp(bmetrics,'all'))) )
    fname = fullfile(outDir, 'eval_nclustersstats_thr.txt');
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
iids=Listacrossfolders(imgDir,'jpg',Inf); % iids = dir(fullfile(imgDir,'*.jpg'));

[encimagevideo,encisvideo]=Collectimagevideowithnames(iids,considervideos);
fprintf('Encountered %d videos / images\n',numel(encimagevideo));
fprintf('Evaluating images/frames length statistics (out of %d):',numel(encimagevideo));
parfor i = 1:numel(encimagevideo)
    fprintf(' %d', i);
    
    if ( (analyzeonevideo) && (~strcmp(encimagevideo{i}.videoimagenamewithunderscores,justavideo)) ) % A policy for images may be introduced based on (considervideos)
        continue;
    end
 
    %Retrieve image / video variables
    videodetected=encisvideo(i);
    videoimagename=encimagevideo{i}.videoimagename;
    nframes=encimagevideo{i}.nframes;
    fnames=encimagevideo{i}.fnames;
    videoimagenamewithunderscores=encimagevideo{i}.videoimagenamewithunderscores;

    evFile8 = fullfile(outDir, strcat(videoimagenamewithunderscores, '_ev8.txt')); %length and nclusters
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
    if ( (any(strcmp(bmetrics,'lengthsncl'))) || (any(strcmp(bmetrics,'all'))) )
        Evaluatesegmstat(inFile, gtFile, evFile8, nthresh, bmetrics, excludeth, offsetgt);
    end
end
fprintf('\n');



%% collect results
if ( (any(strcmp(bmetrics,'lengthsncl'))) || (any(strcmp(bmetrics,'all'))) )
    Collectevalaluatestat(outDir);
end



%% clean up
delete(sprintf('%s/*_ev8.txt', outDir));



