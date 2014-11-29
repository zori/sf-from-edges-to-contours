% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
data=[...
  struct('out','Output_sf_segs','legend','SE watershed','style',{{}}),...
  struct('out','Output_sf_ucm','legend','SE ucm','style',{{'LineStyle','--'}}),...
  struct('out','Output_sf_sPb_nms','legend','SE + sPb','style',{{'LineStyle','--'}}),... % non-max-suppressed E as input to sPb
  struct('out','Output_MCG_downloaded','legend','MCG','style',{{}}),...
  struct('out','Output_BSDS_downloaded','legend','gPb+ucm','style',{{}})...
  ];

eval_dir='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test';
plotOpts=struct('path',eval_dir,'dirR','precomputed','superposePlot',true);
for d=1:length(data)
  plotOpts.plotStyle=[{[30, 144, 255]./255} data(d).style {'LineWidth',2,'MarkerSize',4}];
  plotOpts.outDirR=data(d).out;
  [output,fhs_curr]=ComputeRP(plotOpts);
end
[fhSf,legendSf]=plot_BPR_for_SE(plotOpts);
