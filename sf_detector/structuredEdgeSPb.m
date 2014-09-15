% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function ucm2 = structuredEdgeSPb(I,model)
% detection is done using the SE output as an input to the sPb globalization from Arbelaez et. al.
% slow detection because of the spectral NCuts
% TODO try nms or nnms as options for the model
E=edgesDetect(I,model);
sf_gPb_orient=globalPb(I,'',1.0,E);
ucm2=contours2ucm(sf_gPb_orient,'doubleSize');
end
