%% Script running all analyses of the placebo-meta-analysis,

% SPECIFY MANUALLY: Add analysis to workspace to make all functions available
analysispath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis'; % SPECIFY MANUALLY
addpath(genpath(analysispath));
% SPECIFY MANUALLY: Path where result figures should be saved
pubpath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/';
% SPECIFY MANUALLY: Path where the data-set rests
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets'; %MUST BE ABSOLUTE PATH. SPM and CANlab functions do not deal well with relative paths

%% A) import raw data and image paths into data-frame
% (creates: ../datasets/data_frame.mat)

% FOLDER: ./A_import/
A_create_study_overview_table(datapath);
B_run_all_single_imports(datapath);

%% B) define sample
% and a corresponding df

% FOLDER: ./B_define_samples/
A_run_all_single_condition_summaries(datapath);
B_select_for_meta_full_sample(datapath);
C_contrast_placebo_minus_control(datapath,'noimcalc');
D_contrast_placebo_and_control(datapath,'noimcalc');
% run('./B_define_samples/E_select_for_meta_conservative_sample.m')

%% C) preprocess images

% FOLDER: ./C_prepro_images/
A_equalize_image_size_and_mask(datapath,'noimcalc'); % Required for all analyses
%TODO B_scale_voxel_values_by_sd(datapath)'  % Required for SPM analysis
%TODO C_equalize_smoothing(datapath) % Optional: Just to check if smoothness affects results

%% Apply all Masks (NPS, MHE, Tissue Probability-Maps, Brain-Masks)
A_apply_tissuemasks(datapath);      %Calculate tissue-signal levels analog to other masks, add to df, used for outlier screening
B_apply_NPS(datapath);              %Apply NPS study-wise, add to df, save new df as study_NPS
C_apply_MHE(datapath);        %Apply MHE (whole brain-analog of the NPS published in Zunhammer et al. 2016, Scientific Reports)
D_apply_SIIPS(datapath);      %Apply SIIPS mask by Woo 2017, Nature Communications

%% Exploratory Analyses

% Check image alignment
% FOLDER ./E_exploratory_analyses/A_check_image_alignment
A_check_coverage_and_alignment(datapath);
B_check_coverage_NPS();

% Check for outliers
% FOLDER ./E_exploratory_analyses/B_outlier_search/
A_by_study_tissue_signal_outlier_detection(datapath);   % Refacturing incomplete: absolute  tissue signal estimates missing.
B_by_subject_tissue_signal_outlier_detection(datapath); % Refacturing incomplete: absolute  tissue signal estimates missing.
C_designate_excluded(datapath);                         % Designated outliers by behavior and extreme imaging data
% Also see report of visual follow-up: Outlier_Subject_Checks.xlsx

% Calculate overall demographic and behavioral results for tabulation
% FOLDER ./E_exploratory_analyses/C_descriptive_results
D_demographics(datapath);

%% Generic Inverse Variance (GIV) meta-analysis
% For NPS paper, main outcomes NPS, pain ratings

%First run unit-test to assert validity of GIV functions:
% FOLDER ./GIV_functions
validate_GIV();

%Assemble full data-set and inclusive/conservative data-set
% FOLDER ./F_NPS_meta_analysis_placebo
A_meta_analysis_all(datapath,pubpath);
B_meta_analysis_conservative(datapath,pubpath);
%C_meta_analysis_responder(datapath,pubpath) %Refacturing incomplete: no responder selection, yet
% Correlation NPS vs Ratings
D_meta_placebo_correlation_NPS_vs_ratings(datapath,pubpath);
E_meta_analysis_all_subregions(datapath,pubpath);
F_funnel_plot_pain_ratings(datapath,pubpath);

%% Whole brain analysis
% FOLDER ./G_meta_analysis_whole_brain/GIV
% there are is also a SPM version, but I've opted for the GIV since SPM
% analysis is not native to meta-analysis

A_vectorize_all(datapath)
B_mask_missing_voxels(datapath)
C_winsorize(datapath)

A_WB_meta_analysis_all(datapath)
B_WB_meta_analysis_permute_pain(datapath,1000)
C_WB_meta_analysis_permute_placebo(datapath,1000)
D_WB_meta_analysis_p_values(datapath)

%% Meta-analysis validation paper (Ratings, NPS)
% 
% % Validation findings NPS (all inclusive)
% % Pain vs baseline
% run('./F_NPS_Meta_Analysis_Validation/A1_NPS_pain_vs_baseline.m')
% run('./F_NPS_Meta_Analysis_Validation/A2_NPS_pain_vs_baseline_outlier_excluded.m')
% 
% % Sequence effects and reliability
% run('./F_NPS_Meta_Analysis_Validation/B1_NPS_sequence_effects.m')
% run('./F_NPS_Meta_Analysis_Validation/B1_NPS_reliability.m')
% 
% % High pain vs low pain
% run('./F_NPS_Meta_Analysis_Validation/C1_NPS_hi_vs_lo_pain_all.m')
% run('./F_NPS_Meta_Analysis_Validation/C2_NPS_hi_vs_lo_pain_wo_outlier.m')
% 
% % Low pain effects
% run('./F_NPS_Meta_Analysis_Validation/D1_NPS_lo_pain_vs_baseline_all.m')
% 
% % Medications effects
% run('./F_NPS_Meta_Analysis_Validation/E1_NPS_medication_effects.m')
% run('./F_NPS_Meta_Analysis_Validation/E2_rating_medication_effects.m')

%% 

