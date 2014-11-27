% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function montage2title(mTitle)
% adds a title to a figure drawn using the montage2 function
set(gca,'Visible','on'); set(gca,'xtick',[]); set(gca,'ytick',[]);
title(mTitle);
end
