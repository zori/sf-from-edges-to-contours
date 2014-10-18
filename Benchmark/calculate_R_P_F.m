% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function [F, R, P] = calculate_R_P_F(cntR, sumR, cntP, sumP)
R=cntR ./ (sumR+(sumR==0));
P=cntP ./ (sumP+(sumP==0));
F=fmeasure(R,P);
end
