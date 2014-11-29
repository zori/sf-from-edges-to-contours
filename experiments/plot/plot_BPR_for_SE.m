% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function [fhSf,legendSf] = plot_BPR_for_SE(plotOpts)
% SF is an edge detector; segmentation benchmarks are not applicable, only BPR
plotOpts.outDirR='Output_sf_edges';
plotOpts.metrics='bdry';
plotOpts.plotStyle={'k'};
[output,fhSf]=ComputeRP(plotOpts);
legendSf=['SE' fscore_str(output.B_G_ODS, output.B_G_OSS)];
end
