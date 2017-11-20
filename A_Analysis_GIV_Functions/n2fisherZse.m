function SE_Z=n2fisherZse(n)
% Converts the n of pairs in a correlation to the corresponding SE
% of Fisher's z.
% Returns NaN instead of Inf for small sample sizes.
% The Standard Error (SE) of Fisher's z only depends on n (e.g. see: E.g.
% https://en.wikipedia.org/wiki/Fisher_transformation)
SE_Z=sqrt(1./(n-3));
SE_Z(n<=3)=NaN;
end