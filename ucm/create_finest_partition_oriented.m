% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function ws_wt = create_finest_partition_oriented(pb_oriented)
% the original implementation as in the gPb-owt-ucm
% 4.1 OWT
pb = max(pb_oriented,[],3);
ws = watershed(pb);
ws_bw = (ws == 0);

c = fit_contour(double(ws_bw));
angles = zeros(numel(c.edge_x_coords), 1);

for e = 1 : numel(c.edge_x_coords)
  if c.is_completion(e), continue; end
  v1 = c.vertices(c.edges(e, 1), :);
  v2 = c.vertices(c.edges(e, 2), :);
  
  if v1(2) == v2(2),
    ang = 90;
  else
    ang = atan((v1(1)-v2(1)) / (v1(2)-v2(2)));
  end
  angles(e) = ang*180/pi;
end

orient = zeros(numel(c.edge_x_coords), 1);
orient((angles<-78.75) | (angles>=78.75)) = 1;
orient((angles<78.75) & (angles>=56.25)) = 2;
orient((angles<56.25) & (angles>=33.75)) = 3;
orient((angles<33.75) & (angles>=11.25)) = 4;
orient((angles<11.25) & (angles>=-11.25)) =5;
orient((angles<-11.25) & (angles>=-33.75)) = 6;
orient((angles<-33.75) & (angles>=-56.25)) = 7;
orient((angles<-56.25) & (angles>=-78.75)) = 8;

% use the oriented contour detector output to assign each arc pixel a bdry strength
ws_wt = zeros(size(ws_bw));
for e = 1 : numel(c.edge_x_coords)
  if c.is_completion(e), continue; end
  for p = 1 : numel(c.edge_x_coords{e}),
    ws_wt(c.edge_x_coords{e}(p), c.edge_y_coords{e}(p)) = ...
      max(pb_oriented(c.edge_x_coords{e}(p), c.edge_y_coords{e}(p), orient(e)), ws_wt(c.edge_x_coords{e}(p), c.edge_y_coords{e}(p)));
  end
  v1=c.vertices(c.edges(e,1),:);
  v2=c.vertices(c.edges(e,2),:);
  ws_wt(v1(1),v1(2))=max( pb_oriented(v1(1),v1(2), orient(e)),ws_wt(v1(1),v1(2)));
  ws_wt(v2(1),v2(2))=max( pb_oriented(v2(1),v2(2), orient(e)),ws_wt(v2(1),v2(2)));
end
ws_wt=double(ws_wt);
end
