

%% SAME AS SPM_random_effects, but with images where each voxel was scaled
% to its within-study SD. This is analog to the standardized effect sizes
% used in the GIV function and NOT analog to SPM, which scales all voxels
% to a single grand mean value)

%% Load df containing target images
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets';% Must be explicit path, as SPM's jobman does can't handle relative paths
df_path=fullfile(datapath,'data_frame.mat');
load(df_path,'df');

%% Create random-effects summary of pain>baseline images
% (averaged across placebo and control conditions)

% "2nd level analysis"
% > summarize all subjects of each study
%(note that calc_2nd_level applies grand mean scaling)
anapath_2nd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_2nd_level_study_summaries/random_std/pain';% Must be explicit path, as SPM's jobman does can't handle relative paths
for i=1:size(df,1)
    calc_2nd_level_no_scaling(fullfile(anapath_2nd,df.study_dir(i)),...
                   fullfile(datapath,df.full(i).mean_pla_con.std_norm_img));
end
% "3rd level analysis"
% > summarize studies
%(note that calc_3rd_level does not apply grand mean scaling)
anapath_3rd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_3rd_level_summary/random_std/pain';% Must be explicit path, as SPM's jobman does can't handle relative paths
calc_3rd_level(fullfile({anapath_3rd}),...
               fullfile(anapath_2nd,df.study_dir,'beta_0001.nii'));
% "3rd level analysis – permutation test"
calc_3rd_level_perm(fullfile({anapath_3rd},'/perm'),...
               fullfile(anapath_2nd,df.study_dir,'beta_0001.nii'));         
%% Create random-effects summary of placebo>control images

% "2nd level analysis"
% > summarize all subjects of each study
%(note that calc_2nd_level applies grand mean scaling)
anapath_2nd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_2nd_level_study_summaries/random_std/placebo';% Must be explicit path, as SPM's jobman does can't handle relative paths
for i=1:size(df,1)
    if ~isempty(df.full(i).pla_minus_con)
    calc_2nd_level_no_scaling(fullfile(anapath_2nd,df.study_dir(i)),...
                   fullfile(datapath,df.full(i).pla_minus_con.std_norm_img));
    else
    calc_2nd_level_between_no_scaling(fullfile(anapath_2nd,df.study_dir(i)),...
                   {fullfile(datapath,df.full(i).con.std_norm_img),...
                    fullfile(datapath,df.full(i).pla.std_norm_img)});
    end
end
% "3rd level analysis"
% > summarize studies
%(note that calc_3rd_level does not apply grand mean scaling)
anapath_3rd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_3rd_level_summary/random_std/placebo';% Must be explicit path, as SPM's jobman does can't handle relative paths
calc_3rd_level(fullfile({anapath_3rd}),...
               fullfile(anapath_2nd,df.study_dir,'con_0001.nii'));
calc_3rd_level_perm(fullfile({anapath_3rd},'/perm'),...
               fullfile(anapath_2nd,df.study_dir,'con_0001.nii'));  