% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function s = RI(patch1,patch2)
% RI (Rand Index)
%
% INPUTS
%  patch1       - w x w input patch
%  patch2       - w x w input patch
%
% OUTPUTS
%  s            - patch similarity score in [0;1]
s=CPS(patch1,patch2,Inf);
end
