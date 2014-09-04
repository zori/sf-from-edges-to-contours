% Zornitsa Kostadinova
% Sep 2014
% 8.3.0.532 (R2014a)
function metrics = benchmarkMetrics()
% possible benchmark metrics
metrics={
  'bdry',...       % BPR - Boundary Precision-Recall
  '3dbdry'...      % TODO is this not implemented
  'regpr',...      % VPR - Volumetric Precision-Recall
  'sc',...         % SC  - Segmentation Covering
  'pri',...        % PRI - Probabilistic Rand Index
  'vi',...         % VI  - Variation of Information
  'lengthsncl',... % length statistics and number of clusters
  'all'};          % computes all available
end
