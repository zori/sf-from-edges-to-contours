% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function h = pshow(p,figHandle)
% shows a patch
%
% INPUTS
%  p            - patch
%  figHandle    - (optional) figure handle; useful when initialising the grid
%
% OUTPUTS
%  h            - figure handle of patch shown
%
% See also initFig, im
if ~exist('figHandle','var'), figHandle=[]; end
h=initFig(figHandle); im(p);
r=size(p,1)./2;
hold on; plot(r,r,'x');
end
