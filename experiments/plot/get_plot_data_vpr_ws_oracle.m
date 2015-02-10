% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)
% merge
data_oracle_fairer_merge_vpr_norm_ws=[struct('out','Output_oracle_fairer_merge_VPR_normalised_ws','legend','o. fairer s. VPR norm ws','style',{{'Marker','x'}})];
data_oracle_region_bdry_fairer_merge_vpr_norm_ws=[struct('out','Output_oracle_region_bdry_fairer_merge_VPR_normalised_ws','legend','o. region bdry fairer s. VPR norm ws','style',{{'Marker','x'}})];
data_oracle_region_bdry_fair_segs_vpr_norm_ws=[struct('out','Output_oracle_region_bdry_fair_segs_VPR_normalised_ws','legend','o. region bdry fs. VPR norm ws','style',{{'LineStyle','-.','Marker','x'}})];
% 1-of-3) line
data_oracle_line_vpr_norm_ws=struct('out','Output_oracle_line_VPR_normalised_ws','legend','o. l. VPR norm ws','style',{{'LineStyle','-.','Marker','*'}});
% 2-of-3) line_centre
data_oracle_arc_line_centre_vpr_norm_ws=struct('out','Output_oracle_line_centre_VPR_normalised_ws','legend','o. l.c. VPR norm ws','style',{{'LineStyle','-.','Marker','*'}});
data_oracle_mixed_voting_line_centre_vpr_norm_ws=[struct('out','Output_oracle_mixed_voting_line_centre_vpr_norm_ws_rescaled','legend','o. m. l.c. VPR norm ws','style',{{'LineStyle','-.','Marker','*'}})]; % rescaled
data_oracle_region_bdry_line_centre_vpr_norm_ws=[struct('out','Output_oracle_region_bdry_line_centre_VPR_normalised_ws','legend','o. region bdry l.c. VPR norm ws','style',{{'LineStyle','-.','Marker','*'}})];
% summary
data_oracle_line_centre_vpr_norm_ws=[data_oracle_arc_line_centre_vpr_norm_ws data_oracle_mixed_voting_line_centre_vpr_norm_ws data_oracle_region_bdry_line_centre_vpr_norm_ws];
% 3-of-3) line_lls
data_arc_oracle_line_lls_vpr_norm_ws=[struct('out','Output_oracle_line_lls_VPR_normalised_ws_rescaled','legend','o. l.lls. VPR norm ws','style',{{'LineStyle','-.','Marker','*'}})]; % rescaled;
data_oracle_mixed_voting_line_lls_vpr_norm_ws=[struct('out','Output_oracle_mixed_voting_scope_line_lls_VPR_normalised_ws_rescaled','legend','o. m. l.lls. VPR norm ws','style',{{'LineStyle','-.','Marker','*'}})]; % rescaled;
% summary
data_oracle_line_lls_vpr_norm_ws=[data_arc_oracle_line_lls_vpr_norm_ws data_oracle_mixed_voting_line_lls_vpr_norm_ws];
% conic
data_oracle_conic_vpr_norm_ws=[
  struct('out','Output_oracle_conic_VPR_normalised_ws','legend','o. c. VPR norm ws','style',{{'LineStyle','-.'}}),...
  struct('out','Output_oracle_region_bdry_conic_VPR_normalised_ws','legend','o. region bdry c. VPR norm ws','style',{{'LineStyle','-.'}}),...
  ];
  
data_oracle_vote_range_vpr_norm_ws=[... % the 'c' is computed in the 'region boundary' fashion (although I suspect it would make no difference)
  struct('out','Output_oracle_votes0_line_centre_VPR_normalised_ws','legend','o. vote.0 region bdry l.c. VPR norm ws','style',{{'LineStyle','-.','Marker','x'}}),... % vote is cast only on a single pixel; vertices with no internal edge pixels of the c. (contours)-structure are set to 0
  struct('out','Output_oracle_votespb_line_centre_VPR_normalised_ws','legend','o. vote.Pb region bdry l.c. VPR norm ws','style',{{'LineStyle','-.','Marker','x'}}),... % vote is cast only on a single pixel; vertices with no internal edge pixels of the c. (contours)-structure are filled in from the pb
  ];
data_oracle_merge_vpr_norm_ws=[
  data_oracle_region_bdry_fair_segs_vpr_norm_ws,... % slightly better than the rest 0.76
  data_oracle_region_bdry_fairer_merge_vpr_norm_ws,... % 0.75
  data_oracle_fairer_merge_vpr_norm_ws,... % 0.75
  ];
dataOracleVPRnormWS=[...
  struct('out','Output_oracle_segs_VPR_normalised_ws','legend','o. s. VPR norm ws','style',{{'LineStyle','-.','Marker','*'}}),...
  struct('out','Output_oracle_fair_segs_VPR_normalised_ws','legend','o. fs. VPR norm ws','style',{{'LineStyle','-.','Marker','x'}}),...
  data_oracle_merge_vpr_norm_ws,...
  data_oracle_line_vpr_norm_ws,...
  data_oracle_line_centre_vpr_norm_ws,...
  data_oracle_line_lls_vpr_norm_ws,...
  data_oracle_conic_vpr_norm_ws,...
  data_oracle_vote_range_vpr_norm_ws,...
  struct('out','Output_oracle_poly_VPR_normalised_ws_1','legend','o. poly1 VPR norm ws','style',{{'LineStyle','-.','Marker','x'}}),...
];
