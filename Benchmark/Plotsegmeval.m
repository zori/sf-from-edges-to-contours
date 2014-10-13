function [output,fhs]=Plotsegmeval(outDirA,superposePlot,plotStyle)
% Plot evaluation results.
%
% INPUTS
%  outDirA        - absolute path to the output directory
%  superposePlot  - [false] when true additional graphs will be plotted on the
%                   same figure for comparing results of multiple algorithms;
%                   otherwise the plot has isolines and is saved in outDirA
%  curveColor     - ['r'] color for plotting the curves
%  model          - trained structured edge detector w the following fields
%
% OUTPUTS
%  output         - structure summarising the evaluation results
%  fhs            - array of figure handles to the plots
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
%
% modified by Fabio Galasso
% February 2014
%
% modified by Zornitsa Kostadinova
% Jun 2014

output=struct();
fhs=[];

if ( (~exist('superposePlot','var')) || (isempty(superposePlot)) )
    superposePlot=false;
end
if ( (~exist('plotStyle','var')) || (isempty(plotStyle)) )
    plotStyle={'r'};
end
plotColor=plotStyle{1};
if numel(plotStyle)==1, plotStyle={}; else plotStyle=plotStyle(2:end); end
ODS_plotStyle=getPrmDflt(plotStyle,{'Color',plotColor,'LineWidth',3},-1);
ODS_plotStyle=struct2cell2(ODS_plotStyle);
G_ODS_plotStyle=getPrmDflt(plotStyle,{'Marker','o','MarkerFaceColor',plotColor,'MarkerEdgeColor',plotColor,'MarkerSize',8},-1);
G_ODS_plotStyle=struct2cell2(G_ODS_plotStyle);

% %Determine case dir for printing hline
% wherefilesep=strfind(outDirA(1:end-1),filesep); %one character (t from Output) is truncated or filesep is removed)
% if (numel(wherefilesep)>=2)
%     casebenchdir=outDirA(wherefilesep(end-1)+1:wherefilesep(end)-1);
% else
%     casebenchdir='CASEDIR';
% end
% 
% % fprintf('%s\n',casebenchdir);

%Boundary metrics
if (exist(fullfile(outDirA,'eval_bdry_globalthr.txt'),'file'))
    
    %%% Global statistics %%%
    prvals = dlmread(fullfile(outDirA,'eval_bdry_globalthr.txt')); % thresh,r,p,f global values across all image for each threshold
    prvals = prvals( (prvals(:,2)>=0.01) ,:); %only those threshold numbers for recall > 0.01

    evalRes = dlmread(fullfile(outDirA,'eval_bdry_globossods.txt')); %bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR
    
    if (superposePlot)
        figure(1);
    else
        Init_figure_no(1), Plotisofigregpr(); %Plotisofig
    end
    hold on
    if (size(prvals,1)>1) %if only one hierarchical level is present, the figures correspond to ODS
        plot(prvals(1:end,2),prvals(1:end,3),ODS_plotStyle{:});
    else
        % Just the value corresponding to the maxmimum F is plotted, i.e. G-ODS
        plot(evalRes(2),evalRes(3),G_ODS_plotStyle{:});
    end
    xlabel('recall');
    ylabel('precision');
    title('BPR');
    hold off
    if ~superposePlot, saveas(gcf,fullfile(outDirA,'_BPR'),'jpg'); end
    fhs=[fhs gcf];
    
    fprintf('Boundary PR global\n');
    fprintf('   G-ODS: F( R %1.2f, P %1.2f ) = %1.2f   [th = %1.2f]\n',evalRes(2:4),evalRes(1));
    fprintf('   G-OIS: F( R %1.2f, P %1.2f ) = %1.2f\n',evalRes(5:7));
    fprintf('   Area_PR = %1.2f\n',evalRes(8));
    output.B_G_ODS=evalRes(4); output.B_G_OSS=evalRes(7); output.B_G_area=evalRes(8);
end

%Volume metrics: precision recall
if (exist(fullfile(outDirA,'eval_regpr_globalthr.txt'),'file'))
    
    %%% Global statistics %%%
    prvals = dlmread(fullfile(outDirA,'eval_regpr_globalthr.txt')); % thresh,r,p,f global values across all image for each threshold
%     prvals = prvals( (prvals(:,3)>=0.01) ,:); %only those threshold numbers for precision > 0.01

    evalRes = dlmread(fullfile(outDirA,'eval_regpr_globossods.txt')); %bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR
    
    if (superposePlot)
        figure(6);
    else
        Init_figure_no(6), Plotisofigregpr();
    end
    hold on
    if (size(prvals,1)>1) %if only one hierarchical level is present, the figures correspond to ODS
        plot(prvals(1:end,2),prvals(1:end,3),ODS_plotStyle{:});
    else
        % Just the value corresponding to the maxmimum F is plotted, i.e. G-ODS
        plot(evalRes(2),evalRes(3),G_ODS_plotStyle{:});
    end
    xlabel('recall');
    ylabel('precision');
    title('VPR');
    hold off
    if ~superposePlot, saveas(gcf,fullfile(outDirA,'_VPR'),'jpg'); end
    fhs=[fhs gcf];
    
    fprintf('Volume PR global\n');
    fprintf('   G-ODS: F( R %1.2f, P %1.2f ) = %1.2f   [th = %1.2f]\n',evalRes(2:4),evalRes(1));
    fprintf('   G-OSS: F( R %1.2f, P %1.2f ) = %1.2f\n',evalRes(5:7));
    fprintf('   G-Area_PR = %1.2f\n',evalRes(8));
    output.R_G_ODS=evalRes(4); output.R_G_OSS=evalRes(7); output.R_G_area=evalRes(8);
end

%Segmentation covering
if (exist(fullfile(outDirA,'eval_cover.txt'),'file'))
    evalRes = dlmread(fullfile(outDirA,'eval_cover.txt')); %bestT, bestR, R_best, R_best_total
    fprintf('Region\n');
    fprintf('   GT covering: ODS = %1.2f [th = %1.2f]. OSS = %1.2f. Best = %1.2f\n',evalRes(2),evalRes(1),evalRes(3:4));
    output.SC_ODS=evalRes(2); output.SC_OSS=evalRes(3); output.SC_Best=evalRes(4);  
end

%PRI and VI
if (exist(fullfile(outDirA,'eval_RI_VOI.txt'),'file'))
    evalRes = dlmread(fullfile(outDirA,'eval_RI_VOI.txt'));
    fprintf('Region\n');
    fprintf('   Rand Index: ODS = %1.2f [th = %1.2f]. OSS = %1.2f.\n',evalRes(2),evalRes(1),evalRes(3));
    fprintf('   Var. Info.: ODS = %1.2f [th = %1.2f]. OSS = %1.2f.\n',evalRes(5),evalRes(4),evalRes(6));
    output.PRI_ODS=evalRes(2); output.PRI_OSS=evalRes(3); output.VI_ODS=evalRes(5); output.VI_OSS=evalRes(6);
end

%Length and n cluster statistics
if ( (exist(fullfile(outDirA,'eval_regpr_avgthr.txt'),'file')) && (exist(fullfile(outDirA,'eval_nclustersstats_thr.txt'),'file')) && (true) )   
    %%%Global length statistics
    if (true)
        %Load relevant average volume metrics
        prvals = dlmread(fullfile(outDirA,'eval_regpr_globalthr.txt')); % thresh,r,p,f global values across all image for each threshold
        evalRes = dlmread(fullfile(outDirA,'eval_regpr_globossods.txt'));

        %Load the relevant average length statistics
        lengthvals = dlmread(fullfile(outDirA,'eval_lengthglobstats_thr.txt')); % thresh meanlengths_avg stdlengths_avg

        %Length and Precision
            if (superposePlot)
                figure(9);
            else
                Init_figure_no(9,[],false); Plotisofiglengthstats(false);
            end
            hold on
            if (size(prvals,1)>1)
                plot(lengthvals(1:end,2),prvals(1:end,3),ODS_plotStyle{:});
            else
                plot(lengthvals(2),evalRes(3),G_ODS_plotStyle{:});
            end
            xlabel('avg length');
            title('length precision'); % Length Precision Curve Global
            hold off
            if ~superposePlot, saveas(gcf,fullfile(outDirA,'_length_precision'),'jpg'); end
            fhs=[fhs gcf];
        
        [val,idx]=sort( abs( lengthvals(:,1)-repmat(evalRes(1),size(lengthvals,1),1) ) , 'ascend'); %#ok<ASGLU>
        fprintf('Length stats with Volume PR global\n');
        fprintf('   Length best F [th = %1.2f] G-ODS: mean %1.2f, std %1.2f \n',evalRes(1), lengthvals(idx(1),2), lengthvals(idx(1),3) );
        output.MLen_G_ODS=lengthvals(idx(1),2); output.StdLen_G_ODS=lengthvals(idx(1),3);
    end

    %%%Global cluster statistics
    if (true)
        %Load relevant average volume metrics
        prvals = dlmread(fullfile(outDirA,'eval_regpr_globalthr.txt')); % thresh,r,p,f global values across all image for each threshold
        evalRes = dlmread(fullfile(outDirA,'eval_regpr_globossods.txt'));

        %Load the relevant average number of cluster statistics
        nclustervals = dlmread(fullfile(outDirA,'eval_nclustersstats_thr.txt')); % thresh meanlengths_avg stdlengths_avg

        %Length and Precision
            if (superposePlot)
                figure(11);
            else
                Init_figure_no(11,[],false); Plotisofiglengthstats(false);
            end
            hold on
            if (size(prvals,1)>1)
                plot(log10(nclustervals(1:end,2)),prvals(1:end,3),ODS_plotStyle{:});
            else
                plot(log10(nclustervals(2)),evalRes(3),G_ODS_plotStyle{:});
            end
            xlabel('avg N clusters (log10)');
            title('ncluster precision'); % Ncluster Precision Curve Global
            hold off
            if ~superposePlot, saveas(gcf,fullfile(outDirA,'_ncluster_precision'),'jpg'); end
            fhs=[fhs gcf];

        [val,idx]=sort( abs( nclustervals(:,1)-repmat(evalRes(1),size(nclustervals,1),1) ) , 'ascend'); %#ok<ASGLU>
        fprintf('Ncluster stats with Volume PR global\n');
        fprintf('   Ncluster best F [th = %1.2f] G-ODS: avg ncluster %1.2f \n',evalRes(1), nclustervals(idx(1),2) );
        output.Ncl_G_ODS=nclustervals(idx(1),2);

    end
end

%Include into output also the R and P at ODS
if (exist(fullfile(outDirA,'eval_bdry_globossods.txt'),'file')) %B G
    evalRes = dlmread(fullfile(outDirA,'eval_bdry_globossods.txt')); %bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR
    output.B_ODSG_R=evalRes(2); output.B_ODSG_P=evalRes(3);
end
if (exist(fullfile(outDirA,'eval_regpr_globossods.txt'),'file')) %R G
    evalRes = dlmread(fullfile(outDirA,'eval_regpr_globossods.txt')); %bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR
    output.R_ODSG_R=evalRes(2); output.R_ODSG_P=evalRes(3);
end
end

% ----------------------------------------------------------------------
function c = struct2cell2(s)
  fs=fieldnames(s);
  vs=struct2cell(s);
  tmp=[fs';vs'];
  c=tmp(:);
end
