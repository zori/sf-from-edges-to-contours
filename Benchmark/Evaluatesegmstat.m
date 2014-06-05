function [thresh, nclusters, sumlength, sqrsumlength] = Evaluatesegmstat(inFile, gtFile, evFile8, nthresh, bmetrics, excludeth, offsetgt)
% Fabio Galasso
% April 2013

%Note: nsegs in the comments refers to maxseglabs(threshold)
%Note: 0 values should not be used to indicate background. They mean other.
%      E.g. they are not considered for assigment as the best overlapping
%      regions

if (~exist('offsetgt','var')) %only applies if segs is used
    offsetgt=[]; %offset introduced for the number of GT objects, level two is replicated nGT-offsetgt.max times, level penultimate offsetgt.min-nGT times
end
if (~exist('excludeth','var'))
    excludeth=[]; %Numbers indicated (positions in thresh array) are excluded (nthresh is adjusted consequently)
end
if ( (~exist('bmetrics','var')) || (isempty(bmetrics)) )
    bmetrics={'all'}; %'bdry','3dbdry','regpr','sc','pri','vi','all'
end
if ( (~exist('nthresh','var')) || (isempty(nthresh)) )
    nthresh=99;
end

DEBUGVRANGE=false; DONELABEL=true;

if ( (any(strcmp(bmetrics,'lengths'))) || (any(strcmp(bmetrics,'all'))) ), computestatlengths=true; else computestatlengths=false; end

%Transform non cell arrays inFile and gtFile into cell arrays
if (~iscell(gtFile))
    tmpfile=gtFile; clear gtFile; gtFile=cell(1); gtFile{1}=tmpfile;
end
if (~iscell(inFile))
    tmpfile=inFile; clear inFile; inFile=cell(1); inFile{1}=tmpfile;
end

%Allocate number of ground truths
load(gtFile{1});
if (isempty(groundTruth)) %#ok<USENS>
    error(' bad gtFile !');
end
ngts = numel(groundTruth);
if (ngts == 0)
    error(' bad gtFile !');
end

%Compute mean ground truth object number, used for offsetting, this would also count others(0) and outliers(-1)
if ( (~isempty(offsetgt)) && (isstruct(offsetgt)) )
    allgtobjs=cell(1,ngts);
    for ff=1:numel(gtFile)
        load(gtFile{ff});
    
        for i=1:ngts
            if (~isempty(groundTruth{i}))
                allgtobjs{i}=[allgtobjs{i},reshape(unique(groundTruth{i}.Segmentation),1,[])];
            end
        end
    end
    meangtobjs=0;
    for i=1:ngts
        meangtobjs=meangtobjs+numel(unique(allgtobjs{i}));
    end
    meangtobjs=round(meangtobjs/ngts);
end

%Preallocate max n labels for each ground truth segmentation
maxgtlabelsngt=zeros(1,ngts);
for ff=1:numel(gtFile)
    load(gtFile{ff});

    for i=1:ngts
        if (~isempty(groundTruth{i}))
            maxgtlabelsngt(i)=max(maxgtlabelsngt(i),max(groundTruth{i}.Segmentation(:)));
        end
    end
end



%Aggregate allthesegmentations cell array from the different sources
firstpass=true; %labels extracted from ucm2 are supposed to be independent at each frame, so countucm2(t) must be added at each frame (and incremented at each addition)
for ff=1:numel(inFile)
    load(inFile{ff});  % segs or allthesegmentations
    if (exist('ucm2', 'var'))
        ucm = double(ucm2);
        clear ucm2;
    elseif ( (~exist('segs', 'var')) && (~exist('allthesegmentations', 'var')) )
        error('unexpected input in inFile');
    end

    %offset segs, when requested
    if ( (~isempty(offsetgt)) && (isstruct(offsetgt)) )
        if ( (exist('segs', 'var')) && (numel(segs)>1) )
            segs=Offsetthesegs(segs,offsetgt,meangtobjs);
        elseif ( (exist('allthesegmentations', 'var')) && (numel(allthesegmentations)>1) )
            allthesegmentations=Offsetthesegs(allthesegmentations,offsetgt,meangtobjs);
        end
    end

    if exist('segs', 'var')
        if (nthresh ~= numel(segs))
    %         warning('Setting nthresh to number of segmentations');
            nthresh = numel(segs);
        end
        thresh = 1:nthresh; thresh=thresh';
    elseif exist('allthesegmentations', 'var')
        if (nthresh ~= numel(allthesegmentations))
    %         warning('Setting nthresh to number of segmentations');
            nthresh = numel(allthesegmentations);
        end
        thresh = 1:nthresh; thresh=thresh';
    else        
        thresh = linspace(1/(nthresh+1),1-1/(nthresh+1),nthresh)';
    end

    %Exclude some threshold from the computation
    if (~isempty(excludeth))
        excludeth(excludeth>nthresh)=[];
        thresh(excludeth)=[];
        nthresh=numel(thresh);
    end
    
    %Initialize count offset for ucm2 in the case of videos and collectedvs
    if (firstpass)
        %Count IS superpixels when video requested
        countucm2=zeros(1,nthresh);
        
        %Init the relevant structure to collect all VS
        collectedvs=cell(1,nthresh);
        if exist('segs', 'var')%In this implementation this files are just put together stacking them, while this would require using indexing
            noFrames=numel(inFile);
            dimi=size(segs{thresh(1)},1);
            dimj=size(segs{thresh(1)},2);
        elseif exist('allthesegmentations', 'var')
            noFrames=size(allthesegmentations{thresh(1)},3); %allthesegmentations case
            dimi=size(allthesegmentations{thresh(1)},1);
            dimj=size(allthesegmentations{thresh(1)},2);
        else %ucm case
            noFrames=numel(inFile);
            dimi=floor(size(ucm,1)/2); %-1 is not required as using floor
            dimj=floor(size(ucm,2)/2);
        end
        
        for t=1:nthresh
            collectedvs{t}=zeros(dimi,dimj,noFrames);
        end
        
        firstpass=false;
    end
    
    for t = 1 : nthresh
        if exist('segs', 'var')
            seg = Doublebackconv(segs{thresh(t)});
            collectedvs{t}(:,:,ff)=seg;
        elseif exist('allthesegmentations', 'var')
            collectedvs{t}=Doublebackconv(allthesegmentations{thresh(t)});
        else
            labels2 = bwlabel(ucm <= thresh(t));
            seg = labels2(2:2:end, 2:2:end);
            seg = seg + countucm2(t); %we assume bwlabel assigns labels from 1
            countucm2(t) = max(seg(:));
            collectedvs{t}(:,:,ff)=seg;
        end
    end
end

maxseglabs=zeros(1,nthresh);
for t = 1 : nthresh
    maxseglabs(t)=max( collectedvs{t}(:) );
end

if (DEBUGVRANGE)
    for t = 1 : nthresh
        if (DONELABEL)
            collectedvs{t} = ones(size(collectedvs{t}));
        else
            collectedvs{t}(:) = 1:numel(collectedvs{t});
        end
    end
end



%Main cycle: iterated once for images, iterated over the video frames for the videos - compute statistics
%nthresh number of hierarchies
nclusters = zeros(nthresh,1);
sumlength = zeros(nthresh,1);
sqrsumlength = zeros(nthresh,1);
for t = 1 : nthresh

    %Compute length statistics and set to zero shorter tracks
    maxallsegs=max(collectedvs{t}(:));
    allpresences=false(maxallsegs,size(collectedvs{t},3));
    for ff=1:size(collectedvs{t},3)
        labelsatff=unique(collectedvs{t}(:,:,ff));
        labelsatff(labelsatff<1)=[]; %so as to not consider 0 and -1
        allpresences(labelsatff,ff)=true;
    end

    alllengths=zeros(1,maxallsegs);
    for i=1:maxallsegs
        themin=find(allpresences(i,:),1,'first');
        themax=find(allpresences(i,:),1,'last');
        if (~isempty(themin))
            alllengths(i)=themax-themin+1;
        end
    end

    %Record length statistics
    sumlength(t)=sum(alllengths(alllengths>0));
    sqrsumlength(t)=sum(alllengths(alllengths>0).^2);
    nclusters(t)=numel(alllengths(alllengths>0));
    
end %Main cycle compute statistics



%%%Save Results%%%
if (computestatlengths)
    fid = fopen(evFile8, 'w');
    if fid == -1, 
        error('Could not open file %s for writing.', evFile8);
    end
    fprintf(fid,'%10g %10g %10g %10g\n',[thresh, nclusters, sumlength, sqrsumlength]');
    fclose(fid);
end


