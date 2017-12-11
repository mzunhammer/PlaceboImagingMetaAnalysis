function [fixed,random,heterogeneity]=GIV_weight_fishersZ2r(fixed,random,heterogeneity)
 heterogeneity.tausq=fishersZ2r(sqrt(heterogeneity.tausq)).^2; % The measure tau is the SD of between-subject differences and is in units of the outcome... has to be transformed, as well! Before transform, root has to be taken, after it has to be squared again!
 fixed.summary=fishersZ2r(fixed.summary);
 fixed.SEsummary=fishersZ2r(fixed.SEsummary);
 fixed.CI_lo=fishersZ2r(fixed.CI_lo);
 fixed.CI_hi=fishersZ2r(fixed.CI_hi);
 random.summary=fishersZ2r(random.summary);
 random.SEsummary=fishersZ2r(random.SEsummary);
 random.CI_lo=fishersZ2r(random.CI_lo);
 random.CI_hi=fishersZ2r(random.CI_hi);
end