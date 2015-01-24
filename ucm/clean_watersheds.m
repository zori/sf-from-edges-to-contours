% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
% extracted this function from contours2ucm (Arbelaez et al) in order to reuse it
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
  
  % TODO(zori) how does this code work - without checks for out-of-matrix access?
  % should be the following:
%   vec = [ max(safe_matrix(ws_clean,xc-2,yc-1), safe_matrix(ws_clean,xc-1,yc-2)) ...
%     max(safe_matrix(ws_clean,xc+2,yc-1), safe_matrix(ws_clean,xc+1,yc-2)) ...
%     max(safe_matrix(ws_clean,xc+2,yc+1), safe_matrix(ws_clean,xc+1,yc+2)) ...
%     max(safe_matrix(ws_clean,xc-2,yc+1), safe_matrix(ws_clean,xc-1,yc+2)) ];

  vec = [ max(ws_clean(xc-2, yc-1), ws_clean(xc-1, yc-2)) ...
    max(ws_clean(xc+2, yc-1), ws_clean(xc+1, yc-2)) ...
    max(ws_clean(xc+2, yc+1), ws_clean(xc+1, yc+2)) ...
    max(ws_clean(xc-2, yc+1), ws_clean(xc-1, yc+2)) ];
  
  [~,id] = min(vec);
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
function val = safe_matrix(m,x,y)
try
  val=m(x,y);
catch
  val=Inf;
end
end
