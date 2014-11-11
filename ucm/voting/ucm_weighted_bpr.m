% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function ucm2 = ucm_weighted_bpr(I,model,varargin)
% varargin:
%  T
%  gts
fmt='doubleSize';
ucm2=ucm_weighted(I,model,'bpr',fmt,varargin{:});
end
