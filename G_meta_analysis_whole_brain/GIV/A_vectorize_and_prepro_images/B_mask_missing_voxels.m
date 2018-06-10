function B_mask_missing_voxels(datapath,varargin)
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,['(?<!^)',filesep], 'DelimiterType','RegularExpression');
whole_brain_path=fullfile(splitp{1:end-1});
results_path=fullfile(whole_brain_path,'nii_results');
mask_path=fullfile(splitp{1:end-4},'pattern_masks','brainmask_logical_50.nii');
%% Run once to get a mask excluding all voxels where signal == 0 in more
% than X% of cases.
null_trshld=0.1; %PROPORTION OF MISSING CASES NECESSARY TO EXCLUDE A VOXEL

% Add folder with Generic Inverse Variance Methods Functions first
if strcmp(varargin,'conservative')
    fname_dfv='vectorized_images_conservative';
else
    fname_dfv='vectorized_images_full';
end
load(fullfile(datapath,fname_dfv),'dfv');
load(fullfile(datapath,'data_frame'),'df');

%% Masking on a by-study basis to detect outliers studies
% Loop to identify proportion of missing subjects at a given voxel
n_nan=NaN(size(df,1),size(dfv.pain_placebo{1},2));
n_subj=NaN(size(df,1),1);
for i=1:size(df,1) % Calculate for all studies except...
    if df.contrast_imgs_only(i)==0 %...data-sets where only contrasts are available
        if strcmp(df.study_design{i},'within') %Calculate for within-subject studies
           cdata=mean(cat(3,dfv.pain_placebo{i},dfv.pain_control{i}),3); %if either pla or con image is nan, voxel is marked as nan
        elseif strcmp(df.study_design{i},'between') %Calculate between-group studies
           cdata=[dfv.pain_placebo{i};dfv.pain_control{i}];
        end
    end
    n_nan(i,:)=sum(isnan(cdata));
    n_not_nan(i,:)=sum(~isnan(cdata));
    n_subj(i,:)=size(cdata,1);
end

% Extra loop for (within-subject) studies where only
% pla>con contrasts are available (con_img is filled with nans)
conOnly=find(df.contrast_imgs_only==1);
for i=conOnly'
    cdata=dfv.placebo_minus_control{i};
    n_nan(i,:)=sum(isnan(cdata));
    n_not_nan(i,:)=sum(~isnan(cdata));
    n_subj(i,:)=size(cdata,1);
end
       
%For each study: Proportion of participants with nan and not-nan at any given voxel
prop_nan_study_level=n_nan./n_subj;
prop_not_nan_study_level=n_not_nan./n_subj;

%For each study: Exclude (set to all-nan) studies with less than 3 not-nan
%subjects. ( those will be excluded anyway when calculating the meta-stats, as
% correlations/error estimates based on 3 participants are unreliable and will produce outlier voxels)

too_few_study_level=n_not_nan<=3; %select voxels where n<3 on study-level
n_subj_matrix=repmat(n_subj,1,size(n_nan,2)); %create helper-matrix with max n of participants

n_nan_corrected=n_nan; %copy n_nan...   
n_nan_corrected(too_few_study_level)=n_subj_matrix(too_few_study_level); %...replace voxels with too few subjects on study level

%Calculate overall proportion of subjects with nan at a given voxel (subjects from voxels with too few subjects at study-level excluded)
prop_nan_overall=sum(n_nan_corrected)/sum(n_subj);


 hist(prop_nan_overall,50);
 hold on
 vline(null_trshld);
 hold off
 
mask_exvoxels=prop_nan_overall<null_trshld;

dfv_masked=dfv;
for i=1:size(df,1)
    if ~isempty(dfv.pain_placebo{i})
    dfv_masked.pain_placebo{i}=dfv.pain_placebo{i}(:,mask_exvoxels);
    end
    if ~isempty(dfv.pain_control{i})
    dfv_masked.pain_control{i}=dfv.pain_control{i}(:,mask_exvoxels);
    end
    if ~isempty(dfv.placebo_and_control{i})
    dfv_masked.placebo_and_control{i}=dfv.placebo_and_control{i}(:,mask_exvoxels);
    end
    if ~isempty(dfv.placebo_minus_control{i})
    dfv_masked.placebo_minus_control{i}=dfv.placebo_minus_control{i}(:,mask_exvoxels);
    end
end
dfv_masked.brainmask=mask_exvoxels;
dfv_masked.brainmask3d=vector2img(mask_exvoxels,mask_path);

save(fullfile(datapath,[fname_dfv, '_masked_10_percent.mat']),'dfv_masked','-v7.3');
delete(fullfile(datapath,[fname_dfv,'.mat'])); %The unmasked file is huge (>2GB) and only needed once. Delete to free diskspace.

if strcmp(varargin,'conservative')
    print_image(mask_exvoxels,mask_path,fullfile(results_path,'conservative_masked_10_percent'))

else
    print_image(mask_exvoxels,mask_path,fullfile(results_path,'full_masked_10_percent'))
end
%% Mask studies on study-level to check for outliers
for i = 1:size(df,1)
    mask_exvoxels=prop_nan_study_level(i,:)<null_trshld;
    print_image(mask_exvoxels,mask_path,fullfile(whole_brain_path,'single_study_masks', [df.study_ID{i},'_10_percent_mask']));
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
% extinctions, some maps look like there are  unaccounted movement artifacts in
% the parietal cortex.
% 'Wager et al. 2004, Study 1:';...well aligned,some orbitofrontal extinction 
% 'Wager et al. 2004, Study 2:';...well aligned, but WHITE MATTER MASKED!
% 'Wrobel et al. 2014:'...well aligned
% 'Zeidan et al. 2015:';... unmasked, activity well aligned.
end