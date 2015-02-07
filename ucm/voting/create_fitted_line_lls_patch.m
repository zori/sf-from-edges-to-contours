% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)
function patch = create_fitted_line_lls_patch(px,py,rg,c,e)
patch_side=2*rg;
% Linear least squares fit (minimisation) to the edge data:
[x_all,y_all]=edge_coords_in_patch_space(c,e,patch_side);

% current_edge=zeros(size(c.skel));
% for k=1:length(x_all)
%   current_edge(y_all(k),x_all(k))=1;
% end
% initFig;im(current_edge);

% we solve Afc*p=b where p is the parameter to be learnt (by minimisation)
% Afc contains observed variables
Afc=fit_patch_coords_to_model(x_all,y_all);
% b is the result - 0 for any input, as the points lie on the curve
b=zeros(length(x_all),1);
% fix the learnt parameters to sum to 1 (last value of b)
Afc(end+1,:)=ones(1,size(Afc,2));
b(end+1)=1;

% to be able to visualise the edge patch
% go back to 1-16 coords:
x=x_all-(px-rg); y=y_all-(py-rg);
% get only those edges that are within the patch
ind=0<x & x<=patch_side & 0<y & y<=patch_side;
x=x(ind); y=y(ind);
edge_patch=zeros(patch_side);
edge_patch(sub2ind(size(edge_patch),y,x))=1;

% p_opt1=Afc\b; % fewer non-zero components
% p_opt2=pinv(Afc)*b; % smallest norm
% p=Afc\b;
p=pinv(Afc)*b;
assert(all(~isnan(p)) && all(~isinf(p)));

% plot(x,y,'o')
% hold on

xgv=px-rg+1:px+rg;
ygv=py-rg+1:py+rg;

[X,Y]=meshgrid(xgv,ygv);
A_model=fit_patch_coords_to_model(X(:),Y(:));
Z=A_model*p;
Z=reshape(Z,length(ygv),length(xgv));
% initFig;surf(X,Y,Z);
% initFig;contour(X,Y,Z,[0 0]);
% initFig;contour(Z)
% initFig;im(edge_patch);

% mark transitions between non-positive and positive locations
pos=Z>0;
patch=mark_transitions(~pos,pos);
% 0-1 result - 1=boundary, 0=no boundary

if all(patch(:)==0)
  % warning('no line intersection; fitting using another line fitting function');
  patch=create_fitted_line_centre_patch(px,py,rg,c,e);
end
end

% ----------------------------------------------------------------------
function X = fit_patch_coords_to_model(x,y)
n_observations=length(x);
assert(size(x,2)==1 && size(y,2)==1 && size(x,1)==size(y,1) && size(x,1)==n_observations);
X = [x y ones(n_observations,1)];
end
