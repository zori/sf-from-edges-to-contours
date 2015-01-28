% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function patch = create_fitted_poly_patch(px,py,n,rg,c,e)
persistent cache;
patch_side=2*rg;
if ~isempty(cache) && cache{1}==e && cache{2}==n, [~,~,p]=deal(cache{:}); else
  p=fit_poly(n,c,e,patch_side); cache={e,n,p};
end

x1=px-rg+1:px+rg;
y1=py-rg+1:py+rg;
f1=polyval(p,x1);
% plot(x1,f1,'*')

thresh=2.1;
A=abs(repmat(y1',1,patch_side)-repmat(f1,patch_side,1));
mask=A<thresh;
A=-A+max(A(:));
A=(mask).*A;
% patch=compress_labels(patch); % not needed
% nms
O=edgeOrient(single(A),4);
patch=edgeNms(A,O,1,0); % 0 - no nms near boundaries
% turn to 0-1 result - 1=boundary, 0=no boundary
patch=double(patch~=0);
end

% ----------------------------------------------------------------------
function p = fit_poly(n,c,e,patch_side)
[x,y]=edge_coords_in_patch_space(c,e,patch_side);
x=x'; y=y'; % TODO is it necessary to transpose the vectors to vector-rows?

% assert(x(1)~=x(end)); % if all x's are the same, will end up reducing them
% from first to last (i.e. d==-1)
d=(x(1)<x(end))*2-1;
ep=0.03; % epsilon;
[~,ix,~]=unique(x,'stable');
ix=[ix;length(x)+1];
times=zeros(size(x));
for k=1:length(ix)-1
  times(ix(k):ix(k+1)-1)=0:(ix(k+1)-ix(k))-1;
end
x=x+d.*ep.*times;
p=polyfit(x,y,n); % TODO why warnings sometimes when degree==2
% p=rand(1,2); % how to do rand line
assert(all(~isnan(p)) && all(~isinf(p)));
% plot(x,y,'o')
% hold on
end
