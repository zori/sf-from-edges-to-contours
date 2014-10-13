% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function ENew = edgesDetectOnContours(I,model)
opts=model.opts;
ri=opts.imWidth/2; % patch radius 16
rg=opts.gtWidth/2; % patch radius 8
% pad image, making divisible by 4
szOrig=size(I); pd=[ri ri ri ri];
pd([2 4])=pd([2 4])+mod(4-mod(szOrig(1:2)+2*ri,4),4);
IPadded=imPad(I,pd,'symmetric');
% compute feature channels
[chnsReg,chnsSim]=edgesChns(IPadded,model.opts);
% apply forest to image
Es=edgesDetectMex(model,chnsReg,chnsSim);
% normalize and finalize edge maps
t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval;
Es_=Es(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg)*t;
E=convTri(Es_,1);

ws=watershed(E);

c=fit_contour(double(ws==0));
% remove empty fields
c=rmfield(c,{'edge_equiv_ids','regions_v_left','regions_v_right','regions_e_left','regions_e_right','regions_c_left','regions_c_right'});
nEdges=numel(c.edge_x_coords);
EsNew=zeros(size(Es));
for e=1:nEdges
  if c.is_completion(e), continue; end % TODO why?
  for p=1:numel(c.edge_x_coords{e})
    % NOTE x and y are swapped here (in the output from fit_contour)
    % the correct way is (for an image of dimensions h x w x 3)
    % first coord, in [1,h], is y, second coord, in [1,w], is x
    ey=c.edge_x_coords{e}(p); ex=c.edge_y_coords{e}(p);
    % transformCoords, COPY-PASTED from coords2forestLocation
    x1=ceil(((ex+pd(3))-opts.imWidth)/opts.stride)+rg; % rg<=x1<=w1, for w1 see edgesDetectMex.cpp
    y1=ceil(((ey+pd(1))-opts.imWidth)/opts.stride)+rg; % rg<=y1<=h1
    Es4=edgesDetectMex(model,chnsReg,chnsSim,x1,y1);
    EsNew=EsNew+Es4;
  end
end % for e - edge index
Es_New=EsNew(1+rg:szOrig(1)+rg,1+rg:szOrig(2)+rg)*t;
ENew=convTri(Es_New,1);
end
