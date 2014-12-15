% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function ws = SE_ws(I,model)
E=edgesDetect(I,model);
% run vanilla watershed, which is an (over-)seg
ws=watershed(E);
end

