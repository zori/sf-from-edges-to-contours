function confcounts = Getconfcounts(seg, groundTruth, maxgtlabelsngt)
% Produce a confidence count from the machine and ground truth
% segmentations. maxgtlabelsngt is used to accumulate the counts over the
% video frames.
%
% Output:
%        confcounts: matrix of size [nsegs+1 x total_gt+ngts], transpose in
%        this function
%
% based on PASCAL evaluation code:
% http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2010/index.html#devkit
% and Arbelaez et al. CVPR 2009
%
% modified by Fabio Galasso
% September 2012

seg(seg<0)=-Inf; %This excludes pixels in seg <1 from statistics
    
ngts=numel(groundTruth);
nsegs=max(seg(:));

if ( (~exist('maxgtlabelsngt','var')) || (isempty(maxgtlabelsngt)) )
    maxgtlabelsngt=zeros(1,ngts);
    for s = 1 : ngts
        if (~isempty(groundTruth{s}))
            maxgtlabelsngt(s) = max(groundTruth{s}.Segmentation(:));
        end
    end
end

total_gt = sum(maxgtlabelsngt);

cnt = 0;
confcounts = zeros(total_gt+ngts, nsegs+1); %an extra column and row to include zero label confusion counts
for s = 1 : ngts
    if (~isempty(groundTruth{s}))
        gt = groundTruth{s}.Segmentation;

        num1 = maxgtlabelsngt(s) + 1; 
        num2 = nsegs + 1;
        aconfcounts = zeros(num1, num2);

        % joint histogram
        gt(gt<0)=-Inf; %This excludes pixels in GT <0 from statistics
        sumim = 1 + gt + seg*num1;

        hs = histc(sumim(:), 1:num1*num2);
        aconfcounts(:) = aconfcounts(:) + hs(:);

        confcounts(cnt+1:cnt+maxgtlabelsngt(s)+1, :) = aconfcounts;
    end
    cnt = cnt + maxgtlabelsngt(s)+1;
end

confcounts = confcounts';




