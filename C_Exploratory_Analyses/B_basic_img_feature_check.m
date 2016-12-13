clear

%% Load all images and compute NaNcount, ImgMean, IQR
% Takes about 10-15 minutes
%Load Dataframe
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets/';
cd(datapath)
df_path='AllData_w_NPS_MHE_NOBRAIN_checks.mat';
load(df_path);

%Variables to be used for outlier prediction
columns_for_mahal={'grey','white','csf','brain','nobrain','AllImg_IQR'}; % select variables for which mahal should be computed

%Limit outlier prediction to images representing pain (anticipation etc may be scaled differently)
df=df(logical(df.pain),:);

%% Compute mahalanobi's distance by study and condition
studies=unique(df.studyID);
pain_columns_for_mahal={'NPSraw','MHEraw'};

df.mahal=NaN(size(df.grey));
df.img_p=NaN(length(df.grey),length(columns_for_mahal));

%df.mahalPainSignal=NaN(size(df.grey));
for i=1:length(studies)
   istudy=strcmp(df.studyID,studies(i)); %create current study index
   conditions=unique(df.cond(istudy));   %get all image types fore each study
    for j=1:length(conditions)
          iscond=strcmp(df.cond,conditions(j)); %create current condition index
          istudycond=istudy & iscond;           %get all images  fore current condition and study
          
          img_data=df{istudycond,columns_for_mahal};
          df.mahal(istudycond)=mahal(img_data,mvnrnd(mean(img_data),cov(img_data),1000));
          df.img_p(istudycond,:)=normcdf(zscore(img_data));
          %pain_data=df{istudycond,pain_columns_for_mahal};
          %df.mahalPainSignal(istudycond)=mahal(pain_data,mvnrnd(mean(pain_data),cov(pain_data),1000));
          
    end
end
% Mahalanobi's distance (D) follows a chi-square distribution.
% Calculate outlier-threshold as value of D that is less likely than 1:100
% (D was calculated by-study and by-condition... since all studies except rütgen et al had <100 participants values with a prob <1:100 are suspicious)
mahal_outlr_tresh_img=chi2inv(.99, length(columns_for_mahal));
%mahal_outlr_tresh_pain=chi2inv(.99, length(pain_columns_for_mahal));

ioutliers=df.mahal>mahal_outlr_tresh_img
p_mahal=chi2cdf(df.mahal(ioutliers),length(columns_for_mahal));
outlier_image_p=df.img_p(ioutliers,:);
df_outliers_by_study_and_cond=[table(df.img(ioutliers),'VariableNames',{'image'}),...
             table(df.subID(ioutliers),'VariableNames',{'subject'}),...
             table(df.cond(ioutliers),'VariableNames',{'condition'}),...
             table(p_mahal),...
             df(ioutliers,columns_for_mahal),...
             array2table(outlier_image_p,'VariableNames',strcat('p_',columns_for_mahal))]
%df.img(df.mahalPainSignal>mahal_outlr_tresh_pain)


%% Summarize variables for prediction BY STUDY
columns_for_mahal={'grey','white','csf','brain','nobrain','AllImg_IQR'}; % select variables for which mahal should be computed
df_by_study=varfun(@mean,df,'InputVariables',columns_for_mahal,...
    'GroupingVariables','studyID')

tonorm={'mean_grey','mean_white','mean_csf'}; % select variables for which mahal should be computed
df_by_study=[df_by_study,...
             array2table(zscore(df_by_study{:,tonorm},[],2),...
             'VariableNames',strcat('norm_',tonorm))];

Y=df_by_study{:,strcat('norm_',tonorm)};
df_by_study.mahal=mahal(Y,mvnrnd(mean(Y),cov(Y),1000));
df_by_study.img_p=normcdf(zscore(Y));

figure(1)
plot(df_by_study.norm_mean_grey,df_by_study.norm_mean_white,'.')
text(df_by_study.norm_mean_grey,df_by_study.norm_mean_white,df_by_study.studyID)
xlabel('grey')
ylabel('white')


figure(2)
plot(df_by_study.norm_mean_grey,df_by_study.norm_mean_csf,'.')
text(df_by_study.norm_mean_grey,df_by_study.norm_mean_csf,df_by_study.studyID)
xlabel('grey')
ylabel('csf')

figure(3)
plot(df_by_study.norm_mean_grey,df_by_study.norm_mean_white,'.')
text(df_by_study.norm_mean_grey,df_by_study.norm_mean_white,df_by_study.studyID)
xlabel('grey')
ylabel('white')


% Mahalanobi's distance (D) follows a chi-square distribution.
% Calculate outlier-threshold as value of D that is less likely than 1:100
% (D was calculated by-study and by-condition... since all studies except rütgen et al had <100 participants values with a prob <1:100 are suspicious)
%mahal_outlr_tresh_img=chi2inv(.99, length(columns_for_mahal));
%ioutliers=df_by_study.mahal>mahal_outlr_tresh_img
%% Summarize variables for prediction BY SUBJECT
df_by_subID=varfun(@mean,df,'InputVariables',columns_for_mahal,...
    'GroupingVariables','subID')



%% Plot Histogram of NaNs per study/condition


for i=1:length(studies)
   istudy=strcmp(df.studyID,studies(i)); 
   conditions=unique(df.cond(istudy));
   figure('name',studies{i})
   hold on
   for j=1:length(conditions)
   iscond=strcmp(df.cond,conditions(j));
   istudycond=istudy & iscond;
   histogram(df.NaNcount(istudycond),10)
   end
   hold off
end
%% Plot Histogram of Mean Image Signal per study/condition
for i=1:length(studies)
   istudy=strcmp(df.studyID,studies(i)); 
   conditions=unique(df.cond(istudy));
   figure('name',studies{i})
   hold on
   for j=1:length(conditions)
   iscond=strcmp(df.cond,conditions(j));
   istudycond=istudy & iscond;
        histogram(df.AllImg_Mean(istudycond),10)
   end
   hold off
end

%% Plot Histogram of Inter-Quartile Range per study/condition
for i=1:length(studies)
   istudy=strcmp(df.studyID,studies(i)); 
   conditions=unique(df.cond(istudy));
   figure('name',studies{i})
   hold on
   for j=1:length(conditions)
   iscond=strcmp(df.cond,conditions(j));
   istudycond=istudy & iscond;
        histogram(df.AllImg_IQR(istudycond),10)
   end
   hold off
end