function [ bestF, bestP, bestR, bestT, F_max, P_max, R_max, Area_PR] = Collectevalaluatebdry(outDir,addstr)
% function [ bestF, bestP, bestR, bestT, F_max, P_max, R_max, Area_PR ] = Collectevalaluatebdry(outDir)
%
% calculate P, R and F-measure from individual evaluation files
%
% Pablo Arbelaez <arbelaez@eecs.berkeley.edu>
%
% modified by Fabio Galasso
% October 2012

if ( (~exist('addstr','var')) || (isempty(addstr)) )
    addstr=''; %The string is inserted in front of the output files
                %It also replaces 1 in _ev1.txt files
end

fname = fullfile(outDir, [addstr,'eval_bdry_globossods.txt']);
if (length(dir(fname))==1),
  tmp = dlmread(fname); 
  bestT = tmp(1);
  bestR = tmp(2);
  bestP = tmp(3);
  bestF = tmp(4);
  R_max = tmp(5);
  P_max = tmp(6);
  F_max = tmp(7);
  Area_PR = tmp(8);
else

    if (isempty(addstr))
        S = dir(fullfile(outDir,'*_ev1.txt'));
    else
        S = dir(fullfile(outDir,['*_ev',addstr,'.txt']));
    end
    
    if (~isempty(S))

        % deduce nthresh from .pr files
        filename = fullfile(outDir,S(1).name);
        AA = dlmread(filename); % thresh cntR sumR cntP sumP

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

        %statistics based on best R
        cntR_maxjr = 0;
        sumR_maxjr = 0;
        cntP_maxjr = 0;
        sumP_maxjr = 0;
        scoresjr = zeros(length(S),5);
        aoss_p_jr = 0;
        aoss_r_jr = 0;

        fprintf('Processing boundaries:');
        for i = 1:length(S),

            fprintf(' %d',i);
            % iid = S(i).name(1:end-8);
            % fprintf(2,'Processing image %s (%d/%d)...\n',iid,i,length(S));

            filename = fullfile(outDir,S(i).name);
            AA  = dlmread(filename);

            %check and adjust different number of coarse-to-fine levels
            %This is used for algorithm which do not let the user fix the
            %number of levels. The finest level is replicated
            AAsize=size(AA,1);
            if (AAsize<nthresh) %if not of equal size, the final line is replicated
                AA=[AA;repmat(AA(end,:),nthresh-AAsize,1)]; %#ok<AGROW>
            elseif (AAsize>nthresh)
                thresh=[thresh;repmat(thresh(end),AAsize-nthresh,1)]; %#ok<AGROW>
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

            R = cntR ./ (sumR + (sumR==0));
            P = cntP ./ (sumP + (sumP==0));
            F = fmeasure(R,P);

            [bestT,bestR,bestP,bestF] = maxF(thresh,R,P); %Best F-measure for the segmentation, and corresponding thr, p, r
            scores(i,:) = [i bestT bestR bestP bestF];

            %statistics based on best R
            [bestjrR ind] = max(R);
            bestjrT = thresh(ind(1));
            bestjrF = F(ind(1));
            bestjrP = P(ind(1));
            scoresjr(i,:) = [i bestjrT bestjrR bestjrP bestjrF];

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

            %statistics based on best R
            rr=find(R==max(R));
            cntR_maxjr = cntR_maxjr + cntR(rr(1));
            sumR_maxjr = sumR_maxjr + sumR(rr(1));
            cntP_maxjr = cntP_maxjr + cntP(rr(1));
            sumP_maxjr = sumP_maxjr + sumP(rr(1));
            aoss_r_jr = aoss_r_jr + R(rr(1));
            aoss_p_jr = aoss_p_jr + P(rr(1));
        end
        fprintf('\n');

        %Average P and R for each thr
        avg_ods_Rth = aods_r / aodsosscnt;
        avg_ods_Pth = aods_p / aodsosscnt;
        avg_ods_Fth = fmeasure(avg_ods_Rth,avg_ods_Pth);
        [avg_ods_T,avg_ods_R,avg_ods_P,avg_ods_F] = maxF(thresh,avg_ods_Rth,avg_ods_Pth);

        %Average P and R for each thr, plotted
        fname = fullfile(outDir,'eval_bdry_avgthr.txt');
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
%             avg_area_PR = 0;
        end

        %Aggregated performance A-ODS and A-OSS
        fname = fullfile(outDir,'eval_bdry_avgodsoss.txt');
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

        %statistics based on best R
        [bestjrR ind] = max(R);
        bestjrT = thresh(ind(1));
        bestjrF = F(ind(1));
        bestjrP = P(ind(1));
        [bestavgjrR ind] = max(avg_ods_Rth);
        bestavgjrT = thresh(ind(1));
        bestavgjrF = avg_ods_Fth(ind(1));
        bestavgjrP = avg_ods_Pth(ind(1));

        %statistics based on best R
        fname = fullfile(outDir,[addstr,'eval_bdry_segmbestrscores.txt']);
        fid = fopen(fname,'w');
        if fid==-1,
            error('Could not open file %s for writing.',fname);
        end
        fprintf(fid,'%10d %10g %10g %10g %10g\n',scoresjr');
        fclose(fid);

        %List of [id,bestT,bestR,bestP,bestF] for each segmentation
        %best values correspond to bestF for each segmentation
        fname = fullfile(outDir,[addstr,'eval_bdry_segmbestscores.txt']);
        fid = fopen(fname,'w');
        if fid==-1,
            error('Could not open file %s for writing.',fname);
        end
        fprintf(fid,'%10d %10g %10g %10g %10g\n',scores');
        fclose(fid);
        %for each image, R, P and F are computed for all thresholds and the best
        %values are chosen according to F

        %Global P and R for each thr, plotted
        fname = fullfile(outDir,[addstr,'eval_bdry_globalthr.txt']);
        fid = fopen(fname,'w');
        if fid==-1,
            error('Could not open file %s for writing.',fname);
        end
        fprintf(fid,'%10g %10g %10g %10g\n',[thresh R P F]');
        fclose(fid);
        %R,P,F numbers (eval_bdry_globalthr.txt) for each threshold across all images:
        %global values for R and P, F computed from them

        %statistics based on best R
        R_maxjr = cntR_maxjr ./ (sumR_maxjr + (sumR_maxjr==0));
        P_maxjr = cntP_maxjr ./ (sumP_maxjr + (sumP_maxjr==0));
        F_maxjr = fmeasure(R_maxjr,P_maxjr);
        R_avgmaxjr = aoss_r_jr / aodsosscnt;
        P_avgmaxjr = aoss_p_jr / aodsosscnt;
        F_avgmaxjr = fmeasure(R_avgmaxjr,P_avgmaxjr);

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
%             Area_PR = 0;
        end
        
        
        
        %statistics based on best average R
        fname = fullfile(outDir,'eval_bdryavgodsoss_rmax.txt');
        fid = fopen(fname,'w');
        if fid==-1,
            error('Could not open file %s for writing.',fname);
        end
        fprintf(fid,'%10g %10g %10g %10g %10g %10g %10g %10g\n',bestavgjrT,bestavgjrR,bestavgjrP,bestavgjrF,R_avgmaxjr,P_avgmaxjr,F_avgmaxjr);
        fclose(fid);

        %statistics based on best global R
        fname = fullfile(outDir,[addstr,'eval_bdryglobodsoss_rmax.txt']);
        fid = fopen(fname,'w');
        if fid==-1,
            error('Could not open file %s for writing.',fname);
        end
        fprintf(fid,'%10g %10g %10g %10g %10g %10g %10g %10g\n',bestjrT,bestjrR,bestjrP,bestjrF,R_maxjr,P_maxjr,F_maxjr);
        fclose(fid);

        %Aggregated performance ODS and OSS
        fname = fullfile(outDir,[addstr,'eval_bdry_globossods.txt']);
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

