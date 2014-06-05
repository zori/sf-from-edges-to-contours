function Init_figure_no(nofigure,figuretitle,remticks)

figure(nofigure), clf, set(gcf, 'color', 'white');

if (exist('figuretitle','var') && (~isempty(figuretitle)) )
    title(figuretitle);
end

if ( (~exist('remticks','var')) || (isempty(remticks)) || (remticks) ) %Removes ticks by default
    set(gca,'xtick',[],'ytick',[]);
end

% axis off;
% set(gca,'FontSize',17);

% print('-dpng','Affinity2aba.png')
% print('-depsc2','Affinity2aba.eps')
