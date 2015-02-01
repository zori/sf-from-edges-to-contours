% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function [sf_wt,votes,vote_fcn,c] = create_finest_partition_voting_per_pixel_vote(pb,vote_fcn,DBG)
% the extra output args - votes,vote_fcn,c - are only for hard_negatives_mining
ws=watershed(pb);
sz=size(pb);

% c_subdivided=fit_contour(double(ws==0));
c=fit_contour(double(ws==0),false); % not subdivided, get region boundaries
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
nEdges=numel(c.edge_x_coords);
c.edge_weights=zeros(nEdges,2); % tuples of accumulated weights and number of pixels per edge
votes=cell(sz); % for hard_negatives_mining
ws_args={c,NaN,sz};
dbg=false; % a debug flag to allow to inspect intermediate results
dbg_cnt=0; dbg_limit=10;
edge_chunk=floor(nEdges/dbg_limit/2);
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
  ws_args{2}=e;
  for p=1:numel(c.edge_x_coords{e})
    % NOTE x and y are swapped here (in the output from fit_contour)
    % the correct way is (for an image of dimensions h x w x 3)
    % first coord, in [1,h], is y, second coord, in [1,w], is x
    y=c.edge_x_coords{e}(p); x=c.edge_y_coords{e}(p);
    assert(c.is_e(y,x)==1);
    c.is_e(y,x)=e; % modify to allow to find the edge number by the coords
    % x | 24 | 24 | 44 |    | 46 | 40 |
    % y | 23 | 24 | 44 |    | 46 | 51 |
    % e |  8 |  8 | 38 | 40 | 41 | 48 |    % c.is_v(47,46)==1
    % if DBG && any(abs([8 38 40 41 48]-e)<eps), dbg=true; end
    if DBG && dbg_cnt<dbg_limit && e>dbg_cnt*edge_chunk && ~coords_on_bdry(x,y,sz), dbg=true; dbg_cnt=dbg_cnt+1; end
    w=vote_fcn(x,y,ws_args,dbg); dbg=false;
    votes{y,x}=w;
    c.edge_weights(e,:)=c.edge_weights(e,:)+[sum(w)/numel(w) 1];
  end
end % for e - edge index

% % optionally, display colour-coded watershed locations
% initFig; imagesc(label2rgb(c_subdivided.is_e,'jet',[0.5 0.5 0.5],'shuffle'));
% axis('image'); title('Colour-coded watershed arcs');

% initFig; imagesc(label2rgb(c.is_e,'jet',[0.5 0.5 0.5],'shuffle'));
% axis('image'); title('Colour-coded region boundary');

% apply weights to ucm
sf_wt=zeros(sz);
vo2=zeros(sz);
for e=1:nEdges
  if c.is_completion(e), continue; end
  W=c.edge_weights(e,1)/c.edge_weights(e,2); % avg weight on edge e
  for p=1:numel(c.edge_x_coords{e})
    y=c.edge_x_coords{e}(p); x=c.edge_y_coords{e}(p);
    sf_wt(y,x)=W;
    assert(~isempty(votes{y,x}));
    vo2(y,x)=mean(votes{y,x});
  end
  v1=c.vertices(c.edges(e,1),:);
  v2=c.vertices(c.edges(e,2),:);
  sf_wt(v1(1),v1(2))=max(W,sf_wt(v1(1),v1(2)));
  sf_wt(v2(1),v2(2))=max(W,sf_wt(v2(1),v2(2)));
  if numel(c.edge_x_coords{e})~=0
    y1=c.edge_x_coords{e}(1); x1=c.edge_y_coords{e}(1);
    y2=c.edge_x_coords{e}(numel(c.edge_x_coords{e})); x2=c.edge_y_coords{e}(numel(c.edge_x_coords{e}));
    vo2(v1(1),v1(2))=vo2(y1,x1); % at the vertices, copy the neighboring value from the corresponding edge
    vo2(v2(1),v2(2))=vo2(y2,x2); %
  else
    % NOTE: there are "edges" with no internal nodes, only two end vertices;
    % how to weight those end vertices?
    % 1) set to 0,
    % 2) copy value from corresponding pb(v1(1),v1(2)) and pb(v2(1),v2(2))?
    vo2(v1(1),v1(2))=pb(v1(1),v1(2)); % 0;
    vo2(v2(1),v2(2))=pb(v2(1),v2(2)); % 0;
  end
end % for e - edge index

% imwrite(uint8((~c.is_e)*255),'/home/kostadinova/downloads/tikis-watershed-arcs-locations.png')
% imwrite(uint8((1-sf_wt)*255),'/home/kostadinova/downloads/tiki-finest-partition.png')
ws_wt=create_finest_partition_non_oriented(pb);
% vo=zeros(sz);
% for y=1:sz(1)
%   for x=1:sz(2)
%     v=votes{y,x};
%     if ~isempty(v)
%       vo(y,x)=mean(v);
%     end
%   end
% end
% initFig; im(vo);
% initFig; im(vo2); % vo and vo2 differ only on the vertices locations (vo2 has values)
% initFig; im(ws_wt);
% sf_wt=sf_wt.* ws_wt; % VPR .* pb
% rgb_loc=cat(3,~~c.is_e,zeros(size(sf_wt)),~~sf_wt);
% initFig; im(rgb_loc); % reg - watershed arcs that received no votes; blue - vertices of watershed arcs; magenta - watershed arcs that did receive some != 0 votes
% sf_wt=vo2;
end
