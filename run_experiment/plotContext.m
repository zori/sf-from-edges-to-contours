% Zornitsa Kostadinova
% Jul 2014
function plotContext(LOG)
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
  LOG.dsDir=fullfile(LOG.evalDir, LOG.ds.name);
end

plotOpts=struct('path',fullfile(LOG.dsDir,'test'),'dirR','precomputed','superposePlot',true);

% TODO add avg human agreement ComputeRP(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'k',false,[],'all',[],'Output_general_human');

% directories, labels and colors for the precomputed results
% structure is defined in this manner to allow easy rearrangement of order of
% curves (in the legend)
switch experimentsToPlot
  case 'best'
    data=[...
      struct('outDir','Output_sf_segs','legend','SF watershed','color','b'),...
      struct('outDir','Output_sf_ucm','legend','SF ucm','color','m--'),...
      struct('outDir','Output_sf_sPb','legend','SF + sPb','color','g--'),...
      struct('outDir','Output_mcg_downloaded','legend','MCG','color','c'),...
      struct('outDir','Output_bsds_downloaded','legend','gPb+ucm','color','y')...
      ];
  case 'ours'
    % initial experiments with metrics and input types
    data=[...
      struct('outDir','Output_sf_ucm','legend','SF ucm','color','k-x'),...
      struct('outDir','Output_VprBdry01','legend','VprBdry01','color','c-x'),... % unsuitable: struct('outDir','Output_VprBdry12','legend','VprBdry12','color','y'),...
      struct('outDir','Output_VprSegs','legend','VprSegs','color','g-x'),...
      struct('outDir','Output_CpdBdry01','legend','CpdBdry01','color','b-x'),...
      struct('outDir','Output_CpdSegs','legend','CpdSegs','color','r-x'),...
      ];
    % best performing from the above - CpdSegs
    data=[...
      struct('outDir','Output_sf_ucm','legend','SF ucm','color','k-x'),...
      struct('outDir','Output_CpdSegs','legend','vote','color','r-x'),...
      struct('outDir','Output_sf_vote','legend','vote++','color','g--x'),... % CpdSegs improved by merging some regions of the superpixelisation
      struct('outDir','Output_Pri_vote','legend','PRI vote','color','m:x'),... % rather than CPD, increases the nSample to the max, so we have a PRI measure; same results, only slower
      struct('outDir','Output_sf_votePb','legend','vote .* pb','color','b-x'),... % vote++ multiplied with the pb from create_finest_partition by Arbelaez
      ];
  otherwise
    assert(strcmp(experimentsToPlot,'all'));
    data=[...
      struct('outDir','Output_sf_segs','legend','SF watershed','color','b'),...
      struct('outDir','Output_sf_ucm','legend','SF ucm','color','m--'),...
      struct('outDir','Output_sf_sPb','legend','SF + sPb','color','g--'),...
      struct('outDir','Output_mcg_downloaded','legend','MCG','color','c'),...
      struct('outDir','Output_bsds_downloaded','legend','gPb+ucm','color','y')...
      struct('outDir','Output_CpdSegs','legend','vote','color','r-x'),...
      struct('outDir','Output_sf_vote','legend','vote++','color','g--x'),... % CpdSegs improved by merging some regions of the superpixelisation
      struct('outDir','Output_Pri_vote','legend','PRI vote','color','m:x'),... % rather than CPD, increases the nSample to the max, so we have a PRI measure; same results, only slower
      struct('outDir','Output_sf_votePb','legend','vote .* pb','color','b-x'),... % vote++ multiplied with the pb from create_finest_partition by Arbelaez
      ];
end

fsz=4; % number of figures, BPR, VPR, length statistics and number of clusters
l=repmat({data.legend},[fsz 1]); % metric-specific label
for d=1:length(data)
  plotOpts.curveColor=data(d).color;
  plotOpts.outDirR=data(d).outDir;
  [output,fhs]=ComputeRP(plotOpts);
  l{1,d}=[l{1,d} ' ' fscoreStr(output.B_G_ODS, output.B_G_OSS)]; % BPR
  l{2,d}=[l{2,d} ' ' fscoreStr(output.R_G_ODS, output.R_G_OSS)]; % VPR
end

if ~strcmp(experimentsToPlot,'ours'), [fhSf,legendSf]=plotBprForSfEdges(plotOpts); end

assert(isequal(fsz,length(fhs)));
for f=1:fsz
  figure(fhs(f));
  l1=l(f,:);
  if exist('fhSf','var') && exist('legendSf','var') && isequal(f,fhSf), l1=[l(f,:) {legendSf}]; end
  legend(l1,'Location','NorthEastOutside');
  figTitle=get(get(gca,'Title'),'String');
  fileName=strrep(figTitle,' ','_');
  saveas(gcf,fullfile(plotOpts.path,plotOpts.dirR,['_',fileName]),'jpg');
end
end

% ----------------------------------------------------------------------
function str=fscoreStr(ODS,OSS)
str=sprintf('[ODS %1.2f, OSS %1.2f]',ODS,OSS);
end

% ----------------------------------------------------------------------
function [fhSf,legendSf] = plotBprForSfEdges(plotOpts)
% SF is an edge detector; segmentation benchmarks are not applicable, only BPR
plotOpts.outDirR='Output_sf_edges';
plotOpts.metrics='bdry';
plotOpts.curveColor='k';
[output,fhSf]=ComputeRP(plotOpts);
legendSf=['SF edge ' fscoreStr(output.B_G_ODS, output.B_G_OSS)];
end
