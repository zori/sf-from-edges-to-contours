% Zornitsa Kostadinova
% Jul 2014
% 8.3.0.532 (R2014a)
function ucm2 = ucm_weighted(I,model,voting,fmt,DBG,varargin)
% function ucm2 = ucm_weighted(I,model,voting,fmt,DBG,T,gts)
% creates a ucm of an image, that is weighted based on the patches in the leaves of a
% decision forest
%
% INPUTS
%  I            - image
%  model        - structured decision forest (SF)
%  voting       - configuration string - how to vote
%  fmt          - output format; 'imageSize' (default) or 'doubleSize'
%  DBG          - flag whether to pause when computing weighting function on
%                 some edges
% varargin:
%  T            - (optional) individual trees of the SF (for visualisation only - processLocation)
%  gts          - (optional) ground truth segmentations; for oracle only; used
%                 to analyse the performance of similarity scoring functions on
%                 patches
%
% OUTPUTS
%  ucm2         - Ultrametric Contour Map
%
% See also contours2ucm
is_hard_negative_mining=false;
[cfp_fcn,E]=get_voting_fcn(I,model,voting,DBG,is_hard_negative_mining,varargin{:});
if ~exist('fmt','var'), fmt='imageSize'; end
ucm2=contours2ucm(E,fmt,cfp_fcn);
end
