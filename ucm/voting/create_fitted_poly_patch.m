% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function patch = create_fitted_poly_patch(px,py,n,rg,c,e)
persistent cache;
side=2*rg;
if ~isempty(cache) && cache{1}==e, [~,p]=deal(cache{:}); else
  p=fit_poly(n,c,e,side); cache={e,p};
end

x1=px-rg+1:px+rg;
y1=py-rg+1:py+rg;
f1=polyval(p,x1);
% plot(x1,f1,'*')

thresh=2.1;
A=abs(repmat(y1',1,side)-repmat(f1,side,1));
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
esz=numel(c.edge_x_coords{e});
x=zeros(1,esz); y=x;
for k=1:esz
  y(k)=c.edge_x_coords{e}(k)+patch_side; % adjust indices for the padded superpixelised image (+patch_side)
  x(k)=c.edge_y_coords{e}(k)+patch_side;
end

% also consider the end vertices
v1=c.vertices(c.edges(e,1),:)+patch_side; % fst coord is y - row ind
v2=c.vertices(c.edges(e,2),:)+patch_side;
x=[v1(2) x v2(2)];
y=[v1(1) y v2(1)];
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
