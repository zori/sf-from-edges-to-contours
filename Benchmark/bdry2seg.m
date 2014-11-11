% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function seg = bdry2seg(bdry)
% transforms a bdry patch to a segmentation patch
seg=watershed(bdry,4);
seg(seg==0)=1; % TODO fix how, rather than arbitrarily assign to the one class
end
