function Plotisofiglengthstats(isrecall)
%clear all;close all;clc;

if ( (~exist('isrecall','var')) || (isempty(isrecall)) )
    isrecall=true;
end

title('Length statistics');
hold on;


% colormap green
map=zeros(256,3); map(:,1)=0; map(:,2)=1; map(:,3)=0; colormap(map);

box on;
grid on;
set(gca,'YGrid','on');
set(gca,'XGrid','on');
title('');

if (isrecall)
    set(gca,'XTick',0:0.1:1);
    xlabel('Recall');
else
    set(gca,'YTick',0:0.1:1);
    ylabel('Precision');
end

% axis square;
% axis([0 1 0 1]);

%legend('Human','Location','NorthEast')

hold off
