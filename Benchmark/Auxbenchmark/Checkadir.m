function [dirname,isvalid]=Checkadir(dirname)

isvalid=true;
if (~exist(dirname,'dir'))
    fprintf('Directory %s does not exist\n',dirname);
    isvalid=false;
end
