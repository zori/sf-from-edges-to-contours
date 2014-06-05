function groundTruth=Compactthelabelsatframes(groundTruth)
%Remove unused labels at each frame separately, so max-min expresses the
%total number of labels


% animage=zeros(size(groundTruth{1}.Segmentation));

for c=1:numel(groundTruth)
    animage=groundTruth{c}.Segmentation;
    
    [tmp1,tmp2,newlabels]=unique(animage(:)); %#ok<ASGLU>
    animage(:)=newlabels(:);
    
    %Remove the empty labels
    %output to the designed structure
    groundTruth{c}.Segmentation=animage;
    %The function maintains the Segmentation format (double, uint32, etc.)
    
end
