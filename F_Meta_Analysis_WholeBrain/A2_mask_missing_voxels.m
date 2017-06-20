%% Run once to get a mask excluding all voxels where signal == 0 in more
% than X% of cases.
clear

null_trshld=0.1; %PROPORTION OF MISSING CASES NECESSARY TO EXCLUDE A VOXEL

% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/MontagePlot')
load('A1_Full_Sample_Img_Data.mat')

%% Masking on a by-study basis to detect outliers studies

% Loop to identify proportion of missing subjects at a given voxel
n_nan=NaN(length(df_full.studies),size(df_full.pla_img{1},2));
n_subj=NaN(length(df_full.studies),1);
for i=1:length(df_full.studies) % Calculate for all studies except...
    if df_full.consOnlyImg(i)==0 %...data-sets where only contrasts are available
        if df_full.BetweenSubject(i)==0 %Calculate for within-subject studies
           cdata=mean(cat(3,df_full.pla_img{i},df_full.con_img{i}),3); %if either pla or con image is nan, voxel is marked as nan
        elseif df_full.BetweenSubject(i)==1 %Calculate between-group studies
           cdata=[df_full.pla_img{i};df_full.con_img{i}];
        end
    end
    n_nan(i,:)=sum(isnan(cdata));
    n_subj(i,:)=size(cdata,1);
end

% Extra loop for (within-subject) studies where only
% pla>con contrasts are available (con_img is filled with nans)
conOnly=find(df_full.consOnlyImg==1);
for i=conOnly'
    cdata=df_full.pla_img{i};
    n_nan(i,:)=sum(isnan(cdata));
    n_subj(i,:)=size(cdata,1);
end
       
%Proportion subjects with nan at a given voxel
prop_nan_overall=sum(n_nan)/sum(n_subj);
%Proportion studies with nan at a given voxel
prop_nan_study_level=n_nan./n_subj;

 hist(prop_nan_overall,50);
 hold on
 vline(null_trshld)
 hold off
 
mask_exvoxels=prop_nan_overall<null_trshld;

df_full_masked=df_full;
df_full_masked.pla_img=cellfun(@(x) x(:,mask_exvoxels),df_full.pla_img,'UniformOutput',0);
df_full_masked.con_img=cellfun(@(x) x(:,mask_exvoxels),df_full.con_img,'UniformOutput',0);
df_full_masked.brainmask=mask_exvoxels;
save('A1_Full_Sample_Img_Data_Masked_10_percent.mat','df_full_masked');
printImage(mask_exvoxels,'../../pattern_masks/brainmask_logical_50.nii','./nii_results/Full_Sample_10_percent_mask')

%% Mask studies on study-level to check for outliers
for i = 1:length(df_full.studies)
    mask_exvoxels=prop_nan_study_level(i,:)<null_trshld;
    printImage(mask_exvoxels,'../../pattern_masks/brainmask_logical_50.nii',['./single_study_masks/', df_full.studies{i},'_10_percent_mask'])
end

% 'Atlas et al. 2012:';... well aligned
% 'Bingel et al. 2006:';... well aligned
% 'Bingel et al. 2011:';... well aligned
% 'Choi et al. 2011:';... looks strange at first sight as values outside of
% the brain are non-null. however, looking at single- subject images and
% a quick pain>no pain SPM second-level analysis it seems as if activity and brain are well
% aligned.
% 'Eippert et al. 2009:';... unmasked first-level stats activity well aligned, some images cropped at apex.
% 'Ellingsen et al. 2013:';... well aligned, temporal poles cropped
% 'Elsenbruch et al. 2012:';... well aligned, cropped apex in others
% 'Freeman et al. 2015:';... unmasked activity well aligned.
% 'Geuter et al. 2013:';... well aligned, cropped apex!
% 'Kessner et al. 2014:';... well aligned
% 'Kong et al. 2006:';... well aligned, some extinctinction near
% orbitofrontal
% 'Kong et al. 2009:';... well aligned, some extinctinction near
% orbitofrontal
% 'Lui et al. 2010:';... well aligned, some extinctinction near
% orbitofrontal
% 'Ruetgen et al. 2015:'... well aligned
% 'Schenk et al. 2015:'... well aligned, "flattened" apex, cropped with
% posterior tilted FOV
% 'Theysohn et al. 2009:';... well aligned, strong orbitofrontal signal
% extinctions
% 'Wager et al. 2004, Study 1:';...well aligned,some orbitofrontal extinction 
% 'Wager et al. 2004, Study 2:';...well aligned, but WHITE MATTER MASKED!
% 'Wrobel et al. 2014:'...well aligned
% 'Zeidan et al. 2015:';... unmasked, activity well aligned.

%%

load('A1_Conservative_Sample_Img_Data.mat')

n_nan=NaN(length(df_conserv.studies),size(df_conserv.pla_img{1},2));
n_subj=NaN(length(df_conserv.studies),1);
for i=1:length(df_conserv.studies) % Calculate for all studies except...
    if df_full.consOnlyImg(i)==0 %...data-sets where only contrasts are available
        if df_conserv.BetweenSubject(i)==0 %Calculate for within-subject studies
           cdata=mean(cat(3,df_conserv.pla_img{i},df_conserv.con_img{i}),3);
           % Note that no extra loop for (within-subject) studies where only
           % pla>con contrasts are available (con_img is filled with nans) is
           % not needed, since nanmean will yield a non-nan number for voxels
           % where pla_img is filled.
        elseif df_conserv.BetweenSubject(i)==1 %Calculate between-group studies
           cdata=[df_conserv.pla_img{i};df_conserv.con_img{i}];
        end
    end
    n_nan(i,:)=sum(isnan(cdata));
    n_subj(i,:)=size(cdata,1);
end

% Extra loop for (within-subject) studies where only
% pla>con contrasts are available (con_img is filled with nans)
conOnly=find(df_conserv.consOnlyImg==1);
for i=conOnly'
    cdata=df_conserv.pla_img{i};
    n_nan(i,:)=sum(isnan(cdata));
    n_subj(i,:)=size(cdata,1);
end


%Proportion subjects with nan at a given voxel
prop_nan_overall=sum(n_nan)/sum(n_subj);
%Proportion studies with nan at a given voxel
prop_nan_study_level=n_nan./n_subj;

conserv_mask_exvoxels=prop_nan_overall<null_trshld;

df_conserv_masked=df_conserv;
df_conserv_masked.pla_img=cellfun(@(x) x(:,conserv_mask_exvoxels),df_conserv.pla_img,'UniformOutput',0);
df_conserv_masked.con_img=cellfun(@(x) x(:,conserv_mask_exvoxels),df_conserv.con_img,'UniformOutput',0);
df_full_masked.brainmask=conserv_mask_exvoxels;

save('A1_Conservative_Sample_Img_Data_Masked_10_percent.mat','df_conserv_masked');
printImage(conserv_mask_exvoxels,'../../pattern_masks/brainmask_logical_50.nii','./nii_results/Conservative_Sample_10_percent_mask')




