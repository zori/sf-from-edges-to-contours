% Zornitsa Kostadinova
% Oct 2014
% 8.3.0.532 (R2014a)
function png2ucms()
p='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test/ucm2_precomputed/'; % path
d_in=['Ucm2_SF_single_scale_on_contours' '_png']; % dir
d_out=['Ucm2_SF_single_scale_on_contours' '_ucm2'];

pa=fullfile(p,d_in);
fmt='doubleSize';
D=dir([pa '/*.png']);
for k=1:length(D)
  IM=imread(fullfile(pa,D(k).name));
  E=double(IM)/255;
  ucm2=contours2ucm(E,fmt); %#ok<NASGU>
  n=D(k).name(1:end-4); % remove filename extension
  save(fullfile(p,d_out,n),'ucm2'); % write mat output
end
end
