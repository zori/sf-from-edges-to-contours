% Zornitsa Kostadinova
% Aug 2014
% 8.3.0.532 (R2014a)
function h = initFig(figureHandle)
% creates and positions a figure on a 3 x 4 grid layout for convenient viewing
%
% INPUTS
%  figureHandle - (optional) handle/index for the figure
%
% OUTPUTS
%  h            - figure handle
%
persistent cache figCnt;
if isempty(figCnt), figCnt=1; end
if nargin, figCnt=figureHandle; end
if (~isempty(cache)), [scrSz,figSz,nFigs]=deal(cache{:}); else
  set(0,'Units','pixels');
  scrSz=get(0,'ScreenSize'); scrSz=scrSz(3:4);
  figSz=[4 3]; nFigs=figSz(1)*figSz(2); cache={scrSz,figSz,nFigs};
end
h=figure(figCnt); clf;
ind=figCnt;
if figCnt>1, ind=mod(figCnt-2,nFigs-1)+2; end
[x,y]=ind2sub(figSz,ind);
position=[...
  (x-1)*scrSz(1)/figSz(1),... % left
  (3-y)*scrSz(2)/figSz(2),... % bottom
  scrSz(1)/figSz(1),...       % width
  scrSz(2)/figSz(2)];         % height
set(h,'OuterPosition',position);
figCnt=figCnt+1;
end
