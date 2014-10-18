% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function F = vpr_s(S,G)
% F score of the VPR, normalised w.r.t S; not symmetric w.r.t. its input
F = VPR_F(G,S,true);
end
