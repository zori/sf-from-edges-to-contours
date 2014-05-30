% Demo for Structured Edge Detector.
%
% The Structured Edge Detector is described in the following work:
%  P. Dollár and C. Zitnick
%  "Structured Forests for Fast Edge Detection", ICCV 2013.
% Please cite the above paper if you end up using the edge detector.
%
% Short summary: Very fast detector (up to 60 fps depending on parameter
% settings) that achieves excellent accuracy (top accuracy on BSDS500
% Segmentation dataset and NYU Depth dataset as of publication date). Can
% serve as input to any vision algorithm requring high quality edge maps.
%
% A fully trained model is available as part of this release.
%
% Setup (follow instructions, only need to do once):
% (1) Download and compile Piotr's toolbox (directions on website)
%    http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html
% (2) Compile detector mex code (note: win64/linux64 binaries included):
%    mex private/edgesDetectMex.cpp -outdir private '-DUSEOMP' ...
%      'OPTIMFLAGS="$OPTIMFLAGS' '/openmp"' % Windows
%    mex private/edgesDetectMex.cpp -outdir private '-DUSEOMP' ...
%      CFLAGS="\$CFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp" % Linux
%    mex private/edgesDetectMex.cpp -outdir private '-DUSEOMP' ...
%      CXXFLAGS="\$CXXFLAGS -fopenmp" LDFLAGS="\$LDFLAGS -fopenmp" % Linux
% (3) Add edge detection code to path (change to current directory first):
%    addpath(pwd); savepath;
% (4) Optionally download BSDS500 (necessary only for training):
%    http://www.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/
%    BSR/ should contain BSDS500, bench, and documentation
% (5) Add BSR code to path (necessary only for evaluation):
%    addpath('BSR/bench/benchmarks'); savepath;
%
% Structured Edge Detection Toolbox      Version 1.0
% Copyright 2013 Piotr Dollar.  [pdollar-at-microsoft.com]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the MSR-LA Full Rights License [see license.txt]

close_matlabpool = 0;
%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm='modelVSB100_40';   % model name
opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
opts.useParfor=0;                 % parallelize if sufficient memory

%% train edge detector (~30m/15Gb per tree, proportional to nPos/nNeg)
% opts.dsDir='/BS/kostadinova/work/BSR/BSDS500/data/';
opts.dsDir='/BS/kostadinova/work/video_segm/evaluation/VSB100_40_train_test/train/';
if (opts.useParfor && ~matlabpool('size'))
    matlabpool open 12;
    matlabpool('addattachedfiles', {'video_segm/private/edgesDetectMex.mexw64'});
end;
tic, model=edgesTrain(opts); training_time=toc; % will load model if already trained

%% set detection parameters (can set after training)
model.opts.multiscale=0;          % for top accuracy set multiscale=1
model.opts.nTreesEval=4;          % for top speed set nTreesEval=1
model.opts.nThreads=4;            % max number threads for evaluation
model.opts.nms=0;                 % set to true to enable nms (fairly slow)

%% evaluate edge detector on BSDS500 (see edgesEval.m)
ev_opts = {'dsDir', '/BS/kostadinova/work/video_segm/evaluation/VSB100_40_train_test/test/'};
tic, [ODS,OIS,AP]=segmEval( model, ev_opts ); evaluation_time=toc;
if (close_matlabpool && matlabpool('size')), matlabpool close; end;

fprintf('Training took %f, testing took %f\n', training_time, evaluation_time);
% % detect edge and visualize results
% I = imread('peppers.png');
% tic, E=edgesDetect(I,model); toc
% figure(1); im(I); figure(2); im(1-E);
% ws=watershed(E);
% figure(3); im(ws);
