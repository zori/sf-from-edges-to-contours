function [sumRI, sumVOI] = Getprivi(confcountslabels, maxgtlabelsngt)
% match a test segmentation to a set of ground-truth segmentations with the PROBABILISTIC RAND INDEX and VARIATION OF INFORMATION metrics.
% performance metrics following the implementation by Allen Yang:
% http://perception.csl.uiuc.edu/coding/image_segmentation/
%
% modified by Fabio Galasso
% September 2012

%confcountslabels = nsegs x total_gt

ngts=numel(maxgtlabelsngt);
% nsegs=size(confcountslabels,1);

total_gt = size(confcountslabels,2); %sum(maxgtlabelsngt)
if (total_gt ~= sum(maxgtlabelsngt))
    fprintf('Total gt and gt label count\n');
    sumRI=[]; sumVOI=[];
    return;
end

sumRI = 0;
sumVOI = 0;
cnt = 0;
ngtstocount=0;
for s = 1 : ngts

    if (maxgtlabelsngt(s)>0)
        aconfcounts = confcountslabels(: , cnt+1:cnt+maxgtlabelsngt(s));
        %aconfcounts = nsegs x maxgtlabelsngt(s)

        curRI = Randindex(aconfcounts); %input nsegs x maxgtlabelsngt(s)
        curVOI = Variationofinformation(aconfcounts);

        sumRI = sumRI + curRI;
        sumVOI = sumVOI + curVOI;
        
        ngtstocount=ngtstocount+1;
    end

    cnt = cnt + maxgtlabelsngt(s);
end

sumRI = sumRI / ngtstocount;
sumVOI = sumVOI / ngtstocount;

