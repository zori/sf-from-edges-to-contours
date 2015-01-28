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
dataOracleContourBpr=struct('out','Output_oracle_contour_bpr3','legend','o. c. BPR3','style',{{}});

data_line_bpr_3_4=[dataLineBPR(3:4) dataOracleLineBPR]; % these are good values; when having to choose, go for max_dist=3px
data_line_bpr_3=[dataLineBPR(3) dataOracleLineBPR(1)]; % why are we still worse than the baseline?; this motivates the hard-negative mining

data_contour_bpr=[dataContourBpr dataOracleContourBpr]; % the new contour BPR + its oracle

data_line_vs_contour_bpr=[dataLineBPR(3) dataContourBpr]; % line vs contour BPR
data_oracle_line_vs_contour_bpr=[dataOracleLineBPR(1) dataOracleContourBpr]; % same, oracles comparison

% summary
data_bpr=[data_line_vs_contour_bpr];
data_oracle_bpr=[data_oracle_line_vs_contour_bpr];
