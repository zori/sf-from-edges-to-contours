% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function h = show_patch(src,imPad_fcn,px,py,rg,src_title)
src_padded=imPad_fcn(src);
h=pshow(cropPatch(src_padded,px,py,rg)); title(src_title);
end
