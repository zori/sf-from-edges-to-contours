% Zornitsa Kostadinova
% Jun 2014
assert(~isempty(model) && ~isempty(T));

% an image from BSDS500 validation subset
imFile='/BS/kostadinova/work/BSR/BSDS500/data/images/val/101085.jpg'; % tikis
imFile='/home/kostadinova/downloads/video_segm_extras_keep/imgs/test_16068_zebras.jpg'; % zebra
imFile='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/Images/100039.jpg'; % bear
% imFile='/BS/kostadinova/work/BSR/grouping/data/101087_small.jpg';
I=imread(imFile);
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
  if exist('x','var') && length(x)==1, hold on; plot(x,y,'rx','MarkerSize',20); end
  [x,y]=ginput; % here is where the program pauses, waiting for user input
  % if no, or more than one location is clicked, stop the interactive demo
  if (length(x)~= 1), close all; return; end
  x=floor(x); y=floor(y);
  [x,y]=bounce_input_to_image_interior(x,y,ri,szOrig(1:2));
  % figure(1); hold on; plot(x,y,'rx','MarkerSize',20);
  % imagesc(I); axis('image'); title('Choose a patch to crop');
  % hold on;
  % close(1);
  processLocationFun(x,y);
end % while(true)
