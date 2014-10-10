% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function testMetrics()
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
% S={b,b,d,d,d,d,x,b};
% G={b,d,d,v,D,t,d,a};

% test segmentation (e.g. watershed)
S={b,v,v,v,v,...
  v,t3,h,t3,... % yellow in google doc
  t3v,...
  v,v,... % purple in gdoc
  t3h,...
  v,f4,... % blue in gdoc
  b
  };
% ground truth (e.g. from the tree)
G={b,v,b,d,h,...
  t3,v,t3,h,... % yellow in google doc
  v,...
  t3v,t3h,... % purple in gdoc
  v,...
  f4,v,... % blue in gdoc
  a
  };
nPatches=length(S);
assert(nPatches==length(G));
vpr_norm=@(fst,snd) VPR(fst,snd);
vpr_unnorm=@(fst,snd) VPR(fst,snd,false);
metrics={vpr_norm}; % {@RSRI,@RI,vpr_unnorm,vpr_norm};
res=zeros(length(metrics),nPatches);
m=1;
for metric = metrics
  for k=1:nPatches
    f=false;
    if f
      disp(k);
      initFig(1); im(S{k});
      initFig(); im(G{k});
    end
    res(m,k)=metric{1}(S{k},G{k});
  end
  m=m+1;
end
disp(res');
end
