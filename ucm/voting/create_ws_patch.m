% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function ws_patch = create_ws_patch(px,py,rg,E,p)
persistent cache;
if ~isempty(cache), [ws_padded]=deal(cache{:}); else
  ws_padded=imPad(double(watershed(E)),p,'symmetric'); cache={ws_padded};
end
ws_patch=cropPatch(ws_padded,px,py,rg);
end
