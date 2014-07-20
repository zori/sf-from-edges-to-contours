% Zornitsa Kostadinova
% Jul 2014
function plotContext(LOG)
% Plot precomputed benchmark results (also from other algorithms).
%
% INPUT
%  LOG        - see runExperiment

plotOpts=struct('path',fullfile(LOG.dsDir,'test'),'dirR','precomputed',...
  'outDirR',fullfile('recordings', LOG.timestamp),...
  'tempConsistency',LOG.dss(LOG.dsId).isVideo,...
  'nthresh',51,'superposePlot',true);

% TODO add avg human agreement ComputeRP(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'k',false,[],'all',[],'Output_general_human');
% directories, labels and colors for the precomputed results
data=struct('outDir',{'Output_srf_dollar','Output_df_vanilla_watershed_over-seg','Output_df_ucm','Output_df_and_sPb','Output_mcg'},...
  'legend',{'DF structured edge','DF watershed over-segmentation','UCM','DF + sPb','MCG'},...
  'color',{'g','b','m','r.','c'});

for k=1:length(data)
  plotOpts.curveColor=data(k).color;
  plotOpts.outDirR=data(k).outDir;
  [~,fhs]=ComputeRP(plotOpts);
end
for k=1:length(fhs)
  figure(fhs(k));
  legend(data.legend,'Location','NorthEastOutside');
  figTitle=get(get(gca,'Title'),'String');
  fileName=strrep(figTitle,' ','_');
  saveas(gcf,fullfile(plotOpts.path,plotOpts.dirR,['_',fileName]),'jpg');
end
end
