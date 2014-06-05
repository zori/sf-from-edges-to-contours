function Collectevalaluatereg(outDir)
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
%
% modified by Fabio Galasso
% February 2014

%SC
fname = fullfile(outDir, 'eval_cover.txt');
S = dir(fullfile(outDir,'*_ev2.txt'));
if ( (length(dir(fname))~=1) && (~isempty(S)) )
    
    % deduce nthresh from files
    AA = dlmread(fullfile(outDir,S(1).name));
    nthresh = size(AA,1);
    
    cntR_total = zeros(nthresh,1);
    sumR_total = zeros(nthresh,1);
    cntP_total = zeros(nthresh,1);
    sumP_total = zeros(nthresh,1);
    cntR_best = 0;
    sumR_best = 0;
    cntP_best = 0;
    sumP_best = 0;
    
    cntR_best_total = 0;
    
    scores = zeros(numel(S),4);
    
    fprintf('Processing regions (SC):');
    for i = 1:numel(S),
        
        fprintf(' %d',i);
%         iid = S(i).name(1:end-8);
%         fprintf(2,'Processing image %s (%d/%d)...\n',iid,i,length(S));
        
        evFile1 = fullfile(outDir,S(i).name);
        tmp  = dlmread(evFile1);

        %check and adjust different number of coarse-to-fine levels
        %This is used for algorithms which do not let the user fix the
        %number of levels. The finest level is replicated
        tmpsize=size(tmp,1);
        if (tmpsize<nthresh) %if not of equal size, the final line is replicated
            tmp=[tmp;repmat(tmp(end,:),nthresh-tmpsize,1)]; %#ok<AGROW>
        elseif (tmpsize>nthresh)
            cntR_total=[cntR_total;repmat(cntR_total(end),tmpsize-nthresh,1)]; %#ok<AGROW>
            sumR_total=[sumR_total;repmat(sumR_total(end),tmpsize-nthresh,1)]; %#ok<AGROW>
            cntP_total=[cntP_total;repmat(cntP_total(end),tmpsize-nthresh,1)]; %#ok<AGROW>
            sumP_total=[sumP_total;repmat(sumP_total(end),tmpsize-nthresh,1)]; %#ok<AGROW>
            nthresh=tmpsize;
        end
        
        thresh = tmp(:, 1);
        cntR = tmp(:, 2);
        sumR = tmp(:, 3);
        cntP = tmp(:, 4);
        sumP = tmp(:, 5);
        
        R = cntR ./ (sumR + (sumR==0));
        P = cntP ./ (sumP + (sumP==0));
        
        [bestR ind] = max(R);
        bestT = thresh(ind(1));
        bestP = P(ind(1));
        scores(i,:) = [i bestT bestR bestP ];
        
        cntR_total = cntR_total + cntR;
        sumR_total = sumR_total + sumR;
        cntP_total = cntP_total + cntP;
        sumP_total = sumP_total + sumP;
        
        ff=find(R==max(R));
        cntR_best = cntR_best + cntR(ff(end));
        sumR_best = sumR_best + sumR(ff(end));
        cntP_best = cntP_best + cntP(ff(end));
        sumP_best = sumP_best + sumP(ff(end));
        
        evFile2 = fullfile(outDir,[S(i).name(1:end-5) '3.txt']);
        tmp  = dlmread(evFile2);
        cntR_best_total = cntR_best_total + tmp(1);
        
    end
    fprintf('\n');
    
    R = cntR_total ./ (sumR_total + (sumR_total==0));
    
    [bestR ind] = max(R);
    bestT = thresh(ind(1));
    
    
    fname = fullfile(outDir,'eval_cover_img.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10d %10g %10g %10g\n',scores');
    fclose(fid);
    
    fname = fullfile(outDir,'eval_cover_th.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g\n',[thresh R]');
    fclose(fid);
    
    R_best = cntR_best ./ (sumR_best + (sumR_best==0));
    
    R_best_total = cntR_best_total / sumR_total(1) ;
    
    fname = fullfile(outDir,'eval_cover.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g\n',bestT, bestR, R_best, R_best_total);
    fclose(fid);
    
    %bestT,bestR,bestP numbers in scores (eval_cover_img.txt) from best R,P,F across the thresholds for each image:
    %for each image, R and P are computed for all thresholds and the best
    %values are chosen according to R

    %R values and T in eval_cover_th.txt: for each image, cntR and sumR are summed
    %to form a total for each threshold. cntR_total/sumR_total are the global
    %R scores for each threshold
    
    %bestT, bestR, R_best, R_best_total in eval_cover.txt: cntR/P and
    %sumR/P are summed for each threshold across the images to form
    %cntR/P_total and sumR/P_total. The best R value across the thresholds
    %is bestR and its index is bestT. The best values of R and P across
    %thresholds are chosen according to R and summed up across images to
    %form cntR/P_best and sumR/P_best. Their ratio provides R_best.
    %The best R, considering for each ground truth segment the best matched
    %segment (over all thresholds) from the computed segmentation, is
    %summed up and divided by the summed total for the R for the lowest
    %threshold to provide R_best_total
    
end

%PRI and VI
fname = fullfile(outDir, 'eval_RI_VOI.txt');
S = dir(fullfile(outDir,'*_ev4.txt'));
if ( (length(dir(fname))~=1) && (~isempty(S)) )
    
    % deduce nthresh from files
    AA = dlmread(fullfile(outDir,S(1).name));
    nthresh = size(AA,1);
    
    globalRI = zeros(nthresh,1);
    globalVOI = zeros(nthresh,1);
    RI_best = 0;
    VOI_best = 0;
    
    fprintf('Processing regions (PRI, VI):');
    for i = 1:numel(S),
        
        fprintf(' %d',i);
%         iid = S(i).name(1:end-8);
%         fprintf(2,'Processing image %s (%d/%d)...\n',iid,i,length(S));
        
        evFile3 = fullfile(outDir,S(i).name);
        tmp  = dlmread(evFile3);

        %check and adjust different number of coarse-to-fine levels
        %This is used for algorithm which do not let the user fix the
        %number of levels. The finest level is replicated
        tmpsize=size(tmp,1);
        if (tmpsize<nthresh) %if not of equal size, the final line is replicated
            tmp=[tmp;repmat(tmp(end,:),nthresh-tmpsize,1)]; %#ok<AGROW>
        elseif (tmpsize>nthresh)
            globalRI=[globalRI;repmat(globalRI(end),tmpsize-nthresh,1)]; %#ok<AGROW>
            globalVOI=[globalVOI;repmat(globalVOI(end),tmpsize-nthresh,1)]; %#ok<AGROW>
            nthresh=tmpsize;
        end
        
        thresh = tmp(:, 1);
        for posc=2:3
            if (any(isnan(tmp(:,posc))))
                nans=isnan(tmp(:,posc));
                tmp(nans,posc)=0;
                fprintf('*');
            end
        end
        
        globalRI = globalRI + tmp(:,2);
        globalVOI = globalVOI + tmp(:,3);
        
        ff = find( tmp(:,2)==max(tmp(:,2)) );
        RI_best = RI_best + tmp(ff(end),2);
        ff = find( tmp(:,3)==min(tmp(:,3)) );
        VOI_best = VOI_best + tmp(ff(end),3);
    end
    fprintf('\n');
    
    globalRI = globalRI / numel(S);
    globalVOI = globalVOI / numel(S);
    RI_best = RI_best / numel(S);
    VOI_best = VOI_best / numel(S);
    [bgRI igRI]=max(globalRI);
    [bgVOI igVOI]=min(globalVOI);
    
    fname = fullfile(outDir,'eval_RI_VOI_thr.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g\n',[thresh globalRI globalVOI]');
    fclose(fid);

    fname = fullfile(outDir,'eval_RI_VOI.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g %10g %10g\n',thresh(igRI), bgRI, RI_best, thresh(igVOI),  bgVOI, VOI_best);
    fclose(fid);
end



%New region evaluationwith precision/recall
fname = fullfile(outDir, 'eval_regpr_global.txt');
% filenames: eval_regpr_global.txt, eval_regpr_average.txt
S = dir(fullfile(outDir,'*_ev6.txt'));
if ( (length(dir(fname))~=1) && (~isempty(S)) )

    % deduce nthresh from .pr files
    AA = dlmread( fullfile(outDir,S(1).name) ); % thresh cntR sumR cntP sumP
    thresh = AA(:,1);

    nthresh = numel(thresh);
    cntR_total = zeros(nthresh,1);
    sumR_total = zeros(nthresh,1);
    cntP_total = zeros(nthresh,1);
    sumP_total = zeros(nthresh,1);
    cntR_max = 0;
    sumR_max = 0;
    cntP_max = 0;
    sumP_max = 0;
    scores = zeros(length(S),5);
    %New indexes for average performance: A-ODS, A-OSS
    aods_p = zeros(nthresh,1);
    aods_r = zeros(nthresh,1);
    aoss_p = 0;
    aoss_r = 0;
    aodsosscnt=0;

    %statistics based on best P
    cntR_maxjp = 0;
    sumR_maxjp = 0;
    cntP_maxjp = 0;
    sumP_maxjp = 0;
    scoresjp = zeros(length(S),5);
    aoss_p_jp = 0;
    aoss_r_jp = 0;

    fprintf('Processing regions (RP):');
    for i = 1:length(S),

        fprintf(' %d',i);
%         iid = S(i).name(1:end-8);
%         fprintf(2,'Processing image %s (%d/%d)...\n',iid,i,length(S));

        evFile6 = fullfile(outDir,S(i).name);
        AA  = dlmread(evFile6);
        
        %check and adjust different number of coarse-to-fine levels
        %This is used for algorithm which do not let the user fix the
        %number of levels. The finest level is replicated
        AAsize=size(AA,1);
        if (AAsize<nthresh) %if not of equal size, the final line is replicated
            AA=[AA;repmat(AA(end,:),nthresh-AAsize,1)]; %#ok<AGROW>
        elseif (AAsize>nthresh)
            thresh=[thresh;repmat(thresh(end),AAsize-nthresh,1)]; %#ok<AGROW>
            %thresh=[thresh;[(thresh(end)+1):AAsize]'];
            cntR_total=[cntR_total;repmat(cntR_total(end),AAsize-nthresh,1)]; %#ok<AGROW>
            sumR_total=[sumR_total;repmat(sumR_total(end),AAsize-nthresh,1)]; %#ok<AGROW>
            cntP_total=[cntP_total;repmat(cntP_total(end),AAsize-nthresh,1)]; %#ok<AGROW>
            sumP_total=[sumP_total;repmat(sumP_total(end),AAsize-nthresh,1)]; %#ok<AGROW>
            %New indexes for average performance: A-ODS, A-OSS
            aods_p=[aods_p;repmat(aods_p(end),AAsize-nthresh,1)]; %#ok<AGROW>
            aods_r=[aods_r;repmat(aods_r(end),AAsize-nthresh,1)]; %#ok<AGROW>
            nthresh=AAsize;
        end
        
        cntR = AA(:, 2);
        sumR = AA(:, 3);
        cntP = AA(:, 4);
        sumP = AA(:, 5);

        %Precision recall and F measure for the considered segmentation
        R = cntR ./ (sumR + (sumR==0));
        P = cntP ./ (sumP + (sumP==0));
        F = fmeasure(R,P);

        [bestT,bestR,bestP,bestF] = maxF(thresh,R,P); %Best F-measure for the segmentation, and corresponding thr, p, r
        scores(i,:) = [i bestT bestR bestP bestF];

        %statistics based on best P
        [bestjpP ind] = max(P);
        bestjpT = thresh(ind(1));
        bestjpF = F(ind(1));
        bestjpR = R(ind(1));
        scoresjp(i,:) = [i bestjpT bestjpR bestjpP bestjpF];

        %Aggregate for ODS
        cntR_total = cntR_total + cntR;
        sumR_total = sumR_total + sumR;
        cntP_total = cntP_total + cntP;
        sumP_total = sumP_total + sumP;

        %Aggregate for OSS
        ff=find(F==max(F));
        cntR_max = cntR_max + cntR(ff(1));
        sumR_max = sumR_max + sumR(ff(1));
        cntP_max = cntP_max + cntP(ff(1));
        sumP_max = sumP_max + sumP(ff(1));
        
        %Aggregate for A-ODS
        aods_p = aods_p + P;
        aods_r = aods_r + R;
        
        %Aggregate for A-OSS
        aoss_p = aoss_p+bestP; %bestP and bestR are interpolated, 
        aoss_r = aoss_r+bestR; %ff index could also be used instead

        %Aggregate cnt for A-ODS, A-OSS
        aodsosscnt=aodsosscnt+1;

        %statistics based on best P
        pp=find(P==max(P));
        cntR_maxjp = cntR_maxjp + cntR(pp(1));
        sumR_maxjp = sumR_maxjp + sumR(pp(1));
        cntP_maxjp = cntP_maxjp + cntP(pp(1));
        sumP_maxjp = sumP_maxjp + sumP(pp(1));
        aoss_r_jp = aoss_r_jp + R(pp(1));
        aoss_p_jp = aoss_p_jp + P(pp(1));
    end
    fprintf('\n');
    
    %Average P and R for each thr
    avg_ods_Rth = aods_r / aodsosscnt;
    avg_ods_Pth = aods_p / aodsosscnt;
    avg_ods_Fth = fmeasure(avg_ods_Rth,avg_ods_Pth);
    [avg_ods_T,avg_ods_R,avg_ods_P,avg_ods_F] = maxF(thresh,avg_ods_Rth,avg_ods_Pth);
    
    %Average P and R for each thr, plotted
    fname = fullfile(outDir,'eval_regpr_avgthr.txt'); %eval_bdry_thr
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g\n',[thresh avg_ods_Rth avg_ods_Pth avg_ods_Fth]');
    fclose(fid);
    
    avg_oss_r = aoss_r / aodsosscnt;
    avg_oss_p = aoss_p / aodsosscnt;
    avg_oss_f = fmeasure(avg_oss_r,avg_oss_p);

    [Ru, indR] = unique(avg_ods_Rth);
    Pu = avg_ods_Pth(indR);
    Ri = 0 : 0.01 : 1;
    if numel(Ru)>1,
        P_int1 = interp1(Ru, Pu, Ri);
        P_int1(isnan(P_int1)) = 0;
        %
        P_int1(Ri<Ru(1))=Pu(1); %Set initial part of the curve to the precision value corresponding to the smallest value of recall
        %
        avg_area_PR = sum(P_int1)*0.01;

    else
        avg_area_PR = Ru * Pu; %The area of the rectangle
%         avg_area_PR = 0;
    end
    
    %Aggregated performance A-ODS and A-OSS
    fname = fullfile(outDir,'eval_regpr_avgodsoss.txt'); %eval_bdry
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g %10g %10g %10g %10g\n',avg_ods_T,avg_ods_R,avg_ods_P,avg_ods_F,avg_oss_r,avg_oss_p,avg_oss_f,avg_area_PR);
    fclose(fid);


    %Global P and R for each thr
    R = cntR_total ./ (sumR_total + (sumR_total==0));
    P = cntP_total ./ (sumP_total + (sumP_total==0));
    F = fmeasure(R,P);
    [bestT,bestR,bestP,bestF] = maxF(thresh,R,P);

    %statistics based on best P
    [bestjpP ind] = max(P);
    bestjpT = thresh(ind(1));
    bestjpF = F(ind(1));
    bestjpR = R(ind(1));
    [bestavgjpP ind] = max(avg_ods_Pth);
    bestavgjpT = thresh(ind(1));
    bestavgjpF = avg_ods_Fth(ind(1));
    bestavgjpR = avg_ods_Rth(ind(1));

    %statistics based on best P
    fname = fullfile(outDir,'eval_regpr_segmbestpscores.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10d %10g %10g %10g %10g\n',scoresjp');
    fclose(fid);

    %List of [id,bestT,bestR,bestP,bestF] for each segmentation
    %best values correspond to bestF for each segmentation
    fname = fullfile(outDir,'eval_regpr_segmbestscores.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10d %10g %10g %10g %10g\n',scores'); %[i bestT bestR bestP bestF]
    fclose(fid);
    %for each image, R, P and F are computed for all thresholds and the best
    %values are chosen according to F

    %Global P and R for each thr, plotted
    fname = fullfile(outDir,'eval_regpr_globalthr.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g\n',[thresh R P F]');
    fclose(fid);
    %R,P,F numbers (eval_regpr_globalthr.txt) for each threshold across all images:
    %global values for R and P, F computed from them

    %statistics based on best P
    R_maxjp = cntR_maxjp ./ (sumR_maxjp + (sumR_maxjp==0));
    P_maxjp = cntP_maxjp ./ (sumP_maxjp + (sumP_maxjp==0));
    F_maxjp = fmeasure(R_maxjp,P_maxjp);
    R_avgmaxjp = aoss_r_jp / aodsosscnt;
    P_avgmaxjp = aoss_p_jp / aodsosscnt;
    F_avgmaxjp = fmeasure(R_avgmaxjp,P_avgmaxjp);

    R_max = cntR_max ./ (sumR_max + (sumR_max==0));
    P_max = cntP_max ./ (sumP_max + (sumP_max==0));
    F_max = fmeasure(R_max,P_max);

    [Ru, indR] = unique(R);
    Pu = P(indR);
    Ri = 0 : 0.01 : 1;
    if numel(Ru)>1,
        P_int1 = interp1(Ru, Pu, Ri);
        P_int1(isnan(P_int1)) = 0;
        %
        P_int1(Ri<Ru(1))=Pu(1); %Set initial part of the curve to the precision value corresponding to the smallest value of recall
        %
        Area_PR = sum(P_int1)*0.01;
    else
        Area_PR = Ru * Pu; %The area of the rectangle
%         Area_PR = 0;
    end
    
    %statistics based on best average P
    fname = fullfile(outDir,'eval_regpravgodsoss_pmax.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g %10g %10g %10g %10g\n',bestavgjpT,bestavgjpR,bestavgjpP,bestavgjpF,R_avgmaxjp,P_avgmaxjp,F_avgmaxjp);
    fclose(fid);
    
    %statistics based on best global P
    fname = fullfile(outDir,'eval_regprglobodsoss_pmax.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g %10g %10g %10g %10g\n',bestjpT,bestjpR,bestjpP,bestjpF,R_maxjp,P_maxjp,F_maxjp);
    fclose(fid);

    %Aggregated performance ODS and OSS
    fname = fullfile(outDir,'eval_regpr_globossods.txt'); %eval_bdry
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g %10g %10g %10g %10g %10g\n',bestT,bestR,bestP,bestF,R_max,P_max,F_max,Area_PR);
    fclose(fid);
    %bestT,bestR,bestP,bestF numbers from best R,P,F across the thresholds:
    %cntR,P and sumR,P are summed across all images for each threshold,
    %then the best threshold is chosen according to the best F measure

    %R_max,P_max,F_max the best R and P are chosen (across the thresholds)
    %for each image and then cntR/P_max and sumR/P_max are summed across
    %all the images and the division yields the values

    %Area_PR is the area under the PR curve computed with interpolation
    %from the same R and P values used for computing the bestR/P/F
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute f-measure fromm recall and precision
function [f] = fmeasure(r,p)
f = 2*p.*r./(p+r+((p+r)==0));

% interpolate to find best F and coordinates thereof
function [bestT,bestR,bestP,bestF] = maxF(thresh,R,P)
bestT = thresh(1);
bestR = R(1);
bestP = P(1);
bestF = fmeasure(R(1),P(1));
for i = 2:numel(thresh),
  for d = linspace(0,1),
    t = thresh(i)*d + thresh(i-1)*(1-d);
    r = R(i)*d + R(i-1)*(1-d);
    p = P(i)*d + P(i-1)*(1-d);
    f = fmeasure(r,p);
    if f > bestF,
      bestT = t;
      bestR = r;
      bestP = p;
      bestF = f;
    end
  end
end




