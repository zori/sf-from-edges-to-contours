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
meangtobjs=[];
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
[collectedvs,thresh,nthresh]=Loadvideofrominfile(inFile,nthresh,excludeth,offsetgt,meangtobjs);

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


