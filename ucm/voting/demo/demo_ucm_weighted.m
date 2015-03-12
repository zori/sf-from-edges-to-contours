% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
model_name='modelBSDS500_patches';
load_model_and_trees;
% strings describing all possible types of vote to weigh the watershed
% e.g. RSRI RI vpr_s vpr_gt
bpr_votings={'bpr' 'line_bpr_3' 'line_bpr_4' 'line_centre_bpr_3' 'line_centre_bpr_4' 'contour_bpr_3'};
vpr_unnorm_votings={'naive_greedy_merge_VPR_unnorm' 'fairer_merge_VPR_unnorm' ...
  'line_VPR_unnorm' 'line_centre_VPR_unnorm' 'line_lls_VPR_unnorm' 'conic_VPR_unnorm'};
vpr_votings=[vpr_unnorm_votings {'line_VPR_normalised_ws' 'line_centre_VPR_normalised_ws'  ...
  'line_lls_VPR_normalised_ws' 'naive_greedy_merge_VPR_normalised_ws' ...
  'fairer_merge_VPR_normalised_ws' 'fairer_merge_VPR_normalised_trees' ...
  'conic_VPR_normalised_ws'}];
vpr_votings_broken={'poly_VPR_normalised_ws_1' 'poly_VPR_normalised_ws_2'}; % UPDATE: 2015-03-02 those seem to be hopeless, won't fix
rimc_votings={'fairer_merge_RIMC'};
ri_votings=[rimc_votings {'line_RI' 'line_centre_RI' 'naive_greedy_merge_RI' 'fairer_merge_RI'}];
% % deprecated
% other_votings={'greedy_merge'};
votings=[bpr_votings vpr_votings ri_votings];
% sketchbook - last stuff I've worked on
votings={'line_centre_VPR_normalised_ws'};
votings={'conic_VPR_normalised_ws'};
fmt='doubleSize';
dbg=false; % if true, will pause during computation for a few locations

% data
li=zeros(16,16); li(:,8)=1; % 16x16 vertical line
[test_data(1).I,test_data(1).gt]=make_example(li); clear li;
[test_data(2).I,test_data(2).gt]=make_example(eye(260)); % bw diagonal

names=im_gt_filenames; % load real images filenames

ns=[names.tikis names.hawaii names.zebras2 names.old_man names.elephants names.leopard names.corrida names.eagle];

% populate test_data(3), ... test_data(9) dynamically
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
    %     % to save a fademap coloured version:
    %     ii=test_data(l).res{k};
    %     f=figure('visible','off'), imshow(ii,'Border','tight'); colormap(cmap); figure(f);
    %     % then :( manually click on the figure File -> Save as (choose .png format); call the file ['UCM_' votings{k}]
  end
  keyboard; % will pause here
end
