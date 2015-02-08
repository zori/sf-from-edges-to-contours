% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)

% runs a voting experiment and its oracle one after the other
experiment_name='mixed_voting_scope_foo_rescaled'; % 'region_bdry_line_lls_VPR_normalised_ws';
runExperiment(experiment_name,'voteUcm');
runExperiment(['oracle_' experiment_name],'oracle');
