% Zornitsa Kostadinova
% Jul 2014
% 8.3.0.532 (R2014a)
function ucm2 = ucm_weighted(I,model,patch_score_fcn,fmt,varargin)
% function ucm = ucm_weighted(I,model,patch_score_fcn,fmt,T,gts)
% creates a ucm of an image, that is weighted based on the patches in the leaves of a
% decision forest
%
% INPUTS
%  I            - image
%  model        - structured decision forest (SF)
%  patch_score_fcn - function for the similarity between the watershed and the
%                    segmentation patch
%                    score in [0,1]; 0 - no similarity; 1 - maximal similarity
%                    function could be: bpr vpr_s vpr_gt RI RSRI compareSegs
%  fmt          - output format; 'imageSize' (default) or 'doubleSize'
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
[cfp_fcn,E]=get_voting_fcn(I,model,patch_score_fcn,varargin{:});
if ~exist('fmt','var'), fmt='imageSize'; end
ucm2=contours2ucm(E,fmt,cfp_fcn);
end
