function [encountered,pos]=Videoinstruct(encimagevideo,encisvideo,videoimagename)

% encimagevideo{numel(encimagevideo)}.videoimagename=videoimagename;
% encimagevideo{numel(encimagevideo)}.nframes=nframes;
% encimagevideo{numel(encimagevideo)}.fnames=fnames;
% encimagevideo{numel(encimagevideo)}.videoimagenamewithunderscores=videoimagenamewithunderscores;
% encisvideo=false(0);

encountered=false;
pos=0;
for i=1:numel(encisvideo)
    
    if ( encisvideo(i) )
        
        if ( strcmp(encimagevideo{i}.videoimagename,videoimagename) )  
            encountered=true;
            pos=i;
            break;
        end
        
    end
end

