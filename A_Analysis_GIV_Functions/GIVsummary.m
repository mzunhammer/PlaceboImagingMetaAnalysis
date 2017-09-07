function [summary]=GIVsummary(stats, outputs)
% Generic inverse-variance (GIV) method to summarize continuous statistics across studies 
% Input:
% stats: objects from withinMetastats or betweenMetastats with N studies.
% outputs: OPTIONAL! will default to: outputs={'mu','d','g','r'}
%          if fewer arguments are desired (e.g. to speed up computation and
%          limit size of results for whole-brain imaging analysis), those
%          can be specified explicitly (e.g. as {'g'})

% Output:
% Per default the "summary" output object will contain fixed and random summaries for
% 'mu': unstandardized (raw) means
% 'd': Cohen's d
% 'g': Hedges' g
% 'r': Correlation between repeated measures (only within-metastats)
% 'r': Correlation between repeated measures (only within-metastats)
% 'r_external': Correlation of original data with external data (used to
% correlate voxel activation changes with behavioral changes)

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

if ~exist('outputs')
    outputs={'mu','d','g','r'};
end

%Global variables (true for all statistics computed)

%means
if any(strcmp(outputs,'mu'))
[summary.mu.fixed,...
 summary.mu.random,...
 summary.mu.heterogeneity]=GIV_weight(vertcat(stats.mu),vertcat(stats.se_mu));
 summary.mu.n=nansum(vertcat(stats(:).n));
end
%d
if any(strcmp(outputs,'d'))
[summary.d.fixed,...
 summary.d.random,...
 summary.d.heterogeneity]=GIV_weight(vertcat(stats.d),vertcat(stats.se_d));
 summary.d.n=nansum(vertcat(stats(:).n));
end
%g
if any(strcmp(outputs,'g'))
[summary.g.fixed,...
 summary.g.random,...
 summary.g.heterogeneity]=GIV_weight(vertcat(stats.g),vertcat(stats.se_g));
 summary.g.n=nansum(vertcat(stats(:).n));
end
%r
% For correlations all r-values have to be transformed to Fisher's Z before summary and back to r after.
if any(strcmp(outputs,'r'))
[summary.r.fixed,...
 summary.r.random,...
 summary.r.heterogeneity]=GIV_weight(r2fishersZ(vertcat(stats.r)),n2fisherZse(vertcat(stats.n))); %For Fisher's Z the SE of correlations only depends on n sqrt(1./(n-3))
 summary.r.n=nansum(vertcat(stats(:).n));

% Back-transform from fishersZ to r
 summary.r.heterogeneity.tausq=fishersZ2r(sqrt(summary.r.heterogeneity.tausq)).^2; % The measure tau is the SD of between-subject differences and is in units of the outcome... has to be transformed, as well!
 summary.r.fixed.summary=fishersZ2r(summary.r.fixed.summary);
 summary.r.fixed.SEsummary=fishersZ2r(summary.r.fixed.SEsummary);
 summary.r.fixed.CI_lo=fishersZ2r(summary.r.fixed.CI_lo);
 summary.r.fixed.CI_hi=fishersZ2r(summary.r.fixed.CI_hi);
 summary.r.random.summary=fishersZ2r(summary.r.random.summary);
 summary.r.random.SEsummary=fishersZ2r(summary.r.random.SEsummary);
 summary.r.random.CI_lo=fishersZ2r(summary.r.random.CI_lo);
 summary.r.random.CI_hi=fishersZ2r(summary.r.random.CI_hi);

end

%r external
% Same as above: all r-values have to be transformed to Fisher's Z before summary and back to r after.
if any(strcmp(outputs,'r_external'))
% Empty fields have to be filled with nans

[summary.r_external.fixed,...
 summary.r_external.random,...
 summary.r_external.heterogeneity]=GIV_weight(r2fishersZ(vertcat(stats.r_external)),n2fisherZse(vertcat(stats.n_r_external))); %For Fisher's Z the SE of correlations only depends on n. sqrt(1./(n-3))
 summary.r_external.n=nansum(vertcat(stats(:).n_r_external)); % N where both observations are available!

% Back-transform from fishersZ to r
 summary.r_external.heterogeneity.tausq=fishersZ2r(sqrt(summary.r_external.heterogeneity.tausq)).^2; % tau is the SD of between-subject differences and is in units of the outcome... has to be transformed, as well!
 summary.r_external.fixed.summary=fishersZ2r(summary.r_external.fixed.summary);
 summary.r_external.fixed.SEsummary=fishersZ2r(summary.r_external.fixed.SEsummary);
 summary.r_external.fixed.CI_lo=fishersZ2r(summary.r_external.fixed.CI_lo);
 summary.r_external.fixed.CI_hi=fishersZ2r(summary.r_external.fixed.CI_hi);
 summary.r_external.random.summary=fishersZ2r(summary.r_external.random.summary);
 summary.r_external.random.SEsummary=fishersZ2r(summary.r_external.random.SEsummary);
 summary.r_external.random.CI_lo=fishersZ2r(summary.r_external.random.CI_lo);
 summary.r_external.random.CI_hi=fishersZ2r(summary.r_external.random.CI_hi);
end

 % For ICC all r-values have to be transformed to Fisher's Z before summary and back to r after.
if any(strcmp(outputs,'ICC'))
    if ~isempty([stats.ICC])
        [summary.ICC.fixed,...
         summary.ICC.random,...
         summary.ICC.heterogeneity]=GIV_weight(r2fishersZ(vertcat(stats.ICC)),n2fisherZse(vertcat(stats.n))); %For Fisher's Z the SE of correlations only depends on n sqrt(1./(n-3))

        % Back-transform from fishersZ to r
         summary.ICC.heterogeneity.tausq=fishersZ2r(sqrt(summary.ICC.heterogeneity.tausq)).^2; % tau is the SD of between-subject differences and is in units of the outcome... has to be transformed, as well!
         summary.ICC.fixed.summary=fishersZ2r(summary.ICC.fixed.summary);
         summary.ICC.fixed.SEsummary=fishersZ2r(summary.ICC.fixed.SEsummary);
         summary.ICC.fixed.CI_lo=fishersZ2r(summary.ICC.fixed.CI_lo);
         summary.ICC.fixed.CI_hi=fishersZ2r(summary.ICC.fixed.CI_hi);
         summary.ICC.random.summary=fishersZ2r(summary.ICC.random.summary);
         summary.ICC.random.SEsummary=fishersZ2r(summary.ICC.random.SEsummary);
         summary.ICC.random.CI_lo=fishersZ2r(summary.ICC.random.CI_lo);
         summary.ICC.random.CI_hi=fishersZ2r(summary.ICC.random.CI_hi);
    end 
end
% Actual GIV function, used since same formula applies for all outcomes... (means,d,g,r)
function [fixed,random,heterogeneity]=GIV_weight(effects,SEs)
   %Exclude invalid values...
   effects(isinf(effects))=NaN; % exclude studies with infinite values (can occur in fisher's z transformation of perfect correlations (r=1 or r=-1) >> e.g. due to a lack of variance
   SEs(isinf(effects))=NaN;         % exclude studies with 0 error (due to lack of variance), otherwise we will get inf values
   effects(SEs==0)=NaN;         % exclude studies with 0 error (due to lack of variance), otherwise we will get inf values
   SEs(SEs==0)=NaN;         % exclude studies with 0 error (due to lack of variance), otherwise we will get inf values

   z_CI=abs(icdf('normal',0.025,0,1));% z-Value for confidence intervals
   % Fixed effects statistics are calculated first
   fixed.weight=1./SEs.^2; % weight derived from every SE
   fixed.df=sum(~isnan(effects),1)-1; %degrees of freedom
   total_weight=nansum(fixed.weight);
   fixed.rel_weight=fixed.weight./total_weight; %normalized weight in %
   fixed.summary=nansum(effects.*fixed.weight)./total_weight; %Formula 7 in Deeks&Higgins
   fixed.SEsummary=1./sqrt(total_weight); %Formula 8 in Deeks&Higgins
   % Heterogeneity statistic Q (same for random & fixed, tausq is required as an addition for random)
   heterogeneity.chisq=nansum(fixed.weight.*(bsxfun(@minus,effects,fixed.summary)).^2); % aka Q
   heterogeneity.p_het=1-chi2cdf(heterogeneity.chisq,fixed.df);
   heterogeneity.Isq=max([100.*((heterogeneity.chisq-fixed.df)./heterogeneity.chisq)
                          zeros(size(heterogeneity.chisq))],[],1);
   % Test for overall effect (Deeks&Higgins, page 9ff)
   fixed.z=fixed.summary./fixed.SEsummary; % Standardized overall effect (z-Value)
   % Normal t-value (based on normal distribution, uncorrected for multiple comparisons)
   fixed.p = normcdf(-abs(fixed.z),0,1).*2; % p of z-Value assuming a normal distribution (two-tailed!)
   fixed.CI_lo=fixed.summary-fixed.SEsummary.*z_CI;
   fixed.CI_hi=fixed.summary+fixed.SEsummary.*z_CI;
   
   % Random effects statistics differ in weight, rel_weight, summary and SEsummary, and heterogeneity
   heterogeneity.tausq=max([(heterogeneity.chisq-fixed.df)./(total_weight-(nansum(fixed.weight.^2)./total_weight)),
                            zeros(size(heterogeneity.chisq))],... %Page 8, first formula in in Deeks&Higgins
                            [],1); % makes sure that max of tau or 0 is taken across first dimension
   random.df=fixed.df;
   random.weight=1./(SEs.^2+heterogeneity.tausq);
   random.rel_weight=random.weight./nansum(random.weight);
   random.summary=nansum(effects.*random.weight)./nansum(random.weight); %Formula 13 in Deeks&Higgins
   random.SEsummary=1./sqrt(nansum(random.weight)); %Formula 14 in Deeks&Higgins
   random.z=random.summary./random.SEsummary; % Standardized overall effect (z-Value)
   random.p = normcdf(-abs(random.z),0,1).*2; % p of z-Value assuming a normal distribution (two-tailed!)
   random.CI_lo=random.summary-random.SEsummary.*z_CI;
   random.CI_hi=random.summary+random.SEsummary.*z_CI;
end
end