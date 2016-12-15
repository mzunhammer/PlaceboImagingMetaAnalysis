clear

%% Load all images and compute NaNcount, ImgMean, IQR
% Takes about 22 minutes for all data
%Load Dataframe
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets/';
cd(datapath)
df_name='AllData_w_NPS_MHE_NOBRAIN_checks';
load([df_name '.mat']);

% Mark participants with pain ratings <5% VAS
df.excluded_pain_ratings=logical(zeros(height(df),1));
df.excluded_pain_ratings(strcmp(df.subID,'elsenbruch_TH_209'))=1;
df.excluded_pain_ratings(strcmp(df.subID,'elsenbruch_BP_204'))=1;
df.excluded_pain_ratings(strcmp(df.subID,'theysohn_2130'))=1;
df.excluded_pain_ratings(strcmp(df.subID,'huber_09'))=1;

save([df_name '_checks.mat'], 'df')