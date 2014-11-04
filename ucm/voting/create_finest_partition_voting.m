% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function [sf_wt,votes,process_location_fcn] = create_finest_partition_voting(pb,rg,patch_score_fcn,ws_fcn,hs_fcn,process_location_fcn)
ws=watershed(pb);
sz=size(pb);

c=fit_contour(double(ws==0));
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
nEdges=numel(c.edge_x_coords);
c.edge_weights=zeros(nEdges,2); % tuples of accumulated weights and number of pixels per edge
votes=cell(sz); % for hard_negatives_mining
ws_args={c,NaN,sz};
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
  if e == 40 || e == 48
    disp(e);
  end
  ws_args{2}=e;
  for p=1:numel(c.edge_x_coords{e})
    % NOTE x and y are swapped here (in the output from fit_contour)
    % the correct way is (for an image of dimensions h x w x 3)
    % first coord, in [1,h], is y, second coord, in [1,w], is x
    y=c.edge_x_coords{e}(p); x=c.edge_y_coords{e}(p);
    w=vote(x,y,rg,ws_fcn,ws_args,hs_fcn,patch_score_fcn,process_location_fcn);
    votes{y,x}=w;
    w=sum(w)/numel(w);
    c.edge_weights(e,:)=c.edge_weights(e,:)+[w 1];
  end
end % for e - edge index

% apply weights to ucm
sf_wt=zeros(sz);
for e=1:nEdges
  if c.is_completion(e), continue; end
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
end % create_finest_partition_voting

% ----------------------------------------------------------------------
function w = vote(x,y,rg,ws_fcn,ws_args,hs_fcn,patch_score_fcn,process_location_fcn)
px=x+2*rg; py=y+2*rg; % adjust patch dimensions TODO: should be p(3) and p(1)
[ws_patch,ws_patch_init]=ws_fcn(px,py,ws_args{:});
[hs,hs_init]=hs_fcn(x,y); % a few 16x16 segmentation patches
assert(size(hs,1)==rg*2);
w=compute_weights(ws_patch,hs,patch_score_fcn);
f=false;
if f
  pshow(ws_patch_init,1); title('ws patch - initial');
  pshow(ws_patch); title('ws patch - processed');
  if ~all(hs(:)==hs_init(:))
    for k=1:size(hs_init,3), pshow(hs_init(:,:,k)); title('a ''G'' patch - initial'); end
  end
  process_location_fcn(x,y,w);
  close all; % TIP put a breakpoint here
end
end

% ----------------------------------------------------------------------
function w = compute_weights(ws_patch,hs,patch_score_fcn)
hsz=size(hs,3); % number of ground truth patches
w=zeros(hsz,1);
for k=1:hsz
  w(k)=patch_score_fcn(double(ws_patch),double(hs(:,:,k))); % could work with uint8, but not desirable in case some of the segments have labels bigger than 255
end
end % computeWeights
