function ri = Randindex(n)
% performance metrics following the implementation by Allen Yang:
% http://perception.csl.uiuc.edu/coding/image_segmentation/

N = sum(sum(n));
n_u=sum(n,2);
n_v=sum(n,1);
N_choose_2=N*(N-1)/2;
ri = 1 - ( sum(n_u .* n_u)/2 + sum(n_v .* n_v)/2 - sum(sum(n.*n)) )/N_choose_2;
