function A_check_coverage_and_alignment(datapath)
% Setup: Load df with paths and variables
load(fullfile(datapath,'data_frame.mat'),'df')
[currpath,~,~]=fileparts(mfilename('fullpath'));

% A) Check coverage across all studies (full sample)
% Note 1: Use mean_pla_con contrasts as these cover all images for placebo
% and control studies
% Note 2: use raw image (.img), as norm_img are already masked.
df_all_subs=vertcat(df.subjects{:});
df_all_imgs=vertcat(df_all_subs.placebo_and_control{:});

in_imgs=fullfile(datapath,df_all_imgs.img);
outfile='check_coverage_full_sample_pla.nii';
volume_coverage(in_imgs,fullfile(currpath,'results',outfile))

% B) Check coverage for each study (full sample)
 for i=1:size(df,1)
    curr_study_df=df.subjects{i};
    curr_contrast_df=vertcat(curr_study_df.placebo_and_control{:});
    in_imgs=fullfile(datapath,curr_contrast_df.img);
    volume_coverage(in_imgs,fullfile(currpath,'/results/',['coverage_',df.study_ID{i},'.nii']))
 end
 
% Descriptive summary:

% 1.) For the FSL studies (Choi, Ellingsen, Zeidan), coverage is larger than
% the MNI152 brain template. It seems like as if brain & skull are covered.
% However, this is not due to false normalization ("inflated brains"), since
% the 2nd level SPM pain>baseline analysis clearly shows that the main
% activations are clearly within the skull and at the expected places
% (insula, sII), while estimates in the periphery are negligible.
% 2.) Similarly, coverage/registration for Atlas and Freeman have to be
% checked looking at the pain>baseline analysis, as the coverage includes
% the FOV, not just the brains.
% 3.) Wager_Michigan excluded white matter.
% 4.) In several studies some participants are missing the most superior
% part of the brain (likely limited FOV, e.g. see Geuter) and some participants
% are missing the orbitofrontal cortex (likely signal extinction artifacts, e.g.
% see: Theysohn et al.)
end