% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function contour_patch = create_contour_patch(px,py,rg,c,e,sz)
persistent cache;
if ~isempty(cache) && cache{1}==e, [~,ws_contour]=deal(cache{:}); else
  ws_contour=create_ws_contour(rg,c,e,sz); cache={e,ws_contour};
end
contour_patch=cropPatch(ws_contour,px,py,rg);
end

function ws_contour = create_ws_contour(rg,c,e,sz)
ws_contour=zeros(sz);
for p=1:numel(c.edge_x_coords{e})
  y=c.edge_x_coords{e}(p); x=c.edge_y_coords{e}(p);
  ws_contour(y,x)=1;
end
ri=2*rg; % TODO no, create a padding wrapper that knows :)
ws_contour=padarray(ws_contour,[ri ri],'both');
end
