% Zornitsa Kostadinova
% Feb 2015
% 8.3.0.532 (R2014a)
data_fairer_merge_vpr_norm_Ts=[struct('out','Output_fairer_merge_VPR_normalised_trees','legend','fairer s. VPR norm Ts','style',{{'Marker','x'}})];
data_region_bdry_fairer_merge_vpr_norm_Ts=[struct('out','Output_region_bdry_fairer_merge_VPR_normalised_trees','legend','region bdry fairer s. VPR norm Ts','style',{{'Marker','x'}})];
dataVPRnormTs=[... % VPR normalised on the side of the trees
  struct('out','Output_segs_VPR_normalised_trees','legend','s. VPR norm Ts','style',{{'Marker','x'}}),...
  struct('out','Output_line_VPR_normalised_trees','legend','line VPR norm Ts','style',{{'Marker','x'}}),...
  data_fairer_merge_vpr_norm_Ts,...
  data_region_bdry_fairer_merge_vpr_norm_Ts,...
  ];
% dataVPRnormTs_pb=[... % VPR normalised on the side of the trees point-multiplied with pb from the edge detector of Dollar
%   struct('out','Output_segs_VPR_normalised_trees_pb','legend','s. VPR Ts .*pb','style',{{'LineStyle','--','Marker','x'}}),...
%   struct('out','Output_line_VPR_normalised_trees_pb','legend','l. VPR norm Ts .*pb','style',{{'LineStyle','--','Marker','x'}}),...
%   ];

data_oracle_fairer_merge_vpr_norm_Ts=[struct('out','Output_oracle_fairer_merge_VPR_normalised_trees','legend','o. fairer s. VPR norm Ts','style',{{'Marker','x'}})];
data_oracle_region_bdry_fairer_merge_vpr_norm_Ts=[struct('out','Output_oracle_region_bdry_fairer_merge_VPR_normalised_trees','legend','o. region bdry fairer s. VPR norm Ts','style',{{'Marker','x'}})];
dataOracleVPRnormTs=[...
  struct('out','Output_oracle_segs_VPR_normalised_trees','legend','o. s. VPR norm Ts','style',{{'Marker','x'}}),...
  data_oracle_fairer_merge_vpr_norm_Ts,...
  data_oracle_region_bdry_fairer_merge_vpr_norm_Ts,...
  ];
