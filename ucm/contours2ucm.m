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
