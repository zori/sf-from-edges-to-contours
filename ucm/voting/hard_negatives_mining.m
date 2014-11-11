% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
% for k=1:length(gts), initFig(); im(gts{k}); end
% for k=vi, initFig(); im(data(k).seg); end

for ind=inds(1:10:100)'
  x=xs(ind); y=ys(ind);
  for k=vi
    disp(data(k).ucm2(y,x));
    disp(votes{k}{y,x}'); % this is [] in the first case; investigate why; don't rerun 'precompute' as the method is randomized!!!!
    initFig(1); im(data(k).ucm2); hold on; plot(x,y,'x','MarkerSize',20);
    show_patch(data(k).mean,x,y,r,'crop of the mean of votes');
    show_patch(sf_wt{k},x,y,r,'crop of the finest partition');
    show_patch(data(k).ucm2,x,y,r,'crop of the ucm2');
    dbg=true; % will pause after displaying the patches
    vote_fcn{k}(x,y,{c{k},c{k}.is_e(y,x),sz},dbg);
    close all;
  end
end
