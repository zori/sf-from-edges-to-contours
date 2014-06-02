function runExperiment()
% SRF training and evaluation (using the VSB100 benchmark)

close_matlabpool = false;
to_log = true;

log_.timestamp = datestr(clock,'yyyy-mm-dd_HH-MM-SS');
log_.dir = '/BS/kostadinova/work/video_segm/evaluation/';
log_.folder = fullfile(log_.dir, [log_.timestamp '_recordings']);
log_.file = fullfile(log_.folder, 'recordings.txt');
log_.fid = 1;    % default is stdout
if (to_log), mkdir(log_.folder), log_.fid = fopen(log_.file, 'w'); end
[status, git_commit_id] = system('git --no-pager log --format="%H" -n 1');
if (status), warning('no git repository in %s', pwd); end
fprintf(log_.fid, 'Last git commit %s \n', git_commit_id);

%% Training

%% set opts for training (see edgesTrain.m)
tr_opts=edgesTrain();                % default options (good settings)
tr_opts.modelDir='models/';          % model will be in models/forest
tr_opts.modelFnm='modelVSB100_40';   % model name
tr_opts.nPos=5e5;                    % decrease to speedup training
tr_opts.nNeg=5e5;                    % decrease to speedup training
tr_opts.useParfor=0;                 % parallelize if sufficient memory
dsDir = '/BS/kostadinova/work/video_segm/evaluation/VSB100_40_train_test/'; % dsDir='/BS/kostadinova/work/BSR/BSDS500/data/';
tr_opts.dsDir= fullfile(dsDir, 'train/');

%% train edge detector (~30m/15Gb per tree, proportional to nPos/nNeg)
if (tr_opts.useParfor && ~matlabpool('size'))
    matlabpool open 12;
    matlabpool('addattachedfiles', ...
        {'/BS/kostadinova/work/video_segm/private/edgesDetectMex.mexw64'});
end;

tic;
model = edgesTrain(tr_opts); % will load model if already trained
training_time=toc;

%% Detection

%% set detection parameters (can set after training)
model.opts.multiscale=false;      % for top accuracy set multiscale=true
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=false;             % set to true to enable nms (fairly slow)

%% run edge/segment detector
det_opts = {
    'imgDir', fullfile(dsDir, 'test/Images/'), ...
    'gtDir', fullfile(dsDir, 'test/Groundtruth/'), ...
    'resDir', fullfile(dsDir, 'test/Ucm2/'), ...  % 'resDir', fullfile(opts.modelDir, 'test/', [opts.modelFnm eval_name filesep]) ...
    };

tic;
segmDetect(model, det_opts);
detection_time=toc;

%% Benchmark

bm_opts.path = dsDir;                   % path to bm_opts.dir
bm_opts.dir = 'test';                   % contains the folders `Images', `Groundtruth' and `Ucm2' (computed results of the algorithm of Dollar)
bm_opts.delPrompt = true;               % allows overwriting without prompting a message
bm_opts.nthresh = 51;                   % number of hierarchical levels to include
bm_opts.superposeGraph = false;         % true - new curves are added to the same graph; false - a new graph is initialized
bm_opts.testTempConsistency = true;     % false for images
% possible benchmark metrics
metrics = {
    'bdry', ...       % BPR - Boundary Precision-Recall
    'regpr', ...      % VPR - Volumetric Precision-Recall
    'sc', ...         % SC  - Segmentation Covering
    'pri', ...        % PRI - Probabilistic Rand Index
    'vi', ...         % VI  - Variation of Information
    'lengthsncl', ... % length statistics and number of clusters
    'all' ...         % computes all available
    };
bm_opts.metric = metrics{end};
bm_opts.outDir = log_.folder;

tic;
% Computerpimvid computes the Precision-Recall curves
output = Computerpimvid(bm_opts.path, bm_opts.nthresh, bm_opts.dir, ...
    bm_opts.delPrompt, 0, 'r', bm_opts.superposeGraph, ...
    bm_opts.testTempConsistency, bm_opts.metric, [], bm_opts.outDir);
benchmark_time=toc;

fprintf(log_.fid, 'Training %s \nDetection %s \nBenchmark %s\n\n', ...
    seconds2human(training_time), ...
    seconds2human(detection_time), ...
    seconds2human(benchmark_time));

if (close_matlabpool && matlabpool('size')), matlabpool close; end;

if (to_log) 
    save(fullfile(log_.folder, 'recordings'), ...
        'tr_opts', 'det_opts', 'bm_opts', 'output');
    fclose(log_.fid);
end
end