% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function ucm = ucm_weighted_bpr(I,model,T,gts)
px_max_dist=3;
patch_score_fcn=@(S,G) bpr(seg2bdry(S),seg2bdry(G),px_max_dist);
fmt='doubleSize';
if ~exist('T','var'), T=[]; end
if exist('gts','var')
  % oracle
  ucm=ucm_weighted(I,model,patch_score_fcn,fmt,T,gts);
else
  % detection using bpr
  ucm=ucm_weighted(I,model,patch_score_fcn,fmt,T);
end
end
