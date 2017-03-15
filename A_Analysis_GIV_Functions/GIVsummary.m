function [summary]=GIVsummary(stats)
% Generic inverse-variance (GIV) method to summarize continuous statistics across studies 
% Input:
% stats objects from withinMetastats or betweenMetastats with N studies.

% Output:
% Adds "summary" field to stats objects with fixed and random summaries for
% unstandardized (raw) means
% Cohen's d
% Hedges' g
% r

% Further adds "weight_d","weight_g" and "weight_r" fields to stats object
% for reviewing the weights used by the GIV method.

% Random/Fixed Summary statistics include:

% summary ? Weighted effects summary of effects
% SEsummary ? Standard error of weighted effects summary
% z - z-score of summary effect
% p - probability ('statistical significance') of summary effect
% CI_lo - 95% confidence intervals lower bound
% CI_hi - 95% confidence intervals upper bound
% chisq - fixed effects measure of heterogeneity in sample
% tausq - random effects measure of heterogeneity in sample
% df - degrees of freedom (just number of input studies-1)
% p_het - probability ('statistical significance') of observed heterogeneity based on chisq (same for fixed/random)
% Isq - I-squared... "This measures the extent of inconsistency among the
% studies, and is interpreted as approximately the proportion of
% total variation in study estimates that is due to heterogeneity rather
% than sampling error." (see: Deeks & Higgins, p. 6)

% All calculations are performed for all columns in stats object.

% See:
% Statistical algorithms in Review Manager 5
% Jonathan J Deeks and Julian PT Higgins
% on behalf of the Statistical Methods Group
% of The Cochrane Collaboration
% August 2010

%Globals variables (true for all statistics computed)

%means
[summary.mu.fixed,...
 summary.mu.random,...
 summary.mu.heterogeneity]=GIV_weight(vertcat(stats.mu),vertcat(stats.se_mu));
%d
[summary.d.fixed,...
 summary.d.random,...
 summary.d.heterogeneity]=GIV_weight(vertcat(stats.d),vertcat(stats.se_d));
%g
[summary.g.fixed,...
 summary.g.random,...
 summary.g.heterogeneity]=GIV_weight(vertcat(stats.g),vertcat(stats.se_g));
%r
% For correlations all r-values have to be transformed to Fisher's Z before summary and back to r after.
[summary.r.fixed,...
 summary.r.random,...
 summary.r.heterogeneity]=GIV_weight(r2fishersZ(vertcat(stats.r)),sqrt(1./(vertcat(stats.n)-3))); %For Fisher's Z the SE of correlations only depends on n sqrt(1./(n-3))

% Back-transform from fishersZ to r
 summary.r.fixed.summary=fishersZ2r(summary.r.fixed.summary);
 summary.r.fixed.SEsummary=fishersZ2r(summary.r.fixed.SEsummary);
 summary.r.fixed.CI_lo=fishersZ2r(summary.r.fixed.CI_lo);
 summary.r.fixed.CI_hi=fishersZ2r(summary.r.fixed.CI_hi);
 summary.r.random.summary=fishersZ2r(summary.r.random.summary);
 summary.r.random.SEsummary=fishersZ2r(summary.r.random.SEsummary);
 summary.r.random.CI_lo=fishersZ2r(summary.r.random.CI_lo);
 summary.r.random.CI_hi=fishersZ2r(summary.r.random.CI_hi);
 
% Actual GIV function, used since same formula applies for all outcomes... (means,d,g,r)
function [fixed,random,heterogeneity]=GIV_weight(effects,SEs) 
   % Fixed effects statistics are calculated first
   fixed.weight=1./SEs.^2; % weight derived from every SE
   fixed.df=sum(~isnan(effects))-1; %degrees of freedom
   fixed.rel_weight=fixed.weight/nansum(fixed.weight); %normalized weight in %
   fixed.summary=nansum(effects.*fixed.weight)./nansum(fixed.weight); %Formula 7 in Deeks&Higgins
   fixed.SEsummary=1./sqrt(nansum(fixed.weight)); %Formula 8 in Deeks&Higgins
   % Heterogeneity statistic (same for random & fixed, tausq is required as an addition for random)
   heterogeneity.chisq=nansum(fixed.weight.*(bsxfun(@minus,effects,fixed.summary)).^2);
   heterogeneity.p_het=1-chi2cdf(heterogeneity.chisq,fixed.df);
   heterogeneity.Isq=max([100*((heterogeneity.chisq-fixed.df)/heterogeneity.chisq),0]);
   % Test for overall effect (Deeks&Higgins, page 9ff)
   fixed.z=fixed.summary./fixed.SEsummary; % Standardized overall effect (z-Value)
   % Normal t-value (based on normal distribution, uncorrected for multiple comparisons)
   fixed.p = normcdf(-abs(fixed.z),0,1)*2; % p of z-Value assuming a normal distribution (two-tailed!)
   fixed.CI_lo=fixed.summary-fixed.SEsummary*1.96;
   fixed.CI_hi=fixed.summary+fixed.SEsummary*1.96;
   
   % Random effects statistics differ in weight, rel_weight, summary and SEsummary, and heterogeneity
   heterogeneity.tausq=max([(heterogeneity.chisq-fixed.df)/(nansum(fixed.weight)-(nansum(fixed.weight.^2)/nansum(fixed.weight))),0]); %Page 8 in in Deeks&Higgins
   random.df=fixed.df;
   random.weight=1./(SEs.^2+heterogeneity.tausq);
   random.rel_weight=random.weight/nansum(random.weight);
   random.summary=nansum(effects.*random.weight)./nansum(random.weight); %Formula 13 in Deeks&Higgins
   random.SEsummary=1./sqrt(nansum(random.weight)); %Formula 14 in Deeks&Higgins
   random.z=random.summary./random.SEsummary; % Standardized overall effect (z-Value)
   random.p = normcdf(-abs(random.z),0,1)*2; % p of z-Value assuming a normal distribution (two-tailed!)
   random.CI_lo=random.summary-random.SEsummary*1.96;
   random.CI_hi=random.summary+random.SEsummary*1.96;
end
end