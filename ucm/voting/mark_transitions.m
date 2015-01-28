% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)
function fst_borders = mark_transitions(fst,snd)
% mark the locations of fst that are bordering with snd (i.e., the transitional
% pixels)
% fst and snd must be binary matrices of the same dimensions
sz=size(fst);
assert(all(sz==size(snd)));
fst_borders=zeros(sz);
% -> (to the right)
fst_borders(:,1:end-1)=fst_borders(:,1:end-1) | (fst(:,1:end-1) & snd(:,2:end));
% <- (to the left)
fst_borders(:,2:end)=fst_borders(:,2:end) | (fst(:,2:end) & snd(:,1:end-1));
% v (down)
fst_borders(1:end-1,:)=fst_borders(1:end-1,:) | (fst(1:end-1,:) & snd(2:end,:));
% ^ (up)
fst_borders(2:end,:)=fst_borders(2:end,:) | (fst(2:end,:) & snd(1:end-1,:));
end
