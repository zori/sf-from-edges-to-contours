% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
function [smallest, largest, num_nonzeros] = nonzeros_hist(pb)
% input is pb or ucm
nonzeros=pb(pb~=0);
num_nonzeros=length(nonzeros);
un=unique(nonzeros);
smallest=un(1);
largest=un(end);
initFig; hist(un);
end
