% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function f = fmeasure(r,p)
% compute f-measure from recall and precision
f = 2*p.*r./(p+r+((p+r)==0));
end
