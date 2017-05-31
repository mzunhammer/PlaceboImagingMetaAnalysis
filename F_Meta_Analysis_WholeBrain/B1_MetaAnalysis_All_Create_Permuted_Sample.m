%% Meta-Analysis for FULL BRAIN ANALYSIS
% Script analog to the full meta-analysis of NPS results
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
%% Create permuted sample for thresholding meta-analysis maps
tic
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')

n_perms=1000; %number of permutations smallest p possible is 1/n_perms
summary_perm(n_perms)=struct('g',[]); %preallocate growing struct
for p=1:n_perms
    curr_df_null=relabel_df_for_perm(df_full_masked);
    curr_null_stats=create_meta_stats(curr_df_null);
    curr_perm_summary_stats=GIVsummary(curr_null_stats,{'g'});           % use output-argument to only compute stats for "g"
    %keep only essential stats to keep size of output low
    curr_perm_summary_stats.g.fixed=[]; % remove fixed effects to reduce size of results matrix
    curr_perm_summary_stats.g.random.df=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.weight=[]; % remove weight to reduce size of results matrix
    curr_perm_summary_stats.g.random.rel_weight=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.p=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.CI_lo=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.random.CI_hi=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.g.heterogeneity.p_het=[];
    summary_perm(p)=curr_perm_summary_stats;
end

% SAVE PERMUTED SUMMARY (... COMPUTE ONLY ONCE)
save('Full_Sample_Permuted_Summary_Results.mat','summary_perm','-v7.3');
toc