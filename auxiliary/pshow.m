% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function h = pshow(p,show_colourcoded,figHandle)
% shows a patch
%
% INPUTS
%  p                - patch
%  show_colourcoded - (optional) binary flag if to show the patch colour-coded; defaults to 'false'
%  figHandle        - (optional) figure handle; useful when initialising the grid
%
% OUTPUTS
%  h            - figure handle of patch shown
%
% See also initFig, im
if ~exist('show_colourcoded','var'), show_colourcoded=false; end
if ~exist('figHandle','var'), figHandle=[]; end
h=initFig(figHandle);
if show_colourcoded
  imcc(p);
else
  im(p);
end
r=size(p,1)./2;
hold on;
plot(r,r,'LineWidth',8,...
  'Marker','o',... % circle
  'MarkerSize',36,...
  'MarkerFaceColor',[0.5,0.5,0.5],... % grey marker inside
  'MarkerEdgeColor','b'); % or 'r' for red sometimes

% % to copy-paste; with 'r':
% hold on; plot(8,8,'LineWidth',8,'Marker','o','MarkerSize',36,'MarkerFaceColor',[0.5,0.5,0.5],'MarkerEdgeColor','r');

% plot(r,r,'x'); % might need plot(r,r,'rx'); for a red 'x'
end
