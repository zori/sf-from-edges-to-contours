% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
function patch = create_fitted_conic_patch(px,py,rg,c,e)
persistent cache;
patch_side=2*rg;
if ~isempty(cache) && cache{1}==e, [~,p,D]=deal(cache{:}); else
  [p,D]=fit_conic(c,e,patch_side); cache={e,p,D};
end

xgv=px-rg+1:px+rg;
ygv=py-rg+1:py+rg;

[X,Y]=meshgrid(xgv,ygv);
A=patch_coords_to_conic(X(:),Y(:));
Z=A*p;
Z=reshape(Z,length(ygv),length(xgv));
% initFig;surf(X,Y,Z);
% initFig;contour(X,Y,Z,[0 0]);
% initFig;contour(Z)

% mark transitions between non-positive and positive locations
pos=Z>0;
patch=mark_transitions(~pos,pos);
% 0-1 result - 1=boundary, 0=no boundary
%patch=double(patch==0);

if D>0
  % hyperbola
  % initFig;im(patch);
  [x,y]=edge_coords_in_patch_space(c,e,patch_side);
  % go back to 1-16 coords:
  x=x-(px-rg); y=y-(py-rg);
  % get only those edges that are withinthe patch
  ind=0<x & x<=patch_side & 0<y & y<=patch_side;
  x=x(ind); y=y(ind);
  edge_patch=zeros(patch_side);
  edge_patch(sub2ind(size(edge_patch),y,x))=1;
  d=bwdist(edge_patch);
  
  hyperbola_arms=bwlabel(patch); % the two arms (if 2 are present) will be labeled '1' and '2'
  if ~isempty(find(hyperbola_arms==2))
    % two separated arms of the hyperbola
    % choose the label that minimizes the distance to the edge
    arm{1}=d(hyperbola_arms==1); arm{2}=d(hyperbola_arms==2);
    if mean(arm{1})<mean(arm{2})
      l=1;
    else
      l=2;
    end
    patch=double(hyperbola_arms==l);
  else
    % the arms of the hyperbola touch
    % choose based on the minimising segment
    segs=bwlabel(~patch,4);
    u=unique(segs); u=u(u>0); usz=length(u); m=zeros(size(u));
    for k=1:usz
      m(k)=mean(d(segs==u(k)));
    end
    [~,l]=min(m);
    patch=mark_transitions(patch,segs==l);
  end
  % initFig;im(edge_patch);
  % initFig;im(patch);
else
  ; % not a hyperbola
end
if all(patch(:)==0)
  % warning('no conic intersection; fitting a line');
  patch=create_fitted_line_centre_patch(px,py,rg,c,e);
end
end

% ----------------------------------------------------------------------
function X = patch_coords_to_conic(x,y)
n_observations=length(x);
assert(size(x,2)==1 && size(y,2)==1 && size(x,1)==size(y,1) && size(x,1)==n_observations);
X = [x.*x x.*y y.*y x y ones(n_observations,1)];
% X = [x.*y x y ones(n_observations,1)]; % this was an attempt to lower the degree of the model that we fit; could quite possibly also be done in 'fit_conic' function below, see comment about "fix the learnt parameters to sum to 1"
end

% ----------------------------------------------------------------------
function [p,D] = fit_conic(c,e,patch_side)
[x,y]=edge_coords_in_patch_space(c,e,patch_side);

% we solve A*p=b where p is the parameter to be learnt (by minimisation)
% A=[(x.*x)' (x.*y)' (y.*y)' x' y' ones(length(x),1)];
% A contains observed variables
A=patch_coords_to_conic(x,y);
% b is the result - 0 for any input, as the points lie on the curve
b=zeros(length(x),1);
% fix the learnt parameters to sum to 1 (last value of b)
A(end+1,:)=ones(1,size(A,2));
% % try sth different
% A(end+1,:)=zeros(1,size(A,2));
% A(end,1:3)=1;
b(end+1)=1;

% p_opt1=A\b; % fewer non-zero components
% p_opt2=pinv(A)*b; % smallest norm
% p=A\b;
p=pinv(A)*b;
assert(all(~isnan(p)) && all(~isinf(p)));
% discriminant classification of the conic section
D=p(2).^2-4.*p(1).*p(3);
if D>0
  ; % hyperbola
  % warning('hyperbola');
else
  if D<0
    ; % ellipse
  else
    ; % parabola
  end
end

% plot(x,y,'o')
% hold on
end
