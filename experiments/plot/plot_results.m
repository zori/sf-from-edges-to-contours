% Zornitsa Kostadinova
% Jul 2014
function plot_results(LOG)
% Plot precomputed benchmark results (also from other algorithms).
%
% INPUT
%  LOG        - (optional) see runExperiment

% flag to indicate whether we are plotting the best curves or our experiments -
% the weighted (voted) ucms
experiments={'best','ours','all','mid-masters','masters-thesis'};
experiments_to_plot=experiments{5};

if nargin==0
  LOG.evalDir='/BS/kostadinova/work/video_segm_evaluation';
  LOG.ds.name='BSDS500';
end
LOG.dsDir=fullfile(LOG.evalDir, LOG.ds.name);

plotOpts=struct('path',fullfile(LOG.dsDir,'test'),'dirR','precomputed','superposePlot',true);

colours=get_colour_map(experiments_to_plot);

data=get_plot_data(experiments_to_plot);

% avg human agreement (on BPR)
% R=0.7 P=0.9 Human [F = 0.79]
plot_human=true;
plot_human=false;
Init_figure_no(1), Plotisofigregpr(); hold on;
if plot_human
  Init_figure_no(1), Plotisofigregpr(); hold on;
  colour_green_house=[0 129 0]./256;
  plot(0.7,0.9,'o','MarkerFaceColor',colour_green_house,'MarkerSize',12);
end

fhs=[1 6 9 11];
fsz=length(fhs); % number of figures, BPR, VPR, length statistics and number of clusters
l=cell(fsz,length(data)); % metric-specific label
cnt=0; % number of curves plotted
for d=1:length(data)
  plotOpts.plotStyle=[{colours(d,:)} data(d).style {'LineWidth',2,'MarkerSize',4}];
  plotOpts.outDirR=data(d).out;
  [output,fhs_curr]=ComputeRP(plotOpts);
  if isempty(fieldnames(output))
    warning('No output produced for directory %s',plotOpts.outDirR);
  else
    cnt=cnt+1;
    l(:,cnt)={data(d).legend};
    l{1,cnt}=[l{1,cnt} ' ' fscore_str(output.B_G_ODS, output.B_G_OSS)]; % BPR
    if numel(fhs_curr) > 1, l{2,cnt}=[l{2,cnt} ' ' fscore_str(output.R_G_ODS, output.R_G_OSS)]; end % VPR
  end
end
l=l(:,1:cnt);

% if ~strcmp(experiments_to_plot,'ours'), [fhSf,legendSf]=plot_BPR_for_SE(plotOpts); end

for f=1:fsz
  figure(fhs(f));
  l1=l(f,:);
  if f==1 && plot_human, l1=[{'human [F=0.79]'} l1]; end % according to the Arbelaez11 paper, it might be F=0.80
  if exist('fhSf','var') && exist('legendSf','var') && isequal(f,fhSf), l1=[l1 {legendSf}]; end
  if f==4 % ncluster precision
    legend_location='southeast';
  else
    legend_location='southwest';
  end
  % legend(cell(l1),'Location',legend_location);
  legend(cell(l1),'Location',legend_location,'FontSize',20,'FontWeight','bold'); % for presentations and papers
  % legend(cell(l1),'Location',legend_location,'FontSize',16,'FontWeight','bold'); % for the oracles example (9 curves) presentations and papers
  % legend('boxoff'); % remove the legend border % not good when the background is the isocurves
  figTitle=get(get(gca,'Title'),'String');
  fileName=strrep(figTitle,' ','_');
  saveas(gcf,fullfile(plotOpts.path,plotOpts.dirR,['_',fileName]),'png');
end
close all;
end
