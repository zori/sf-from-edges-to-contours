% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function hard_negatives_mining()
load('hard_negatives_mining');
for k=vi, data(k).mean=cellfun(@mean,votes{k}); end

for k=1:dsz, u{k}=unique(data(k).ucm2); end
for k=1:dsz, l(k)=length(u{k}); end
% "see" that values are roughly on the same scale
% for k=1:sz, disp(u{k}(1:5)); end
% for k=1:sz, disp(u{k}(end-5:end)); end

d=abs(data(1).ucm2-data(3).ucm2); % diff with oracle
% d=abs(ucms{1}-ucms{2}); % diff with baseline
d=d .* ~(isnan(data(1).mean) | isnan(data(1).mean)); % TODO why isnan when we have voted there
sz=size(data(1).ucm2);
r=16;
[~,sort_ind]=sort(d(:),'descend'); % TODO instead, do top 5 unique
maxIndex=sort_ind(1:555);  % linear index of the 5 largest values
[ys,xs]=ind2sub(sz,maxIndex);
inds=find(ys+r<=sz(1) & xs+r<=sz(2));
for ind=inds(1:10:100)'
  x=xs(ind); y=ys(ind);
  initFig(1); im(data(3).ucm2); hold on; plot(x,y,'x','MarkerSize',20);
  % for k=1:usz, initFig(); im(ucms{k}); hold on; plot(x(ind),y(ind),'x', 'MarkerSize',20); end
  for k=vi
    cps{k}=cropPatch(data(k).ucm2,x,y,r);
    initFig(); im(cps{k});
    disp(data(k).ucm2(y,x));
    disp(votes{k}{y,x}');
    mcps{k}=cropPatch(data(k).mean,x,y,r);
    initFig(); im(mcps{k}); hold on; plot(r,r,'x');
  end
  % figure; im(d(1).mean); hold on; plot(x,y,'x','MarkerSize',20)
  % processLocation();
end

for k=1:length(gts), initFig(); im(gts{k}); end
for k=1:dsz, initFig(); im(data(k).seg); end
close all;
end
