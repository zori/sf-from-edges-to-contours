% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function crop_plots()
orig_dir_a='/home/kostadinova/downloads/mid-masters presentation/3/imgs/results-plots/orig/';
imgs=dir(fullfile(orig_dir_a,'*.png'));
for k=1:length(imgs)
  plot_name=imgs(k).name;
  orig=imread(fullfile(orig_dir_a,plot_name));
  cropped=orig(35:858,87:1093,:); % nice cropping for plots saved with saveas(gcf,file_name,'png'))
  imwrite(cropped,fullfile('/home/kostadinova/downloads/mid-masters presentation/3/imgs/results-plots/cropped/',plot_name));
end
end
