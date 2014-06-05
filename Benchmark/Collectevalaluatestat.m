function Collectevalaluatestat(outDir)
% Fabio Galasso
% April 2013



%Length statistics and number of clusters
fname = fullfile(outDir, 'eval_nclustersstats_thr.txt');
% filenames: 'eval_nclustersstats_thr.txt', 'eval_lengthglobstats_thr.txt', 'eval_lengthavgstats_thr.txt'
S = dir(fullfile(outDir,'*_ev8.txt'));
if ( (length(dir(fname))~=1) && (~isempty(S)) )

    % deduce nthresh from files
    AA = dlmread( fullfile(outDir,S(1).name) ); % thresh nclusters sumlength sqrsumlength
    thresh = AA(:,1);

    nthresh = numel(thresh);
    
    nvideos_tot = 0; %Counter of processed videos, this coincides with length(S)
    
    %Global length statistics
    nclusters_tot = zeros(nthresh,1);
    sumlength_tot = zeros(nthresh,1);
    sqrsumlength_tot = zeros(nthresh,1);
    
    %Average length statistics
%     nclusters_avg_tot = zeros(nthresh,1); %same as the total
    meanlengths_avg_tot = zeros(nthresh,1);
    stdlengths_avg_tot = zeros(nthresh,1);
    
    

    fprintf('Processing length statistics:');
    for i = 1:length(S),

        fprintf(' %d',i);
%         iid = S(i).name(1:end-8);
%         fprintf(2,'Processing image %s (%d/%d)...\n',iid,i,length(S));

        evFile8 = fullfile(outDir,S(i).name);
        AA  = dlmread(evFile8);
        
        %check and adjust different number of coarse-to-fine levels
        %This is used for algorithm which do not let the user fix the
        %number of levels. The finest level is replicated
        AAsize=size(AA,1);
        if (AAsize<nthresh) %if not of equal size, the final line is replicated
            AA=[AA;repmat(AA(end,:),nthresh-AAsize,1)]; %#ok<AGROW>
        elseif (AAsize>nthresh)
            thresh=[thresh;repmat(thresh(end),AAsize-nthresh,1)]; %#ok<AGROW>
            %thresh=[thresh;[(thresh(end)+1):AAsize]'];
            %Global statistics
            nclusters_tot=[nclusters_tot;repmat(nclusters_tot(end),AAsize-nthresh,1)]; %#ok<AGROW>
            sumlength_tot=[sumlength_tot;repmat(sumlength_tot(end),AAsize-nthresh,1)]; %#ok<AGROW>
            sqrsumlength_tot=[sqrsumlength_tot;repmat(sqrsumlength_tot(end),AAsize-nthresh,1)]; %#ok<AGROW>
            %Average statistics
            meanlengths_avg_tot=[meanlengths_avg_tot;repmat(meanlengths_avg_tot(end),AAsize-nthresh,1)]; %#ok<AGROW>
            stdlengths_avg_tot=[stdlengths_avg_tot;repmat(stdlengths_avg_tot(end),AAsize-nthresh,1)]; %#ok<AGROW>
            nthresh=AAsize;
        end
        
        nclusters = AA(:, 2);
        sumlength = AA(:, 3);
        sqrsumlength = AA(:, 4);

        %Computation of mean and std for average statistics
        meanlengths=zeros(nthresh,1);
        meanlengths(nclusters>0) = sumlength(nclusters>0) ./ nclusters(nclusters>0);

        stdlengths=zeros(nthresh,1);
        stdlengths(nclusters>0)= sqrt( ( sqrsumlength(nclusters>0) ./ nclusters(nclusters>0) ) - (meanlengths(nclusters>0).^2) );
        
        %Aggregate for average statistics
        meanlengths_avg_tot = meanlengths_avg_tot + meanlengths;
        stdlengths_avg_tot = stdlengths_avg_tot + stdlengths;
        
        %Aggregate for global statistics
        nclusters_tot = nclusters_tot + nclusters;
        sumlength_tot = sumlength_tot + sumlength;
        sqrsumlength_tot = sqrsumlength_tot + sqrsumlength;

        nvideos_tot=nvideos_tot+1;
    end
    fprintf('\n');
    
    %Average number of clusters
    nclusters_avg = nclusters_tot ./ repmat(nvideos_tot,size(meanlengths_avg_tot));
    
    %Average length statistics
    meanlengths_avg=meanlengths_avg_tot./repmat(nvideos_tot,size(meanlengths_avg_tot));
    stdlengths_avg=stdlengths_avg_tot./repmat(nvideos_tot,size(stdlengths_avg_tot));
    
    %Global length statistics
    
    meanlengths_glob=zeros(nthresh,1);
    meanlengths_glob(nclusters_tot>0) = sumlength_tot(nclusters_tot>0) ./ nclusters_tot(nclusters_tot>0);

    stdlengths_glob=zeros(nthresh,1);
    stdlengths_glob(nclusters_tot>0)= sqrt( ( sqrsumlength_tot(nclusters_tot>0) ./ nclusters_tot(nclusters_tot>0) ) - (meanlengths_glob(nclusters_tot>0).^2) );

    
    
    %Number of cluster statistics
    fname = fullfile(outDir,'eval_nclustersstats_thr.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g\n',[thresh nclusters_avg]');
    fclose(fid);
    
    %Global length statistics
    fname = fullfile(outDir,'eval_lengthglobstats_thr.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g\n',[thresh meanlengths_glob stdlengths_glob]');
    fclose(fid);
    
    %Average length statistics
    fname = fullfile(outDir,'eval_lengthavgstats_thr.txt');
    fid = fopen(fname,'w');
    if fid==-1,
        error('Could not open file %s for writing.',fname);
    end
    fprintf(fid,'%10g %10g %10g\n',[thresh meanlengths_avg stdlengths_avg]');
    fclose(fid);
    
end
