function output=Plotsegmeval(outDir,plotsuperpose,col)
% plot evaluation results
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
%
% modified by Fabio Galasso
% February 2014

output=struct();

if ( (~exist('plotsuperpose','var')) || (isempty(plotsuperpose)) )
    plotsuperpose=false;
end
if ( (~exist('col','var')) || (isempty(col)) )
    col='r';
end

%Determine case dir for printing hline
wherefilesep=strfind(outDir(1:end-1),filesep); %one character (t from Output) is truncated or filesep is removed)
if (numel(wherefilesep)>=2)
    casebenchdir=outDir(wherefilesep(end-1)+1:wherefilesep(end)-1);
else
    casebenchdir='CASEDIR';
end

% fprintf('%s\n',casebenchdir);


%Boundary metrics
if (exist(fullfile(outDir,'eval_bdry_globalthr.txt'),'file'))
    
    %%% Global statistics %%%
    prvals = dlmread(fullfile(outDir,'eval_bdry_globalthr.txt')); % thresh,r,p,f global values across all image for each threshold
    prvals = prvals( (prvals(:,2)>=0.01) ,:); %only those threshold numbers for recall > 0.01

    evalRes = dlmread(fullfile(outDir,'eval_bdry_globossods.txt')); %bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR
    
    if (plotsuperpose)
        figure(1);
    else
        Init_figure_no(1), Plotisofigregpr(); %Plotisofig
    end
    hold on
    if (size(prvals,1)>1) %if only one hierarchical level is present, the figures correspond to ODS
        plot(prvals(1:end,2),prvals(1:end,3),col,'LineWidth',3);
        title('Boundary Global PR Curve');
    else
        plot(evalRes(2),evalRes(3),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',8);
        title('Boundary Global PR Curve'); %Just the value corresponding to the maxmimum F is plotted, i.e. G-ODS
    end
    hold off
    saveas(gcf,fullfile(outDir,'BPR'),'jpg');
    
    fprintf('Boundary PR global\n');
    fprintf('   G-ODS: F( R %1.2f, P %1.2f ) = %1.2f   [th = %1.2f]\n',evalRes(2:4),evalRes(1));
    fprintf('   G-OIS: F( R %1.2f, P %1.2f ) = %1.2f\n',evalRes(5:7));
    fprintf('   Area_PR = %1.2f\n',evalRes(8));
    output.B_G_ODS=evalRes(4); output.B_G_OSS=evalRes(7); output.B_G_area=evalRes(8);

end

%Volume metrics: precision recall
if (exist(fullfile(outDir,'eval_regpr_globalthr.txt'),'file'))
    
    %%% Global statistics %%%
    prvals = dlmread(fullfile(outDir,'eval_regpr_globalthr.txt')); % thresh,r,p,f global values across all image for each threshold
%     prvals = prvals( (prvals(:,3)>=0.01) ,:); %only those threshold numbers for precision > 0.01

    evalRes = dlmread(fullfile(outDir,'eval_regpr_globossods.txt')); %bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR
    
    if (plotsuperpose)
        figure(6);
    else
        Init_figure_no(6), Plotisofigregpr();
    end
    hold on
    if (size(prvals,1)>1) %if only one hierarchical level is present, the figures correspond to ODS
        plot(prvals(1:end,2),prvals(1:end,3),col,'LineWidth',3);
        title('Volume Global PR Curve');
    else
        plot(evalRes(2),evalRes(3),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',8);
        title('Volume Global PR Curve'); %Just the value corresponding to the maxmimum F is plotted, i.e. G-ODS
    end
    hold off
    saveas(gcf,fullfile(outDir,'VPR'),'jpg');
    
    fprintf('Volume PR global\n');
    fprintf('   G-ODS: F( R %1.2f, P %1.2f ) = %1.2f   [th = %1.2f]\n',evalRes(2:4),evalRes(1));
    fprintf('   G-OSS: F( R %1.2f, P %1.2f ) = %1.2f\n',evalRes(5:7));
    fprintf('   G-Area_PR = %1.2f\n',evalRes(8));
    output.R_G_ODS=evalRes(4); output.R_G_OSS=evalRes(7); output.R_G_area=evalRes(8);

end

%Segmentation covering
if (exist(fullfile(outDir,'eval_cover.txt'),'file'))
    evalRes = dlmread(fullfile(outDir,'eval_cover.txt')); %bestT, bestR, R_best, R_best_total
    fprintf('Region\n');
    fprintf('   GT covering: ODS = %1.2f [th = %1.2f]. OSS = %1.2f. Best = %1.2f\n',evalRes(2),evalRes(1),evalRes(3:4));
    output.SC_ODS=evalRes(2); output.SC_OSS=evalRes(3); output.SC_Best=evalRes(4);
    
end

%PRI and VI
if (exist(fullfile(outDir,'eval_RI_VOI.txt'),'file'))
    evalRes = dlmread(fullfile(outDir,'eval_RI_VOI.txt'));
    fprintf('Region\n');
    fprintf('   Rand Index: ODS = %1.2f [th = %1.2f]. OSS = %1.2f.\n',evalRes(2),evalRes(1),evalRes(3));
    fprintf('   Var. Info.: ODS = %1.2f [th = %1.2f]. OSS = %1.2f.\n',evalRes(5),evalRes(4),evalRes(6));
    output.PRI_ODS=evalRes(2); output.PRI_OSS=evalRes(3); output.VI_ODS=evalRes(5); output.VI_OSS=evalRes(6);

end



%Length and n cluster statistics
if ( (exist(fullfile(outDir,'eval_regpr_avgthr.txt'),'file')) && (exist(fullfile(outDir,'eval_nclustersstats_thr.txt'),'file')) && (true) )
    
    %%%Global length statistics
    if (true)
        %Load relevant average volume metrics
        prvals = dlmread(fullfile(outDir,'eval_regpr_globalthr.txt')); % thresh,r,p,f global values across all image for each threshold
        evalRes = dlmread(fullfile(outDir,'eval_regpr_globossods.txt'));

        %Load the relevant average length statistics
        lengthvals = dlmread(fullfile(outDir,'eval_lengthglobstats_thr.txt')); % thresh meanlengths_avg stdlengths_avg

        %Length and Precision
            if (plotsuperpose)
                figure(9);
            else
                Init_figure_no(9,[],false); Plotisofiglengthstats(false);
            end
            hold on
            if (size(prvals,1)>1)
                plot(lengthvals(1:end,2),prvals(1:end,3),col,'LineWidth',3);
                xlabel('Avg Length');
                title('Length Precision Curve Global');
            else
                plot(lengthvals(2),evalRes(3),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',8);
                xlabel('Avg Length');
                title('Length Precision Curve Global');
            end
            hold off
            saveas(gcf,fullfile(outDir,'length_precision'),'jpg');
        
        [val,idx]=sort( abs( lengthvals(:,1)-repmat(evalRes(1),size(lengthvals,1),1) ) , 'ascend'); %#ok<ASGLU>
        fprintf('Length stats with Volume PR global\n');
        fprintf('   Length best F [th = %1.2f] G-ODS: mean %1.2f, std %1.2f \n',evalRes(1), lengthvals(idx(1),2), lengthvals(idx(1),3) );
        output.MLen_G_ODS=lengthvals(idx(1),2); output.StdLen_G_ODS=lengthvals(idx(1),3);

    end
    
    
    %%%Global cluster statistics
    if (true)
        %Load relevant average volume metrics
        prvals = dlmread(fullfile(outDir,'eval_regpr_globalthr.txt')); % thresh,r,p,f global values across all image for each threshold
        evalRes = dlmread(fullfile(outDir,'eval_regpr_globossods.txt'));

        %Load the relevant average number of cluster statistics
        nclustervals = dlmread(fullfile(outDir,'eval_nclustersstats_thr.txt')); % thresh meanlengths_avg stdlengths_avg

        %Length and Precision
            if (plotsuperpose)
                figure(11);
            else
                Init_figure_no(11,[],false); Plotisofiglengthstats(false);
            end
            hold on
            if (size(prvals,1)>1)
                plot(log10(nclustervals(1:end,2)),prvals(1:end,3),col,'LineWidth',3);
                xlabel('Avg N Clusters (log10)');
                title('Ncluster Precision Curve Global');
            else
                plot(log10(nclustervals(2)),evalRes(3),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,'MarkerSize',8);
                xlabel('Avg N Clusters (log10)');
                title('Ncluster Precision Curve Global');
            end
            hold off
            saveas(gcf,fullfile(outDir,'ncluster_precision'),'jpg');


        [val,idx]=sort( abs( nclustervals(:,1)-repmat(evalRes(1),size(nclustervals,1),1) ) , 'ascend'); %#ok<ASGLU>
        fprintf('Ncluster stats with Volume PR global\n');
        fprintf('   Ncluster best F [th = %1.2f] G-ODS: avg ncluster %1.2f \n',evalRes(1), nclustervals(idx(1),2) );
        output.Ncl_G_ODS=nclustervals(idx(1),2);

    end
end




%Include into output also the R and P at ODS
if (exist(fullfile(outDir,'eval_bdry_globossods.txt'),'file')) %B G
    evalRes = dlmread(fullfile(outDir,'eval_bdry_globossods.txt')); %bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR
    output.B_ODSG_R=evalRes(2); output.B_ODSG_P=evalRes(3);
end
if (exist(fullfile(outDir,'eval_regpr_globossods.txt'),'file')) %R G
    evalRes = dlmread(fullfile(outDir,'eval_regpr_globossods.txt')); %bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR
    output.R_ODSG_R=evalRes(2); output.R_ODSG_P=evalRes(3);
end




            
            
            
            
            
