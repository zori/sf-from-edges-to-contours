function [collectedvs,thresh,nthresh]=Loadvideofrominfile(inFile,nthresh,excludeth,offsetgt,meangtobjs)

if (~exist('offsetgt','var')) %only applies if segs is used
  offsetgt=[]; %offset introduced for the number of GT objects, level two is replicated nGT-offsetgt.max times, level penultimate offsetgt.min-nGT times
end
if (~exist('excludeth','var'))
  excludeth=[]; %Numbers indicated (positions in thresh array) are excluded (nthresh is adjusted consequently)
end
if ( (~exist('nthresh','var')) || (isempty(nthresh)) )
  nthresh=99;
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
      seg = threshold_ucm2(ucm,thresh(t));
      seg = seg + countucm2(t); %we assume bwlabel assigns labels from 1
      countucm2(t) = max(seg(:));
      collectedvs{t}(:,:,ff)=seg;
    end
  end
end
