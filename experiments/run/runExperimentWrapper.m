% Zornitsa Kostadinova
% Jan 2015
% 8.3.0.532 (R2014a)

% runs a voting experiment and its oracle one after the other
% 'foo_rescaled' or 'mixed_voting_scope_foo_rescaled' or 'region_bdry_scope_foo_rescaled' 
experiment_name='foo_rescaled';
runExperiment(experiment_name,'voteUcm');
runExperiment(['oracle_' experiment_name],'oracle');
