%Use the command Computerpimvid computes the Precision-Recall curves

benchmarkpath = '/BS/kostadinova/work/video_segm/evaluation/'; %The directory where all results directory are contained
benchmarkdir= 'SRF_VSB100'; %One the computed results set up for benchmark, here the output of the algorithm of Dollar (Ucm2 folder) set up for the general benchmark (Images and Groundtruth folders)
requestdelconf=true; %boolean which allows overwriting without prompting a message. By default the user is input for deletion of previous calculations
nthresh=51; %Number of hierarchical levels to include when benchmarking image segmentation
superposegraph=false; %When false a new graph is initialized, otherwise the new curves are added to the graph
testtemporalconsistency=true; %this option is set to false for testing image segmentation algorithms
bmetrics={'bdry','regpr','sc','pri','vi','lengthsncl','all'}; %which benchmark metrics to compute:
                                            %'bdry' BPR, 'regpr' VPR, 'sc' SC, 'pri' PRI, 'vi' VI, 'all' computes all available

tic;
output=Computerpimvid(benchmarkpath,nthresh,benchmarkdir,requestdelconf,0,'r',superposegraph,testtemporalconsistency,'bdry');
toc;
