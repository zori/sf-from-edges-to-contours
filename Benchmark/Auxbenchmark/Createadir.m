function dirname=Createadir(dirname,printtext)

if ( (~exist('printtext','var')) || (isempty(printtext)) )
    printtext=true;
end

if (~exist(dirname,'dir'))
    mkdir(dirname);
    if (printtext)
        fprintf('Directory %s created\n',dirname);
    end
else
    if (printtext)
        fprintf('Directory %s existing\n',dirname);
    end
end
