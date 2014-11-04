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
    ucm2crop=cropPatch(data(k).ucm2,x,y,r); pshow(ucm2crop);
    mean_crop=cropPatch(data(k).mean,x,y,r); pshow(mean_crop);
    if k == 1
      % bpr3
      process_location_fcn{k}(x,y,votes{k}{y,x});
    else
      % k == 3
      % crop the gts
      p=[0 0 0 0]; % no padding, kind of hack, since we are only cropping away from the boundary to avoid the problem
      process_location_gt(x,y,votes{k}{y,x},gts,p,r);
    end
    close all; % TIP: put a breakpoint here
  end
end
