function [fixed,random,heterogeneity]=GIV_weight(effects,SEs)
% Actual GIV weighting. One formula applies for all outcomes... (means,d,g,Fisher's Z transformed r)
% See:
% Statistical algorithms in Review Manager 5
% Jonathan J Deeks and Julian PT Higgins
% on behalf of the Statistical Methods Group
% of The Cochrane Collaboration
% August 2010


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