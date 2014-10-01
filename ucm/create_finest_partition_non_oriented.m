% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function ws_wt = create_finest_partition_non_oriented(pb)
% uses as an input a simple probability of boundary, not a (8D) matrix with
% the probability of boundary for 8 orientations
ws=watershed(pb); ws_bw=double(ws==0);
c=fit_contour(ws_bw);
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
ws_wt=zeros(size(ws_bw)); % weight
for e=1:numel(c.edge_x_coords)
  if c.is_completion(e), continue; end
  for p=1:numel(c.edge_x_coords{e})
    ey=c.edge_x_coords{e}(p); ex=c.edge_y_coords{e}(p);
    assert(~ws_wt(ey,ex)); % the max() in the following code in create_finest_partition_oriented is because of the multiple orientations
    ws_wt(ey,ex)=pb(ey,ex);
  end
  v1=c.vertices(c.edges(e,1),:);
  v2=c.vertices(c.edges(e,2),:);
  ws_wt(v1(1),v1(2))=pb(v1(1),v1(2));
  ws_wt(v2(1),v2(2))=pb(v2(1),v2(2));
end
ws_wt=double(ws_wt);
end
