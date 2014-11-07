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
experimentsToPlot=experiments{2};

if nargin==0
  LOG.evalDir='/BS/kostadinova/work/video_segm_evaluation';
  LOG.ds.name='BSDS500';
end
LOG.dsDir=fullfile(LOG.evalDir, LOG.ds.name);

plotOpts=struct('path',fullfile(LOG.dsDir,'test'),'dirR','precomputed','superposePlot',true);

% TODO add avg human agreement ComputeRP(plotOpts.path,nthresh,benchmarkdir,requestdelconf,0,'k',false,[],'all',[],'Output_general_human');

% courtesy jhosang; colors for up to 28 curves
colorMap = [
0, 100, 0;
30, 144, 255;
75, 0, 130;
255, 20, 147;
153, 50, 204;
238, 130, 238;
135,206,235;
228, 229, 97;
0, 250, 154;
163, 163, 163;
218, 71, 56;
219, 135, 45;
145, 92, 146;
83, 136, 173;
255,228,225;
225, 119, 174;
142, 195, 129;
139, 69, 19;
240, 128, 128;
92, 172, 158;
177,89,40;
0, 255, 255;
188, 128, 189;
138, 180, 66;
255, 255, 0;
223, 200, 51;
0, 0, 205;
135, 130, 174;
] ./ 256;

% directories, labels and line styles for the precomputed results
% structure is defined in this manner to allow easy rearrangement of order of
% curves (in the legend)
% dataSfUcm is our baseline
dataSfUcm=struct('out','Output_sf_ucm','legend','SF ucm','style',{{'LineStyle','--'}}); % multiscale, model.opts.nms=1
dataBest=[...
  struct('out','Output_sf_segs','legend','SF watershed','style',{{}}),...
  dataSfUcm,...
  struct('out','Output_sf_sPb_nms','legend','SF + sPb','style',{{'LineStyle','--'}}),... % non-max-suppressed E as input to sPb
  struct('out','Output_MCG_downloaded','legend','MCG','style',{{}}),...
  struct('out','Output_BSDS_downloaded','legend','gPb+ucm','style',{{}})...
  ];
% our experiments
dataRSRI=[...
  struct('out','Output_RSRI_segs','legend','segs 256 RSRI','style',{{'Marker','x'}}),... % used to be calles 'CpdSegs', now 256
  struct('out','Output_RSRI_segs_merge','legend','s. merge RSRI','style',{{'Marker','x'}}),... % RSRI segs improved by merging some regions of the superpixelisation
  struct('out','Output_RSRI_segs_merge_Pb','legend','s. merge RSRI .*pb','style',{{'LineStyle','--','Marker','x'}}),... % segs merge RSRI, value-multiplied with the pb from create_finest_partition by Arbelaez
  struct('out','Output_RI','legend','RI (32640)','style',{{'LineStyle',':','Marker','x'}}),... % rather than RSRI, increases the nSample to the max, so we have a RI measure; same results, only slower (is it really slower?)
  struct('out','Output_line_RSRI','legend','l. RSRI','style',{{'Marker','x'}}),... % the first patch has only two segments - the fitted line
  ];
dataVPRnormTs=[... % VPR normalised on the side of the trees
  struct('out','Output_segs_VPR_normalised_trees','legend','s. VPR norm Ts','style',{{'Marker','x'}}),...
  struct('out','Output_segs_VPR_normalised_trees_pb','legend','s. VPR Ts .*pb','style',{{'LineStyle','--','Marker','x'}}),...
  struct('out','Output_line_VPR_normalised_trees','legend','line VPR norm Ts','style',{{'Marker','x'}}),...
  struct('out','Output_line_VPR_normalised_trees_pb','legend','l. VPR norm Ts .*pb','style',{{'LineStyle','--','Marker','x'}}),...
  ];
dataVPRnormWS=[... % VPR normalised on the side of the watershed
  struct('out','Output_segs_VPR_normalised_ws','legend','s. VPR norm ws','style',{{'Marker','x'}}),...
  struct('out','Output_segs_VPR_normalised_ws_pb','legend','s. VPR ws .*pb','style',{{'LineStyle','--','Marker','x'}}),...
  struct('out','Output_line_VPR_normalised_ws','legend','l. VPR norm ws','style',{{'Marker','x'}}),...
  struct('out','Output_line_VPR_normalised_ws_pb','legend','l. VPR norm ws .*pb','style',{{'LineStyle','--','Marker','x'}}),...
  ];
dataOracleSimple=[... % oracle - using the GT patches instead of the leaves of the SF trees
  struct('out','Output_oracle_segs_merge_RSRI','legend','oracle s. merge RSRI','style',{{'LineStyle','-.','Marker','*'}}),...
  struct('out','Output_oracle_line_RSRI','legend','o. l. RSRI','style',{{'LineStyle','-.','Marker','*'}}),...
  struct('out','Output_oracle_segs_VPR_normalised_trees','legend','o. s. VPR norm Ts','style',{{'LineStyle','-.','Marker','*'}}),...
  struct('out','Output_oracle_segs_VPR_normalised_ws','legend','o. s. VPR norm ws','style',{{'LineStyle','-.','Marker','*'}}),...
  struct('out','Output_oracle_line_VPR_normalised_ws','legend','o. l. VPR norm ws','style',{{'LineStyle','-.','Marker','*'}}),...
  ];
dataOraclePB=[... % oracle result value-multiplied by the probability of boundary
  struct('out','Output_oracle_line_RSRI_pb','legend','o. l. RSRI pb','style',{{'Marker','o'}}),...
  struct('out','Output_oracle_segs_VPR_normalised_trees_pb','legend','o. s. VPR norm Ts pb','style',{{'Marker','o'}}),...
  struct('out','Output_oracle_segs_VPR_normalised_ws_pb','legend','o. s. VPR norm ws pb','style',{{'Marker','o'}}),...
  struct('out','Output_oracle_line_VPR_normalised_ws_pb','legend','o. l. VPR norm ws pb','style',{{'Marker','o'}}),...
  ];
ksz=7;
k=num2str((1:ksz)');
out=num2cell([repmat('Output_bpr_',ksz,1) k],2)';
l=num2cell([repmat('l. BPR',ksz,1) k],2)';
dataBPR=struct('out',out,'legend',l,'style',{{'Marker','x'}});
dataOracleBPR=struct('out',{'Output_oracle_bpr_3' 'Output_oracle_bpr_4'},...
  'legend',{'o. l. BPR3' 'o. l. BPR4'},'style',{{'Marker','x'}});
dataContourBpr=struct('out','Output_contour_bpr3','legend','c. BPR3','style',{{}});
dataOracleContourBpr=struct('out','Output_oracle_contour_bpr3','legend','o. c. BPR3','style',{{}});
dataOracle=[dataOracleSimple,dataOraclePB,dataOracleBPR,dataOracleContourBpr];
dataOurs=[...
  dataRSRI,...
  struct('out','Output_segs_VPR_unnormalised','legend','s. VPR unnorm','style',{{'Marker','x'}}),... % unnormalised VPR
  dataVPRnormTs,...
  dataVPRnormWS,...% dataOracle,...  
  dataBPR(2:5),... % these are good values; when having to choose, set for 3px
  dataOracleBPR,...
  ];
dataOurs=[dataBPR(3:4) dataOracleBPR];
dataOurs=[dataOracleSimple,dataOracleBPR]; % all oracles
dataOurs=[dataBPR(3) dataOracleBPR(1)]; % why are we still worse than the baseline?; this motivates the hard-negative mining

dataOurs=[dataContourBpr dataOracleContourBpr]; % the new contour BPR + its oracle
dataOurs=[dataBPR(3) dataContourBpr]; % line vs contour BPR
dataOurs=[dataOracleBPR(1) dataOracleContourBpr]; % same, oracles comparison

switch experimentsToPlot
  case 'best'
    data=dataBest;
  case 'ours'
    % experiment for checking if anything is lost by reweighing only on the
    % boundary location
    % in all, the E (pb) is not nms (opts.model.nms=0), and detection was single scale
    data=[...
      struct('out','Output_SF_single_scale','legend','SF ucm','style',{{'Marker','x'}}),...
      struct('out','Output_SF_single_scale_on_contours','legend','SF ucm, on contours','style',{{'Marker','x'}}),...
      struct('out','Output_SF_single_scale_png','legend','SF edge','style',{{'Marker','x'}}),...
      struct('out','Output_SF_single_scale_on_contours_png','legend','SF edge, on contours','style',{{'Marker','x'}}),...
      ];
    % initial experiments with metrics and input types
    data=[...
      dataSfUcm,...
      struct('out','Output_VprBdry01','legend','VPR bdry01','style',{{'Marker','x'}}),... % unsuitable: struct('out','Output_VprBdry12','legend','VPR bdry12','style',{{'Marker','x'}}),...
      struct('out','Output_VprSegsUnnormalised','legend','VPR unnorm. segs','style',{{'Marker','x'}}),...
      struct('out','Output_RSRI_bdry01','legend','RSRI bdry01','style',{{'Marker','x'}}),...
      struct('out','Output_RSRI_segs','legend','RSRI segs','style',{{'Marker','x'}}),...
      ];
    % best performing from the above - RSRI_segs, improved in dataOurs
    data=[dataSfUcm,dataOurs];
  otherwise
    assert(strcmp(experimentsToPlot,'all'));
    data=[dataBest,dataOurs];
end

fhs=[1 6 9 11];
fsz=length(fhs); % number of figures, BPR, VPR, length statistics and number of clusters
l=cell(fsz,length(data)); % metric-specific label
cnt=0; % number of curves plotted
for d=1:length(data)
  plotOpts.plotStyle=[{colorMap(d,:)} data(d).style {'LineWidth',2,'MarkerSize',4}];
  plotOpts.outDirR=data(d).out;
  [output,fhs_curr]=ComputeRP(plotOpts);
  if isempty(fieldnames(output))
    warning('No output produced for directory %s',plotOpts.outDirR);
  else
    cnt=cnt+1;
    l(:,cnt)={data(d).legend};
    l{1,cnt}=[l{1,cnt} ' ' fscoreStr(output.B_G_ODS, output.B_G_OSS)]; % BPR
    if numel(fhs_curr) > 1, l{2,cnt}=[l{2,cnt} ' ' fscoreStr(output.R_G_ODS, output.R_G_OSS)]; end % VPR
  end
end
l=l(:,1:cnt);

if ~strcmp(experimentsToPlot,'ours'), [fhSf,legendSf]=plotBprForSfEdges(plotOpts); end

for f=1:fsz
  figure(fhs(f));
  l1=l(f,:);
  if exist('fhSf','var') && exist('legendSf','var') && isequal(f,fhSf), l1=[l(f,:) {legendSf}]; end
  legend(l1,'Location','NorthEastOutside');
  figTitle=get(get(gca,'Title'),'String');
  fileName=strrep(figTitle,' ','_');
  saveas(gcf,fullfile(plotOpts.path,plotOpts.dirR,['_',fileName]),'jpg');
end
close all;
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
