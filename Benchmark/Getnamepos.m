function nonnumberpos=Getnamepos(basename)
% Filenames containing only numbers return []


for nonnumberpos=numel(basename):-1:1
    
    x = str2double(basename(nonnumberpos));
    if ( (isnan(x)) || strcmp(basename(nonnumberpos),'e') || strcmp(basename(nonnumberpos),'i') )
        break;
    end
end

if ( (~isnan(x)) && (~strcmp(basename(nonnumberpos),'e')) && (~strcmp(basename(nonnumberpos),'i')) && (nonnumberpos==1) )
    nonnumberpos=[];
end
