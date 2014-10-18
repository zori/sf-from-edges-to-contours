% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function test_scoring_fcns()
sz=16;
% z=zeros(sz);
% o=ones(sz);
% vpr(z,o) % no, labels should start from 1 at least (0 are not counted)

b=ones(sz); % background
v=b; v(:,sz/2+1:end)=2; % vertical
h=b; h(sz/2+1:end,:)=2; % horizontal
t3=v; t3(sz/2+1:end,:)=3; % three segs
t3v=b; t3v(:,sz/4+1:end)=2; t3v(sz/2+1:end,:)=3; % three segs, modified vertical component
t3h=v; t3h(sz/4+1:end,:)=3; % three segs, modified horizontal component
f4=v; f4(sz/2+1:end,:)=f4(sz/2+1:end,:)+2; % four segs
a=reshape(randperm(sz*sz),[sz sz]); % reshape(1:sz*sz,[sz sz]); % all segments have a different label
d=create_seg_patch(0,0,sz/2,createLine(0,0,1,-1)); % second diagonal
D=create_seg_patch(0,0,sz/2,createLine(0,0,1,1)); % main diagonal

% patches for the cases according to Fabio's idea
% 2 small difference on the 3 axis
vt=create_seg_patch(0,0,sz/2,createLine(0,0,1,5)); % v, tilted
ht=create_seg_patch(0,0,sz/2,createLine(0,0,5,-1)); % h, tilted
dt=create_seg_patch(0,0,sz/2,createLine(0,0,0.9,-1)); % d, tilted
beo=b; beo(sz-2:end,1:2)=2; % background with small extra object
bEO=b; bEO(sz/2+1:end,1:sz/2)=2; % background with big extra object
am=reshape(randperm(sz*sz),[sz sz]); am(sz-2:end,sz-2:end)=am(end,end); % all pixels different, with some segments merged
aM=reshape(randperm(sz*sz),[sz sz]); aM(sz/2+1:end,sz/2+1:end)=aM(end,end); % all pixels different, with more segments merged
vteo=vt; vteo(1:3,1)=3; % vertical tilted with an extra object
t3eo=t3; t3eo(1:2,1)=4; t3eo(1,2)=4; % t3 (3 segments) with extra object
heo=h; heo(1:sz/2,1)=3; % horizontal with extra object
v_3_4=b; v_3_4(:,3*sz/4+1:end)=2; % vertical line on 3/4 distance
v_thin=b; v_thin(:,1:2)=2; % thin vertical strip
h_thin=b; h_thin(1:2,:)=2; % thin horizontal strip
ah=reshape(randperm(sz*sz),[sz sz]); ah(sz/2+1:end,:)=ah(end,end); % a, half horizontal
av=reshape(randperm(sz*sz),[sz sz]); av(:,sz/2+1:end)=av(end,end); % a, half vertical

% tuples of patches
% p={{b b} {b d} {d d} {d v} {d D} {d t} {x d} {b a}};

% from google doc
% p={{b b} {v v} {v b} {v d} {v h}...
%   {v t3} {t3 v} {h t3} {t3 h}... % yellow in google doc
%   {t3v v}...
%   {v t3v} {v t3h}... % purple in gdoc
%   {t3h v}...
%   {v f4} {f4 v}... % blue in gdoc
%   {b a}...
%   };

% tuples for the cases according to Fabio's idea
% 4 different strata where we know the score ranking between the strata, but
% not within
%
% 1. equal case
p_eq={{b b} {v v} {h h} {D D} {d d} {a a} {t3 t3} {am am} {aM aM} {bEO bEO}};
% 2. small difference on the 3 axis
p_s_contour={{v vt} {ht h} {d dt}}; % volume, boundary - slightly misaligned contour
p_s_extra_obj={{beo b} {a am}}; % object count - small extra object in S
p_s_missing_obj={{v vteo} {t3 t3eo} {h heo}}; % object count - small missing object (in G but missing in S)
p_small_difference=[p_s_contour p_s_extra_obj p_s_missing_obj];
% 3. bigger difference on the 3 axis
p_b_contour={{v d} {v v_3_4}};
p_b_extra_obj={{bEO b}};
p_b_missing_obj={{h t3} {aM a}};
p_big_diff=[p_b_contour p_b_extra_obj p_b_missing_obj {{am aM} {aM am} {beo bEO}}]; % some examples added afterwards
% 4. worst ranks
p_worst={...
  {b a}... % worst rank for volumes
  {h v}... % worst rank for boundaries
  {v_thin h_thin}... % worst rank for boundaries, but not too bad for volumes
  {ah av}... % strange example, hard for human also; the many small segments have "good boundary match"; volumetric metrics place it quite high as well
  };
ps={p_eq p_small_difference p_big_diff p_worst}; % the 4 cases
% to display only one example
% ps={{{beo bEO}}};
psz=length(ps); % number of strata (case distinctions)

scoring_fcns={@RSRI,@RI,@vpr,@vpr_gt,@vpr_s};
sfsz=length(scoring_fcns);
res=cell(psz,sfsz);
for c=1:psz % c - case number
  exsz=numel(ps{c});
  for e=1:exsz % e - example
    ex=ps{c}{e}; ex{1}=double(ex{1}); ex{2}=double(ex{2}); % a tuple of (2) patches
    for sf=1:sfsz % scoring function number
      score=scoring_fcns{sf}(ex{:});
      res{c,sf}=[res{c,sf};score];
      if c>1
        cmp=~(score<res{c-1,sf});
        % make sure this strata has lower score than its predecessor
        if any(cmp) % that should rarely happen, based on how we have intuitively placed the examples in the strata (different cases)
          warning('score violator: between cases (%d <-> %d); example number %d of case %d; scoring function number %d',c-1,c,e,c,sf);
          violators=ps{c-1}(cmp);
          disp(score);
          disp(res{c-1,sf}(cmp)');
          f=false;
          if f
            show_segments(ex,true); % current segments compared
            for vi=violators, show_segments(vi{:}); end % the violators from the previous case
          end
        end
      end
    end % sf
  end % ex
end

% disp(res); just displays the sizes of the output (number of examples)

% print results in a table by iterating over the examples
disp('       RSRI         RI VPR_unnorm VPR_norm_Ts VPR_norm_ws')
l=repmat('-',1,sfsz*10); % line to be displayed between the strata (the different test cases)
for k=1:psz
  if k>1, disp(l); end
  % disp([res{k,:}]); % can't control the displaying of doubles with no decimal
  % precision, e.g. 0 and 1
  exsz=numel(res{k,1});
  for e=1:exsz % e - example
    for sf=1:sfsz % scoring function number
      assert(exsz==numel(res{k,sf}));
      fprintf(' %10.4f', res{k,sf}(e));
    end
    fprintf('\n');
  end
end
end

% ----------------------------------------------------------------------
function show_segments(e,init_fig_cnt)
if ~exist('init','var'), init_fig_cnt=false; end
if init_fig_cnt, initFig(1); else initFig(); end
im(e{1}); % test segmentation (e.g. watershed)
initFig(); im(e{2}); % ground truth (e.g. from the tree)
end
