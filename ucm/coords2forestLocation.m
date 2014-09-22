% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function [treeIds,leafIds,x1,y1] = coords2forestLocation(x,y,ind,opts,p,nTreeNodes)
[x1,y1]=transformCoords(x,y,p,opts);
ids=double(ind(y1,x1,:)); % indices come from cpp and are 0-based
treeIds=uint32(floor(ids./nTreeNodes)+1);
leafIds=uint32(mod(ids,nTreeNodes)+1);
end

function [x1,y1] = transformCoords(x,y,p,opts)
% transform the coordinates to correctly index into ind
rg=opts.gtWidth/2; % patch radius 8
x1=ceil(((x+p(3))-opts.imWidth)/opts.stride)+rg; % rg<=x1<=w1, for w1 see edgesDetectMex.cpp
y1=ceil(((y+p(1))-opts.imWidth)/opts.stride)+rg; % rg<=y1<=h1
% assert((x1==ceil(x/2)) && (y1==ceil(y/2)));
end
