function [encimagevideo,encisvideo]=Collectimagevideowithnames(iids,considervideos)



encimagevideo=cell(0);
encisvideo=false(0); %encisvideo=[encisvideo,false]
count=0;
for i = 1:numel(iids)
    
    if (considervideos)
        [videodetected,videoimagename,fnames,nframes]=Detectvideo(iids,i); % disp(fnames(1))
        videoimagenamewithunderscores=strrep(videoimagename, filesep, '_');
    else
        videodetected=false;
    end
    
    
    
    %Avoid considering videos twice
    if (videodetected)
        isvideoprocessed=Videoinstruct(encimagevideo,encisvideo,videoimagename);
        if (isvideoprocessed) % The video has already been processed
            continue;
        end
    end
    
    
    
    %Adopt format of images to videos
    if (~videodetected)
        videoimagename=iids(i).name(1:end-4); %Remove extension
        videoimagenamewithunderscores=strrep(videoimagename, filesep, '_');
        nframes=[]; %placeholder
        fnames=[]; %placeholder
    end
    
    
    
    %Add new item
    count=count+1;
    encisvideo(count)=videodetected;
    encimagevideo{count}=struct;
    encimagevideo{count}.videoimagename=videoimagename;
    encimagevideo{count}.nframes=nframes;
    encimagevideo{count}.fnames=fnames;
    encimagevideo{count}.videoimagenamewithunderscores=videoimagenamewithunderscores;
end
