function Z=r2fishersZ(r)
% Function to transform Pearson's r to Fisher's Z (required for meta-analysis of associations)
Z=0.5.*log((1+r)./(1-r));
end