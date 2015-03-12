
% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)

% plots that will be in the thesis; copy-pasted from throughout
% get_plot_data_* , which comprehensively contain all our experiments
%
% purpose of this is to be able to freely change the legend depending on where
% the plot is to be featured

% IMPORTANT
% here we redefine how the baseline is labelled in the legend:
% data_SE_ucm_irreproducible_baseline=struct('out','Output_sf_ucm','legend','16x16 (baseline)','style',{{'LineStyle','--'}});
data_SE_ucm_irreproducible_baseline=struct('out','Output_sf_ucm','legend','SE-UCM','style',{{'LineStyle','--'}});
data_SE_ucm_baseline=data_SE_ucm_irreproducible_baseline;

% plots for chapter 5 - ``experiment''
% 1
data_SE_vs_gPb_OWT_UCM=[
  struct('out','Output_SE_no_nms_single_scale','legend','Structured edge','style',{{}}),... % only edge detection!
  struct('out','Output_BSDS_downloaded','legend','gPb-OWT-UCM','style',{{}})
  ];

% 2
% vanilla watershed
data_SE_watershed=struct('out','Output_sf_segs','legend','SE-watershed','style',{{}});

% 3
% (SE+sPb)-OWT-UCM
% not-nms performs slightly worse, but it is fair to compare with us, since we cannot apply watershed on top of thinned edges
data_SE_sPb_OWT_UCM=[
  struct('out','Output_BSDS_downloaded','legend','gPb-OWT-UCM','style',{{}})... % gPb+ucm  
  struct('out','Output_sf_sPb_nnms','legend','(SE+sPb)-OWT-UCM','style',{{}})... % '(SE nonnms+sPb)-UCM' % not-nms
  ];

data_segs_to_greedy_merge_RIMC=[ % RIMC metric on 3 watershed transformations
  struct('out','Output_RSRI_segs','legend','Oversegmentation','style',{{'Marker','x'}}),... %'segs 256 RIMC' % used to be calles 'CpdSegs', now 256
  struct('out','Output_RSRI_segs_merge','legend','Naive greedy merge','style',{{'Marker','x'}}),... % 's. merge RIMC' % RSRI segs improved by merging some regions of the superpixelisation
  struct('out','Output_fair_segs_merge','legend','Fair greedy merge','style',{{'Marker','x'}}),... % 'fair s. merge RIMC'
  ];

% 
% watershed arc - `line fitting (end) BPR3' vs `contour BPR3'
data_watershed_arc_BPR3=[ % scoring function for both: BPR with distance threshold for the bipartite matching = 3 pixels
  struct('out','Output_bpr_3','legend','fitted line','style',{{'Marker','x'}}),...
  struct('out','Output_contour_bpr3','legend','watershed arc','style',{{'Marker','x'}})
  ];

% quadratic LLS fitting
data_conic=[
  struct('out','Output_line_lls_VPR_normalised_ws_rescaled','legend','linear fit','style',{{'Marker','x'}}),... % rescaled
  struct('out','Output_conic_VPR_normalised_ws_rescaled','legend','quadratic fit','style',{{}}) % without oracle data_oracle_conic_vpr_norm_ws
  ];

% oracle - experiments with the ground truth 4 methods + 4 corresponding oracles
% (a). quadratic LLS + VPR normalised on the side of the watershed
% (b). fairer greedy merge + VPR normalised on the side of the trees
% (c). watershed arc + BPR 3
% (d). line (ends) + RI
% TODO (d) is being rescaled 2015-03-05
data_oracle_ex=[
  struct('out','Output_conic_VPR_normalised_ws_rescaled','legend','(a)','style',{{}}),... % c. VPR norm ws % Output_conic_VPR_normalised_ws
  struct('out','Output_fairer_merge_VPR_normalised_trees_rescaled','legend','(b)','style',{{}}),... % fairer s. VPR norm Ts % 'Output_fairer_merge_VPR_normalised_trees'
  struct('out','Output_contour_bpr3','legend','(c)','style',{{}}),... % c. BPR3 % dataContourBpr
  struct('out','Output_line_RI_rescaled','legend','(d)','style',{{}}),... % l. RI % watershed arc % Output_line_RI
  ];
data_oracle_oracle=[
  struct('out','Output_oracle_conic_VPR_normalised_ws_rescaled','legend','oracle: (a)','style',{{'LineStyle','-.'}}),... % o. c. VPR norm ws % Output_oracle_conic_VPR_normalised_ws
  struct('out','Output_oracle_fairer_merge_VPR_normalised_trees_rescaled','legend','oracle: (b)','style',{{'LineStyle','-.'}}),... % o. fairer s. VPR norm Ts % 'Output_oracle_fairer_merge_VPR_normalised_trees'
  struct('out','Output_oracle_contour_bpr3','legend','oracle: (c)','style',{{'LineStyle','-.'}}),... % o. c. BPR3,'style % dataOracleContourBpr
  struct('out','Output_oracle_line_RI_rescaled','legend','oracle: (d)','style',{{'LineStyle','-.'}}),... % o. l. RI % watershed arc % Output_oracle_line_RI
  ];
data_oracle=[data_oracle_ex data_oracle_oracle];

% voting scope
% 1) degraded baseline
data_SE_ucm_degraded_baseline_thesis=[ % new baseline - evaluate SF on a pixel (or smaller patch); rescaled ucm2s
  struct('out','Output_ucm_bdry_sz_1_mid_1x1_rescaled','legend','1x1','style',{{'Marker','x'}}),... % 1x1 mid
  struct('out','Output_ucm_bdry_sz_1_ul_2x2_rescaled','legend','2x2','style',{{'Marker','x'}}),...
  struct('out','Output_ucm_bdry_sz_1_ul_4x4_rescaled','legend','4x4','style',{{'Marker','x'}}),...
  struct('out','Output_ucm_bdry_sz_1_ul_8x8_rescaled','legend','8x8','style',{{'Marker','x'}}),...
];

% 2) reduced voting scope
data_voting_scope_vpr_norm_ws=[ % the 'c' is computed in the 'region boundary' fashion (although I suspect it would make no difference)
  struct('out','Output_line_centre_VPR_normalised_ws','legend','averaging (on watershed arc)','style',{{'Marker','x'}}),... % l.c. VPR norm ws
  struct('out','Output_votespb_line_centre_VPR_normalised_ws','legend','no averaging (per-pixel)','style',{{'Marker','x'}}),... % vote.Pb region bdry l.c. VPR norm ws% vote is cast only on a single pixel; vertices with no internal edge pixels of the c. (contours)-structure are filled in from the pb
  ];

% 3) expanded voting scope
% voting scope experiment on line_centre_VPR_norm_ws
% originally [data_line_centre_vpr_norm_ws data_oracle_line_centre_vpr_norm_ws]
% but relabelled for the thesis
data_voting_scope_line_centre_VPR_norm_ws=[ % all experiments are done using line fitting through the centre of the watershed patch, oriented according to the derivative of the end points
  struct('out','Output_line_centre_VPR_normalised_ws','legend','arc - arc','style',{{}}),...
  struct('out','Output_mixed_voting_line_centre_vpr_norm_ws_rescaled','legend','region boundary - arc','style',{{}}),... % rescaled
  struct('out','Output_region_bdry_line_centre_VPR_normalised_ws','legend','region boundary - region boundary','style',{{}}),...
  struct('out','Output_oracle_line_centre_VPR_normalised_ws','legend','oracle: arc - arc','style',{{'LineStyle','-.'}}),...
  struct('out','Output_oracle_mixed_voting_line_centre_vpr_norm_ws_rescaled','legend','oracle: region boundary - arc','style',{{'LineStyle','-.'}}),... % rescaled
  struct('out','Output_oracle_region_bdry_line_centre_VPR_normalised_ws','legend','oracle: region boundary - region boundary','style',{{'LineStyle','-.'}}),...
  ];

% state-of-the-art methods
data_SoA=[ 
  struct('out','Output_line_centre_VPR_normalised_ws_rescaled','legend','Ours - SE-SV-UCM','style',{{'Marker','x'}}),... % l.c. VPR norm ws % % to compare to SoA use the rescaled version
  struct('out','Output_BSDS_downloaded','legend','gPb-OWT-UCM','style',{{}})... % gPb+ucm
  struct('out','Output_SE_nms_multiscale','legend','SE','style',{{}}),... % F=.74
  struct('out','Output_MCG_downloaded','legend','MCG','style',{{}}),...
  struct('out','Output_N4_Fields_downloaded','legend','N^4 Fields','style',{{}})... % TODO this method has only BPR output, as well as SE; allow plotting to not mess up the legend
  struct('out','Output_Crisp_(PMI)_downloaded','legend','Crisp (PMI)','style',{{}})... % TODO 
  ];
  
% for masters defence
data_SoA=[
  struct('out','Output_SE_no_nms_single_scale','legend','SE single scale','style',{{'LineStyle','--'}})...
  struct('out','Output_BSDS_downloaded','legend','gPb-OWT-UCM','style',{{'LineStyle','--'}})... % gPb+ucm
  struct('out','Output_SE_nms_multiscale','legend','SE MS','style',{{}}),... % F=.74
  struct('out','Output_MCG_downloaded','legend','MCG','style',{{}}),...
  struct('out','Output_N4_Fields_downloaded','legend','N^4 Fields','style',{{}})... % TODO this method has only BPR output, as well as SE; allow plotting to not mess up the legend
  struct('out','Output_Crisp_(PMI)_downloaded','legend','Crisp (PMI)','style',{{}})... % TODO 
  ];

% for masters defence
data_SoA=[
  struct('out','Output_BSDS_downloaded','legend','gPb-OWT-UCM','style',{{}})... % gPb+ucm
  struct('out','Output_SE_nms_multiscale','legend','SE','style',{{}}),... % F=.74
  struct('out','Output_MCG_downloaded','legend','MCG','style',{{}}),...
  struct('out','Output_N4_Fields_downloaded','legend','N^4 Fields','style',{{}})... % TODO this method has only BPR output, as well as SE; allow plotting to not mess up the legend
  struct('out','Output_Crisp_(PMI)_downloaded','legend','Crisp (PMI)','style',{{}})... % TODO 
  ];

% for masters defence
data_SoA_relevant=[
  struct('out','Output_BSDS_downloaded','legend','gPb-OWT-UCM','style',{{}})... % gPb+ucm
  struct('out','Output_SE_nms_multiscale','legend','SE multiscale','style',{{}}),... % F=.74
  ];

% for masters defence
data_SoA_relevant=[
  struct('out','Output_SE_no_nms_single_scale','legend','SE single scale','style',{{'LineStyle','--'}})...
  struct('out','Output_BSDS_downloaded','legend','gPb-OWT-UCM','style',{{}})... % gPb+ucm
  struct('out','Output_SE_nms_multiscale','legend','SE multiscale','style',{{}}),... % F=.74
  ];

% TODO rescale the oracle experiments before plotting
data_region_bdry_decreases_performance_vpr_norm_Ts_see_oracle=[data_fairer_merge_vpr_norm_Ts data_region_bdry_fairer_merge_vpr_norm_Ts data_oracle_fairer_merge_vpr_norm_Ts data_oracle_region_bdry_fairer_merge_vpr_norm_Ts];
data_thesis=data_region_bdry_decreases_performance_vpr_norm_Ts_see_oracle;

% TODO
data_voting_scope_contour_bpr_3;


% defense presentation
data_vpr_line_centre=[ % 'legend','Ours - SE-SV-UCM','style',{{'Marker','x'}}),... 
  struct('out','Output_line_centre_VPR_normalised_ws','legend','fitted line + VPR','style',{{}}),... % l.c. VPR norm ws
  struct('out','Output_oracle_region_bdry_line_centre_VPR_normalised_ws','legend','oracle: fitted line + VPR','style',{{'LineStyle','-.'}}) % ,'Marker','*' % o. region bdry l.c. VPR norm ws
  ];

data_thesis=[
  struct('out','Output_segs_VPR_normalised_ws','legend','s. VPR norm ws','style',{{'Marker','x'}}),...
  struct('out','Output_fair_segs_VPR_normalised_ws','legend','fair s. VPR norm ws','style',{{'Marker','x'}}),...
  data_naive_greedy_merge,...
  data_merge_vpr_norm_ws,...
  ];

data_thesis=[
  data_merge_RI,...
  data_oracle_merge_RI,...
  ];

data_thesis=[
  data_SE_ucm_no_nms_single_scale,...
  data_SE_ucm_no_nms_multiscale,...
  ];

data_thesis=data_SoA_relevant;

data_vpr_line_centre=[ % 'legend','Ours - SE-SV-UCM','style',{{'Marker','x'}}),... 
  struct('out','Output_line_centre_VPR_normalised_ws','legend','fitted line + VPR','style',{{}}),... % l.c. VPR norm ws
  struct('out','Output_oracle_region_bdry_line_centre_VPR_normalised_ws','legend','oracle: fitted line + VPR','style',{{'LineStyle','-.'}}) % ,'Marker','*' % o. region bdry l.c. VPR norm ws
  ];


data_thesis=[
  struct('out','Output_oracle_region_bdry_line_centre_VPR_normalised_ws','legend','Ours oracle: SE-SV-UCM','style',{{'LineStyle','-.'}}),... % ,'Marker','*' % o. region bdry l.c. VPR norm ws
  struct('out','Output_line_centre_VPR_normalised_ws','legend','Ours: SE-SV-UCM','style',{{}}),... % l.c. VPR norm ws
  struct('out','Output_sf_ucm','legend','SE-UCM','style',{{'LineStyle','--'}}),...
  struct('out','Output_SE_no_nms_single_scale','legend','SE single scale','style',{{'LineStyle','--'}})...
  ];
% data_thesis=data_oracle;
% data_thesis=data_vpr_line_centre;

