% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function [sf_wt,votes] = create_finest_partition_voting(pb,ws_padded,rg,get_hs_fcn,process_location_fcn,patch_score_fcn,ws2seg_fcn)
ws=watershed(pb);

c=fit_contour(double(ws==0));
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
nEdges=numel(c.edge_x_coords);
c.edge_weights=zeros(nEdges,2); % tuples of accumulated weights and number of pixels per edge
votes=cell(size(pb)); % for hard_negatives_mining
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
  if e == 40 || e == 48
    disp(e);
  end
  v1=c.vertices(c.edges(e,1),:); % fst coord is y - row ind
  v2=c.vertices(c.edges(e,2),:);
  l=fit_line(v1,v2,2*rg); % rg==ri/2, but that is not really relevant
  for p=1:numel(c.edge_x_coords{e})
    % NOTE x and y are swapped here (in the output from fit_contour)
    % the correct way is (for an image of dimensions h x w x 3)
    % first coord, in [1,h], is y, second coord, in [1,w], is x
    y=c.edge_x_coords{e}(p); x=c.edge_y_coords{e}(p);
    w=vote(x,y,l,rg,ws_padded,ws2seg_fcn,get_hs_fcn,patch_score_fcn,process_location_fcn);
    votes{y,x}=w;
    w=sum(w)/numel(w);
    c.edge_weights(e,:)=c.edge_weights(e,:)+[w 1];
  end
end % for e - edge index

% apply weights to ucm
sf_wt=zeros(size(pb));
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
  W=c.edge_weights(e,1)/c.edge_weights(e,2); % avg weight on edge e
  for p=1:numel(c.edge_x_coords{e})
    y=c.edge_x_coords{e}(p); x=c.edge_y_coords{e}(p);
    sf_wt(y,x)=W;
  end
  v1=c.vertices(c.edges(e,1),:);
  v2=c.vertices(c.edges(e,2),:);
  sf_wt(v1(1),v1(2))=max(W,sf_wt(v1(1),v1(2)));
  sf_wt(v2(1),v2(2))=max(W,sf_wt(v2(1),v2(2)));
end % for e - edge index
% sf_wt=sf_wt.*create_finest_partition_non_oriented(pb); % VPR .* pb
end % create_finest_partition

% ----------------------------------------------------------------------
function w = vote(x,y,l,rg,ws_padded,ws2seg_fcn,get_hs_fcn,patch_score_fcn,process_location_fcn)
px=x+2*rg; py=y+2*rg; % adjust patch dimensions TODO: should be p(3) and p(1)
ws_patch=cropPatch(ws_padded,px,py,rg); % crop from the padded watershed, to make sure a superpixels patch can always be cropped
ws_patch=create_seg_patch(px,py,rg,l); % create_bdry_patch and ws2seg_fcn will be bdry2seg() <- TODO write it
ws_patch=ws2seg_fcn(ws_patch);
hs=get_hs_fcn(x,y); % a few 16x16 segmentation patches
w=compute_weights(ws_patch,hs,patch_score_fcn);
f=false;
if f
  % close all;
  initFig(1); im(ws_padded); hold on; plot(px,py,'rx','MarkerSize',12);
  initFig(); im(ws_patch);
  process_location_fcn(x,y,w); % this needs a model with the patches saved
end
end

% ----------------------------------------------------------------------
function l = fit_line(v1,v2,patch_side)
% adjust indices for the padded superpixelised image
v1=v1+patch_side;v2=v2+patch_side;
l=createLine([v1(2),v1(1)],[v2(2),v2(1)]);
end

% ----------------------------------------------------------------------
function w = compute_weights(ws_patch,hs,patch_score_fcn)
hsz=size(hs,3); % number of ground truth patches
w=zeros(hsz,1);
for k=1:hsz
  w(k)=patch_score_fcn(double(ws_patch),double(hs(:,:,k))); % could work with uint8, but not desirable in case some of the segments have labels bigger than 255
end
end % computeWeights
