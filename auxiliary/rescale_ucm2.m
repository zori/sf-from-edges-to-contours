% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function rescale_ucm2(indir_experiment_name)
% rescales the ucm2 output, so that the values are roughly in [0,1]
% indir_experiment_name='ucm_bdry_sz_1_ul_1x1'
assert(~isempty(indir_experiment_name));
% input
path_to_dir='/BS/kostadinova/work/video_segm_evaluation/BSDS500/test';
indir.r=['Ucm2_' indir_experiment_name]; % relative directory name
indir.a=fullfile(path_to_dir,indir.r); % absolute directory name
ucm2s=dir(fullfile(indir.a,'*mat'));
ucm2sz=[643 963];
ucm2n=length(ucm2s);
assert(ucm2n==200);

% analysis
data=repmat(struct('ucm2',zeros(ucm2sz)),ucm2n,1);
for k=1:ucm2n
  u=load(fullfile(indir.a,ucm2s(k).name)); u=u.ucm2;
  data(k).ucm2=u;
  data(k).nonzeros=u(u~=0);
  data(k).num_nonzeros=length(data(k).nonzeros);
  un=unique(data(k).nonzeros);
  data(k).num_unique=length(un);
  data(k).min=un(1);
  data(k).max=un(end);
  if false,
    % histogram of the values in the original ucm2s
    figure; hist(u(inds))
  end
end
if true
  % data statistics
  mean([data.num_nonzeros]) % 815.8 avg number of nonzeros per ucm2 (out of 643*963=619209 pixels)
  mean([data.num_unique]) % 15.5 avg number of unique values in a ucm2
  total.nonzeros=vertcat(data.nonzeros);
  total.un=unique(total.nonzeros);
  total.num_unique=length(total.un) % 337
  total.un(1)   % 0.00061
  total.un(end) % 0.00245
end

% output
outdir.r = [indir.r '_rescaled'];
[~,~,msgid] = mkdir(path_to_dir,outdir.r);
if strcmp(msgid,'MATLAB:MKDIR:DirectoryExists')
  warning('Directory already exists. Exiting');
  return;
end
outdir.a=fullfile(path_to_dir,outdir.r);

scale=1 ./ total.un(end);
% the following rescaling schema would result to the dataset-maximum value
% being 1 = total.un(end) * scale
% the dataset-minimum = total.un(1) * scale;
% for indir_experiment_name='ucm_bdry_sz_1_ul_1x1' the dataset-minimum will be 0.2504
for k=1:ucm2n
  % % if you want to exted the data struct with the rescaled result:
  % data(k).ucm2_rescaled=data(k).ucm2 .* scale;
  f=matfile(fullfile(outdir.a,ucm2s(k).name),'Writable',true);
  f.ucm2=data(k).ucm2 .* scale;
end
end