function Benchmarksegmeval(imgDir, gtDir, inDir, outDir, nthresh, maxDist, thinpb, bmetrics, considervideos, justavideo)
% Benchmarksegmeval(imgDir, gtDir, inDir, outDir, nthresh, maxDist, thinpb)
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
%   outDir: folder where evaluation results will be stored
%	nthresh	: Number of points in precision/recall curve.
%   MaxDist : For computing Precision / Recall.
%   thinpb  : option to apply morphological thinning on segmentation
%             boundaries before benchmarking.
%
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
%
% bmetrics specifies which benchmark metrics should be computed
% bmetrics={'bdry','3dbdry','regpr','sc','pri','vi','all'}
% all requires computation of all metrics
% 
% modified by Fabio Galasso
% February 2014

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
    bmetrics={'all'};
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
if ( (any(strcmp(bmetrics,'bdry'))) || (any(strcmp(bmetrics,'all'))) )
    fname = fullfile(outDir, 'eval_bdry_globossods.txt');
    yettoprocess=yettoprocess|(~(length(dir(fname))==1));
end
if ( (any(strcmp(bmetrics,'sc'))) || (any(strcmp(bmetrics,'all'))) )
    fname = fullfile(outDir, 'eval_cover.txt');
    yettoprocess=yettoprocess|(~(length(dir(fname))==1));
end
if ( (any(strcmp(bmetrics,'pri'))) || (any(strcmp(bmetrics,'vi'))) || (any(strcmp(bmetrics,'all'))) )
    fname = fullfile(outDir, 'eval_RI_VOI.txt');
    yettoprocess=yettoprocess|(~(length(dir(fname))==1));
end
if ( (any(strcmp(bmetrics,'regpr'))) || (any(strcmp(bmetrics,'all'))) )
    fname = fullfile(outDir, 'eval_regpr_globalthr.txt');
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



iids=Listacrossfolders(imgDir,'jpg',Inf); % iids = dir(fullfile(imgDir,'*.jpg'));
encvideos=cell(0);
fprintf('Evaluating images/frames (out of %d):',numel(iids));
for i = 1:numel(iids)
    fprintf(' %d', i);
    
    if (considervideos)
        [videodetected,videoimagename,fnames,nframes]=Detectvideo(iids,i); % disp(fnames(1))
        videoimagenamewithunderscores=strrep(videoimagename, filesep, '_');
    else
        videodetected=false;
    end
    if (~videodetected)
        videoimagename=iids(i).name(1:end-4); %Remove extension
        videoimagenamewithunderscores=strrep(videoimagename, filesep, '_');
    end
    if (videodetected)
        if (any(strcmp(encvideos,videoimagename))) % The video has already been processed
            continue;
        else
            encvideos{numel(encvideos)+1}=videoimagename;
        end
    end
    
    if ( (analyzeonevideo) && (~strcmp(videoimagenamewithunderscores,justavideo)) ) % A policy for images may be introduced based on (considervideos)
        continue;
    end
    
    evFile1 = fullfile(outDir, strcat(videoimagenamewithunderscores, '_ev1.txt')); %bdry
    evFile2 = fullfile(outDir, strcat(videoimagenamewithunderscores, '_ev2.txt')); %sc
    evFile3 = fullfile(outDir, strcat(videoimagenamewithunderscores, '_ev3.txt')); %sc
    evFile4 = fullfile(outDir, strcat(videoimagenamewithunderscores, '_ev4.txt')); %pri,vi
    evFile5 = fullfile(outDir, strcat(videoimagenamewithunderscores, '_ev5.txt')); %3dbdry
    evFile6 = fullfile(outDir, strcat(videoimagenamewithunderscores, '_ev6.txt')); %regpr

    if (~isempty(dir(evFile4))), continue; end

    
    
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
    
    
    
    %Evaluate boundary benchmark
    if ( (any(strcmp(bmetrics,'bdry'))) || (any(strcmp(bmetrics,'all'))) )
        use3dbdry=false;
        Evaluatesegmbdry(inFile,gtFile, evFile1, nthresh, maxDist, thinpb, use3dbdry, excludeth, offsetgt);
    end
    %Evaluate 3D boundary benchmark
%     if ( (any(strcmp(bmetrics,'3dbdry'))) || (any(strcmp(bmetrics,'all'))) )
%         use3dbdry=true; 
%         Evaluatesegmbdry(inFile,gtFile, evFile5, nthresh, maxDist, thinpb, use3dbdry, excludeth, offsetgt);
%     end
    %Evaluate region benchmarks
    if ( (any(strcmp(bmetrics,'regpr'))) || (any(strcmp(bmetrics,'sc'))) || (any(strcmp(bmetrics,'pri'))) || (any(strcmp(bmetrics,'vi'))) || (any(strcmp(bmetrics,'all'))) )
        Evaluatesegmregion(inFile, gtFile, evFile2, evFile3, evFile4, evFile6, nthresh, bmetrics, excludeth, offsetgt);
    end
end
fprintf('\n');



%% collect results
if ( (any(strcmp(bmetrics,'bdry'))) || (any(strcmp(bmetrics,'all'))) )
    Collectevalaluatebdry(outDir);
end
% if ( (any(strcmp(bmetrics,'3dbdry'))) || (any(strcmp(bmetrics,'all'))) )
%     Collectevalaluatebdry(outDir,'5');
% end
if ( (any(strcmp(bmetrics,'regpr'))) || (any(strcmp(bmetrics,'sc'))) || (any(strcmp(bmetrics,'pri'))) || (any(strcmp(bmetrics,'vi'))) || (any(strcmp(bmetrics,'all'))) )
    Collectevalaluatereg(outDir);
end



%% clean up
delete(sprintf('%s/*_ev1.txt', outDir));
delete(sprintf('%s/*_ev2.txt', outDir));
delete(sprintf('%s/*_ev3.txt', outDir));
delete(sprintf('%s/*_ev4.txt', outDir));
delete(sprintf('%s/*_ev5.txt', outDir));
delete(sprintf('%s/*_ev6.txt', outDir));



