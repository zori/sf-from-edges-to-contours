% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function O = edgeOrient( E, r )
% compute very approximate orientation map from edge map
E2=convTri(E,r); f=[-1 2 -1];
Dx=conv2(E2,f,'same'); Dy=conv2(E2,f','same');
F=conv2(E2,[1 0 -1; 0 0 0; -1 0 1],'same')>0;
Dy(F)=-Dy(F); O=mod(atan2(Dy,Dx),pi);
end
