function B_WB_meta_analysis_permutate_pain(datapath,n_perms)
%% Create permuted sample for thresholding meta-analysis maps
% Script analog to the full meta-analysis of NPS results
% for creating a permuted (null) distribution of statistics
% Duration for 1000 permutations: 3 hours!
% smallest p possible is 1/n_perms

p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
whole_brain_path=fullfile(filesep,splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');

load_a=load(fullfile(datapath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
load_b=load(fullfile(datapath,'data_frame'),'df');
dfv_masked=load_a.dfv_masked; % Cludge necessary for parfor
df=load_b.df; % Cludge necessary for parfor
clear load_a load_b
%% Meta-Analysis for FULL BRAIN ANALYSIS
g_z_fixed=NaN(n_perms,sum(dfv_masked.brainmask));
g_z_random=NaN(n_perms,sum(dfv_masked.brainmask));
g_het=NaN(n_perms,sum(dfv_masked.brainmask));

tic
h = waitbar(0,'Permuting pain...');
for p=1:n_perms %exchange parfor with for if parallel processing is not possible
    % Shuffle pain contrast signs 
    curr_dfv_null=relabel_pain_for_perm(df,dfv_masked);
    % Analyze as in original
    curr_null_stats_voxels_pain=create_meta_stats_voxels_pain(df,curr_dfv_null); 
    % Summarize
    curr_perm_summary_stats=GIV_summary(curr_null_stats_voxels_pain,'g');           % use output-argument to only compute stats for "g"
    % Obtained smoothed error image and smoothed z-Distribution
    curr_perm_summary_stats.g=smooth_SE(curr_perm_summary_stats.g,dfv_masked.brainmask3d);

    g_z_fixed(p,:)=curr_perm_summary_stats.g.fixed.z_smooth;
    g_z_random(p,:)=curr_perm_summary_stats.g.random.z_smooth;
    g_het(p,:)=curr_perm_summary_stats.g.heterogeneity.chisq;
    waitbar(p / n_perms)
end
close(h) 

%% Add permuted null-distributions to statistical summary struct
load(fullfile(results_path,'WB_summary_pain_full.mat'),...
    'summary_pain');
summary_pain.g.fixed.perm.z_dist=g_z_fixed;
summary_pain.g.random.perm.z_dist=g_z_random;
summary_pain.g.heterogeneity.perm.chi_dist=g_het;
%% Add smoothened errors and pseudo-z to statistical summary struct
summary_pain.g=smooth_SE(summary_pain.g,dfv_masked.brainmask3d);

%% Save results in struct
save(fullfile(results_path,'WB_summary_pain_full.mat'),...
    'summary_pain','-append');