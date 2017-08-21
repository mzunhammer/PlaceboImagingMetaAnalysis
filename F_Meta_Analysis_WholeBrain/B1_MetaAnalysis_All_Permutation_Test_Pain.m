%% Meta-Analysis for FULL BRAIN ANALYSIS
% Script analog to the full meta-analysis of NPS results
% for creating a permuted (null) distribution of statistics
% Duration for 1000 permutations (with two parpools): ~160 minutes! Size of saved distribution is ~6 GB
% 
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
%% Create permuted sample for thresholding meta-analysis maps
tic
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')

n_perms=2000; %number of permutations smallest p possible is 1/n_perms

g_min_z_fixed=NaN(n_perms,1);
g_max_z_fixed=NaN(n_perms,1);
g_min_z_random=NaN(n_perms,1);
g_max_z_random=NaN(n_perms,1);
g_het_max_chi=NaN(n_perms,1);

parfor p=1:n_perms %exchange parfor with for if parallel processing is not possible
    % Shuffle placebo/baseline labels 
    curr_df_null=relabel_pain_for_perm(df_full_masked);
    
    % Analyze as in original
    curr_null_stats_voxels_pain=create_meta_stats_voxels_pain(curr_df_null);
    
    % Summarize
    curr_perm_summary_stats=GIVsummary(curr_null_stats_voxels_pain,'g');           % use output-argument to only compute stats for "g"

    g_min_z_fixed(p)=min(curr_perm_summary_stats.g.fixed.z);
    g_max_z_fixed(p)=max(curr_perm_summary_stats.g.fixed.z);
    g_min_z_random(p)=min(curr_perm_summary_stats.g.random.z);
    g_max_z_random(p)=max(curr_perm_summary_stats.g.random.z);
    g_het_max_chi(p)=max(curr_perm_summary_stats.g.heterogeneity.chisq);
end

toc
%% Create thresholds:

% Add permutation summary to statistical summary struct
load('B1_Full_Sample_Summary_Pain.mat')
summary_pain.g.fixed.perm.min_z=quantile(g_min_z_fixed,0.025); %two-tailed!
summary_pain.g.fixed.perm.max_z=quantile(g_max_z_fixed,0.975); %two-tailed!
summary_pain.g.fixed.perm.min_z_dist=g_min_z_fixed; %two-tailed!
summary_pain.g.fixed.perm.max_z_dist=g_max_z_fixed; %two-tailed!
summary_pain.g.fixed.perm.p=p_perm(summary_pain.g.fixed.z,[g_min_z_fixed;g_max_z_fixed],'monte-carlo','two-tailed');

summary_pain.g.random.perm.min_z=quantile(g_min_z_random,0.025); %two-tailed!
summary_pain.g.random.perm.max_z=quantile(g_max_z_random,0.975); %two-tailed!
summary_pain.g.random.perm.min_z_dist=g_min_z_random; %two-tailed!
summary_pain.g.random.perm.max_z_dist=g_max_z_random; %two-tailed!
summary_pain.g.random.perm.p=p_perm(summary_pain.g.random.z,[g_min_z_random;g_max_z_random],'monte-carlo','two-tailed');

summary_pain.g.heterogeneity.perm.max_chi=quantile(g_het_max_chi,0.95); %one-tailed!
summary_pain.g.heterogeneity.perm.max_chi_dist=g_het_max_chi; %one-tailed!
summary_pain.g.heterogeneity.perm.p=p_perm(summary_pain.g.heterogeneity.chisq,g_het_max_chi,'monte-carlo','one-tailed-larger');
save('B1_Full_Sample_Summary_Pain.mat','summary_pain','-append');