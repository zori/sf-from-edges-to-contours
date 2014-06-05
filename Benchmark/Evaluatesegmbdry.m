function [thresh,cntR,sumR,cntP,sumP] = Evaluatesegmbdry(inFile,gtFile, evFile1, nthresh, maxDist, thinpb, use3dbdry, excludeth, offsetgt)
% [thresh,cntR,sumR,cntP,sumP] = boundaryPR_image(inFile,gtFile, evFile1, nthresh, maxDist, thinpb)
%
% Calculate precision/recall curve.
%
% INPUT
%	inFile  : Can be one of the following:
%             - a soft or hard boundary map in image format.
%             - a collection of segmentations in a cell 'segs' stored in a mat file
%             - an ultrametric contour map in 'doubleSize' format, 'ucm2'
%               stored in a mat file with values in [0 1].
%
%	gtFile	: File containing a cell of ground truth boundaries
%   evFile1 : Temporary output for this image.
%	nthresh	: Number of points in PR curve.
%   MaxDist : For computing Precision / Recall.
%   thinpb  : option to apply morphological thinning on segmentation
%             boundaries.
%
% OUTPUT
%	thresh		Vector of threshold values.
%	cntR,sumR	Ratio gives recall.
%	cntP,sumP	Ratio gives precision.
%
% modified by Fabio Galasso
% September 2012

if (~exist('offsetgt','var')) %only applies if segs is used
    offsetgt=[]; %offset introduced for the number of GT objects, level two is replicated nGT-offsetgt.max times, level penultimate offsetgt.min-nGT times
end
if (~exist('excludeth','var'))
    excludeth=[]; %Numbers indicated (positions in thresh array) are excluded (nthresh is adjusted consequently)
end
if ( (~exist('use3dbdry','var')) || (isempty(use3dbdry)) )
    use3dbdry=false; %This option only applies to videos (inFile and gtFile cell arrays)
end
if ( (~exist('thinpb','var')) || (isempty(thinpb)) )
    thinpb=true;
end
if ( (~exist('maxDist','var')) || (isempty(maxDist)) )
    maxDist=0.0075; %3px for a 320x240 image
end
if ( (~exist('nthresh','var')) || (isempty(nthresh)) )
    nthresh=99;
end

DEBUGVRANGE=false; DONELABEL=true;

%Transform non cell arrays inFile and gtFile into cell arrays
if (~iscell(gtFile))
    tmpfile=gtFile; clear gtFile; gtFile=cell(1); gtFile{1}=tmpfile;
end
if (~iscell(inFile))
    tmpfile=inFile; clear inFile; inFile=cell(1); inFile{1}=tmpfile;
end

%Compute mean ground truth object number, used for offsetting
if ( (~isempty(offsetgt)) && (isstruct(offsetgt)) )
    load(gtFile{1});
    if (isempty(groundTruth)) %#ok<USENS>
        error(' bad gtFile !');
    end
    ngts = numel(groundTruth);
    if (ngts == 0)
        error(' bad gtFile !');
    end
    
    allgtobjs=cell(1,ngts);
    for ff=1:numel(gtFile)
        load(gtFile{ff});
    
        for i=1:ngts
            if (~isempty(groundTruth{i}))
                segtmp=Doublebackconv(groundTruth{i}.Segmentation);
                segtmp(segtmp<1)=max(segtmp(:));
                allgtobjs{i}=[allgtobjs{i},reshape(unique(segtmp),1,[])];
%                 allgtobjs{i}=[allgtobjs{i},reshape(unique(groundTruth{i}.Segmentation),1,[])];
            end
        end
    end
    meangtobjs=0;
    for i=1:ngts
        meangtobjs=meangtobjs+numel(unique(allgtobjs{i})); %This should not include (-1) objects
    end
    meangtobjs=round(meangtobjs/ngts);
end




%Main cycle: iterated once for images, iterated over the video frames for the videos
for ff=1:numel(inFile)

    %Load machine segmentation
    [p,n,e]=fileparts(inFile{ff});
    if (~exist(inFile{ff},'file')) && (~exist( fullfile(p,[n,'.png']) ,'file')) && (~exist( fullfile(p,[n,'.bmp']) ,'file')) %It is not necessary to repeat this check in the following iterations
        error('Output file %s could not be found',n);
    end
    
    clear segs;
    if ( (strcmp(e,'.mat')) && (exist(inFile{ff},'file')~=0) )
        load(inFile{ff}); % segs
    end

    if (exist('ucm2', 'var'))
        pb = double(ucm2(3:2:end, 3:2:end));
        clear ucm2;
    elseif (~exist('segs', 'var'))
        if (exist( fullfile(p,[n,'.png']) ,'file')~=0)
            pb = double(imread( fullfile(p,[n,'.png']) ))/255;
        elseif (exist( fullfile(p,[n,'.bmp']) ,'file')~=0)
            ucm2 = double(imread( fullfile(p,[n,'.bmp']) ))/255;
            pb=ucm2(3:2:end, 3:2:end);
            clear ucm2;
        end
    end
%     Init_figure_no(10), imagesc(pb)
    
    %Load GT
    load(gtFile{ff});
    if (isempty(groundTruth))
        error(' bad gtFile !');
    end
    ngts = numel(groundTruth);
    if (ngts == 0)
        error(' bad gtFile !');
    end
%     Init_figure_no(10), imagesc(groundTruth{1}.Boundaries)

    %offset segs, when requested
    if ( (~isempty(offsetgt)) && (isstruct(offsetgt)) && (exist('segs', 'var')) && (numel(segs)>1) )
        segs=Offsetthesegs(segs,offsetgt,meangtobjs);
    end

    if (~exist('segs', 'var'))
        thresh = linspace(1/(nthresh+1),1-1/(nthresh+1),nthresh)';
    else
        if ( nthresh ~= numel(segs) )
    %         warning('Setting nthresh to number of segmentations');
            nthresh = numel(segs);
        end
        thresh = 1:nthresh; thresh=thresh';
    end

    %Exclude some threshold from the computation
    if (~isempty(excludeth))
        excludeth(excludeth>nthresh)=[];
        thresh(excludeth)=[];
        nthresh=numel(thresh);
    end

    % zero all counts
    if (~exist('cntR','var'))
        cntR = zeros(size(thresh));
        sumR = zeros(size(thresh));
        cntP = zeros(size(thresh));
        sumP = zeros(size(thresh));
    end

    for t = 1:nthresh
        
        if (~exist('segs', 'var'))
            bmap = (pb>=thresh(t));
        else
            bmap = logical(seg2bdry(segs{thresh(t)},'imageSize')); %Doublebackconv(segs{thresh(t)}); is not necessary, as just a value difference matter
        end
%         Init_figure_no(10), imagesc(bmap)

        if (DEBUGVRANGE)
            seg=zeros(size( segs{thresh(t)} ));
            if (DONELABEL)
                seg = ones(size(seg));
            else
                seg(:)=1:numel(seg);
            end
            bmap=logical(seg2bdry(seg,'imageSize'));
        end
        
        % thin the thresholded pb to make sure boundaries are standard thickness
        if (thinpb)
            bmap = double(bwmorph(bmap, 'thin', inf));    % OJO
        else
            bmap=double(bmap);
        end

        % accumulate machine matches, since the machine pixels are
        % allowed to match with any segmentation
        accP = zeros(size(bmap));

        % compare to each seg in turn
        for i = 1:numel(groundTruth)
            if (~isempty(groundTruth{i}))
                % compute the correspondence
                [match1,match2] = correspondPixels(bmap, double(groundTruth{i}.Boundaries), maxDist);
                % accumulate machine matches
                accP = accP | match1;
                % compute recall
                sumR(t) = sumR(t) + sum(groundTruth{i}.Boundaries(:));
                cntR(t) = cntR(t) + sum(match2(:)>0);
%                 Init_figure_no(10), imagesc(accP)
            end
        end
        %sumR(t) for threshold t: the sum of the all boundary pixels from all the ground truth images
        %cntR(t) for threshold t: the sum of the ground truth boundary pixels
            %which can be matched to the computed segmentation pixels, over the
            %available ground truths

        % compute precision
        sumP(t) = sumP(t) + sum(bmap(:));
        cntP(t) = cntP(t) + sum(accP(:));
        %sumP(t) for threshold t: the sum of boundary pixels from the computed segmentation
        %cntP(t) for threshold t: the sum of the boundary pixels from the computed
            %segmentation which can be matched to any boundary from any of the ground truth
    end

end %Main cycle

% output
fid = fopen(evFile1,'w');
if (fid==-1)
    error('Could not open file %s for writing.', evFile1);
end
fprintf(fid,'%10g %10g %10g %10g %10g\n',[thresh cntR sumR cntP sumP]');
fclose(fid);

