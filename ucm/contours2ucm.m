function [ucm] = contours2ucm(pb, fmt)
% Creates Ultrametric Contour Map from oriented contours
%
% syntax:
%   [ucm] = contours2ucm(pb_oriented, fmt)
%
% description:
%   Computes UCM by considering
%   the mean pb value on the boundary between regions as dissimilarity.
%
% arguments:
%   pb:          Probability of Boundary (not oriented)
%   fmt:         Output format. 'imageSize' (default) or 'doubleSize'
%
% output:
%   ucm:    Ultrametric Contour Map in double
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
% December 2010
%
% modified by Zornitsa Kostadinova
% Jul 2014

if nargin<2, fmt = 'imageSize'; end;

if ~strcmp(fmt,'imageSize') && ~strcmp(fmt,'doubleSize'),
  error('possible values for fmt are: imageSize and doubleSize');
end

% create finest partition and transfer contour strength
[ws_wt] = create_finest_partition(pb);

% prepare pb for ucm
ws_wt2 = double(super_contour_4c(ws_wt));
ws_wt2 = clean_watersheds(ws_wt2);
labels2 = bwlabel(ws_wt2 == 0, 8);
labels = labels2(2:2:end, 2:2:end) - 1; % labels begin at 0 in mex file.
ws_wt2(end+1, :) = ws_wt2(end, :);
ws_wt2(:, end+1) = ws_wt2(:, end);

% compute ucm with mean pb.
super_ucm = double(ucm_mean_pb(ws_wt2, labels));

% output
super_ucm = normalize_output(super_ucm); % ojo

if strcmp(fmt,'doubleSize'),
  ucm = super_ucm;
else
  ucm = super_ucm(3:2:end, 3:2:end);
end
end

% ----------------------------------------------------------------------
function [ws_wt] = create_finest_partition(pb)
% uses as an input a simple probability of boundary, not a (8D) matrix with
% the probability of boundary for 8 orientations
ws = watershed(pb);
ws_bw = (ws == 0);

contours = fit_contour(double(ws_bw));

ws_wt = zeros(size(ws_bw));
for e = 1 : numel(contours.edge_x_coords)
  if contours.is_completion(e), continue; end
  for p = 1 : numel(contours.edge_x_coords{e}),
    ws_wt(contours.edge_x_coords{e}(p), contours.edge_y_coords{e}(p)) = ...
      max(pb(contours.edge_x_coords{e}(p), contours.edge_y_coords{e}(p)), ws_wt(contours.edge_x_coords{e}(p), contours.edge_y_coords{e}(p)));
  end
  v1=contours.vertices(contours.edges(e,1),:);
  v2=contours.vertices(contours.edges(e,2),:);
  ws_wt(v1(1),v1(2))=max( pb(v1(1),v1(2)),ws_wt(v1(1),v1(2)));
  ws_wt(v2(1),v2(2))=max( pb(v2(1),v2(2)),ws_wt(v2(1),v2(2)));
end
ws_wt=double(ws_wt);
end % create_finest_partition

% ----------------------------------------------------------------------
function [pb2, V, H] = super_contour_4c(pb)

V = min(pb(1:end-1,:), pb(2:end,:));
H = min(pb(:,1:end-1), pb(:,2:end));

[tx, ty] = size(pb);
pb2 = zeros(2*tx, 2*ty);
pb2(1:2:end, 1:2:end) = pb;
pb2(1:2:end, 2:2:end-2) = H;
pb2(2:2:end-2, 1:2:end) = V;
pb2(end,:) = pb2(end-1, :);
pb2(:,end) = max(pb2(:,end), pb2(:,end-1));
end

% ----------------------------------------------------------------------
function [ws_clean] = clean_watersheds(ws)
% remove artifacts created by non-thin watersheds (2x2 blocks) that produce
% isolated pixels in super_contour

ws_clean = ws;

c = bwmorph(ws_clean == 0, 'clean', inf);

artifacts = ( c==0 & ws_clean==0 );
R = regionprops(bwlabel(artifacts), 'PixelList');

for r = 1 : numel(R),
  xc = R(r).PixelList(1,2);
  yc = R(r).PixelList(1,1);
  
  vec = [ max(ws_clean(xc-2, yc-1), ws_clean(xc-1, yc-2)) ...
    max(ws_clean(xc+2, yc-1), ws_clean(xc+1, yc-2)) ...
    max(ws_clean(xc+2, yc+1), ws_clean(xc+1, yc+2)) ...
    max(ws_clean(xc-2, yc+1), ws_clean(xc-1, yc+2)) ];
  
  [nd,id] = min(vec);
  switch id,
    case 1,
      if ws_clean(xc-2, yc-1) < ws_clean(xc-1, yc-2),
        ws_clean(xc, yc-1) = 0;
        ws_clean(xc-1, yc) = vec(1);
      else
        ws_clean(xc, yc-1) = vec(1);
        ws_clean(xc-1, yc) = 0;
        
      end
      ws_clean(xc-1, yc-1) = vec(1);
    case 2,
      if ws_clean(xc+2, yc-1) < ws_clean(xc+1, yc-2),
        ws_clean(xc, yc-1) = 0;
        ws_clean(xc+1, yc) = vec(2);
      else
        ws_clean(xc, yc-1) = vec(2);
        ws_clean(xc+1, yc) = 0;
      end
      ws_clean(xc+1, yc-1) = vec(2);
      
    case 3,
      if ws_clean(xc+2, yc+1) < ws_clean(xc+1, yc+2),
        ws_clean(xc, yc+1) = 0;
        ws_clean(xc+1, yc) = vec(3);
      else
        ws_clean(xc, yc+1) = vec(3);
        ws_clean(xc+1, yc) = 0;
      end
      ws_clean(xc+1, yc+1) = vec(3);
    case 4,
      if ws_clean(xc-2, yc+1) < ws_clean(xc-1, yc+2),
        ws_clean(xc, yc+1) = 0;
        ws_clean(xc-1, yc) = vec(4);
      else
        ws_clean(xc, yc+1) = vec(4);
        ws_clean(xc-1, yc) = 0;
      end
      ws_clean(xc-1, yc+1) = vec(4);
  end
end
end

% ----------------------------------------------------------------------
function [pb_norm] = normalize_output(pb)
% map ucm values to [0 1] with sigmoid
% learned on BSDS
[tx, ty] = size(pb);
beta = [-2.7487; 11.1189];
pb_norm = pb(:);
x = [ones(size(pb_norm)) pb_norm]';
pb_norm = 1 ./ (1 + (exp(-x'*beta)));
pb_norm = (pb_norm - 0.0602) / (1 - 0.0602);
pb_norm=min(1,max(0,pb_norm));
pb_norm = reshape(pb_norm, [tx ty]);
end
