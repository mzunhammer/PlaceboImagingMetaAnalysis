%% Script checking if GIV functions betweenMetastats, withinMetastats, and
% GIVsummary yield valid results
clear
cd /Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/

%% Calculate BETWEEN Metastats
% Version with two data-sets
% All numbers are taken from:
% [1] Borenstein M, Hedges L V, Higgins JPT, Rothstein HR. Effect Sizes Based on Means. Introduction to Meta-Analysis.2009. pp. 22-32.

% Define desired target values as taken from [1]:
target.mu=3.0000;
target.sd_diff=NaN; %Not applicable, since betwee-subj
target.sd_pooled=5.0249;
target.se_mu=1.0050;
target.n=100;
target.r=NaN; %Not applicable, since betwee-subj
target.d=0.5970;
target.se_d=0.2044;
target.g=0.5924;
target.se_g=0.2028;
target.delta=[]; %Not applicable, since betwee-subj
target.std_delta=[]; %Not applicable, since betwee-subj

% Create data-set as described in [1]:
mu1=103.00;
mu2=100.00;
sd1=5.5;
sd2=4.5;
n=100;
y1=mu1+(nonrandn(n/2,1)*sd1);
y2=mu2+(nonrandn(n/2,1)*sd2);

% Add some NaN's to one sub-sample to see if that affects results
y1=[y1;NaN;NaN];

%Finally, replicate y1s and y2s to check if matrix-calculations work
y1=repmat(y1,1,3);
y2=repmat(y2,1,3);

% Let the function do its job
BWStudyStat=betweenMetastats(y1,y2);

% >> Visually check results in variable viewer: Row 1 values should all be the same as Row 2
compareResultsBW=[BWStudyStat, target]';
compareResultsBW(1)
compareResultsBW(2)

%% Calculate WITHIN Metastats
% WITHIN: Version with paired data
% All numbers are taken from:
% [1] Borenstein M, Hedges L V, Higgins JPT, Rothstein HR. Effect Sizes Based on Means. Introduction to Meta-Analysis.2009. pp. 22-32.

% Define desired target values as taken from [1] (second example starting at page 8 (or formula 4.26)):
target.mu=3.0000;
target.sd_diff=5.5;
target.sd_pooled=7.1005; % Not applicable because WI study data
target.se_mu=0.7778; % ...not explicity provided in the example, but the number was verified
target.n=50; %50 pairs that is
target.r=.7;

target.d=0.4225;
target.se_d=0.1143;
target.g=0.4160;
target.se_g=0.1126;
target.delta=[]; %Will vary according to sampling
target.std_delta=[]; %Will vary according to sampling


% Create data-set as described in [1]:
n=50;
mu1=103.00;
mu2=100.00;
sd_diff=5.5;
r=.7;
sd=sd_diff/sqrt(2*(1-r))


%Generate two sets of correlated errors (err1, err2, with roughly r=0.7)
curr_r=0;
while (abs(curr_r-0.7))>0.0001 % Too lazy to calculate how to pre-determine r exactly, so I just repeat until I get a sample with r very close to target
    err1=nonrandn(n,1);
    err2=nonrandn(n,1);
    R=[1 0.7; 0.7 1]; % Correlation mask
    L=chol(R);        % Cholesky decomposition
    errorset=[err1,err2]*L;  % Application of Cholesky decomposition to data 
    c=corr(errorset);
    curr_r=c(2);
end

y1=mu1+errorset(:,1)*sd;
y2=mu2+errorset(:,2)*sd;

% Add some NaN's to both sub-sample to see if that affects results
y1=[y1;NaN;NaN];
y2=[y2;NaN;NaN];

%Finally, replicate y1s and y2s to check if matrix-calculations work
y1=repmat(y1,1,3);
y2=repmat(y2,1,3);

% Let the function do its job
WIStudyStat=withinMetastats(y1,y2);
%% Calculate IMPUTED WITHIN/ONE-SAMPLE Metastats
% All numbers are taken from:
% [1] Borenstein M, Hedges L V, Higgins JPT, Rothstein HR. Effect Sizes Based on Means. Introduction to Meta-Analysis.2009. pp. 22-32.

y_diff=y1-y2;
rr=corr(y1,y2,'rows','complete');
WIStudyStat2=withinMetastats(y_diff,rr(2));

% >> Visually check results in variable viewer: Row 1 values should all be the same as Row 2
compareResultsWI=[WIStudyStat,WIStudyStat2, target]';
compareResultsWI(1)
compareResultsWI(2)



%% Finally check if GIVsummary works

% Target values according to an analysis with refMan 5 (Cochrane):
% (Continuous Outcome: Generic Inverse Variance Method, Standardized Mean
%
% Effect size ±95%CI
% summary of g=0.46 [0.26, 0.65]
% summary of g=
%
%Study weights:
% 76.5 (Within)%
% 23.5 (Between)%
%
%Test statistic:
%Test for overall effect: Z = 4.65 (P < 0.00001)
%
%Heterogeneity stats:
%Heterogeneity: Tau² = 0.00; Chi² = 0.58, df = 1 (P = 0.45); I² = 0%

summary_stat=vertcat(WIStudyStat.g,BWStudyStat.g);% Currently uses Hedge's g
se_summary_stat=vertcat(WIStudyStat.se_g,BWStudyStat.se_g); % Currently uses Hedge's g
n=vertcat(WIStudyStat.n,BWStudyStat.n);
type='random';

[summary,SEsummary,rel_weight,z,p,CI_lo,CI_hi,chisq,tausq,df,p_het,Isq]=GIVsummary(summary_stat,se_summary_stat,type)