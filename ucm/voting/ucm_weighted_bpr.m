% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function ucm2 = ucm_weighted_bpr(I,model,varargin)
% varargin:
%  T
%  gts
px_max_dist=3;
patch_score_fcn=@(S,G) bpr(seg2bdry(S),seg2bdry(G),px_max_dist);
fmt='doubleSize';
ucm2=ucm_weighted(I,model,patch_score_fcn,fmt,varargin{:});
end
