% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)
% modified jet colormap
%
% charless fowlkes, (c) 2007
% courtessy of Sam Hallman
function cmap = fademap;
% as seen on Oriented Edge Forests paper (arXiv Dec 2014)
cmap = jet(256);
fadein = linspace(0,1,100)';
cmap(1:length(fadein),3) = cmap(1:length(fadein),3).*fadein;
end
