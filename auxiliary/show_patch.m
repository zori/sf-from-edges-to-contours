% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function h = show_patch(src,x,y,r,src_title)
h=pshow(cropPatch(src,x,y,r)); title(src_title);
end
