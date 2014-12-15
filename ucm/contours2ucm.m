function ucm = contours2ucm(pb, fmt, cfp_fcn)
% NOTE: 'contours' in the name is a misnomer, as input is not a contour map,
% but a probability of boundary (edge map, no closed contours)
% Creates Ultrametric Contour Map from oriented contours
%
% syntax:
%   ucm = contours2ucm(pb_oriented, fmt, cfp_fun)
%
% description:
%   Computes UCM by considering
%   the mean pb value on the boundary between regions as dissimilarity.
%
% arguments:
%   pb:          Probability of Boundary (optionally oriented)
%   fmt:         Output format. 'imageSize' (default) or 'doubleSize'
%   cfp_fun:     (optional) function for creating the finest partition of the
%                UCM hierarchy
%
% output:
%   ucm:    Ultrametric Contour Map in double
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
% December 2010
%
% modified by Zornitsa Kostadinova
% Jul 2014

if nargin<2, fmt = 'imageSize'; end

if ~strcmp(fmt,'imageSize') && ~strcmp(fmt,'doubleSize'),
  error('possible values for fmt are: imageSize and doubleSize');
end

% determine function to create finest partition
if ~exist('cfp_fcn','var')
  % create finest partition and transfer contour strength
  if ndims(pb) == 3
    cfp_fcn=@(pb) create_finest_partition_oriented(pb);
  else
    cfp_fcn=@(pb) create_finest_partition_non_oriented(pb);
  end
end

% timerCfp=tic;
ws_wt = cfp_fcn(pb);
% cfpTime=toc(timerCfp);

% timerUcm=tic;
ucm=finest_partition2ucm(ws_wt,fmt);
% ucmTime=toc(timerUcm);

% disp(cfpTime);
% disp(ucmTime);
% disp(seconds2human(cfpTime));
% disp(seconds2human(ucmTime));
end % contours2ucm

% ----------------------------------------------------------------------
function ucm = finest_partition2ucm(ws_wt,fmt)
% prepare pb for ucm
ws_wt2 = double(super_contour_4c(ws_wt));
cws_wt2 = clean_watersheds(ws_wt2);
% if any(cws_wt2(:)~=ws_wt2(:))
%   keyboard;
% end
ws_wt2=cws_wt2;
% ws_wt2 = clean_watersheds(ws_wt2);
labels2 = bwlabel(ws_wt2 == 0, 8);
labels = labels2(2:2:end, 2:2:end) - 1; % labels begin at 0 in mex file.
assert(min(labels(:))>=0);
ws_wt2(end+1, :) = ws_wt2(end, :);
ws_wt2(:, end+1) = ws_wt2(:, end);

% compute ucm with mean pb
super_ucm = double(ucm_mean_pb(ws_wt2, labels));

% output
super_ucm = normalize_output(super_ucm); % ojo

if strcmp(fmt,'doubleSize'),
  ucm = super_ucm;
else
  ucm = super_ucm(1:2:end-2,1:2:end-2); % TODO figure out was this really a bug - getting the imageSize by subindexing this way (3:2:end, 3:2:end);
end
end

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
pb2(:,end) = pb2(:,end-1);
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
