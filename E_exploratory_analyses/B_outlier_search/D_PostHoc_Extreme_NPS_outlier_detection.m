

%% Load df_pain
datapath='../../../Datasets/';
df_path='AllData.mat';
load(fullfile(datapath,df_path));

%Variables to be used for outlier prediction
img_check_vars={'NPSraw'}; %  select variables for which mahal should be computed
%Limit outlier prediction to images representing pain (anticipation etc may be scaled differently)
df_pain=df(logical(df.pain),:);

%% Summarize variables for outlierdetection BY SUBJECT
df_by_subID=varfun(@mean,df_pain,'InputVariables',img_check_vars,...
    'GroupingVariables','subID')
% Re-Add studyID
stID_raw=regexp(df_by_subID.subID,'_','split');      
df_by_subID.studyID=cellfun(@(x) x(1),stID_raw);
studies=unique(df_by_subID.studyID);
%% Compute probability on normal distribution of NPS values by-study
df_by_subID.p_NPSraw=NaN(length(df_by_subID.mean_NPSraw),1)
for i=1:length(studies)
    istudy=strcmp(df_by_subID.studyID,studies(i)); %create current study index
    Y=df_by_subID{istudy,'mean_NPSraw'};

    mu = nanmean(Y);
    sigma = nanstd(Y);
    pd = makedist('Normal',mu,sigma);
    df_by_subID.p_NPSraw(istudy)= pdf(pd,Y);
end

    a=figure(i);
    figure('Position', [100, 100, 400*4, 400]);
    axes
    axis('equal');
    
    subplot(1,4,1)
    plot(df_by_subID.white_by_gray(istudy),...
        df_by_subID.csf_by_gray(istudy),...
        '.')
    % Label normal data-points
    inormal=istudy&~df_by_subID.NPS_outlier;
    iout=istudy&df_by_subID.NPS_outlier;
    text(df_by_subID.white_by_gray(inormal),...
        df_by_subID.csf_by_gray(inormal),...
        df_by_subID.subID(inormal))
    text(df_by_subID.white_by_gray(iout),...
        df_by_subID.csf_by_gray(iout),...
        df_by_subID.subID(iout),'Color','r')
    xlabel('white/gray')
    ylabel('csf/gray')
print([studies{i},'_NPS_raw'],gcf,'-dtiff');    

end
close all
%Plot histogram of mahal values with threshold
figure;
hist(df_by_subID.mahal_NPS);
vline(mahal_outlr_tresh);

%Print tissue outlier suspects to console
disp(['Outlier_Suspects:'; df_by_subID.subID(df_by_subID.NPS_outlier)]);
