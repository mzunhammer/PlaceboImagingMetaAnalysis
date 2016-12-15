clear

% Setup: Load df with paths and variables
datapath='../../Datasets';
load(fullfile(datapath,'AllData.mat'));
%% Step 1: Pre-select volumes
% limiting the amount of data is key for analysis

% function reduceddf = dfselect(df,'PainVsNoPain','PainPlaceboControl')

%Basic

%'Atlas'
% idf(:,1)    =(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation')));
% idf(:,end+1)=(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_ExpectationPeriod')));
% idf(:,end+1)=(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation')));
% idf(:,end+1)=(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_ExpectationPeriod')));
% 
% idf(:,end+1)=(strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_R')));
% idf(:,end+1)=(strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_R')));
% idf(:,end+1)=(strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_L')));
% idf(:,end+1)=(strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_L')));
% 
% idf(:,end+1)=(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp'));
% idf(:,end+1)=(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*')));
% idf(:,end+1)=(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*')));
% 
% idf(:,end+1)=(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline')));
% idf(:,end+1)=(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline')));
% 
idf(:,1)=(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control')));
idf(:,end+1)=(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo')));
% 
% idf(:,end+1)=(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia')));
% idf(:,end+1)=(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia')));
% 
% idf(:,end+1)=(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain')));
% idf(:,end+1)=(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain')));
% 
% idf(:,end+1)=(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong'));
% idf(:,end+1)=(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl'));
% idf(:,end+1)=(strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg'));
% idf(:,end+1)=(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain'));
% idf(:,end+1)=(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control'));
% idf(:,end+1)=(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group'));
% idf(:,end+1)=(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_control'));
% idf(:,end+1)=(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_placebo'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain'));
% idf(:,end+1)=(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'control_pain'));
% idf(:,end+1)=(strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'placebo_pain'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'wager_princeton')&strcmp(df.cond,'(intense-none)control-placebo'));
% idf(:,end+1)=(strcmp(df.studyID,'wager_princeton')&strcmp(df.cond,'intense-none'));
% 
% idf(:,end+1)=(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline')));
% idf(:,end+1)=(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline')));

% idf(:,1)=(strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pla>Control within painful series'));
% idf(:,end+1)=(strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pain>NoPain controlling for placebo&interaction'));

% collect selectors
idf=logical(sum(idf,2));
% reduce df
df=df(idf,:);

%% Step 2: Import all images in 2d vector
%% USE THE IMAGES (r attached to name) THAT WERE EQUALZED IN DIMENSIONS WITH A_Equalize_Image_Size_and_Mask.m

% Load mask
maskheader=spm_vol('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets/brainmask_logical.nii,1');
mask=logical(spm_read_vols(maskheader));
masking=mask(:);

%Load image headers
images=fullfile(datapath,df.img);
for i=1:length(images)
    [fpath,filename,ext]=fileparts(images{i});
    r_images{i,1}=fullfile(fpath,['r',filename,ext]);
end

headers=spm_vol(r_images);
nimg=length(headers);
%Preallocate target matrix
Y=NaN(nimg,length(masking));
tic
h = waitbar(0,'Reading volumes, reslicing, placing in Y-matrix')
for i=1:nimg
    %Load image data
    [currdat,~]=spm_read_vols(headers{i});
    Y(i,:)=currdat(:)';
    waitbar(i / nimg)
end
close(h)
toc/60

% Display NaN-Voxels(Vertical lines indicate import problems
imagesc(isnan(Y))
% Replace NaN-Voxels with 0
Y(isnan(Y))=0;

%Image-wise standardization (necessary??)
%tic
%Y=zscore(Y,[ ],2);
%toc/60

save(fullfile(datapath,'dfUnMasked_Ellingsen_BasicImg'),'df','Y','-v7.3');