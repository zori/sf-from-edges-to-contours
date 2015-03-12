% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function data = get_plot_data(experiments_to_plot)
% directories, labels and line styles for the precomputed results
% structure is defined in this manner to allow easy rearrangement of order of
% curves (in the legend)

% include definitions from other files
get_plot_data_bpr;
get_plot_data_vpr;
get_plot_data_ri;
get_plot_data_region_bdry;
get_plot_data_SE;
get_thesis_plot_data;

dataBest=[...
  data_SE_watershed,...
  data_SE_ucm_baseline,...
  data_SE_sPb,...
  struct('out','Output_BSDS_downloaded','legend','gPb-OWT-UCM','style',{{}})... % gPb+ucm
  % UPDATE: this one (don't remember how I got the result, is not the best SE
  % result % struct('out','Output_sf_edges','legend','SE','style',{{}}),... %
  struct('out','Output_SE_nms_multiscale','legend','SE','style',{{}}),... % F=.74 % SE nms MS; edge detector output plotOpts.metrics='bdry'; % F=.73
  struct('out','Output_MCG_downloaded','legend','MCG','style',{{}}),...
  struct('out','Output_N4_Fields_downloaded','legend','N^4 Fields','style',{{}})... % TODO this method has only BPR output, as well as SE; allow plotting to not mess up the legend
  struct('out','Output_Crisp_(PMI)_downloaded','legend','Crisp (PMI)','style',{{}})... % TODO 
  ]; % TODO add OEF (of Hallman & Folwkes)
% 'style',{{'LineStyle','-.','Marker','*'}}
% LineStyle '--' '-.'
% Marker '*' 'x' 'd' 'o'

% our experiments
% dataOraclePB=[... % oracle result value-multiplied by the probability of boundary
%   struct('out','Output_oracle_line_RSRI_pb','legend','o. l. RSRI pb','style',{{'Marker','o'}}),...
%   struct('out','Output_oracle_segs_VPR_normalised_trees_pb','legend','o. s. VPR norm Ts pb','style',{{'Marker','o'}}),...
%   struct('out','Output_oracle_segs_VPR_normalised_ws_pb','legend','o. s. VPR norm ws pb','style',{{'Marker','o'}}),...
%   struct('out','Output_oracle_line_VPR_normalised_ws_pb','legend','o. l. VPR norm ws pb','style',{{'Marker','o'}}),...
%   ];

% summary
data_all=[...
  data_bpr,...
  data_vpr,...
  data_ri,...
  dataVPRnormTs,...
  ];
data_oracle_all=[...
  data_oracle_bpr,...
  data_oracle_vpr,...
  data_oracle_ri,...
  dataOracleVPRnormTs,...
  ];

% % programmatically add an empty 'style' field
% if ~isfield(dataOurs,'style')
%   for k=1:length(dataOurs)
%     dataOurs(k).style={};
%   end
% end

% this shows that it is important to have our votes averaged on the region
% boundaries of the watershed; this way we "globalise" the decision of a single
% location, by transfering the vote to the whole "edge"
dataOurs=data_vpr_vote_range;

% checked
dataOurs=[data_merge_vpr_norm_ws data_oracle_merge_vpr_norm_ws]; % does region boundary have a positive influence? % unconclusive: one of the oracles, supposedly buggy, performs better than the rest; regular experiments seem identical
dataOurs=[data_fairer_merge_RI data_oracle_fairer_merge_RI]; % 3 experiments identical, oracles slight, but unconclusive difference
dataOurs=data_voting_scope_contour_bpr_3;
dataOurs=[data_line_centre_vpr_norm_ws data_line_centre_VPR_norm_ws_pb];
dataOurs=[data_SE_ucm_no_nms_single_scale data_SE_ucm_no_nms_multiscale]; % the 'real' baseline - SS vs MS
dataOurs=[data_line_lls_vpr_norm_ws data_oracle_line_lls_vpr_norm_ws]; % slight, barely perceptible difference in favour of "mixed voting" (to "watershed arc")
dataOurs=[data_line_centre_vpr_norm_ws data_oracle_line_centre_vpr_norm_ws]; % arc is performing best, "mixed voting" and "region boundary" - slightly worse; oracle - different; make sure to see VPR as well
dataOurs=[data_line_RI dataOracle_line_RI]; % updated line_centre_RI_rescaled - still, hard to tell if there is a better performing method
dataOurs=[data_SE_sPb_nms data_SE_sPb_nnms]; % SE-nms is better than SE-nnms!

% TODO to be checked
%

data_hard_negative_mining=[data_arc_line_centre_vpr_norm_ws data_SE_ucm_no_nms_single_scale];% data_oracle_arc_line_centre_vpr_norm_ws]; 
dataOurs=[data_SE_ucm_no_nms_single_scale data_SE_ucm_no_nms_multiscale];
dataOurs=data_hard_negative_mining;

% % TODO
% dataOurs=struct('out','Output_region_bdry_linear_least_squares_VPR_normalised_ws','legend','r.b. lower-order-term (conic) VPR norm ws','style',{{}}); % the conic fitting code, without x.^2 and y.^2 terms (but with the mixed x.*y term; otherwise - no intersection :( )

switch experiments_to_plot
  case 'best'
    data=dataBest;
  case 'ours'
    % experiment for checking if anything is lost by reweighing only on the
    % boundary location
    % in all, the E (pb) is not nms (opts.model.nms=0), and detection was single scale
    data=[...
      struct('out','Output_SF_single_scale','legend','SE ucm','style',{{'Marker','x'}}),...
      struct('out','Output_SF_single_scale_on_contours','legend','SE ucm, on contours','style',{{'Marker','x'}}),...
      struct('out','Output_SF_single_scale_png','legend','SE edge','style',{{'Marker','x'}}),...
      struct('out','Output_SF_single_scale_on_contours_png','legend','SE edge, on contours','style',{{'Marker','x'}}),...
      ];
    % initial experiments with metrics and input types
    data=[...
      data_SE_ucm_baseline,...
      struct('out','Output_VprBdry01','legend','VPR bdry01','style',{{'Marker','x'}}),... % unsuitable: struct('out','Output_VprBdry12','legend','VPR bdry12','style',{{'Marker','x'}}),...
      struct('out','Output_VprSegsUnnormalised','legend','VPR unnorm. segs','style',{{'Marker','x'}}),...
      struct('out','Output_RSRI_bdry01','legend','RSRI bdry01','style',{{'Marker','x'}}),...
      struct('out','Output_RSRI_segs','legend','RSRI segs','style',{{'Marker','x'}}),...
      ];

    data=[data_SE_ucm_baseline dataOurs];
  case 'mid-masters'
    data_baseline=[
      struct('out','Output_sf_ucm','legend','baseline (SE+ucm)','style',{{'LineStyle','-.','Marker','d'}});
      ];
    data_mid_presentation=[
      struct('out','Output_fair_segs_merge','legend','greedy merge, RIMC','style',{{}}),...% 1
      struct('out','Output_segs_VPR_normalised_trees','legend','segs, VPR','style',{{}}),... % 2 normalised T
      struct('out','Output_bpr_3','legend','line, BPR','style',{{}}),... %      struct('out','Output_oracle_fair_segs_merge','legend','oracle: greedy merge, RIMC','style',{{'LineStyle','--'}}),... %      struct('out','Output_oracle_segs_VPR_normalised_trees','legend','oracle: segs, VPR','style',{{'LineStyle','--'}}),... %      struct('out','Output_oracle_bpr_3','legend','oracle: line, BPR','style',{{'LineStyle','--'}}),...
      ];
    data_others=[
      struct('out','Output_BSDS_downloaded','legend','gPb-owt-ucm','style',{{}})...
      struct('out','Output_sf_edges','legend','SE','style',{{}}),... % TODO: plotOpts.metrics='bdry';
      struct('out','Output_Crisp_(PMI)_downloaded','legend','Crisp (PMI)','style',{{}})... % TODO 
      struct('out','Output_MCG_downloaded','legend','MCG','style',{{}}),...
      struct('out','Output_N4_Fields_downloaded','legend','N^4 Fields','style',{{}})... % TODO this method has only BPR output, as well as SE; allow plotting to not mess up the legend
      ];
    data=[data_baseline data_mid_presentation data_others];
  case 'masters-thesis'
    data=[data_SE_ucm_baseline data_thesis];
    data=data_thesis;
%     data=[data_SE_ucm_no_nms_single_scale data_SE_ucm_no_nms_multiscale data_SE_ucm_baseline data_all dataOurs];
%     data=[data_all dataOurs];
  otherwise
    assert(strcmp(experiments_to_plot,'all'));
    data=[dataBest,dataOurs];
end
end
