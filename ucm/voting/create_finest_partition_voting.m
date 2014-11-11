% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function [sf_wt,votes,vote_fcn,c] = create_finest_partition_voting(pb,vote_fcn)
% the extra output args - votes,vote_fcn,c - are only for hard_negatives_mining
ws=watershed(pb);
sz=size(pb);

c=fit_contour(double(ws==0));
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
nEdges=numel(c.edge_x_coords);
c.edge_weights=zeros(nEdges,2); % tuples of accumulated weights and number of pixels per edge
votes=cell(sz); % for hard_negatives_mining
ws_args={c,NaN,sz};
dbg=false; % a debug flag to allow to inspect intermediate results
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
%   if e == 40 || e == 48
%     dbg=true;
%     disp(e); % this is a hint to comment out this section when not debugging
%   end
  ws_args{2}=e;
  for p=1:numel(c.edge_x_coords{e})
    % NOTE x and y are swapped here (in the output from fit_contour)
    % the correct way is (for an image of dimensions h x w x 3)
    % first coord, in [1,h], is y, second coord, in [1,w], is x
    y=c.edge_x_coords{e}(p); x=c.edge_y_coords{e}(p);
    assert(c.is_e(y,x)==1);
    c.is_e(y,x)=e; % modify to allow to find the edge number by the coords
    w=vote_fcn(x,y,ws_args,dbg); dbg=false;
    votes{y,x}=w;
    c.edge_weights(e,:)=c.edge_weights(e,:)+[sum(w)/numel(w) 1];
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
