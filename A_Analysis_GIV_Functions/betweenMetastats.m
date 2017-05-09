function StudyStat=betweenMetastats(cond1,cond2)

% Function for computing stats for meta-analysis when single-subject data
% from a two-group between-subject experiment are available or when
% single- group data for comparisons against no effect (0) are available.

% Based on
% [1] Borenstein M, Hedges L V, Higgins JPT, Rothstein HR. Effect Sizes Based on Means. Introduction to Meta-Analysis.2009. pp. 21?32.
% Corresponds to Cochrane's formulas described in:
% [2] Deeks JJ, Higgins JP. Statistical algorithms in Review Manager 5 on behalf of the Statistical Methods Group of The Cochrane Collaboration. 2010
% [1] was used rather than [2], because Cochrane's recommendations for
% calculating standardized effects in cross-over studies
% (see: [3] Cochrane handbook 16.4.6) describe Cohen's d not Hedge's g! 

%FIELDS OF OUTPUT STRUCTURE StudyStat:
%mu, sd, se_mu: Non-standardized mean difference, standard deviation, standard error
%n: Sample size
%d, se_d: Standardized mean difference (COHEN's d), standardized standard error
%g, se_g: Standardized mean difference (HEDGE's g), standardized standard error


% For convenience, if cond1 or cond2 were entered as a table, convert to arrays 
if istable(cond1)
cond1=cond1{:,:};
end

if istable(cond2)
cond2=cond2{:,:};
end

% If cond1 or cond2 contain merely NaN, return a struct of NaNs
if (isscalar(cond1)&&isscalar(cond1))&&(isnan(cond1)||isnan(cond2))
StudyStat.mu=NaN;
StudyStat.sd_diff=NaN;
StudyStat.sd_pooled=NaN;
StudyStat.se_mu=NaN;
StudyStat.n=NaN;
StudyStat.r=NaN;
StudyStat.d=NaN;
StudyStat.se_d=NaN;
StudyStat.g=NaN;
StudyStat.se_g=NaN;
end

% VERSION A: COMPUTE IF TWO SAMPLES ARE PROVIDED
if ((length(cond1)>1) && (length(cond2)>1)) % Check if arrays were provided
   
    mu1=nanmean(cond1);
    mu2=nanmean(cond2);
    delta=[]; % Not applicable for the between group-case. Only for consistency with within-group Metastats.
    std_delta=[]; % Not applicable for the between group-case. Only for consistency with within-group Metastats.
    
    n1=sum(~isnan(cond1));
    n2=sum(~isnan(cond2));
    n=n1+n2;  %number of participants
    df1=n1-1;
    df2=n2-1;
    df=df1+df2;
    
    sd1=nanstd(cond1);
    sd2=nanstd(cond2);
        
    %Unstandardized outcomes
    mu=mu1-mu2;      %mean group difference
    % sd=nanstd([cond1;cond2]); %SD of combined samples... not the same as pooled SD, since it contains the variance caused by any effect between groups!
    sd=sqrt((nanvar(cond1).*df1+nanvar(cond2).*df2)./df); %SD_pooled, aka SD_within a of cond1&2 See: [1]
    se_mu=sqrt(((sd1.^2)./n1)+((sd2.^2)./n2)); % NOTE: SE is computed with separate SD's (without the assumption of equal variance in cond1 and cond2) 
    
    %Standardized outcome 1: Cohen's d
    d=mu./sd;  % d is calculated with pooled SD regardless whether assumption of equal variances are made See: [1]
    var_d=(n)./(n1.*n2)+(d.^2)./(2.*n);
    se_d= sqrt(var_d); % See: [1]
    
    %Standardized outcome 2: Hedge's adjusted g
    J=1-(3./(4.*df-1)); %Approximation to Hedge's correction factor J according to [1]
    g=d.*J;  % Hedges adjusted g, See: [1] Deeks JJ, Higgins JP. Statistical algorithms in Review Manager 5 on behalf of the Statistical Methods Group of The Cochrane Collaboration. 2010
    se_g=sqrt(var_d.*J.^2);
else
    disp('Error, enter two proper numeric vectors representing data from condition1 and condition2. For one-sample data use "withinMetastats" with imputed correlation of r=0 zero instead of Condition 2 ')
end

% Group results in struct to make output shorter and easier to handle

StudyStat.mu=mu;
StudyStat.sd_diff=NaN(size(mu)); %Paired difference, not applicable for between-subj designs. Just for consistency with withinMetastats
StudyStat.sd_pooled=sd;
StudyStat.se_mu=se_mu;
StudyStat.n=n;
StudyStat.r=NaN(size(mu)); %Correlation between repeated measures, not applicable for between-subj designs. Just for consistency with withinMetastats
StudyStat.d=d;
StudyStat.se_d=se_d;
StudyStat.g=g;
StudyStat.se_g=se_g;
StudyStat.delta=delta; %Paired difference (single subj values), only makes sense for single-group case, not for between-subj designs.
StudyStat.std_delta=std_delta; %Standardized paired difference (single subj values), only makes sense for single-group case, not for between-subj designs.
StudyStat.ICC=[];%empty field needed for reliablity analysis
end