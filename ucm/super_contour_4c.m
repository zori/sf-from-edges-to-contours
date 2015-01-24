% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
% extracted this function from contours2ucm (Arbelaez et al) in order to reuse it
function [pb2, V, H] = super_contour_4c(pb)

V = min(pb(1:end-1,:), pb(2:end,:)); % overlap pb vertically (shift=1px)
H = min(pb(:,1:end-1), pb(:,2:end)); % overlap pb horizontally (shift=1px)

[tx, ty] = size(pb);
pb2 = zeros(2*tx, 2*ty);
pb2(1:2:end, 1:2:end) = pb;
pb2(1:2:end, 2:2:end-2) = H;
pb2(2:2:end-2, 1:2:end) = V;
pb2(end,:) = pb2(end-1, :);
assert(all(pb2(:,end)==0));
pb2(:,end) = max(pb2(:,end), pb2(:,end-1));
end
