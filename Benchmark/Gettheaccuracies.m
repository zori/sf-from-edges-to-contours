function [matchesj,confcountssized,volumes] = Gettheaccuracies(confcountst,maxgtlabelsngt,metricstocompute,exczeroformacseg,exczeroforgt)
% Compute a matrix of segmentation coverings and a matrix of confusion
% counts, resized to the labels in use. confcountst contains in fact an
% extra label for the zeros.
% Zero values are considered, -1 values are neglected. A pixel with -1 is
% not counted at all (neither for precision, nor for recall nor for SC)
% A pixel with value 0 is counted as not matched
%
% Input:
%       confcountst = confidence counts including zero label
%                       (nsegs+1) x (total_gt+ngts)
%       maxgtlabelsngt = maximum number of labels per GT
%                       1 x (ngts)
%       metricstocompute = bool to indicate which output to compute
%                           [jaccard indexes, conf counts sized, volumes]
%       exczeroformacseg = bool to indicate whether to exclude the zero values
%                       of machine segmentations from the available assignments (true by default, used to benchmark sparse video segmentations)
%       exczeroforgt = bool to indicate whether to exclude the zero values
%                       of groundtruth from the available assignment (false by default, used to benchmark subtasks, zero values from GT are normalized for)
% Output:
%       matchesj = nsegs x total_gt
%                   total_gt x nsegs in this function
%       confcountssized = nsegs x total_gt
%                   total_gt x nsegs in this function
%       volumes = numerators and denominators for precision and recall of
%                   VPR
%
% based on PASCAL evaluation code:
% http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2010/index.html#devkit
% and Arbelaez et al. CVPR 2009
%
% modified by Fabio Galasso
% September 2012
%
% DEBUG opt: confcountst=normconfcounts{t};
% DEBUG opt: confcountst=confcounts{t};

if ( (~exist('exczeroforgt','var')) || (isempty(exczeroforgt)) )
    exczeroforgt=false;
end
if ( (~exist('exczeroformacseg','var')) || (isempty(exczeroformacseg)) )
    exczeroformacseg=true;
end
if ( (~exist('metricstocompute','var')) || (isempty(metricstocompute)) )
    metricstocompute=true(1,3);
end

ngts=numel(maxgtlabelsngt);
nsegs=size(confcountst,1)-1;

total_gt = size(confcountst,2) - ngts; %sum(maxgtlabelsngt)
if (total_gt ~= sum(maxgtlabelsngt))
    fprintf('Total gt and gt label count\n');
    matchesj=[]; confcountssized=[];
    return;
end

cnt = 0;
cntsized=0;
if (metricstocompute(1))
    matchesj = zeros(nsegs,total_gt); %Computed for SC
else
    matchesj = 0;
end
if (metricstocompute(2))
    confcountssized = zeros(nsegs,total_gt); %Computed for PRI and VI
else
    confcountssized = 0;
end
volumes=struct(); %computed for VPR
volumes.cntprect=0;volumes.sumprect=0;volumes.cntrect=0;volumes.sumrect=0;volumes.nofusedgts=0;

for s = 1 : ngts

    num1 = maxgtlabelsngt(s) + 1; 
    num2 = nsegs + 1;
    
    %Pixel overlaps between gt and segmentation computed for the labels
    aconfcounts = confcountst(: , cnt+1:cnt+maxgtlabelsngt(s)+1);
    %aconfcounts = (nsegs+1) x (maxgtlabelsngt(s)+1)

    
    if (~isempty(aconfcounts(2:end, 2:end))) %This may happen in cases of empty GT for some human annotations or empty machine segmentations (-1)
        %intersections between gt and segmentation computed for the labels (>0)
        if (metricstocompute(2))
            confcountssized(:, cntsized+1:cntsized+maxgtlabelsngt(s)) = aconfcounts(2:end, 2:end);
        end

        %segmentaion coverings between machine segments and GTs (Jaccard indexes)
        if (metricstocompute(1))
            gtjsum=sum(aconfcounts,1);
            segisum=sum(aconfcounts,2);
            matchesj(:, cntsized+1:cntsized+maxgtlabelsngt(s)) = aconfcounts(2:end, 2:end) ./ ( repmat(gtjsum(2:end),num2-1,1) + repmat(segisum(2:end),1,num1-1) - aconfcounts(2:end, 2:end) );
        end
    end
    
    if (metricstocompute(3))
        if (~isempty(aconfcounts( (1+exczeroformacseg):end , (1+exczeroforgt):end)))
            
            %Precision
            %Compute the best overlapping area between the gt and machine segment
            %for each machine segment, repeated over the available gts
            overlapseg= max (  aconfcounts( (1+exczeroformacseg):end , (1+exczeroforgt):end )  , [] , 2);
            %overlapseg= [nsegs+1,1]
            
            volumes.cntprect = volumes.cntprect + sum(overlapseg);
            volumes.sumprect = volumes.sumprect + sum(sum(  aconfcounts( (1+exczeroformacseg):end , 1:end )  )); %Zeros labels are counted for the areas, -1 labels are not counted at all (regions of frames are ignored)



            %Recall
            overlapsGT= max (  aconfcounts( (1+exczeroformacseg):end , (1+exczeroforgt):end )  , [] , 1);
            
            volumes.cntrect = volumes.cntrect + sum(overlapsGT);
            volumes.sumrect = volumes.sumrect + sum(sum(  aconfcounts( 1:end , (1+exczeroforgt):end )  )); %Zeros labels are counted for the areas, -1 labels are not counted at all (regions of frames are ignored)
            
            %Number of GT objects at the frame, used for normalization
            volumes.nofusedgts= volumes.nofusedgts + sum(  overlapsGT>0  );
        end
    end
    
    cntsized = cntsized + maxgtlabelsngt(s);
    cnt = cnt + maxgtlabelsngt(s) + 1 ;
end





