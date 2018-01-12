clear

%% Load all images and compute NaNcount, ImgMean, IQR
% Takes about 22 minutes for all data
%Load Dataframe
datapath='../../datasets/';
df_name='data_frame.mat';
load(fullfile(datapath,df_name));

% Add participants with pain ratings <5% VAS
for i=1:size(df.full,1)
    curr_fields=fieldnames(df.full(i));
    %Load struct of all contrasts for a study 
    for j=1:length(curr_fields)
    if istable(df.full(i).(curr_fields{j})) && (~isempty(df.full(i).(curr_fields{j})))
        n=size(df.full(i).(curr_fields{j}),1);
        df.full(i).(curr_fields{j}).ex_lo_pain=zeros(n,1);
        df.full(i).(curr_fields{j}).ex_extreme_img=zeros(n,1);
    end
    end
end


ex_lo_pain_IDs={'elsenbruch_TH_209','elsenbruch_BP_204','theysohn_2130','lui_09'}
ex_extreme_img_IDs={'bingel11_13','bingel11_14','choi_A','choi_D','choi_F',...
    'eippert_12','freeman_LIDCAP001','geuter_34','lui_28','theysohn_2136',...
    'theysohn_2145','wrobel_42'}

i=strcmp(df.study_id,'elsenbruch');
curr_fields=fieldnames(df.full(i));
    for j=1:length(curr_fields)
        currsub=strcmp(df.full(i).(curr_fields{j}).sub_ID,'elsenbruch_TH_209');
        df.full(i).(curr_fields{j}).ex_lo_pain(currsub)=1
    end
    df.full(i).con.ex_lo_pain

df.full(i).con.ex_lo_pain
df.full(i).con.ex_lo_pain

df.ex_lo_p_ratings(strcmp(df.subID,'elsenbruch_TH_209'))=1;
df.ex_lo_p_ratings(strcmp(df.subID,'elsenbruch_BP_204'))=1;
df.ex_lo_p_ratings(strcmp(df.subID,'theysohn_2130'))=1;
df.ex_lo_p_ratings(strcmp(df.subID,'lui_09'))=1;

% Mark participants with problematic images
df.ex_img_artifact=logical(zeros(height(df),1));
df.ex_img_artifact(strcmp(df.subID,'bingel11_13'))=1;
df.ex_img_artifact(strcmp(df.subID,'bingel11_14'))=1;
df.ex_img_artifact(strcmp(df.subID,'choi_A'))=1;
df.ex_img_artifact(strcmp(df.subID,'choi_D'))=1;
df.ex_img_artifact(strcmp(df.subID,'choi_F'))=1;
df.ex_img_artifact(strcmp(df.subID,'eippert_12'))=1;
df.ex_img_artifact(strcmp(df.subID,'freeman_LIDCAP001'))=1;
df.ex_img_artifact(strcmp(df.subID,'geuter_34'))=1;
df.ex_img_artifact(strcmp(df.subID,'lui_28'))=1;
df.ex_img_artifact(strcmp(df.subID,'theysohn_2136'))=1;
df.ex_img_artifact(strcmp(df.subID,'theysohn_2145'))=1;
df.ex_img_artifact(strcmp(df.subID,'wrobel_42'))=1;

% Summarize
df.ex_all=df.ex_lo_p_ratings|df.ex_img_artifact;

% Mark participants with extreme NPS-scores
%df.ex_NPS=

save(fullfile(datapath,[df_name '.mat']), 'df')