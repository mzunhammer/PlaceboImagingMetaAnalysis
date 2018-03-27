function StudyStat=summarize_within(cond1,cond2,varargin)
% Function for computing stats for meta-analysis when single-subject data
% from a two-condition within-subject experiment are available (cond1-cond2), or when
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

%% Pre-process and check input

% For convenience, if cond1 or cond2 were entered as a table, convert to arrays 
if istable(cond1)
cond1=cond1{:,:};
end

if istable(cond2)
cond2=cond2{:,:};
end

% VERSION A: COMPUTE WHEN TWO ARRAYS (= measurement timepoints) ARE PROVIDED
if size(cond1)==size(cond2) % Check if arrays of equal size were provided
    delta=cond1-cond2;      %by-subj differences
    r=fastcorrcoef(cond1,cond2,'exclude_nan');
    %Correlation between paired conditions
    % MATLABs corrcoef is slow... when using this function for whole-brain
    % analysis it is the main time-consuming step. Thus >> fastcorrcoef
    % Old and slow verion:    
    %     for i=1:size(cond1,2)
    %         r_raw=corrcoef(cond1(:,i),cond2(:,i),'rows','complete');
    %         r(1,i)=r_raw(2);
    %     end
elseif length(cond2)==1 
    delta=cond1;      %if contrasts are entered
    r= cond2;  % cond2 is IMPUTED
    if r==0
            %fprintf('WARNING BY withinMetastats.m: r=0 was used >> one-sample test.\n');
    elseif abs(r)>=1
            fprintf('WARNING BY withinMetastats.m: r>=1 or r<=-1 was used >> Aborted to avoid nonsense.\n');
            StudyStat=[];
            return
        else
            sprintf('WARNING BY withinMetastats.m: r=%0.2f was imputed for this dataset.\n',r);
    end
     r=ones(1,size(cond1,2)).*r; % extend imputed r to all columns
else
        fprintf('WARNING BY withinMetastats.m: Vectors entered in and cond1,cond2 were not of equal length or cond2 was not a scalar.\n')
end

%% OPTINAL: winsorize
if any(strcmp(varargin,'winsor'))
    for i=1:size(delta,2)
        sd_cutoff=varargin{find(strcmp(varargin,'winsor'))+1};
        delta(:,i)=winsor_std(delta(:,i),sd_cutoff);
    end
end

%% Calculate study stats

n=sum(~isnan(delta));   %number of participants
df=n-1;

% Unstandardized mean outcomes
mu=nanmean(delta);      %by-study mean difference

%SD OF DIFFERENCES!
sd_diff=nanstd(delta);  
se_mu=sd_diff./sqrt(n);  %by-study se (based on SD of differences!)

%Standardized outcome 1: Cohen's d
%Here there may be a dispute over how sd_within must be defined.
% Alternative suggestion by Lakens (2013) ("Cohen's d_av):
%sd1=nanstd(cond1);
%sd2=nanstd(cond2);
%sd_pooled=(sd1+sd2)/2;
% We use what Lakens calls: "Cohen's d_rm", which is also used by
% [1] Borenstein et al.
sd_pooled=sd_diff./sqrt(2.*(1-r));% see:[1], Formula 4.27
d=mu./sd_pooled; % see:[1]

var_d=(1./n+((d.^2)./(2.*n))).*2.*(1-r); %see: [1],4.28  The standard error of the standardized difference is corrected by the intra-subject correlation r
se_d= sqrt(var_d) ;

%Standardized outcome 2: Hedge's adjusted g
J=1-(3./(4.*df-1)); %Approximation to Hedge's correction factor J according to [1]
g=d.*J;  % Hedges adjusted g, See: [1] Deeks JJ, Higgins JP. Statistical algorithms in Review Manager 5 on behalf of the Statistical Methods Group of The Cochrane Collaboration. 2010
se_g=sqrt(var_d.*J.^2);

%% Guard against outlier results when n's are very small (n=<3)
% Studies with an n<3 lead to a number of problems: r will be 1 or -1, thus calculation of sd_pooled, and all standardized measures will fail
% This can happen at imaging analyses when certain voxels are covered by
% only a fraction of participants from a given study.
n2small=(n <= 3); 

mu(n2small)=NaN;
sd_diff(n2small)=NaN;
sd_pooled(n2small)=NaN;
se_mu(n2small)=NaN;
n(n2small)=NaN;
r(n2small)=NaN;
d(n2small)=NaN;
se_d(n2small)=NaN;
g(n2small)=NaN;
se_g(n2small)=NaN;
delta(n2small)=NaN;
std_delta(:,n2small)=NaN;

%% Put results
% Group results in struct
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
StudyStat.ICC=NaN;
StudyStat.r_external=[];
StudyStat.n_r_external=[];
end