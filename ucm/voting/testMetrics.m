% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function testMetrics()
sz=16;
% z=zeros(sz);
% o=ones(sz);
% helpers - masks (logical)
b=ones(sz); % background
trl=triu(b); % triangle left
trr=trl(:,end:-1:1); % triangle right
trup=(trl-eye(sz))&trr;
trlo=~(trl|trr);
% patches
d=trl+1; % main diagonal
D=trr+1; % second diagonal
v=b; v(:,sz/2+1:end)=2; % vertical
h=b; h(sz/2+1:end,:)=2; % horizontal
% x=h*2+v;
% t=v; t(sz/2+1:end,sz/2+1:end)=3;
t=trl+trup+(~trl)*3; % three segments
x=t+trlo; % the two diagonals
a=reshape(1:sz*sz,[sz sz]); % all segments have a different label
S={b,b,d,d,d,d,x,b};
G={b,d,d,v,D,t,d,a};
nPatches=length(S);
assert(nPatches==length(G));
% VPR(z,o)
vpr_norm=@(fst,snd) VPR(fst,snd);
vpr_unnorm=@(fst,snd) VPR(fst,snd,false);
metrics={@RSRI,@RI}; % vpr_unnorm,vpr_norm};
res=zeros(length(metrics),nPatches);
m=1;
for metric = metrics
  for k=1:nPatches
    f=false;
    if f
      initFig(1); im(S{k});
      initFig(); im(G{k});
    end
    res(m,k)=metric{1}(S{k},G{k});
  end
  m=m+1;
end
disp(res');
end
