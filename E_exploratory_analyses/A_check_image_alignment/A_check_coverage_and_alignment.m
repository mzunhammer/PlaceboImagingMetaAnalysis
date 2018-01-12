function A_check_coverage_and_alignment()
% Setup: Load df with paths and variables
clear
% Add folder with Generic Inverse Variance Methods Functions first
datapath='../../../datasets/';
load(fullfile(datapath,'data_frame.mat'))

% A) Check coverage across all studies (full sample)
% Note 1: Use mean_pla_con contrasts as these cover all images for placebo
% and control studies
% Note 2: use raw image (.img), as norm_img are already masked.
all_study_table=vertcat(df.full(:).mean_pla_con);
in_imgs=fullfile(datapath,all_study_table.img);
outfile='check_coverage_full_sample_pla.nii';
volume_coverage(in_imgs,fullfile('./results',outfile))

% B) Check coverage for each study (full sample)
 for i=1:size(df,1)
    in_imgs=fullfile(datapath,df.full(i).mean_pla_con.img);
    volume_coverage(in_imgs,fullfile('./results/',['coverage_',df.study_id{i},'.nii']))
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