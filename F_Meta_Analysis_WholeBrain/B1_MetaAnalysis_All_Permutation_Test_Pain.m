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

parpool % comment out in case parallel processing is not possible
n_perms=1000; %number of permutations smallest p possible is 1/n_perms
summary_perm(n_perms)=struct('g_placebo',[]); %preallocate growing struct
parfor p=1:n_perms %exchange parfor with for if parallel processing is not possible
    % Shuffle placebo/baseline labels 
    curr_df_null=relabel_pain_for_perm(df_full_masked);
    
    % Analyze as in original
    curr_null_stats_voxels_pain=create_meta_stats_voxels_pain(curr_df_null);
    
    % Summarize
    curr_perm_summary_stats=GIVsummary(curr_null_stats_voxels_pain,'g');           % use output-argument to only compute stats for "g"
    %keep only essential stats to keep size of output low
    curr_perm_summary_stats.g.fixed=[]; % remove fixed effects to reduce size of results matrix
    curr_perm_summary_stats.g.random.df=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.weight=[]; % remove weight to reduce size of results matrix
    curr_perm_summary_stats.g.random.rel_weight=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.summary=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.SEsummary=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.p=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.CI_lo=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.CI_hi=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.heterogeneity.p_het=[];
    curr_perm_summary_stats.g.heterogeneity.Isq=[];
    curr_perm_summary_stats.g.heterogeneity.tausq=[];
    summary_perm_pain(p)=curr_perm_summary_stats;
end

toc
% SAVE PERMUTED SUMMARY (... COMPUTE ONLY ONCE)
%save('Full_Sample_Permuted_Summary_Pain.mat','summary_perm_pain','-v7.3');

%% Create thresholds:
gstats=squeeze(struct2cell(summary_perm_pain));

g_min_z=cellfun(@(x) min(x.random.z),gstats);
g_max_z=cellfun(@(x) max(x.random.z),gstats);

figure(1)
hist(g_min_z)
hold on
hist(g_max_z)
hold off

g_het_max_chi=cellfun(@(x) max(x.heterogeneity.chisq),gstats);

trshld.g.min_z=quantile(g_min_z,0.025); %two-tailed!
trshld.g.max_z=quantile(g_max_z,0.975); %two-tailed!
trshld.g.het_chi=quantile(g_het_max_chi,0.95); %one-tailed!

save('Full_Sample_Permuted_Thresholds_Pain.mat','trshld');

