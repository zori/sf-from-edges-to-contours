function vi = Variationofinformation(n)
% performance metrics following the implementation by Allen Yang:
% http://perception.csl.uiuc.edu/coding/image_segmentation/

N = sum(sum(n));
joint = n / N; % the joint pmf of the two labels
marginal_2 = sum(joint,1);  % row vector
marginal_1 = sum(joint,2);  % column vector
H1 = - sum( marginal_1 .* log2(marginal_1 + (marginal_1 == 0) ) ); % entropy of the first label
H2 = - sum( marginal_2 .* log2(marginal_2 + (marginal_2 == 0) ) ); % entropy of the second label
MI = sum(sum( joint .* log2_quotient( joint, marginal_1*marginal_2 )  )); % mutual information
vi = H1 + H2 - 2 * MI; 

function lq = log2_quotient( A, B )
lq = log2( (A + ((A==0).*B) + (B==0)) ./ (B + (B==0)) );
