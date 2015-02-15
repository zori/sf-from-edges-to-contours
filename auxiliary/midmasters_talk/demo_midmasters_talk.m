function demo_midmasters_talk(model)
imF='/home/kostadinova/downloads/video_segm_extras_keep/imgs/zebra_classic_bw.png';
imF='/home/kostadinova/downloads/video_segm_extras_keep/imgs/dalmatians.jpg';
names=im_gt_filenames; % load real images filenames
demo_subject=names.starfish;
I=imread(demo_subject.im);
gt=load(demo_subject.gt);
gt=gt.groundTruth;
gtsz=length(gt);

% % crop
% sz=[size(I,1) size(I,2)];
% idx=sub2ind([sz 3],[140:240],[270:350],[1:3]);
% Icp=reshape(I(idx),[sz 3]);
% % suitable crop for the zebra
% crop_rect=[270 140 80 100];
% I=imcrop(I,crop_rect); % snd arg is a four-element position vector[xmin ymin width height]
% for k=1:gtsz
%   gt{k}.Boundaries=imcrop(gt{k}.Boundaries,crop_rect);
%   gt{k}.Segmentation=imcrop(gt{k}.Segmentation,crop_rect);
% end

E=edgesDetect(I,model);
Ec=edge(rgb2gray(I),'canny');
z_SE_ws=SE_ws(I,model);
ws_mask=z_SE_ws==0;
E_ws = E .* ws_mask;
% r_ws_pixels=I(:,:,1).*uint8(ws_mask);
% g_non_ws_pixels=I(:,:,2).*uint8(~ws_mask);
% b_non_ws_pixels=I(:,:,3).*uint8(~ws_mask);

% the image with a red watershed overlaid on it
z_ws_red=I .* cat(3,single(~E_ws),uint8(~ws_mask),uint8(~ws_mask));
z_ws_red(:,:,1)=z_ws_red(:,:,1)+uint8(ws_mask.*255);

% on the watershed locations:
% bright red - strong edge, black - no/weak edge
z_E_ws_red=I .* cat(3,single(~E_ws),uint8(~E_ws),uint8(~E_ws));
z_E_ws_red(:,:,1)=z_E_ws_red(:,:,1)+uint8(E_ws.*single(max(I(:))));

fmt='doubleSize'; % to be able to threshold later and get the segmentation
z_SE_ucm=SE_ucm(I,model,fmt);
z_gPb_owt_ucm=gPb_owt_ucm(I,fmt);

% segmentations
% low threshold - oversegmentation, high recall
% high threshold - undersegmentation, high precision
z_SE_ucm_seg.low=threshold_ucm2(z_SE_ucm,0.2); % ~ 60 segments
z_SE_ucm_seg.high=threshold_ucm2(z_SE_ucm,0.6); % 4 segments

z_gPb_owt_ucm_seg.low=threshold_ucm2(z_gPb_owt_ucm,0.1); % ~ 30 segments
z_gPb_owt_ucm_seg.high=threshold_ucm2(z_gPb_owt_ucm,0.3); % 4 segments

% % TODO: investigate UCM / finest partition (i.e. sf_wt) (generated in create_finest_partition_voting or any of the 3 files that allow for a choice of voting scope - 1) watershed arc, 2) mixed, or 3)region boundary)
% sf_wt=imread('zebra-finest-partition.png'); % this is saved while computing SE_ucm(I,model,fmt);
% U=z_SE_ucm; U=U(1:2:end-2,1:2:end-2); % to get an 'imageSize' - same resolution as sf_wt
% rgb_loc=cat(3,~~U,zeros(size(sf_wt)),~~(1-(double(sf_wt)./255))); initFig; im(rgb_loc); % red arcs (a few of them) - added by the UCM algorithm, blue arcs - removed by the UCM algorithm (but had some votes on them);magenta edges - had votes on them in the weighted watershed (finest partition) and "made it" to the final UCM
% initFig; im(rgb_loc);

set(0,'DefaulttextInterpreter','none'); % display '_' in title normally

initFig(1);im(I)
initFig;im(Ec)
% for k=1:gtsz, initFig;im(gt{k}.Boundaries); end
% for ease of viewing, show the negative of the boundaries
for k=1:gtsz, initFig;im(~gt{k}.Boundaries); end
% for k=1:gtsz, initFig;im(gt{k}.Segmentation); end
% show colour-coded segmentation with the colour of each segment being the mean
% colour of its pixels
for k=1:gtsz, initFig;im(mean_colour_segmentation(I,gt{k}.Segmentation)); end
initFig;im(E)
cmap=fademap;
initFig;im(E);colormap(cmap) % dispalys the edges 'jet' colour-coded
% % this is poor visualisation, since the ws segments are labeled in increasing
% % order, so the contrast between neighbouring segments is low
% initFig;im(z_SE_ws)
initFig; imcc(z_SE_ws);
% this is good visualisation of just the boundaries, since they will end up
% being white, as in the colour-coded case above
initFig;im(ws_mask);
initFig;im(E_ws);
initFig;im(z_ws_red);
initFig;im(z_E_ws_red);

initFig;im(z_SE_ucm)
initFig;im(z_gPb_owt_ucm)
initFig;imagesc(z_gPb_owt_ucm) % heatmap

% initFig;imcc(z_SE_ucm_seg.low)
% initFig;imcc(z_SE_ucm_seg.high)
% 
% initFig;imcc(z_gPb_owt_ucm_seg.low)
% initFig;imcc(z_gPb_owt_ucm_seg.high)
% better with the segmentation colour-coded according to mean colour of segment
initFig;im(mean_colour_segmentation(I,z_SE_ucm_seg.low))
initFig;im(mean_colour_segmentation(I,z_SE_ucm_seg.high))

initFig;im(mean_colour_segmentation(I,z_gPb_owt_ucm_seg.low))
initFig;im(mean_colour_segmentation(I,z_gPb_owt_ucm_seg.high))

% to save as png (the better format for importing images into latex)
% saveas(gcf,'/home/kostadinova/downloads/foo.png');
% imwrite(~gt{3}.Boundaries,'/home/kostadinova/downloads/starfish_bdry_detail.png');
% imwrite(mean_colour_segmentation(I,gt{3}.Segmentation),'/home/kostadinova/downloads/starfish_segm_detail.png');
end
