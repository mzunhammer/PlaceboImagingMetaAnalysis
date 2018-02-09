function A_by_study_tissue_signal_outlier_detection(datapath)

%% CAVE: THIS FUNCTION IS STILL IN THE PROCESS OF REFACTURING:
% Absolute tissue signal estimates not yet added.

%% Load df_pain
df_path='data_frame.mat';
load(fullfile(datapath,df_path));
%Designate variables to be selected  for outlier prediction
img_check_vars={'grey','white','csf','brain','nobrain'}; %  select variables for which mahal should be computed, optional: 'grey_abs','white_abs','csf_abs',,'brain_abs','nobrain_abs'

%% Summarize by study
for i=1:size(df,1)
    curr_study=df.subjects{i}.placebo_and_control;
    curr_study=vertcat(curr_study{:});
    img_check_tbl(i,:)=varfun(@mean,curr_study,'InputVariables',img_check_vars);
end
img_check_tbl.study_ID=df.study_ID
%  add relative tissue intensities and brain vs no-brain intensity by-study
img_check_tbl.white_by_gray=img_check_tbl.mean_white./img_check_tbl.mean_grey;
img_check_tbl.csf_by_gray=img_check_tbl.mean_csf./img_check_tbl.mean_grey;
img_check_tbl.nobrain_by_brain=img_check_tbl.mean_nobrain./img_check_tbl.mean_brain;

% img_check_tbl.white_by_gray_abs=img_check_tbl.mean_white_abs./img_check_tbl.mean_grey_abs;
% img_check_tbl.csf_by_gray_abs=img_check_tbl.mean_csf_abs./img_check_tbl.mean_grey_abs;
% img_check_tbl.nobrain_by_brain_abs=img_check_tbl.mean_nobrain_abs./img_check_tbl.mean_brain_abs;

%% Compute mahal
tomahal={'white_by_gray','csf_by_gray','nobrain_by_brain'}; % note: absolute tissue signal estimates are useless if not based on signal-normalized images, as studies (esp. the fsl studies) differ vastly in scale {'mean_grey','mean_white','mean_csf','mean_brain','mean_nobrain'}
% Mahalanobi's distance (D) follows a chi-square distribution.
% Calculate outlier-threshold as value of D that is less likely than 1:100
% (D was calculated by-study and by-condition... since all studies except ruetgen et al had <100 participants values with a prob <1:100 are suspicious)
mahal_outlr_tresh=chi2inv(.999, length(tomahal));
img_check_tbl.mahal_tissue=NaN(height(img_check_tbl),1);
img_check_tbl.tissue_outlier=logical(zeros(height(img_check_tbl),1));
Y=img_check_tbl{:,tomahal};
img_check_tbl.mahal_tissue=mahal(Y,mvnrnd(mean(Y),cov(Y),1000));
img_check_tbl.tissue_outlier=img_check_tbl.mahal_tissue>mahal_outlr_tresh


%% Plots
a=figure(1);
    figure('Position', [100, 100, 400*4, 400]);
    axes
    axis('equal');
    subplot(1,4,1)
    plot(img_check_tbl.white_by_gray,...
        img_check_tbl.csf_by_gray,...
        '.')
    % Label normal data-points
    inormal=~img_check_tbl.tissue_outlier;
    iout=img_check_tbl.tissue_outlier;
    text(img_check_tbl.white_by_gray(inormal),...
        img_check_tbl.csf_by_gray(inormal),...
        img_check_tbl.study_ID(inormal))
    text(img_check_tbl.white_by_gray(iout),...
        img_check_tbl.csf_by_gray(iout),...
        img_check_tbl.study_ID(iout),'Color','r')
    xlabel('white/gray')
    ylabel('csf/gray')
    
%     subplot(1,4,2)
%     plot(img_check_tbl.white_by_gray_abs,...
%         img_check_tbl.csf_by_gray_abs,...
%         '.')
%     % Label normal data-points
%     inormal=~img_check_tbl.tissue_outlier;
%     iout=img_check_tbl.tissue_outlier;
%     text(img_check_tbl.white_by_gray_abs(inormal),...
%         img_check_tbl.csf_by_gray_abs(inormal),...
%         img_check_tbl.study_ID(inormal))
%     text(img_check_tbl.white_by_gray_abs(iout),...
%         img_check_tbl.csf_by_gray_abs(iout),...
%         img_check_tbl.study_ID(iout),'Color','r')
%     xlabel('abs(white)/abs(gray)')
%     ylabel('abs(csf)/abs(gray)')
    
    % Label outlier data-points
    subplot(1,4,3)
    plot(img_check_tbl.mean_brain,img_check_tbl.mean_nobrain,'.')
    text(img_check_tbl.mean_brain(inormal),img_check_tbl.mean_nobrain(inormal),img_check_tbl.study_ID(inormal))
    text(img_check_tbl.mean_brain(iout),img_check_tbl.mean_nobrain(iout),img_check_tbl.study_ID(iout),'Color','r')
    xlabel('brain')
    ylabel('nobrain')

%     subplot(1,4,4)
%     plot(img_check_tbl.mean_brain_abs,img_check_tbl.mean_nobrain_abs,'.')
%     text(img_check_tbl.mean_brain_abs(inormal),img_check_tbl.mean_nobrain_abs(inormal),img_check_tbl.study_ID(inormal))
%     text(img_check_tbl.mean_brain_abs(iout),img_check_tbl.mean_nobrain_abs(iout),img_check_tbl.study_ID(iout),'Color','r')
%     xlabel('brain_abs')
%     ylabel('nobrain_abs')
    
print('By_study_tissue_and_brain_signal',gcf,'-dtiff');    
    
    
%Plot histogram of mahal values with threshold
% figure(2)
% hist(img_check_tbl.mahal_tissue)
% vline(mahal_outlr_tresh)

%Print tissue outlier suspects to console
disp(img_check_tbl.study_ID(img_check_tbl.tissue_outlier))


% %% Summarize variables for prediction BY STUDY
% img_check_vars={'grey','white','csf','brain','nobrain','AllImg_IQR'}; % select variables for which mahal should be computed
% img_check_tbl=varfun(@mean,df_pain,'InputVariables',img_check_vars,...
%     'GroupingVariables','study_ID')
% 
% tomahal={'mean_grey','mean_white','mean_csf'}; % select variables for which mahal should be computed
% img_check_tbl=[img_check_tbl,...
%              array2table(zscore(img_check_tbl{:,tomahal},[],2),...
%              'VariableNames',strcat('norm_',tomahal))];
% 
% Y=img_check_tbl{:,strcat('norm_',tomahal)};
% img_check_tbl.mahal=mahal(Y,mvnrnd(mean(Y),cov(Y),1000));
% img_check_tbl.img_p=normcdf(zscore(Y));
% 
% figure(1)
% plot(img_check_tbl.norm_mean_grey,img_check_tbl.norm_mean_white,'.')
% text(img_check_tbl.norm_mean_grey,img_check_tbl.norm_mean_white,img_check_tbl.study_ID)
% xlabel('grey')
% ylabel('white')
% 
% 
% figure(2)
% plot(img_check_tbl.norm_mean_grey,img_check_tbl.norm_mean_csf,'.')
% text(img_check_tbl.norm_mean_grey,img_check_tbl.norm_mean_csf,img_check_tbl.study_ID)
% xlabel('grey')
% ylabel('csf')
% 
% figure(3)
% plot(img_check_tbl.norm_mean_grey,img_check_tbl.norm_mean_white,'.')
% text(img_check_tbl.norm_mean_grey,img_check_tbl.norm_mean_white,img_check_tbl.study_ID)
% xlabel('grey')
% ylabel('white')
% 
% 
% 
% 
% %% Compute mahalanobi's distance by STUDY and CONDITION
% studies=unique(df_pain.study_ID);
% pain_img_check_vars={'NPSraw','MHEraw'};
% 
% df_paindf_pain.mahal=NaN(size(df_pain.grey));
% df_pain.img_p=NaN(length(df_pain.grey),length(img_check_vars));
% 
% %df_pain.mahalPainSignal=NaN(size(df_pain.grey));
% for i=1:length(studies)
%    :=strcmp(df_pain.study_ID,studies(i)); %create current study index
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
%              table(df_pain.study_ID(ioutliers),'VariableNames',{'subject'}),...
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
%    :=strcmp(df_pain.study_ID,studies(i)); 
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
%    :=strcmp(df_pain.study_ID,studies(i)); 
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
%    :=strcmp(df_pain.study_ID,studies(i)); 
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