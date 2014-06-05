function Benchmarkevalstats(imgDir, gtDir, inDir, outDir, nthresh, maxDist, thinpb, bmetrics, considervideos, justavideo)
% Fabio Galasso
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
encvideos=cell(0);
fprintf('Evaluating images/frames length statistics (out of %d):',numel(iids));
for i = 1:numel(iids)
    fprintf(' %d', i);
    
    if (considervideos)
        [videodetected,videoimagename,fnames,nframes]=Detectvideo(iids,i); %,fnumber
        videoimagenamewithunderscores=strrep(videoimagename, filesep, '_');
    else
        videodetected=false;
    end
    if (~videodetected)
        videoimagename=iids(i).name(1:end-4);
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
    
    evFile8 = fullfile(outDir, strcat(videoimagenamewithunderscores, '_ev8.txt')); %length and nclusters

    if (~isempty(dir(evFile8))), continue; end



    if (videodetected)
        gtFile=cell(1,nframes); for k=1:nframes, gtFile{k} = fullfile(gtDir, strcat(fnames{k}, '.mat')); end %Not currently used
        
        [matvideodetected,matvideoname,matfnames,matnframes,matfnumber]=Detectvideo(inds,[],videoimagename); %#ok<ASGLU>
        if (~matvideodetected)
            fprintf('Video detected for images but not for Ucm2 mat files\n'); return;
        end
        
        inFile=cell(1,matnframes); %inFile and gtFile are cell arrays in the case of videos
        for k=1:matnframes
            inFile{k} = fullfile(inDir, strcat(matfnames{k}, 'segs.mat')); %For backward compatibility the file segs is checked first
            if (exist(inFile{k},'file')==0)
                inFile{k} = fullfile(inDir, strcat(matfnames{k}, '.mat'));
            end
        end
        %Order the files, important for the computation of length statistics
        [ordfnumbers,ordindex]=sort(matfnumber,'ascend'); %#ok<ASGLU>
        inFile(1:end)=inFile(ordindex);
        
        %Compose allsegs name
        allsegsvideoimagename=Getallsegsvideoname(videoimagename);
        allsegfile=fullfile(inDir, ['allsegs',allsegsvideoimagename,'.mat']); % allsegfile=fullfile(inDir, ['allsegs',videoimagename,'.mat']);
        
        %Check existance of allsegs<sequence>.mat, replaced to inFile instead
        if (exist(allsegfile,'file')~=0)
            inFile=allsegfile;
        end
    else
        inFile = fullfile(inDir, strcat(videoimagename, 'segs.mat')); %For backward compatibility the file segs is checked first
        if (exist(inFile,'file')==0)
            inFile = fullfile(inDir, strcat(videoimagename, '.mat'));
        end
        gtFile = fullfile(gtDir, strcat(videoimagename, '.mat'));
    end
    
    
    
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



