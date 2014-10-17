% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function test_scoring_fcns()
sz=16;
% z=zeros(sz);
% o=ones(sz);
% VPR(z,o) % no, labels should start from 1 at least (0 are not counted)

b=ones(sz); % background
v=b; v(:,sz/2+1:end)=2; % vertical
h=b; h(sz/2+1:end,:)=2; % horizontal
t3=v; t3(sz/2+1:end,:)=3; % three segs
t3v=b; t3v(:,sz/4+1:end)=2; t3v(sz/2+1:end,:)=3; % three segs, modified vertical component
t3h=v; t3h(sz/4+1:end,:)=3; % three segs, modified horizontal component
f4=v; f4(sz/2+1:end,:)=f4(sz/2+1:end,:)+2; % four segs
a=reshape(randperm(sz*sz),[sz sz]); % reshape(1:sz*sz,[sz sz]); % all segments have a different label
d=create_seg_patch(0,0,sz/2,createLine(0,0,1,-1)); % main diagonal
D=create_seg_patch(0,0,sz/2,createLine(0,0,1,1)); % second diagonal

% patches for the cases according to Fabio's idea
% 2 small difference on the 3 axis
vt=create_seg_patch(0,0,sz/2,createLine(0,0,1,5));
ht=create_seg_patch(0,0,sz/2,createLine(0,0,5,-1));
dt=create_seg_patch(0,0,sz/2,createLine(0,0,0.9,-1));
beo=b; beo(sz-2:end,1:2)=2; % background with extra object
am=a; am(sz-2:end,sz-2:end)=am(end,end); % all pixels different, with some segments merged
vteo=vt; vteo(1:3,1)=3; % vertical tilted with an extra object
t3eo=t3; t3eo(1:2,1)=4; t3eo(1,2)=4; % t3 (3 segments) with extra object
heo=h; heo(1:sz/2,1)=3; % horizontal with extra object

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
p_eq={{b b} {v v} {a a} {t3 t3}};
% 2. small difference on the 3 axis
p_s_contour={{v vt} {ht h} {d dt}}; % volume, boundary - slightly misaligned contour
p_s_extra_obj={{beo b} {a am}}; % object count - small extra object in S
p_s_missing_obj={{v vteo} {t3 t3eo} {h heo}}; % object count - small missing object (in G but missing in S)
p_small_difference=[p_s_contour p_s_extra_obj p_s_missing_obj];
% 3. bigger difference on the 3 axis
%
% 4. worst ranks

ps={p_eq p_small_difference}; % the 4 cases
psz=length(ps); % number of strata (case distinctions)

vpr_norm=@(fst,snd) VPR(fst,snd);
vpr_unnorm=@(fst,snd) VPR(fst,snd,false);
scoring_fcns={@RSRI,@RI,vpr_unnorm,vpr_norm};
sfsz=length(scoring_fcns);
res=cell(psz,sfsz);
for c=1:psz % c - case number
  exsz=numel(ps{c});
  for e=1:exsz % e - example
    ex=ps{c}{e}; ex{1}=double(ex{1}); ex{2}=double(ex{2}); % a tuple of (2) patches
    f=false;
    if f
      disp(c); % case number
      show_segments(ex);
    end
    for sf=1:sfsz % scoring function number
      score=scoring_fcns{sf}(ex{:});
      res{c,sf}=[res{c,sf} score];
      if c>1
        % make sure this strata has lower score than its predecessor
        if ~all(score<res{c-1,sf}) % that should be the case, based on how we have intuitively defined the strata (different cases)
          warning('score violator: between cases (%d <-> %d); example number %d of case %d; scoring function number %d',c-1,c,e,c,sf);
          disp(repmat(score,size(ps{c-1})));
          disp(res{c-1,sf});
          f=false;
          if f, show_segments(ex); end
        end
      end
    end % sf
  end % ex
end
% TODO display by iterating over the examples
disp(res);
end

function show_segments(e)
initFig(1); im(e{1}); % test segmentation (e.g. watershed)
initFig(); im(e{2}); % ground truth (e.g. from the tree)
end
