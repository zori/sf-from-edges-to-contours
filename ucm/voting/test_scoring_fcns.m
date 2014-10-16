% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function test_scoring_fcns()
sz=16;
% z=zeros(sz);
% o=ones(sz);
% VPR(z,o) % no, labels should start from 1 at least (0 are not counted)
% helpers - masks (logical)
b=ones(sz); % background
v=b; v(:,sz/2+1:end)=2; % vertical
h=b; h(sz/2+1:end,:)=2; % horizontal
t3=v; t3(sz/2+1:end,:)=3; % three segs
t3v=b; t3v(:,sz/4+1:end)=2; t3v(sz/2+1:end,:)=3; % three segs, modified vertical component
t3h=v; t3h(sz/4+1:end,:)=3; % three segs, modified horizontal component
f4=v; f4(sz/2+1:end,:)=f4(sz/2+1:end,:)+2; % four segs
a=reshape(randperm(sz*sz),[sz sz]); % reshape(1:sz*sz,[sz sz]); % all segments have a different label

trl=triu(b); % triangle left
trr=trl(:,end:-1:1); % triangle right
trup=(trl-eye(sz))&trr;
trlo=~(trl|trr);
d=trl+1; % main diagonal
D=trr+1; % second diagonal
% x=h*2+v;
% t=v; t(sz/2+1:end,sz/2+1:end)=3;
t=trl+trup+(~trl)*3; % three segments
x=t+trlo; % the two diagonals
% p={{b b} {b d} {d d} {d v} {d D} {d t} {x d} {b a}};

% tuples of patches
p={{b b} {v v} {v b} {v d} {v h}...
  {v t3} {t3 v} {h t3} {t3 h}... % yellow in google doc
  {t3v v}...
  {v t3v} {v t3h}... % purple in gdoc
  {t3h v}...
  {v f4} {f4 v}... % blue in gdoc
  {b a}...
  };

psz=length(p);
vpr_norm=@(fst,snd) VPR(fst,snd);
vpr_unnorm=@(fst,snd) VPR(fst,snd,false);
scoring_fcns={@RSRI,@RI,vpr_unnorm,vpr_norm};
res=zeros(psz,length(scoring_fcns));
for k=1:psz
  f=false;
  if f
    disp(k);
    initFig(1); im(p{k}{1}); % test segmentation (e.g. watershed)
    initFig(); im(p{k}{2}); % ground truth (e.g. from the tree)
  end  
  cnt=1;
  for fcn = scoring_fcns
    res(k,cnt)=fcn{1}(p{k}{:});
  cnt=cnt+1;
  end
end
disp(res);
end
