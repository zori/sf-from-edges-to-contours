function filelist=Listacrossfolders(adirectory,searchext,uplevel,stringtoenclose)
%The function returns a list of files with extension searchext across folders and
%subfolders up to subfolder level uplevel
%The output file list contains filenames and path folders
%uplevel = 1 indicates files in the current directory and those in the folders (not in subfolders)
%uplevel = 0 indicates files in the current directory
%uplevel = Inf indicates files in the current directory and those in all subfolders
% filelist=Listacrossfolders(adirectory,'jpg',Inf)
% filelist=Listacrossfolders(adirectory,'jpg',1)
% adirectory=fullfile(basedir,iidss(3).name);
% adirectory=imgDir;
% searchext='jpg';



if ( (~exist('stringtoenclose','var')) || (isempty(stringtoenclose)) )
    stringtoenclose='';
end



iidss = dir(fullfile(adirectory)); %Get directory listing
iidss=Removeadots(iidss); %Remove "." and ".." folders

filelist=struct();
count=0;

for i=1:numel(iidss)
    
    if (iidss(i).isdir) %Iterate in case of folders (if uplevel has not been reached yet)
        
        if (uplevel>0)
            adir=fullfile(adirectory,iidss(i).name);
            newtoenclose=[stringtoenclose,iidss(i).name,filesep];
            %adirectory=adir;
            newfilelist=Listacrossfolders(adir,searchext,uplevel-1,newtoenclose);
            
            for j=1:numel(newfilelist)
                count=count+1;
                if (count==1)
                    filelist=newfilelist(j);
                else
                    filelist(count,1)=newfilelist(j);
                end
            end
        end
        
    else %Add images if these are not directories
        
        afile=fullfile(adirectory,iidss(i).name);
        [thepath,thename,theext]=fileparts(afile); %#ok<ASGLU>
        
        if (strcmp(theext,['.',searchext]))
            count=count+1;
            if (count==1)
                filelist=iidss(i);
            else
                filelist(count,1)=iidss(i);
            end
            filelist(count,1).name=[stringtoenclose,filelist(count,1).name];
        else
            continue;
        end
        
    end
end

if (count==0)
    filelist=[];
end


function File_list() %#ok<DEFNU>

% filelist=iids;

for i=1:numel(iids)
    fprintf('%s\n',iids(i).name);
end

for i=1:numel(filelist)
    fprintf('%s\n',filelist(i).name);
end
