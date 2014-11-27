% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
% for k=1:length(gts), initFig(); im(gts{k}); end
% for k=vi, initFig(); im(data(k).seg); end

for ind=inds(1:10:100)'
  x=xs(ind); y=ys(ind);
  for k=vi
    disp(data(k).ucm2(y,x));
    disp(data(k).votes{y,x}');
    initFig(1); im(data(k).ucm2); hold on; plot(x,y,'x','MarkerSize',20);
    show_patch_fcn=@(src,src_title) show_patch(src,imPad_fcn,x,y,r,src_title);
    show_patch_fcn(data(k).mean,'crop of the mean of votes');
    show_patch_fcn(data(k).sf_wt,'crop of the finest partition');
    show_patch_fcn(data(k).ucm2,'crop of the ucm2');
    dbg=true;
    if c.is_e(y,x)
      data(k).vote_fcn(x,y,{c,c.is_e(y,x),sz},dbg); % will pause after displaying the patches
    else
      warning('location (%d,%d) is a vertex (no voting there)',num2str(x),num2str(y));
      keyboard; % will pause here
    end
    close all;
  end
end
