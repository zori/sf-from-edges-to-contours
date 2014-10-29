% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
% for k=1:length(gts), initFig(); im(gts{k}); end
% for k=vi, initFig(); im(data(k).seg); end

for ind=inds(1:10:100)'
  x=xs(ind); y=ys(ind);
  for k=vi
    disp(data(k).ucm2(y,x));
    disp(votes{k}{y,x}');
    initFig(1); im(data(k).ucm2); hold on; plot(x,y,'x','MarkerSize',20);
    ucm2crop=cropPatch(data(k).ucm2,x,y,r); initFig(); im(ucm2crop); hold on; plot(r,r,'x');
    mean_crop=cropPatch(data(k).mean,x,y,r); initFig(); im(mean_crop); hold on; plot(r,r,'x');
    if k == 1
      process_location_fcn{k}(x,y,votes{k}{y,x});
    else
      % k == 3
      % crop the gts
      for kk=1:length(gts)
        gt_crop=cropPatch(gts{kk},x,y,r);
        initFig(); im(gt_crop); title(['ground truth ' num2str(kk), ' score ' num2str(votes{k}{y,x}(kk))]);
      end
    end
    close all; % TIP: put a breakpoint here
  end
end
