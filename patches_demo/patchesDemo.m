% Zornitsa Kostadinova
% Jun 2014
assert(~isempty(model) && ~isempty(T));

names=im_gt_filenames; % load real images filenames
I=imread(names.zebra.im);
opts=model.opts;
ri=opts.imWidth/2; % patch radius 16
rg=opts.gtWidth/2; % patch radius 8
% pad image, making divisible by 4
szOrig=size(I); p=[ri ri ri ri];
p([2 4])=p([2 4])+mod(4-mod(szOrig(1:2)+2*ri,4),4);
IPadded=imPad(I,p,'symmetric');
% compute feature channels
[chnsReg,chnsSim]=edgesChns(IPadded,model.opts);
% apply forest to image
[Es,ind]=edgesDetectMex(model,chnsReg,chnsSim);
% normalize and finalize edge maps
t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval;
Es_=Es(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg,:)*t; E=convTri(Es_,1);
% ucm=contours2ucm(E); % the small arcs between the statues are erroneously up-voted
ucm=structuredEdgeSPb(I,model,'imageSize');
processLocationFun=@(x,y) processLocation(x,y,model,T,I,false,rg,p,chnsReg,chnsSim,ind,E,ucm);

% interactive demo loop
while (true)
  % get user input
  initFig(1); im(I); title('Choose a patch to crop');
  [x,y]=ginput; % here is where the program pauses, waiting for user input
  x=floor(x); y=floor(y);
  [x,y]=bounce_input_to_image_interior(x,y,ri,szOrig(1:2));
  if length(x)== 1
    hold on; plot(x,y,'rx','MarkerSize',20);
  else
    % if no, or more than one location is clicked, stop the interactive demo
    close all; return;
  end
  processLocationFun(x,y);
end % while(true)
