% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
model_name='modelBSDS500_patches';
load_model_and_trees;
% strings describing all possible types of vote to weigh the watershed
votings={'bpr','greedy_merge','line_VPR_normalised_ws'}; % RSRI RI vpr_s vpr_gt
votings={'line_VPR_normalised_ws','poly_VPR_normalised_ws_1','poly_VPR_normalised_ws_2'};
votings={'greedy_merge'};
fmt='doubleSize';
dbg=false;

% data
li=zeros(16,16); li(:,8)=1; % 16x16 vertical line
[test_data(1).I,test_data(1).gt]=make_example(li); clear li;
[test_data(2).I,test_data(2).gt]=make_example(eye(260)); % bw diagonal
% real image
imFile='/BS/kostadinova/work/BSR/BSDS500/data/images/val/101085.jpg';
test_data(3).I=imread(imFile);
gtFile='/BS/kostadinova/work/BSR/BSDS500/data/groundTruth/val/101085.mat';
test_data(3).gt=load_segmentations(gtFile);

% L_ucm=ucm_weighted(data(1).I,model,'line_VPR_normalised_ws',fmt,true,T); % interactive, pause when computing
% merge_L_ucm=ucm_weighted(data(1).I,model,'greedy_merge',fmt,false,T); % don't pause, just compute

% bw_u_l=ucm_weighted(test_data(2).I,model,'line_VPR_normalised_ws',fmt,dbg,T);
% bw_u_p=ucm_weighted(test_data(2).I,model,'poly_VPR_normalised_ws',fmt,dbg,T);
% im_u=ucm_weighted(test_data(3).I,model,'poly_VPR_normalised_ws',fmt,true,T);

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
    initFig(); im(test_data(l).res{k}); title(['UCM ' votings{k}]);
    initFig(); im(test_data(l).oracle{k}); title(['oracle ' votings{k}]);
  end
  keyboard; % will pause here
end
