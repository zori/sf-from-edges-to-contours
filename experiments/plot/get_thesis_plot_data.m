% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)

% plots that will be featured in the thesis; copy-pasted from throughout
% get_plot_data_* , which comprehensively contain all our experiments
%
% purpose of this is to be able to freely change the legend depending on where
% the plot is to be featured
data_segs_to_greedy_merge_RIMC=[... % RIMC metric on 3 watershed transformations
  struct('out','Output_RSRI_segs','legend','Oversegmentation','style',{{'Marker','x'}}),... %'segs 256 RIMC' % used to be calles 'CpdSegs', now 256
  struct('out','Output_RSRI_segs_merge','legend','Naive greedy merge','style',{{'Marker','x'}}),... % 's. merge RIMC' % RSRI segs improved by merging some regions of the superpixelisation
  struct('out','Output_fair_segs_merge','legend','Fair greedy merge','style',{{'Marker','x'}}),... % 'fair s. merge RIMC'
];

% TODO the conic data has to be rescaled before it can be plotted
data_conic=[data_conic_vpr_norm_ws data_oracle_conic_vpr_norm_ws];
% TODO rescale the oracle experiments before plotting
data_region_bdry_decreases_performance_vpr_norm_Ts_see_oracle=[data_fairer_merge_vpr_norm_Ts data_region_bdry_fairer_merge_vpr_norm_Ts data_oracle_fairer_merge_vpr_norm_Ts data_oracle_region_bdry_fairer_merge_vpr_norm_Ts];
% TODO
data_voting_scope_contour_bpr_3;

data_thesis=data_segs_to_greedy_merge_RIMC;
