% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)

dataRSRI=[... % a.k.a. RIMC - Rand Ind. Monte Carlo
  struct('out','Output_RSRI_segs','legend','segs 256 RIMC','style',{{'Marker','x'}}),... % used to be calles 'CpdSegs', now 256
  struct('out','Output_RSRI_segs_merge','legend','s. merge RIMC','style',{{'Marker','x'}}),... % RSRI segs improved by merging some regions of the superpixelisation
  struct('out','Output_fair_segs_merge','legend','fair s. merge RIMC','style',{{'Marker','x'}}),...
  struct('out','Output_RSRI_segs_merge_Pb','legend','s. merge RIMC .*pb','style',{{'LineStyle','--','Marker','x'}}),... % segs merge RSRI, value-multiplied with the pb from create_finest_partition by Arbelaez
  struct('out','Output_RI','legend','RI (32640)','style',{{'LineStyle',':','Marker','x'}}),... % rather than RSRI, increases the nSample to the max, so we have a RI measure; same results, only slower (is it really slower?)
  struct('out','Output_line_RSRI','legend','l. RIMC','style',{{'Marker','x'}}),... % the first patch has only two segments - those determined by the fitted line
  ];

% data_line_RI_vs_rescaled=[ % shows us that rescaling is successful; use the second
%   struct('out','Output_line_RI','legend','l. RI','style',{{}}),... % watershed arc
%   struct('out','Output_mixed_voting_scope_line_RI_rescaled','legend','mixed l. RI','style',{{}}),... % mixed
% ];

data_line_RI=[
  struct('out','Output_line_RI_rescaled','legend','l. RI','style',{{}}),... % watershed arc % Output_line_RI
  struct('out','Output_line_centre_RI_rescaled','legend','l.c. RI','style',{{}}),... % watershed arc % better use the rescaled % 'Output_line_centre_RI'
  struct('out','Output_region_bdry_line_centre_RI','legend','region bdry l.c. RI','style',{{}}),... % region bdry
  struct('out','Output_mixed_voting_scope_line_RI_rescaled','legend','mixed l. RI','style',{{}}),... % mixed
  struct('out','Output_mixed_voting_scope_line_centre_RI_rescaled','legend','mixed l.c. RI','style',{{}}),... % mixed
  ];

data_naive_merge_RI=struct('out','Output_naive_greedy_merge_RI_rescaled','legend','naive greedy merge RI','style',{{'Marker','x'}});

data_region_bdry_fairer_merge_RI=[
  struct('out','Output_region_bdry_fairer_merge_RI','legend','region bdry fairer s. RI','style',{{'Marker','x'}}),...
  struct('out','Output_region_bdry_fairer_merge_RIMC','legend','region bdry fairer s. RIMC','style',{{'Marker','x'}}),...
  ];

data_fairer_merge_RI=[
  struct('out','Output_fairer_merge_RI','legend','fairer s. RI','style',{{'Marker','x'}}),...
  data_region_bdry_fairer_merge_RI
  ];


dataOracleRSRI=[ % oracle - using the GT patches instead of the leaves of the SF trees
  struct('out','Output_oracle_segs_merge_RSRI','legend','oracle s. merge RIMC','style',{{'LineStyle','-.','Marker','*'}}),...
  struct('out','Output_oracle_fair_segs_merge','legend','o. fair s. merge RIMC','style',{{'LineStyle','-.','Marker','*'}}),...
  struct('out','Output_oracle_line_RSRI','legend','o. l. RIMC','style',{{'LineStyle','-.','Marker','*'}}),...
  ];

dataOracle_line_RI=[
  struct('out','Output_oracle_line_RI_rescaled','legend','o. l. RI','style',{{'LineStyle','-.'}}),... % watershed arc % Output_oracle_line_RI
  struct('out','Output_oracle_line_centre_RI_rescaled','legend','o. l.c. RI','style',{{'LineStyle','-.'}}),... % watershed arc % better use the rescaled 'Output_oracle_line_centre_RI'
  struct('out','Output_oracle_region_bdry_line_centre_RI','legend','o. region bdry l.c. RI','style',{{'LineStyle','-.'}}),... % region bdry
  struct('out','Output_oracle_mixed_voting_scope_line_RI_rescaled','legend','o. mixed l. RI','style',{{'LineStyle','-.'}}),... % mixed
  struct('out','Output_oracle_mixed_voting_scope_line_centre_RI_rescaled','legend','o. mixed l.c. RI','style',{{'LineStyle','-.'}}),... % mixed
  ];

data_oracle_naive_merge_RI=struct('out','Output_oracle_naive_greedy_merge_RI_rescaled','legend','o. naive greedy merge RI','style',{{'LineStyle','-.','Marker','x'}});

data_oracle_region_bdry_fairer_merge_RI=[
  struct('out','Output_oracle_region_bdry_fairer_merge_RI','legend','o. region bdry fairer s. RI','style',{{'LineStyle','-.','Marker','x'}}),...
  struct('out','Output_oracle_region_bdry_fairer_merge_RIMC','legend','o. region bdry fairer s. RIMC','style',{{'LineStyle','-.','Marker','x'}}),...
  ];
data_oracle_fairer_merge_RI=[
  struct('out','Output_oracle_fairer_merge_RI','legend','o. fairer s. RI','style',{{'LineStyle','-.','Marker','x'}}),...
  data_oracle_region_bdry_fairer_merge_RI
  ];

data_merge_RI=[data_naive_merge_RI data_fairer_merge_RI];
data_oracle_merge_RI=[data_oracle_naive_merge_RI data_oracle_fairer_merge_RI];

dataRI=[data_merge_RI data_line_RI];
dataOracleRI=[data_oracle_merge_RI dataOracle_line_RI];
% summary
data_ri=[dataRSRI dataRI];
data_oracle_ri=[dataOracleRSRI dataOracleRI];
