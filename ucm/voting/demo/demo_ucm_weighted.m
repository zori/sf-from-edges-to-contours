% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
model_name='modelBSDS500_patches';
load_model_and_trees;
% strings describing all possible types of vote to weigh the watershed
% e.g. RSRI RI vpr_s vpr_gt
bpr_votings={'bpr' 'line_bpr_3' 'line_bpr_4' 'line_centre_bpr_3' 'line_centre_bpr_4' 'contour_bpr_3'};
vpr_votings={'line_VPR_normalised_ws' 'line_centre_VPR_normalised_ws' 'line_lls_VPR_normalised_ws' 'fairer_merge_VPR_normalised_ws' 'fairer_merge_VPR_normalised_trees' 'conic_VPR_normalised_ws'};
TODO_vpr_votings_={'poly_VPR_normalised_ws_1' 'poly_VPR_normalised_ws_2'};
ri_votings={'line_RI' 'line_centre_RI' 'fairer_merge_RI' 'fairer_merge_RIMC'};
% % deprecated
% other_votings={'greedy_merge'};
votings=[bpr_votings vpr_votings ri_votings];
% sketchbook - last stuff I've worked on
votings={'conic_VPR_normalised_ws'};
votings={'line_centre_VPR_normalised_ws'};
fmt='doubleSize';
dbg=false; % if true, will pause during computation for a few locations

% data
li=zeros(16,16); li(:,8)=1; % 16x16 vertical line
[test_data(1).I,test_data(1).gt]=make_example(li); clear li;
[test_data(2).I,test_data(2).gt]=make_example(eye(260)); % bw diagonal

names=im_gt_filenames; % load real images filenames

ns=[names.tikis names.hawaii names.zebras2 names.old_man];

% populate test_data(3), ... test_data(6) dynamically
for n=1:length(ns)
  test_data(2+n).I=imread(ns(n).im);
  test_data(2+n).gt=load_segmentations(ns(n).gt);
end

for k=1:length(votings)
  for l=1:length(test_data)
    test_data(l).res{k}=ucm_weighted(test_data(l).I,model,votings{k},fmt,dbg,T);
    test_data(l).oracle{k}=ucm_weighted(test_data(l).I,model,votings{k},fmt,dbg,T,test_data(l).gt);
  end
end

set(0,'DefaulttextInterpreter','none'); % display '_' in title normally
for l=1:length(test_data)
  initFig(1); im(test_data(l).I); title('example');
  for k=1:length(votings)
    initFig; im(test_data(l).res{k}); title(['UCM ' votings{k}]);
    initFig; im(test_data(l).oracle{k}); title(['oracle ' votings{k}]);
  end
  keyboard; % will pause here
end
