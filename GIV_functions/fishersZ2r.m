function r=fishersZ2r(Z)
% Function to transform Fisher's Z to Pearson's (required for displaying meta-analysis of associations)
r=(exp(2.*Z)-1)./(exp(2.*Z)+1);
end