clear

%% Load df containing target images
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets';% Must be explicit path, as SPM's jobman does can't handle relative paths
df_path=fullfile(datapath,'data_frame.mat');
load(df_path);
addpath('./')
%% Create random-effects summary of pain>baseline images
% (averaged across placebo and control conditions)

% "2nd level analysis"
% > summarize all subjects of each study
%(note that calc_2nd_level applies grand mean scaling)
anapath_2nd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_2nd_level_study_summaries/random_smoothed/pain';% Must be explicit path, as SPM's jobman does can't handle relative paths
for i=1:size(df,1)
    calc_2nd_level(fullfile(anapath_2nd,df.study_dir(i)),...
                   fullfile(datapath,df.full(i).mean_pla_con.smoothed_norm_img));
end
% "3rd level analysis"
% > summarize studies
%(note that calc_3rd_level does not apply grand mean scaling)
anapath_3rd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_3rd_level_summary/random_smoothed/pain';% Must be explicit path, as SPM's jobman does can't handle relative paths
calc_3rd_level(fullfile({anapath_3rd}),...
               fullfile(anapath_2nd,df.study_dir,'beta_0001.nii'));
% "3rd level analysis – permutation test"
%calc_3rd_level_perm(fullfile({anapath_3rd},'/perm'),...
%               fullfile(anapath_2nd,df.study_dir,'beta_0001.nii'));         
%% Create random-effects summary of placebo>control images

% "2nd level analysis"
% > summarize all subjects of each study
%(note that calc_2nd_level applies grand mean scaling)
anapath_2nd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_2nd_level_study_summaries/random_smoothed/placebo';% Must be explicit path, as SPM's jobman does can't handle relative paths
for i=1:size(df,1)
    if ~isempty(df.full(i).pla_minus_con)
    calc_2nd_level(fullfile(anapath_2nd,df.study_dir(i)),...
                   fullfile(datapath,df.full(i).pla_minus_con.smoothed_norm_img));
    else
    calc_2nd_level_between(fullfile(anapath_2nd,df.study_dir(i)),...
                   {fullfile(datapath,df.full(i).con.smoothed_norm_img),...
                    fullfile(datapath,df.full(i).pla.smoothed_norm_img)});
    end
end
% "3rd level analysis"
% > summarize studies
%(note that calc_3rd_level does not apply grand mean scaling)
anapath_3rd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_3rd_level_summary/random_smoothed/placebo';% Must be explicit path, as SPM's jobman does can't handle relative paths
calc_3rd_level(fullfile({anapath_3rd}),...
               fullfile(anapath_2nd,df.study_dir,'con_0001.nii'));
%calc_3rd_level_perm(fullfile({anapath_3rd},'/perm'),...
%               fullfile(anapath_2nd,df.study_dir,'con_0001.nii'));  

%% After completion get resulting smoothness estimates for pain>baseline images and add to df

%% Loop through studies, get smoothness estimates, add to df
n=size(df,1);
est_smoothness=NaN(n,3);
SPM_analysis_path='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_2nd_level_study_summaries/random_smoothed/pain'
for i=1:n
    load(fullfile(SPM_analysis_path,df.study_dir{i},'SPM.mat'))
    est_smoothness(i,:)=SPM.xVol.FWHM;
end
df.spatial_smoothing_FWHM_est_equalized=est_smoothness;