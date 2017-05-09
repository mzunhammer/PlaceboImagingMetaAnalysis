function StudyStat=withinMetastats(cond1,cond2)
% Function for computing stats for meta-analysis when single-subject data
% from a two-condition within-subject experiment are available, or when
% single- subject data representing the contrast (difference) between the
% groups is available.

% Based on
% [1] Borenstein M, Hedges L V, Higgins JPT, Rothstein HR. Effect Sizes Based on Means. Introduction to Meta-Analysis.2009. pp. 22-32.
% Corresponds to Cochrane's formulas described in:
% [2] Deeks JJ, Higgins JP. Statistical algorithms in Review Manager 5 on behalf of the Statistical Methods Group of The Cochrane Collaboration. 2010
% [1] was used rather than [2], because Cochrane's recommendations for
% calculating standardized effects in cross-over studies
% (see: [3] Cochrane handbook 16.4.6 and 16.4.6.2) describe Cohen's d not Hedge's g! 

%OUTPUTS
%mu, sd_diff,sd_pooled se_mu: Non-standardized mean difference, standard deviation,
%standard error, sd_diff is the sd of differences, sd_pooled the sd of all
%measurements.
%n: Sample size
%r: Correlation between paired measurements
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
    StudyStat.delta=[];
    StudyStat.std_delta=[];
    return
end

% VERSION A: COMPUTE WHEN TWO ARRAYS (= measurement timepoints) ARE PROVIDED
if size(cond1)==size(cond2) % Check if arrays of equal size were provided
    
    delta=cond1-cond2;      %by-subj differences
    n=sum(~isnan(delta));   %number of participants
    df=n-1;
    
    %Correlation between paired conditions
    r=NaN(1,size(cond1,2));
    for i=1:size(cond1,2)
        r_raw=corrcoef(cond1(:,i),cond2(:,i),'rows','complete');
        r(1,i)=r_raw(2);
    end
    
    % Unstandardized mean outcomes
    mu=nanmean(delta);      %by-study mean difference

    %SD OF DIFFERENCES!
    sd_diff=nanstd(delta);  
    se_mu=sd_diff./sqrt(n);  %by-study se (based on SD of differences!)
    
    %Standardized outcome 1: Cohen's d
    %Here there may be a dispute over how sd_within must be defined.
    % Alternative suggestion by Lakens (2013) ("Cohen's d AV):
    %sd1=nanstd(cond1);
    %sd2=nanstd(cond2);
    %sd_pooled=(sd1+sd2)/2;
    sd_pooled=sd_diff./sqrt(2.*(1-r));% see:[1], Formula 4.27
    d=mu./sd_pooled; % see:[1]

    var_d=(1./n+((d.^2)./(2.*n))).*2.*(1-r); %see: [1],4.28  The standard error of the standardized difference is corrected by the intra-subject correlation r
    se_d= sqrt(var_d) ;
    
    %Standardized outcome 2: Hedge's adjusted g
    J=1-(3./(4.*df-1)); %Approximation to Hedge's correction factor J according to [1]
    g=d.*J;  % Hedges adjusted g, See: [1] Deeks JJ, Higgins JP. Statistical algorithms in Review Manager 5 on behalf of the Statistical Methods Group of The Cochrane Collaboration. 2010
    se_g=sqrt(var_d.*J.^2);

    % Standardized mean difference

% VERSION B: COMPUTE IF ONLY ONE A CONTRAST + AN IMPUTED CORRELATION IS
% PROVIDED (also can used for one-sample estimates if is set to 0)
elseif length(cond2)==1 
       % Unstandardized mean difference
        delta=cond1;      %here, first column is equal to delta
        n=sum(~isnan(delta));   %number of participants
        sd_diff=nanstd(delta);
        mu=nanmean(delta);
        se_mu=sd_diff./sqrt(n);
       %Un-standardized outcome 1: Cohen's d... this is tricky, because no SD of
       % the basic condition is available
        r=cond2; %IMPUTED R
        sd_pooled=sd_diff./sqrt(2.*(1-r)); %see: [1] Borenstein M, Hedges L V, Higgins JPT, Rothstein HR. Effect Sizes Based on Means. Introduction to Meta-Analysis.2009. FORMULA 4.27

        d=mu./sd_pooled; % ATTENTION: Imputed r affects d!!! see: [1] or better Cochrane handbook 16.4.6.2  Standardized mean difference
        var_d=(1./n+((d.^2)./(2.*n))).*2.*(1-r); %same as above
        se_d=sqrt(var_d) ; %same as above
        fprintf('WARNING BY withinMetastats.m: r was imputed for this dataset.\n')
       % Standardized outcome 2: Hedge's adjusted g
        df=n-1;
        J=1-(3./(4.*df-1)); %Approximation to Hedge's correction factor J according to [1]
        g=d.*J;  % Hedges adjusted g, See: [1] Deeks JJ, Higgins JP. Statistical algorithms in Review Manager 5 on behalf of the Statistical Methods Group of The Cochrane Collaboration. 2010
        se_g=sqrt(var_d.*J.^2);
        r=ones(size(g)).*(cond2); %Set IMPUTED r as in same format as inputs output!!
else
        fprintf('WARNING BY withinMetastats.m: Vectors entered in and cond1,cond2 were not of equal length.\n')
end

% Group results in struct to make output shorter and easier to handle
StudyStat.mu=mu;
StudyStat.sd_diff=sd_diff;
StudyStat.sd_pooled=sd_pooled;
StudyStat.se_mu=se_mu;
StudyStat.n=n;
StudyStat.r=r;
StudyStat.d=d;
StudyStat.se_d=se_d;
StudyStat.g=g;
StudyStat.se_g=se_g;
StudyStat.delta=delta;
StudyStat.std_delta=bsxfun(@rdivide,delta,sd_pooled);
StudyStat.ICC=[];%empty field needed for reliablity analysis
end