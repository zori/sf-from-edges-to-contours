% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function [I, gt] = make_example(m)
I=repmat(m,1,1,3);
gt=watershed(m,4);
gt(gt==0)=1;
gt={gt};
end
