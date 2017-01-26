function [summary,SEsummary,rel_weight,z,p,CI_lo,CI_hi,chisq,tausq,df,p_het,Isq]=GIVsummary(effects,SEs,method)
% Generic inverse-variance (GIV) method to summarize continuous statistics across studies 
% Input:
% effects ? vector of continuous single-study effect measures (means or d)
% SEs ? vector of standard errors for the effects (means,d)
% method ? 'fixed' for fixed-effects analysis or
%          'random' fir random effects analysis according to DerSimonian and Laird random-effects models
%
% Output:
% summary ? Weighted fixed/random effects summary of effects
% SEsummary ? Standard error of weighted fixed/random effects summary of effects
% rel_weight ? Weight for everey entered effect relative to total effect (fixed/random)
% z ? z-Score of summary effect (fixed/random)
% p ? probability ('statistical significance') of summary effect (fixed/random)
% CI_lo ? 95% confidence intervals lower bound (fixed/random)
% CI_hi ? 95% confidence intervals upper bound (fixed/random)
% chisq ? fixed effects measure of heterogeneity in sample
% tausq ? random effects measure of heterogeneity in sample
% df ? degrees of freedom (just number of inputs-1)
% p_het ? probability ('statistical significance') of observed heterogeneity based on chisq (same for fixed/random)
% Isq ? I-squared... "This measures the extent of inconsistency among the
% studies? results, and is interpreted as approximately the proportion of
% total variation in study estimates that is due to heterogeneity rather
% than sampling error." (see: Deeks & Higgins, p. 6)

% See:
% Statistical algorithms in Review Manager 5
% Jonathan J Deeks and Julian PT Higgins
% on behalf of the Statistical Methods Group
% of The Cochrane Collaboration
% August 2010

% Make sure that effects and SEs are entered as column vectors
if ~iscolumn(effects)
effects=effects';
end
if ~iscolumn(SEs)
SEs=SEs';
end

% Calculate fixed effects model first
% All calculations are performed column-wise

weight=1./SEs.^2; % weight derived from every SE
rel_weight=weight/nansum(weight); %normalized weight in %
df=sum(~isnan(effects))-1; %degrees of freedom,same for fixed and random
summary=nansum(effects.*weight)./nansum(weight); %Formula 7 in Deeks&Higgins
SEsummary=1./sqrt(nansum(weight)); %Formula 8 in Deeks&Higgins

% Heterogeneity statistic (same for random & fixed, but tau is reported additionally for random)
chisq=nansum(weight.*(bsxfun(@minus,effects,summary)).^2);
tausq=NaN(1,1); % Only needed for random effects
p_het=1-chi2cdf(chisq,df);
Isq=max([100*((chisq-df)/chisq),0]);

if strcmp(method,'fixed')
    %Everything comupted up to now was under the assumption of fixed effects
 disp('GIVsummary results reflect fixed effects analysis')

elseif strcmp(method,'random')
% FIXED EFFECTS RESULTS FOR heterogeneity, rel_weight, summary and SEsummary ARE OVERWRITTEN
% Random effects analysis requires heterogeneity estimate first
   tausq=max([(chisq-df)/(nansum(weight)-(nansum(weight.^2)/nansum(weight))),0]); %Page 8 in in Deeks&Higgins
   weightRNDM=1./(SEs.^2+tausq);
   rel_weight=weightRNDM/nansum(weightRNDM);
   summary=nansum(effects.*weightRNDM)./nansum(weightRNDM); %Formula 13 in Deeks&Higgins
   SEsummary=1./sqrt(nansum(weightRNDM)); %Formula 14 in Deeks&Higgins
   disp('GIVsummary results reflect random effects analysis')
else
    disp('ERROR, not explicitly stated if ''fixed'' or ''random'' analysis desired. GIVsummary results reflect fixed effects analysis... ')
end

% Test for overall effect (Deeks&Higgins, page 9ff)
z=summary./SEsummary; % Standardized overall effect (z-Value)
p = normcdf(-abs(z),0,1)*2; % p of z-Value assuming a normal distribution (two-tailed!)
CI_lo=summary-SEsummary*1.96;
CI_hi=summary+SEsummary*1.96;
end