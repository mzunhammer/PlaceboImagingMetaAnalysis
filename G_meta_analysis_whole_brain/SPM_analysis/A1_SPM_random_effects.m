

%% Load df containing target images
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets';% Must be explicit path, as SPM's jobman does can't handle relative paths
df_path=fullfile(datapath,'data_frame.mat');
load(df_path,'df');

%% Create random-effects summary of pain>baseline images
% (averaged across placebo and control conditions)

% "2nd level analysis"
% > summarize all subjects of each study
%(note that calc_2nd_level applies grand mean scaling)
anapath_2nd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_2nd_level_study_summaries/random/pain';% Must be explicit path, as SPM's jobman does can't handle relative paths
for i=1:size(df,1)
    calc_2nd_level(fullfile(anapath_2nd,df.study_dir(i)),...
                   fullfile(datapath,df.full(i).mean_pla_con.norm_img));
end
% "3rd level analysis"
% > summarize studies
%(note that calc_3rd_level does not apply grand mean scaling)
anapath_3rd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_3rd_level_summary/random/pain';% Must be explicit path, as SPM's jobman does can't handle relative paths
calc_3rd_level(fullfile({anapath_3rd}),...
               fullfile(anapath_2nd,df.study_dir,'beta_0001.nii'));
% "3rd level analysis – permutation test"
calc_3rd_level_perm(fullfile({anapath_3rd},'/perm'),...
               fullfile(anapath_2nd,df.study_dir,'beta_0001.nii'));         
%% Create random-effects summary of placebo>control images

% "2nd level analysis"
% > summarize all subjects of each study
%(note that calc_2nd_level applies grand mean scaling)
anapath_2nd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_2nd_level_study_summaries/random/placebo';% Must be explicit path, as SPM's jobman does can't handle relative paths
for i=1:size(df,1)
    if ~isempty(df.full(i).pla_minus_con)
    calc_2nd_level(fullfile(anapath_2nd,df.study_dir(i)),...
                   fullfile(datapath,df.full(i).pla_minus_con.norm_img));
    else
    calc_2nd_level_between(fullfile(anapath_2nd,df.study_dir(i)),...
                   {fullfile(datapath,df.full(i).con.norm_img),...
                    fullfile(datapath,df.full(i).pla.norm_img)});
    end
end
% "3rd level analysis"
% > summarize studies
%(note that calc_3rd_level does not apply grand mean scaling)
anapath_3rd='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_3rd_level_summary/random/placebo';% Must be explicit path, as SPM's jobman does can't handle relative paths
calc_3rd_level(fullfile({anapath_3rd}),...
               fullfile(anapath_2nd,df.study_dir,'con_0001.nii'));
calc_3rd_level_perm(fullfile({anapath_3rd},'/perm'),...
               fullfile(anapath_2nd,df.study_dir,'con_0001.nii'));  