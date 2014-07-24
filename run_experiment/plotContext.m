% Zornitsa Kostadinova
% Jul 2014
function plotContext(LOG)
% Plot precomputed benchmark results (also from other algorithms).
%
% INPUT
%  LOG        - (optional) see runExperiment

if nargin==0
  LOG.evalDir='/BS/kostadinova/work/video_segm_evaluation';
  LOG.ds=struct('name','BSDS500','isVideo',false);
  LOG.dsDir=fullfile(LOG.evalDir, LOG.ds.name);
end

plotOpts=struct('path',fullfile(LOG.dsDir,'test'),'dirR','precomputed',...
  'tempConsistency',LOG.ds.isVideo,'nthresh',51,'superposePlot',true);

% TODO add avg human agreement ComputeRP(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'k',false,[],'all',[],'Output_general_human');

% directories, labels and colors for the precomputed results
% structure is defined in this manner to allow easy rearrangement of order of
% curves
data=[...
  struct('outDir','Output_sf_watershed','legend','SF watershed','color','b'),...
  struct('outDir','Output_sf_ucm','legend','SF ucm','color','m--'),...
  struct('outDir','Output_sf_and_sPb','legend','SF + sPb','color','g--'),...
  struct('outDir','Output_mcg_downloaded','legend','MCG','color','c'),...
  struct('outDir','Output_bsds_downloaded','legend','gPb+ucm','color','y')...
  ];

fsz=4; % number of figures, BPR, VPR, length statistics and number of clusters
l=repmat({data.legend},[fsz 1]); % metric-specific label
for d=1:length(data)
  plotOpts.curveColor=data(d).color;
  plotOpts.outDirR=data(d).outDir;
  [output,fhs]=ComputeRP(plotOpts);
  l{1,d}=[l{1,d} ' ' fscoreStr(output.B_G_ODS, output.B_G_OSS)]; % BPR
  l{2,d}=[l{2,d} ' ' fscoreStr(output.R_G_ODS, output.R_G_OSS)]; % VPR
end

% BPR for SF edges
plotOpts.outDirR='Output_sf_edges';
plotOpts.metrics='bdry';
plotOpts.curveColor='k';
[output,fhSf]=ComputeRP(plotOpts);
legendSf=['SF edge ' fscoreStr(output.B_G_ODS, output.B_G_OSS)];

assert(isequal(fsz,length(fhs)));
for f=1:fsz
  figure(fhs(f));
  l1=l(f,:);
  if isequal(f,fhSf), l1=[l(f,:) {legendSf}]; end
  legend(l1,'Location','NorthEastOutside');
  figTitle=get(get(gca,'Title'),'String');
  fileName=strrep(figTitle,' ','_');
  saveas(gcf,fullfile(plotOpts.path,plotOpts.dirR,['_',fileName]),'jpg');
end
end

function str=fscoreStr(ODS,OSS)
  str=sprintf('[ODS %1.2f, OSS %1.2f]',ODS,OSS);
end
