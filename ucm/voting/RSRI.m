% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function s = RSRI(patch1,patch2,nSamples)
% RSRI (Random Subsample Rand Index)
% After Dollar's patch comparison while training a structured decision tree.
% Since it uses random sampling, exact scores are not reproducible.
%
% INPUTS
%  patch1       - w x w input patch
%  patch2       - w x w input patch
%  nSamples     - [256] (optional) number of unique pixel pairs to sample
%
% OUTPUTS
%  s            - patch similarity score in [0;1]
if ~exist('nSamples','var'), nSamples=256; end
s=CPS(patch1,patch2,nSamples);
end
