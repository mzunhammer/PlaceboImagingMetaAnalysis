function validate_GIV()
%% Script checking if GIV functions betweenMetastats, withinMetastats, and
% GIVsummary yield valid results

tol=0.001; % absolute tolerance for deviations for all values tested
%% Calculate BETWEEN Metastats
% Version with two data-sets
% All numbers are taken from:
% [1] Borenstein M, Hedges L V, Higgins JPT, Rothstein HR. Effect Sizes Based on Means. Introduction to Meta-Analysis.2009. pp. 22-32.

% Define desired target values as taken from [1]:
BWtarget.mu=3.0000;
BWtarget.sd_diff=[]; %Not applicable, since betwee-subj
BWtarget.sd_pooled=5.0249;
BWtarget.se_mu=1.0050;
BWtarget.n=100;
BWtarget.r=[]; %Not applicable, since betwee-subj
BWtarget.d=0.5970;
BWtarget.se_d=0.2044;
BWtarget.g=0.5924;
BWtarget.se_g=0.2028;
BWtarget.delta=[]; %Not applicable, since betwee-subj
BWtarget.std_delta=[]; %Not applicable, since betwee-subj
BWtarget.ICC=[]; %Not applicable, since betwee-subj
BWtarget.r_external=[]; %Not applicable, since betwee-subj
BWtarget.n_r_external=[]; %Not applicable, since betwee-subj

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
BWStudyStat=summarize_between(y1,y2);
% >>Assert results
fields=fieldnames(BWStudyStat);
for i = 1:length(fields)
    if ~isempty(BWtarget.(fields{i}))
    errormsg=['Error in Between-Metastats. Variable missing the BWtarget results:' fields{i}];
    assert(all(abs(BWStudyStat.(fields{i})-BWtarget.(fields{i}))<tol),errormsg);
    end
end
disp('Between-Metastats all match Example Results')
%% Calculate WITHIN Metastats
% WITHIN: Version with paired data
% All numbers are taken from:
% [1] Borenstein M, Hedges L V, Higgins JPT, Rothstein HR. Effect Sizes Based on Means. Introduction to Meta-Analysis.2009. pp. 22-32.

% Define desired target values as taken from [1] (second example starting at page 8 (or formula 4.26)):
WItarget.mu=3.0000;
WItarget.sd_diff=5.5;
WItarget.sd_pooled=7.1005; % Not applicable because WI study data
WItarget.se_mu=0.7778; % ...not explicity provided in the example, but the number was verified
WItarget.n=50; %50 pairs that is
WItarget.r=.7;

WItarget.d=0.4225;
WItarget.se_d=0.1143;
WItarget.g=0.4160;
WItarget.se_g=0.1126;
WItarget.delta=[]; %Will vary according to sampling
WItarget.std_delta=[]; %Will vary according to sampling
WItarget.ICC=[]; %Not applicable, since betwee-subj
WItarget.r_external=[]; %Not applicable, placeholder to store correlations w external var
WItarget.n_r_external=[]; %Not applicable, placeholder to store correlations w external var


% Create data-set as described in [1]:
n=50;
mu1=103.00;
mu2=100.00;
sd_diff=5.5;
r=.7;
sd=sd_diff/sqrt(2*(1-r));


%Generate two sets of correlated errors (err1, err2, with roughly r=0.7)
curr_r=0;
while (abs(curr_r-0.7))>0.0001 % Too lazy to calculate how to pre-determine r exactly, so I just repeat until I get a sample with r very close to WItarget
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

%Replicate y1s and y2s to check if matrix-calculations work
y1=repmat(y1,1,3);
y2=repmat(y2,1,3);


% Let the function do its job
WIStudyStat=summarize_within(y1,y2);

% >>Assert results
fields=fieldnames(WIStudyStat);
for i = 1:length(fields)
    if ~isempty(WItarget.(fields{i}))
    errormsg=['Error in Within-Metastats 1. Variable missing the WItarget results:' fields{i}];
    assert(all(abs(WIStudyStat.(fields{i})-WItarget.(fields{i}))<tol),errormsg);
    end
end

%% Calculate IMPUTED WITHIN/ONE-SAMPLE Metastats
% All numbers are taken from:
% [1] Borenstein M, Hedges L V, Higgins JPT, Rothstein HR. Effect Sizes Based on Means. Introduction to Meta-Analysis.2009. pp. 22-32.

y_diff=y1-y2;
rr=corr(y1,y2,'rows','complete');
WIStudyStat2=summarize_within(y_diff,rr(2));

% >>Assert results
fields=fieldnames(WIStudyStat2);
for i = 1:length(fields)
    if ~isempty(WItarget.(fields{i}))
    errormsg=['Error in Within-Metastats 2. Variable missing the WItarget results:' fields{i}];
    assert(all(abs(WIStudyStat2.(fields{i})-WItarget.(fields{i}))<tol),errormsg);
    end
end
disp('Within-Metastats all match Example Results')
%% Finally check if GIVsummary works

% Target values according to an analysis with refMan 5 (Cochrane):
% (Continuous Outcome: Generic Inverse Variance Method, Standardized Mean


%Test statistic:
%Test for overall effect: Z =  (P < 0.00001)
%
%Heterogeneity stats:
%Heterogeneity: Tau? = 0.00; Chi? = 0.58, df = 1 (P = 0.45); I? = 0%

%SUMMARY_stat=[WItarget,BWtarget];% Simple version: Using Hedge's g for the former TARGETS
SUMMARY_stat=[WIStudyStat,BWStudyStat];
summary=GIV_summary(SUMMARY_stat);

% For summary stats, study-target results were fed into refMan5 (random effects analysis).
%Since refMan returns only rounded results, assertions had to be rounded to two
% decimal places
assert(all(0.46==round(summary.g.random.summary,2)),'g summary stat does not match the result obtained with RefMan5');
assert(all(0.26==round(summary.g.random.CI_lo,2)),'g summary CI_lo does not match the result obtained with RefMan5');
assert(all(0.65==round(summary.g.random.CI_hi,2)),'g summary CI_hi stat does not match the result obtained with RefMan5');
assert(all(0.76==round(summary.g.random.rel_weight(1,:),2)),'g weight of study 1  does not match the result obtained with RefMan5');
assert(all(0.24==round(summary.g.random.rel_weight(2,:),2)),'g weight of study 2   does not match the result obtained with RefMan5');
assert(all(4.65==round(summary.g.random.z,2)),'z stat does not match the result obtained with RefMan5');
disp('All summary results match example results')
end