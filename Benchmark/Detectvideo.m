function [videodetected,videoname,fnames,nframes,fnumber]=Detectvideo(iids,i,providedvideoname)
%If a video name is provided, then the search will be done over iids
%ignoring i, else the video name will be extracted from iids at position i

videodetected=false; videoname=[]; fnames=[]; nframes=[]; fnumber=[];



if ( (exist('providedvideoname','var')) && (~isempty(providedvideoname)) && (ischar(providedvideoname)) )
    
    videoname=providedvideoname;
    nonnumberpos=numel(videoname);
    
else

    % basename= 'hey223123'
    basename=iids(i).name(1:end-4);

    nonnumberpos=Getnamepos(basename);
    if (isempty(nonnumberpos))
        % Filenames containing only numbers return [] and are not considered for videos
        return;
    end

    videoname=iids(i).name(1:nonnumberpos);

end



count=0;
fnames=cell(0);
for k=1:numel(iids)
    
    if ( (numel(iids(k).name)>=nonnumberpos) && (strcmp(videoname,iids(k).name(1:nonnumberpos))) )
        
        newbasename=iids(k).name(1:end-4);
        
        %Additional check to exclude names with the same initial part
        thenewnonnumberpos=Getnamepos(newbasename); %check with isempty is not needed as the initial part is already the same as basename
        if ( (~isempty(thenewnonnumberpos)) && (thenewnonnumberpos==nonnumberpos) )
            
            fnames{numel(fnames)+1}=newbasename;
            count=count+1;
            
        end
        
    end
end

if (count>1)
    videodetected=true;
    nframes=count;
end


if (count>1)
    fnumber=zeros(1,count);
    for k=1:numel(fnames)
        thenewnonnumberpos=Getnamepos(fnames{k});
        fnumber(k) = str2double(  fnames{k}( (thenewnonnumberpos+1) : end )  );
    end
end
