% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)

dataVPRunnorm=[...
  struct('out','Output_segs_VPR_unnormalised','legend','s. VPR unnorm','style',{{'Marker','x'}}),... % unnormalised VPR
  ];

get_plot_data_vpr_Ts;
get_plot_data_vpr_ws_ex;
get_plot_data_vpr_ws_oracle;

% some outtakes:
data_vpr_norm_Ts=[dataVPRnormTs dataOracleVPRnormTs];
data_vpr_norm_ws=[dataVPRnormWS dataOracleVPRnormWS];
data_vpr_vote_range=[...
  data_region_bdry_line_centre_vpr_norm_ws data_vote_range_vpr_norm_ws...
  data_oracle_region_bdry_line_centre_vpr_norm_ws data_oracle_vote_range_vpr_norm_ws...
  ];

% summary
data_vpr=[dataVPRunnorm dataVPRnormTs dataVPRnormWS];
data_oracle_vpr=[dataOracleVPRnormTs dataOracleVPRnormWS]; % there was no dataOracleVPRunnorm - too poor performance
data_line_centre_VPR_norm_ws_pb;
