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
df_by_subID=varfun(@mean,df_pain,'InputVariables',img_check_vars,...
    'GroupingVariables','subID')
% Re-Add studyID
stID_raw=regexp(df_by_subID.subID,'_','split');      
df_by_subID.studyID=cellfun(@(x) x(1),stID_raw);
studies=unique(df_by_subID.studyID);
%% Compute mahal for and plot
%  relative tissue intensities and brain vs no-brain intensity by-study
df_by_subID.white_by_gray=df_by_subID.mean_white./df_by_subID.mean_grey;
df_by_subID.csf_by_gray=df_by_subID.mean_csf./df_by_subID.mean_grey;
df_by_subID.nobrain_by_brain=df_by_subID.mean_nobrain./df_by_subID.mean_brain;

tomahal={'white_by_gray','csf_by_gray','nobrain_by_brain'}; 
% Mahalanobi's distance (D) follows a chi-square distribution.
% Calculate outlier-threshold as value of D that is less likely than 1:100
% (D was calculated by-study and by-condition... since all studies except rütgen et al had <100 participants values with a prob <1:100 are suspicious)
mahal_outlr_tresh=chi2inv(.99, length(tomahal));
df_by_subID.mahal_tissue=NaN(height(df_by_subID),1);
df_by_subID.tissue_outlier=logical(zeros(height(df_by_subID),1));
for i=1:length(studies)
    istudy=strcmp(df_by_subID.studyID,studies(i)); %create current study index
    Y=df_by_subID{istudy,tomahal};
    df_by_subID.mahal_tissue(istudy)=mahal(Y,mvnrnd(mean(Y),cov(Y),1000));
    %df_by_subID.img_p(istudy)=normcdf(zscore(Y));
    df_by_subID.tissue_outlier(istudy)=df_by_subID.mahal_tissue(istudy)>mahal_outlr_tresh;
    
    a=figure(i);
    subplot(1,2,1)
    plot(df_by_subID.white_by_gray(istudy),...
        df_by_subID.csf_by_gray(istudy),...
        '.')
    % Label normal data-points
    inormal=istudy&~df_by_subID.tissue_outlier;
    iout=istudy&df_by_subID.tissue_outlier;
    text(df_by_subID.white_by_gray(inormal),...
        df_by_subID.csf_by_gray(inormal),...
        df_by_subID.subID(inormal))
    text(df_by_subID.white_by_gray(iout),...
        df_by_subID.csf_by_gray(iout),...
        df_by_subID.subID(iout),'Color','r')
    xlabel('white/gray')
    ylabel('csf/gray')
    % Label outlier data-points
    subplot(1,2,2)
    plot(df_by_subID.mean_brain(istudy),df_by_subID.mean_nobrain(istudy),'.')
    text(df_by_subID.mean_brain(inormal),df_by_subID.mean_nobrain(inormal),df_by_subID.subID(inormal))
    text(df_by_subID.mean_brain(iout),df_by_subID.mean_nobrain(iout),df_by_subID.subID(iout),'Color','r')
    xlabel('brain')
    ylabel('nobrain')
end

%Plot histogram of mahal values with threshold
figure
hist(df_by_subID.mahal_tissue)
vline(mahal_outlr_tresh)

%Print tissue outlier suspects to console
disp(df_by_subID.subID(df_by_subID.tissue_outlier))