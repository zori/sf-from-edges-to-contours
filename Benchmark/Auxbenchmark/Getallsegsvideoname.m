function [allsegsvideoimagename,allsegsvideoimagedir]=Getallsegsvideoname(videoimagename)
%The file allsegs has two naming conventions, depending on whether the video
%is contained within a directory of its own or whether all files from all
%videos are within the same directory (in which case their name identifies
%the video)
%
% The output is used as follows:
% allsegfile=fullfile(inDir, ['allsegs',allsegsvideoimagename,'.mat']);
%
% Fabio Galasso
% February 2014


fileseppos=strfind(videoimagename,filesep);

if (isempty(fileseppos)) % Name convention without folders
    allsegsvideoimagename=videoimagename;
    allsegsvideoimagedir='';
else
    allsegsvideoimagedir=videoimagename(1: (fileseppos(end)-1) );
    allsegsvideoimagename=strrep(allsegsvideoimagedir, filesep, '_');
end

