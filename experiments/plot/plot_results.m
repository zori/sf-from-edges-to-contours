% Zornitsa Kostadinova
% Jul 2014
function plot_results(LOG)
% Plot precomputed benchmark results (also from other algorithms).
%
% INPUT
%  LOG        - (optional) see runExperiment

% flag to indicate whether we are plotting the best curves or our experiments -
% the weighted (voted) ucms
experiments={'best','ours','all'};
experimentsToPlot=experiments{1};

if nargin==0
  LOG.evalDir='/BS/kostadinova/work/video_segm_evaluation';
  LOG.ds.name='BSDS500';
end
LOG.dsDir=fullfile(LOG.evalDir, LOG.ds.name);

plotOpts=struct('path',fullfile(LOG.dsDir,'test'),'dirR','precomputed','superposePlot',true);

% TODO add avg human agreement ComputeRP(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'k',false,[],'all',[],'Output_general_human');

colours=get_color_map();

data=get_plot_data(experimentsToPlot);

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

if ~strcmp(experimentsToPlot,'ours'), [fhSf,legendSf]=plot_BPR_for_SE(plotOpts); end

for f=1:fsz
  figure(fhs(f));
  l1=l(f,:);
  if exist('fhSf','var') && exist('legendSf','var') && isequal(f,fhSf), l1=[l(f,:) {legendSf}]; end
  if f==4 % ncluster precision
    legend_location='southeast';
  else
    legend_location='southwest';
  end
  legend(l1,'Location',legend_location);
  legend('boxoff'); % remove the legend border
  figTitle=get(get(gca,'Title'),'String');
  fileName=strrep(figTitle,' ','_');
  saveas(gcf,fullfile(plotOpts.path,plotOpts.dirR,['_',fileName]),'jpg');
end
close all;
end
