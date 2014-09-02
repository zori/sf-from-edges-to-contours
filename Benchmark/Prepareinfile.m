function inFile=Prepareinfile(videodetected,videoimagename,inDir,inds)

if ( (~exist('inds','var')) || (isempty(inds)) )
    inds=Listacrossfolders(inDir,'mat',Inf); %List .mat files in Ucm2
end

if (videodetected)
    [matvideodetected,matvideoname,matfnames,matnframes,matfnumber]=Detectvideo(inds,[],videoimagename); %#ok<ASGLU>
    if (~matvideodetected)
        error('\nVideo detected for images but not for Ucm2 mat files\n\n');
    end

    inFile=cell(1,matnframes); %inFile and gtFile are cell arrays in the case of videos
    for k=1:matnframes
        inFile{k} = fullfile(inDir, strcat(matfnames{k}, 'segs.mat')); %For backward compatibility the file segs is checked first
        if (exist(inFile{k},'file')==0)
            inFile{k} = fullfile(inDir, strcat(matfnames{k}, '.mat'));
        end
    end
    %Order the files, important for the computation of length statistics
    [ordfnumbers,ordindex]=sort(matfnumber,'ascend'); %#ok<ASGLU>
    inFile(1:end)=inFile(ordindex);

    %Compose allsegs name
    allsegsvideoimagename=Getallsegsvideoname(videoimagename);
    allsegfile=fullfile(inDir, ['allsegs',allsegsvideoimagename,'.mat']); % allsegfile=fullfile(inDir, ['allsegs',videoimagename,'.mat']);

    %Check existance of allsegs<sequence>.mat, replaced to inFile instead
    if (exist(allsegfile,'file')~=0)
        inFile=allsegfile;
    end
else
    inFile = fullfile(inDir, strcat(videoimagename, 'segs.mat')); %For backward compatibility the file segs is checked first
    if (exist(inFile,'file')==0)
        inFile = fullfile(inDir, strcat(videoimagename, '.mat'));
    end
end
