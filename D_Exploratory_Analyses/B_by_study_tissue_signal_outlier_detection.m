clear

%% Load df_pain
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets/';
cd(datapath)
df_path='AllData_w_NPS_MHE_NOBRAIN_checks.mat';
load(df_path);

%Variables to be used for outlier prediction
img_check_vars={'grey','white','csf','brain','nobrain'}; %  select variables for which mahal should be computed
%Limit outlier prediction to images representing pain (anticipation etc may be scaled differently)
df_pain=df(logical(df.pain),:);

%% Summarize variables for outlierdetection BY SUBJECT
df_by_study=varfun(@mean,df_pain,'InputVariables',img_check_vars,...
    'GroupingVariables','studyID')
% Re-Add studyID
studies=unique(df_by_study.studyID);
%% Compute mahal for and plot
%  relative tissue intensities and brain vs no-brain intensity by-study
df_by_study.white_by_gray=df_by_study.mean_white./df_by_study.mean_grey;
df_by_study.csf_by_gray=df_by_study.mean_csf./df_by_study.mean_grey;
df_by_study.nobrain_by_brain=df_by_study.mean_nobrain./df_by_study.mean_brain;

tomahal={'white_by_gray','csf_by_gray','nobrain_by_brain'}; 
% Mahalanobi's distance (D) follows a chi-square distribution.
% Calculate outlier-threshold as value of D that is less likely than 1:100
% (D was calculated by-study and by-condition... since all studies except r?tgen et al had <100 participants values with a prob <1:100 are suspicious)
mahal_outlr_tresh=chi2inv(.99, length(tomahal));
df_by_study.mahal_tissue=NaN(height(df_by_study),1);
df_by_study.tissue_outlier=logical(zeros(height(df_by_study),1));
Y=df_by_study{:,tomahal};
df_by_study.mahal_tissue=mahal(Y,mvnrnd(mean(Y),cov(Y),1000));
df_by_study.tissue_outlier=df_by_study.mahal_tissue>mahal_outlr_tresh;
a=figure(1);
    subplot(1,2,1)
    plot(df_by_study.white_by_gray,...
        df_by_study.csf_by_gray,...
        '.')
    % Label normal data-points
    inormal=~df_by_study.tissue_outlier;
    iout=df_by_study.tissue_outlier;
    text(df_by_study.white_by_gray(inormal),...
        df_by_study.csf_by_gray(inormal),...
        df_by_study.studyID(inormal))
    text(df_by_study.white_by_gray(iout),...
        df_by_study.csf_by_gray(iout),...
        df_by_study.studyID(iout),'Color','r')
    xlabel('white/gray')
    ylabel('csf/gray')
    
    % Label outlier data-points
    subplot(1,2,2)
    plot(df_by_study.mean_brain,df_by_study.mean_nobrain,'.')
    text(df_by_study.mean_brain(inormal),df_by_study.mean_nobrain(inormal),df_by_study.studyID(inormal))
    text(df_by_study.mean_brain(iout),df_by_study.mean_nobrain(iout),df_by_study.studyID(iout),'Color','r')
    xlabel('brain')
    ylabel('nobrain')
    
%Plot histogram of mahal values with threshold
figure(2)
hist(df_by_study.mahal_tissue)
vline(mahal_outlr_tresh)

%Print tissue outlier suspects to console
disp(df_by_study.studyID(df_by_study.tissue_outlier))


% %% Summarize variables for prediction BY STUDY
% img_check_vars={'grey','white','csf','brain','nobrain','AllImg_IQR'}; % select variables for which mahal should be computed
% df_by_study=varfun(@mean,df_pain,'InputVariables',img_check_vars,...
%     'GroupingVariables','studyID')
% 
% tomahal={'mean_grey','mean_white','mean_csf'}; % select variables for which mahal should be computed
% df_by_study=[df_by_study,...
%              array2table(zscore(df_by_study{:,tomahal},[],2),...
%              'VariableNames',strcat('norm_',tomahal))];
% 
% Y=df_by_study{:,strcat('norm_',tomahal)};
% df_by_study.mahal=mahal(Y,mvnrnd(mean(Y),cov(Y),1000));
% df_by_study.img_p=normcdf(zscore(Y));
% 
% figure(1)
% plot(df_by_study.norm_mean_grey,df_by_study.norm_mean_white,'.')
% text(df_by_study.norm_mean_grey,df_by_study.norm_mean_white,df_by_study.studyID)
% xlabel('grey')
% ylabel('white')
% 
% 
% figure(2)
% plot(df_by_study.norm_mean_grey,df_by_study.norm_mean_csf,'.')
% text(df_by_study.norm_mean_grey,df_by_study.norm_mean_csf,df_by_study.studyID)
% xlabel('grey')
% ylabel('csf')
% 
% figure(3)
% plot(df_by_study.norm_mean_grey,df_by_study.norm_mean_white,'.')
% text(df_by_study.norm_mean_grey,df_by_study.norm_mean_white,df_by_study.studyID)
% xlabel('grey')
% ylabel('white')
% 
% 
% 
% 
% %% Compute mahalanobi's distance by STUDY and CONDITION
% studies=unique(df_pain.studyID);
% pain_img_check_vars={'NPSraw','MHEraw'};
% 
% df_paindf_pain.mahal=NaN(size(df_pain.grey));
% df_pain.img_p=NaN(length(df_pain.grey),length(img_check_vars));
% 
% %df_pain.mahalPainSignal=NaN(size(df_pain.grey));
% for i=1:length(studies)
%    :=strcmp(df_pain.studyID,studies(i)); %create current study index
%    conditions=unique(df_pain.cond(:));   %get all image types fore each study
%     for j=1:length(conditions)
%           iscond=strcmp(df_pain.cond,conditions(j)); %create current condition index
%           :cond=: & iscond;           %get all images  fore current condition and study
%           
%           img_data=df_pain{:cond,img_check_vars};
%           df_pain.mahal(:cond)=mahal(img_data,mvnrnd(mean(img_data),cov(img_data),1000));
%           df_pain.img_p(:cond,:)=normcdf(zscore(img_data));
%           %pain_data=df_pain{:cond,pain_img_check_vars};
%           %df_pain.mahalPainSignal(:cond)=mahal(pain_data,mvnrnd(mean(pain_data),cov(pain_data),1000));
%           
%     end
% end
% % Mahalanobi's distance (D) follows a chi-square distribution.
% % Calculate outlier-threshold as value of D that is less likely than 1:100
% % (D was calculated by-study and by-condition... since all studies except r?tgen et al had <100 participants values with a prob <1:100 are suspicious)
% mahal_outlr_tresh_img=chi2inv(.99, length(img_check_vars));
% %mahal_outlr_tresh_pain=chi2inv(.99, length(pain_img_check_vars));
% 
% ioutliers=df_pain.mahal>mahal_outlr_tresh_img
% p_mahal=chi2cdf(df_pain.mahal(ioutliers),length(img_check_vars));
% outlier_image_p=df_pain.img_p(ioutliers,:);
% df_outliers_by_study_and_cond=[table(df_pain.img(ioutliers),'VariableNames',{'image'}),...
%              table(df_pain.studyID(ioutliers),'VariableNames',{'subject'}),...
%              table(df_pain.cond(ioutliers),'VariableNames',{'condition'}),...
%              table(p_mahal),...
%              df_pain(ioutliers,img_check_vars),...
%              array2table(outlier_image_p,'VariableNames',strcat('p_',img_check_vars))]
% %df_pain.img(df_pain.mahalPainSignal>mahal_outlr_tresh_pain)
% 
% %% Plot Histogram of NaNs per study/condition
% 
% 
% for i=1:length(studies)
%    :=strcmp(df_pain.studyID,studies(i)); 
%    conditions=unique(df_pain.cond(:));
%    figure('name',studies{i})
%    hold on
%    for j=1:length(conditions)
%    iscond=strcmp(df_pain.cond,conditions(j));
%    :cond=: & iscond;
%    histogram(df_pain.NaNcount(:cond),10)
%    end
%    hold off
% end
% %% Plot Histogram of Mean Image Signal per study/condition
% for i=1:length(studies)
%    :=strcmp(df_pain.studyID,studies(i)); 
%    conditions=unique(df_pain.cond(:));
%    figure('name',studies{i})
%    hold on
%    for j=1:length(conditions)
%    iscond=strcmp(df_pain.cond,conditions(j));
%    :cond=: & iscond;
%         histogram(df_pain.AllImg_Mean(:cond),10)
%    end
%    hold off
% end
% 
% %% Plot Histogram of Inter-Quartile Range per study/condition
% for i=1:length(studies)
%    :=strcmp(df_pain.studyID,studies(i)); 
%    conditions=unique(df_pain.cond(:));
%    figure('name',studies{i})
%    hold on
%    for j=1:length(conditions)
%    iscond=strcmp(df_pain.cond,conditions(j));
%    :cond=: & iscond;
%         histogram(df_pain.AllImg_IQR(:cond),10)
%    end
%    hold off
% end