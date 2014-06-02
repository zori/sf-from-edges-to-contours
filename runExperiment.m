function runExperiment()
% SRF training and evaluation (using the VSB100 benchmark)

close_matlabpool = false;
to_log = true;
logging.timestamp = datestr(clock,'yyyy-mm-dd_HH-MM-SS');
logging.dir = '/BS/kostadinova/work/video_segm/evaluation/';
logging.folder = fullfile(logging.dir, [logging.timestamp '_recordings']);
logging.options_file = fullfile(logging.folder, 'options.txt');
logging.fid = 1;    % default is stdout
if (to_log), mkdir(logging.folder), logging.fid = fopen(logging.options_file, 'w'); end

%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelVSB100_40';   % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory

%% train edge detector (~30m/15Gb per tree, proportional to nPos/nNeg)
% dsDir='/BS/kostadinova/work/BSR/BSDS500/data/';
dsDir = '/BS/kostadinova/work/video_segm/evaluation/VSB100_40_train_test/';
opts.dsDir= fullfile(dsDir, 'train/');
if (opts.useParfor && ~matlabpool('size'))
    matlabpool open 12;
    matlabpool('addattachedfiles', {'/BS/kostadinova/work/video_segm/private/edgesDetectMex.mexw64'});
end;
tic, model=edgesTrain(opts); training_time=toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=false;      % for top accuracy set multiscale=true
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=false;             % set to true to enable nms (fairly slow)

%% evaluate edge/segment detector
eval_name = 'VSB100';
eval_opts = {
    'imgDir', fullfile(dsDir, 'test/Images/'), ...
    'gtDir', fullfile(dsDir, 'test/Groundtruth/'), ...
    'resDir', fullfile(opts.modelDir, 'test/', [opts.modelFnm eval_name filesep]) ... %'resDir', ['models/test/modelVSB100_40' eval_name] ...
    };

tic, segmEval( model, eval_opts ); evaluation_time=toc;
if (close_matlabpool && matlabpool('size')), matlabpool close; end;

% % detect edge and visualize results
% I = imread('peppers.png');
% tic, E=edgesDetect(I,model); toc
% figure(1); im(I); figure(2); im(1-E);
% ws=watershed(E);
% figure(3); im(ws);

% Computerpimvid computes the Precision-Recall curves

benchmarkpath = dsDir;  % The directory where all results directory are contained
benchmarkdir = 'test';  % The computed results set up for benchmark, here the output of the algorithm of Dollar (Ucm2 folder) and set-up for the general benchmark (Images and Groundtruth folders)
requestdelconf = true;  % allows overwriting without prompting a message. By default the user is input for deletion of previous calculations
nthresh=51;             % number of hierarchical levels to include when benchmarking image segmentation
superposegraph=false;   % When false a new graph is initialized, otherwise the new curves are added to the same graph
test_temp_consistency = true; % false for testing image segmentation algorithms
bmetrics={'bdry','regpr','sc','pri','vi','lengthsncl','all'}; %which benchmark metrics to compute:
                                            %'bdry' BPR, 'regpr' VPR, 'sc' SC, 'pri' PRI, 'vi' VI, 'all' computes all available
metric=bmetrics{end};

tic;
output = Computerpimvid(benchmarkpath, nthresh, benchmarkdir, ...
    requestdelconf, 0, 'r', superposegraph, test_temp_consistency, ...
    metric, [], logging.folder);
benchmark_time=toc;

fprintf(logging.fid, 'training %s, \nevaluation %s, \nbenchmark %s\n\n', ...
    seconds2human(training_time), ...
    seconds2human(evaluation_time), ...
    seconds2human(benchmark_time));

if (to_log) 
    save(fullfile(logging.folder, 'output.mat'), 'output');
    fclose(logging.fid);
end
end