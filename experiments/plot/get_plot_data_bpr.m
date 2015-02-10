% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)

% BPR line fitted (end of vertices)
ksz=7;
k=num2str((1:ksz)');
out=num2cell([repmat('Output_bpr_',ksz,1) k],2)'; % should have been named 'Output_line_bpr_'
l=num2cell([repmat('l. BPR',ksz,1) k],2)';
dataLineBPR=struct('out',out,'legend',l,'style',{{'Marker','x'}});
dataOracleLineBPR=struct('out',{'Output_oracle_bpr_3' 'Output_oracle_bpr_4'},... % should have been named 'Output_oracle_line_bpr_'
  'legend',{'o. l. BPR3' 'o. l. BPR4'},'style',{{'Marker','x'}});
% Contour
dataContourBpr=struct('out','Output_contour_bpr3','legend','c. BPR3','style',{{}});
dataOracleContourBpr=struct('out','Output_oracle_contour_bpr3','legend','o. c. BPR3','style',{{'LineStyle','-.'}});

data_contour_bpr_3=[
  dataContourBpr,...
  struct('out','Output_region_bdry_contour_bpr_3','legend','r.b. c. BPR3','style',{{}}),... % not rescaled
  struct('out','Output_mixed_voting_scope_contour_bpr3_rescaled','legend','m.v.s. c. BPR3','style',{{}}),...
  ];

data_oracle_contour_bpr_3=[
  dataOracleContourBpr,...
  struct('out','Output_oracle_region_bdry_contour_bpr_3','legend','o. r.b. c. BPR3','style',{{'LineStyle','-.'}}),...  % not rescaled
  struct('out','Output_oracle_mixed_voting_scope_contour_bpr3_rescaled','legend','o. m.v.s. c. BPR3','style',{{'LineStyle','-.'}}),...
  ];

data_contour_bpr=[dataContourBpr dataOracleContourBpr]; % the new contour BPR + its oracle
data_voting_scope_contour_bpr_3=[data_contour_bpr_3 data_oracle_contour_bpr_3];

data_line_bpr_3_4=[dataLineBPR(3:4) dataOracleLineBPR]; % these are good values; when having to choose, go for max_dist=3px
% why are we still worse than the baseline?; this motivates the hard-negative mining
data_line_bpr_3=[
  dataLineBPR(3),...
  struct('out','Output_line_bpr_3','legend','l. BPR3','style',{{}}),... % this is experiment of dataLineBPR(3) REPEATED
  ];
data_line_centre_bpr_3=[...
  struct('out','Output_line_centre_bpr_3','legend','l.c. BPR3','style',{{}}),...
  struct('out','Output_region_bdry_line_centre_bpr_3','legend','region bdry l.c. BPR3','style',{{}}),...
  ];

% oracle
data_oracle_line_bpr_3=[
  dataOracleLineBPR(1),...
  struct('out','Output_oracle_line_bpr_3','legend','o. l. BPR3','style',{{}}),... % this is dataOracleLineBPR(1) REPEATED
  ];
data_oracle_line_centre_bpr_3=[...
  struct('out','Output_oracle_line_centre_bpr_3','legend','o. l.c. BPR3','style',{{}}),...
  struct('out','Output_oracle_region_bdry_line_centre_bpr_3','legend','o. region bdry l.c. BPR3','style',{{}}),...
];

% line vs contour BPR 3
data_line_vs_contour_bpr=[data_line_bpr_3 data_line_centre_bpr_3 dataContourBpr];
data_oracle_line_vs_contour_bpr=[data_oracle_line_bpr_3 data_oracle_line_centre_bpr_3 dataOracleContourBpr];

% summary
data_bpr=[data_line_vs_contour_bpr];
data_oracle_bpr=[data_oracle_line_vs_contour_bpr];
