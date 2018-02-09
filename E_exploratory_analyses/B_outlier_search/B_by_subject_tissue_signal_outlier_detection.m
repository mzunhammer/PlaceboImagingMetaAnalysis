function B_by_subject_tissue_signal_outlier_detection(datapath)
%% CAVE: THIS FUNCTION IS STILL IN THE PROCESS OF REFACTURING:
% Absolute tissue signal estimates not yet added.

p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
outdir=fullfile(p,'results');


%% Load df_pain
df_path='data_frame.mat';
load(fullfile(datapath,df_path));
%Designate variables to be selected  for outlier prediction
img_check_vars={'grey','white','csf','brain','nobrain'}; %  select variables for which mahal should be computed, optional: 'grey_abs','white_abs','csf_abs',,'brain_abs','nobrain_abs'

%% Get all placebo_and_control contrast estimates in one table
dfl=[];
for i=1:size(df,1)
    curr_study=df.subjects{i}.placebo_and_control;
    curr_study=vertcat(curr_study{:});
    curr_study.study_ID=repmat(df.study_ID(i),size(curr_study,1),1);
    dfl=[dfl;curr_study];
end
%  relative tissue intensities and brain vs no-brain intensity by-study
dfl.white_by_gray=dfl.white./dfl.grey;
dfl.csf_by_gray=dfl.csf./dfl.grey;
dfl.nobrain_by_brain=dfl.nobrain./dfl.brain;

% dfl.white_by_gray_abs=dfl.white_abs./dfl.grey_abs;
% dfl.csf_by_gray_abs=dfl.csf_abs./dfl.grey_abs;
% dfl.nobrain_by_brain_abs=dfl.nobrain_abs./dfl.brain_abs;

%% Compute mahal
tomahal={'white_by_gray','csf_by_gray','nobrain_by_brain'}; %,'white_by_gray_abs','csf_by_gray_abs','nobrain_by_brain_abs'
% Mahalanobi's distance (D) follows a chi-square distribution.
% Calculate outlier-threshold as value of D that is less likely than 1:100
% (D was calculated by-study and by-condition... since all studies except r?tgen et al had <100 participants values with a prob <1:100 are suspicious)
mahal_outlr_tresh=chi2inv(.999, length(tomahal));
dfl.mahal_tissue=NaN(height(dfl),1);
dfl.tissue_outlier=logical(zeros(height(dfl),1));
Y=dfl{:,tomahal};
dfl.mahal_tissue=mahal(Y,mvnrnd(mean(Y),cov(Y),1000));
dfl.tissue_outlier=dfl.mahal_tissue>mahal_outlr_tresh;


%% Plots   
figure('Position', [100, 100, 400*4, 400]);
axes
axis('equal');
subplot(1,4,1)
plot(dfl.white_by_gray,...
    dfl.csf_by_gray,...
    '.')
% Label normal data-points
inormal=~dfl.tissue_outlier;
iout=dfl.tissue_outlier;
text(dfl.white_by_gray(inormal),...
    dfl.csf_by_gray(inormal),...
    dfl.sub_ID(inormal))
text(dfl.white_by_gray(iout),...
    dfl.csf_by_gray(iout),...
    dfl.sub_ID(iout),'Color','r')
xlabel('white/gray')
ylabel('csf/gray')

%     subplot(1,4,2)
%     plot(dfl.white_by_gray_abs,...
%         dfl.csf_by_gray_abs,...
%         '.')
%     % Label normal data-points
%     inormal=~dfl.tissue_outlier;
%     iout=dfl.tissue_outlier;
%     text(dfl.white_by_gray_abs(inormal),...
%         dfl.csf_by_gray_abs(inormal),...
%         dfl.sub_ID(inormal))
%     text(dfl.white_by_gray_abs(iout),...
%         dfl.csf_by_gray_abs(iout),...
%         dfl.sub_ID(iout),'Color','r')
%     xlabel('abs(white)/abs(gray)')
%     ylabel('abs(csf)/abs(gray)')

% Label outlier data-points
subplot(1,4,3)
plot(dfl.brain,dfl.nobrain,'.')
text(dfl.brain(inormal),dfl.nobrain(inormal),dfl.sub_ID(inormal))
text(dfl.brain(iout),dfl.nobrain(iout),dfl.sub_ID(iout),'Color','r')
xlabel('brain')
ylabel('nobrain')

set(gcf,'Name','Global outlier plots')
%     subplot(1,4,4)
%     plot(dfl.brain_abs,dfl.nobrain_abs,'.')
%     text(dfl.brain_abs(inormal),dfl.nobrain_abs(inormal),dfl.sub_ID(inormal))
%     text(dfl.brain_abs(iout),dfl.nobrain_abs(iout),dfl.sub_ID(iout),'Color','r')
%     xlabel('brain_abs')
%     ylabel('nobrain_abs')

print(fullfile(outdir,'global_tissue_and_brain_signal_plot'),gcf,'-dtiff');
close all
%% Plot histogram of mahal values with threshold
figure('Name','Global outlier histogram')
hist(dfl.mahal_tissue,100);
vline(mahal_outlr_tresh);
print(fullfile(outdir,'global_tissue_and_brain_signal_histogram'),gcf,'-dtiff');    

%Print tissue outlier suspects to console
disp(['Outlier_Suspects:'; dfl.sub_ID(dfl.tissue_outlier)]);
close all
%%  BY-STUDY VERSION
for i=1:size(df,1)
    istudy=strcmp(dfl.study_ID,df.study_ID(i)); %create current study index
    Y=dfl{istudy,tomahal};
    dfl.mahal_tissue_by_study(istudy)=mahal(Y,mvnrnd(nanmean(Y),nancov(Y),1000));
    %dfl.img_p(istudy)=normcdf(zscore(Y));
    dfl.tissue_outlier_by_study(istudy)=dfl.mahal_tissue_by_study(istudy)>mahal_outlr_tresh;
    figure('Position', [100, 100, 400*4, 400]);
    axes
    axis('equal');
    
    subplot(1,4,1)
     
    plot(dfl.white_by_gray(istudy),...
        dfl.csf_by_gray(istudy),...
        '.')
    % Label normal data-points
    inormal=istudy&~dfl.tissue_outlier_by_study;
    iout=istudy&dfl.tissue_outlier_by_study;
    text(dfl.white_by_gray(inormal),...
        dfl.csf_by_gray(inormal),...
        dfl.sub_ID(inormal))
    text(dfl.white_by_gray(iout),...
        dfl.csf_by_gray(iout),...
        dfl.sub_ID(iout),'Color','r')
    xlabel('white/gray')
    ylabel('csf/gray')
    
%     subplot(1,4,2)
%     plot(dfl.white_by_gray_abs(istudy),...
%         dfl.csf_by_gray_abs(istudy),...
%         '.')
%     % Label normal data-points
%     inormal=istudy&~dfl.tissue_outlier_by_study;
%     iout=istudy&dfl.tissue_outlier_by_study;
%     text(dfl.white_by_gray_abs(inormal),...
%         dfl.csf_by_gray_abs(inormal),...
%         dfl.sub_ID(inormal))
%     text(dfl.white_by_gray_abs(iout),...
%         dfl.csf_by_gray_abs(iout),...
%         dfl.sub_ID(iout),'Color','r')
%     xlabel('abs(white)/abs(gray)')
%     ylabel('abs(csf)/abs(gray)')
    
    % Label outlier data-points
    subplot(1,4,3)
    plot(dfl.brain(istudy),dfl.nobrain(istudy),'.')
    text(dfl.brain(inormal),dfl.nobrain(inormal),dfl.sub_ID(inormal))
    text(dfl.brain(iout),dfl.nobrain(iout),dfl.sub_ID(iout),'Color','r')
    xlabel('brain')
    ylabel('nobrain')

%     subplot(1,4,4)
%     plot(dfl.brain_abs(istudy),dfl.nobrain_abs(istudy),'.')
%     text(dfl.brain_abs(inormal),dfl.nobrain_abs(inormal),dfl.sub_ID(inormal))
%     text(dfl.brain_abs(iout),dfl.nobrain_abs(iout),dfl.sub_ID(iout),'Color','r')
%     xlabel('brain_abs')
%     ylabel('nobrain_abs')
set(gcf,'Name',['Outlier plot for ' df.study_ID{i}])
print(fullfile(outdir,[df.study_ID{i},'_tissue_and_brain_signal']),gcf,'-dtiff');    
close all
end
%close all

