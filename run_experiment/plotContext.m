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
experimentsToPlot=experiments{2};

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
dataSfUcm=struct('out','Output_sf_ucm','legend','SF ucm','style',{{'m','LineStyle','--'}});
dataBest=[...
  struct('out','Output_sf_segs','legend','SF watershed','style',{{'b'}}),...
  dataSfUcm,...
  struct('out','Output_sf_sPb','legend','SF + sPb','style',{{'g','LineStyle','--'}}),...
  struct('out','Output_mcg_downloaded','legend','MCG','style',{{'c'}}),...
  struct('out','Output_bsds_downloaded','legend','gPb+ucm','style',{{'y'}})...
  ];
dataOurs=[...
  struct('out','Output_CpdSegs','legend','vote','style',{{'r','Marker','x'}}),...
  struct('out','Output_sf_vote','legend','vote++','style',{{'g','Marker','x'}}),... % CpdSegs improved by merging some regions of the superpixelisation
  struct('out','Output_sf_votePb','legend','vote .* pb','style',{{'b','Marker','x'}}),... % vote++ multiplied with the pb from create_finest_partition by Arbelaez
  struct('out','Output_Pri_vote','legend','PRI','style',{{[0.6,0.2,0.6],'LineStyle',':','Marker','x'}}),... % rather than CPD, increases the nSample to the max, so we have a PRI measure; same results, only slower
  struct('out','Output_VprSegsNormalised','legend','VprSegsNormalised','style',{{[1,0.5,0.5],'Marker','x'}}),... % normalised VPR
  struct('out','Output_VprSegsUnnormalised','legend','VprSegsUnnormalised','style',{{[0.2,0.8,0.2],'Marker','x'}}),... % unnormalised VPR
  ];
switch experimentsToPlot
  case 'best'
    data=dataBest;
  case 'ours'
    % initial experiments with metrics and input types
    data=[...
      dataSfUcm,...
      struct('out','Output_VprBdry01','legend','VprBdry01','style',{{'c','Marker','x'}}),... % unsuitable: struct('out','Output_VprBdry12','legend','VprBdry12','style',{{'y'}}),...
      struct('out','Output_VprSegsUnnormalised','legend','VprSegs (Unnormalised)','style',{{'g','Marker','x'}}),...
      struct('out','Output_CpdBdry01','legend','CpdBdry01','style',{{'b','x'}}),...
      struct('out','Output_CpdSegs','legend','CpdSegs','style',{{'r','x'}}),...
      ];
    % best performing from the above - CpdSegs, improved
    data=[dataSfUcm,dataOurs];
  otherwise
    assert(strcmp(experimentsToPlot,'all'));
    data=[dataBest,dataOurs];
end

fsz=4; % number of figures, BPR, VPR, length statistics and number of clusters
l=repmat({data.legend},[fsz 1]); % metric-specific label
for d=1:length(data)
  plotOpts.plotStyle=data(d).style;
  plotOpts.outDirR=data(d).out;
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
plotOpts.plotStyle={'k'};
[output,fhSf]=ComputeRP(plotOpts);
legendSf=['SF edge ' fscoreStr(output.B_G_ODS, output.B_G_OSS)];
end
