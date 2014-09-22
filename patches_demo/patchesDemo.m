% Zornitsa Kostadinova
% Jun 2014
function patchesDemo(model,T)
assert(~isempty(model) && ~isempty(T));

% an image from BSDS500 validation subset
imFile='/BS/kostadinova/work/BSR/BSDS500/data/images/val/101085.jpg';
% imFile='/BS/kostadinova/work/BSR/grouping/data/101087_small.jpg';
I=imread(imFile);
opts=model.opts;
ri=opts.imWidth/2; % patch radius 16
rg=opts.gtWidth/2; % patch radius 8
nTreesEval=opts.nTreesEval;
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
% Superpixelization (over-segmentation)
ws=watershed(E);
% ucm=contours2ucm(E); % the small arcs between the statues are erroneously
% up-voted
ucm=structuredEdgeSPb(I,model,'imageSize');
processLocationFun=@(x,y) processLocation(x,y,model,T,I,opts,ri,rg,nTreesEval,szOrig,p,chnsReg,chnsSim,ind,E,ws,ucm);

if true
% interactive demo loop
while (true)
  clear functions; % clear the persistent vars in getFigPos
  % get user input
  initFig(1); imagesc(I); axis('image'); title('Choose a patch to crop');
  if exist('x','var'), hold on; plot(x,y,'rx','MarkerSize',20); end
  [x,y]=ginput;
  % if no or more than one location is clicked, stop the interactive demo
  if (length(x)~= 1), close all; return; end
  [x,y]=fixInput(x,y,ri,szOrig(1:2));
  imagesc(I); axis('image'); title('Choose a patch to crop');
  hold on;
  processLocationFun(x,y);
end % while(true)
end
end % patchesDemo

% ----------------------------------------------------------------------
function [x,y] = fixInput(x,y,r,szI)
% return x y coordinates within the inside (not a band with width r) of the original image
if y<r, y=r; else if y>szI(1)-r, y=szI(1)-r; end; end
if x<r, x=r; else if x>szI(2)-r, x=szI(2)-r; end; end
end
