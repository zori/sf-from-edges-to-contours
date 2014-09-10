% Zornitsa Kostadinova
% Jul 2014
function plotContext(LOG)
% Plot precomputed benchmark results (also from other algorithms).
%
% INPUT
%  LOG        - (optional) see runExperiment

% flag to indicate whether we are plotting the standard curves or the weighted
% (voted) ucms
PLOT_STANDARD=true;

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
if PLOT_STANDARD
  data=[...
    struct('outDir','Output_sf_segs','legend','SF watershed','color','b'),...
    struct('outDir','Output_sf_ucm','legend','SF ucm','color','m--'),...
    struct('outDir','Output_sf_sPb','legend','SF + sPb','color','g--'),...
    struct('outDir','Output_mcg_downloaded','legend','MCG','color','c'),...
    struct('outDir','Output_bsds_downloaded','legend','gPb+ucm','color','y')...
    ];
else
  data=[...
    struct('outDir','Output_VprBdry12','legend','VprBdry12','color','g')];
% 
%   struct('outDir','Output_sf_ucm','legend','SF ucm','color','m--'),...
%     struct('outDir','Output_VprBdry01','legend','VprBdry01','color','r'),...
%     struct('outDir','Output_VprBdry12','legend','VprBdry12','color','g'),...
%     struct('outDir','Output_VprSegs','legend','VprSegs','color','b'),...
%     struct('outDir','Output_CpdBdry01','legend','CpdBdry01','color','c'),...
%     struct('outDir','Output_CpdSegs','legend','CpdSegs','color','y'),...
%     ];
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

if PLOT_STANDARD, [fhSf,legendSf]=plotBprForSfEdges(plotOpts); end

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
% BPR for SF edges
plotOpts.outDirR='Output_sf_edges';
plotOpts.metrics='bdry';
plotOpts.curveColor='k';
[output,fhSf]=ComputeRP(plotOpts);
legendSf=['SF edge ' fscoreStr(output.B_G_ODS, output.B_G_OSS)];
end
