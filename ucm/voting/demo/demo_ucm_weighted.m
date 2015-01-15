% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
model_name='modelBSDS500_patches';
load_model_and_trees;
% strings describing all possible types of vote to weigh the watershed
% e.g. RSRI RI vpr_s vpr_gt
votings={'bpr','greedy_merge','line_VPR_normalised_ws','poly_VPR_normalised_ws_1','poly_VPR_normalised_ws_2'};
votings={'line_VPR_normalised_ws'}; % TODO debug line fitting for proper region boundaries
votings={'greedy_merge'};
fmt='doubleSize';
dbg=false; % if true, will pause during computation for a few locations

% data
li=zeros(16,16); li(:,8)=1; % 16x16 vertical line
[test_data(1).I,test_data(1).gt]=make_example(li); clear li;
[test_data(2).I,test_data(2).gt]=make_example(eye(260)); % bw diagonal

names=im_gt_filenames; % load real images filenames

test_data(3).I=imread(names.tikis.im);
test_data(3).gt=load_segmentations(names.tikis.gt);

test_data(4).I=imread(names.hawaii.im);
test_data(4).gt=load_segmentations(names.hawaii.gt);

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
