clear

%% Load all images and compute NaNcount, ImgMean, IQR
% Takes about 22 minutes for all data
%Load Dataframe
datapath='../../Datasets/';
df_name='AllData_w_NPS_MHE_NOBRAIN';
load(fullfile(datapath,[df_name '.mat']));

% Mark participants with pain ratings <5% VAS
df.ex_lo_p_ratings=logical(zeros(height(df),1));
df.ex_lo_p_ratings(strcmp(df.subID,'elsenbruch_TH_209'))=1;
df.ex_lo_p_ratings(strcmp(df.subID,'elsenbruch_BP_204'))=1;
df.ex_lo_p_ratings(strcmp(df.subID,'theysohn_2130'))=1;
df.ex_lo_p_ratings(strcmp(df.subID,'huber_09'))=1;

% Mark participants with problematic images
df.ex_img_artifact=logical(zeros(height(df),1));
df.ex_img_artifact(strcmp(df.subID,'bingel06_AK'))=1;
df.ex_img_artifact(strcmp(df.subID,'bingel06_TK'))=1;
df.ex_img_artifact(strcmp(df.subID,'bingel11_13'))=1;
df.ex_img_artifact(strcmp(df.subID,'bingel11_14'))=1;
df.ex_img_artifact(strcmp(df.subID,'choi_A'))=1;
df.ex_img_artifact(strcmp(df.subID,'choi_D'))=1;
df.ex_img_artifact(strcmp(df.subID,'choi_F'))=1;
df.ex_img_artifact(strcmp(df.subID,'eippert_12'))=1;
df.ex_img_artifact(strcmp(df.subID,'freeman_LIDCAP001'))=1;
df.ex_img_artifact(strcmp(df.subID,'geuter_34'))=1;
df.ex_img_artifact(strcmp(df.subID,'huber_28'))=1;
df.ex_img_artifact(strcmp(df.subID,'theysohn_2136'))=1;
df.ex_img_artifact(strcmp(df.subID,'theysohn_2145'))=1;
df.ex_img_artifact(strcmp(df.subID,'wrobel_42'))=1;

save(fullfile(datapath,[df_name '.mat']), 'df')