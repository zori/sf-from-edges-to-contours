function iids=Removeadots(iids)

for i=numel(iids):-1:1
    
    imageFile=fullfile('',iids(i).name);
    [fpathstr, fname] = fileparts(imageFile); %, fext
    
    if ( isempty(fname) || strcmp(fname,'.') || strcmp(fname,'..') )
        iids(i)=[];
    end
    
end
