%% Meta-Analysis for FULL BRAIN ANALYSIS
% Script analog to the full meta-analysis of NPS results
% for creating a permuted (null) distribution of statistics
% Duration for 1000 permutations: ~210 minutes! Size of saved distribution is ~12 GB
% 
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
%% Create permuted sample for thresholding meta-analysis maps
tic
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')

%parpool % comment out in case parallel processing is not possible
n_perms=1000; %number of permutations smallest p possible is 1/n_perms
summary_perm(n_perms)=struct('g',[],'r_external',[]); %preallocate growing struct
for p=1:n_perms %exchange parfor with for if parallel processing is not possible
    curr_df_null=relabel_df_for_perm(df_full_masked);
    curr_null_stats_voxels=create_meta_stats_voxels(curr_df_null);
    
    curr_null_stats_ratings=create_meta_stats_behavior(curr_df_null);
    for i=1:length(curr_null_stats_voxels)
        curr_null_stats_voxels(i).corr_external=fastcorrcoef(curr_null_stats_voxels(i).delta,curr_null_stats_ratings(i).delta,true); % correlate single-subject effect of behavior and voxel signal 
        curr_null_stats_voxels(i).n_corr_external=sum(~(isnan(curr_null_stats_voxels(i).delta)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                             isnan(curr_null_stats_ratings(i).delta))); % AND non nan-ratings
    end
    curr_null_stats_voxels(10).n_corr_external=[]; % exclude between-subject studies
    curr_null_stats_voxels(14).n_corr_external=[]; % exclude between-subject studies

    % Summarize
    curr_perm_summary_stats=GIVsummary(curr_null_stats_voxels,{'g','corr_external'});           % use output-argument to only compute stats for "g"
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
    
    curr_perm_summary_stats.r_external.fixed=[]; % remove fixed effects to reduce size of results matrix
    curr_perm_summary_stats.r_external.random.df=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.r_external.random.weight=[]; % remove weight to reduce size of results matrix
    curr_perm_summary_stats.r_external.random.rel_weight=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.r_external.random.summary=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.r_external.random.SEsummary=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.r_external.random.p=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.r_external.random.CI_lo=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.r_external.random.CI_hi=[]; % remove rel_weight effects to reduce size of results matrix   
    curr_perm_summary_stats.r_external.heterogeneity.p_het=[];
    curr_perm_summary_stats.r_external.heterogeneity.Isq=[];
    curr_perm_summary_stats.r_external.heterogeneity.tausq=[];
    
    summary_perm(p)=curr_perm_summary_stats;
end

% SAVE PERMUTED SUMMARY (... COMPUTE ONLY ONCE)
%save('Full_Sample_Permuted_Summary_Results.mat','summary_perm','-v7.3');
toc

%% Create thresholds:
gstats=squeeze(struct2cell(summary_perm));
stats_g=gstats(1,:);
stats_r_external=gstats(2,:);

g_min_z=cellfun(@(x) min(x.random.z),stats_g);
g_max_z=cellfun(@(x) max(x.random.z),stats_g);

r_external_min_z=cellfun(@(x) min(x.random.z),stats_r_external);
r_external_max_z=cellfun(@(x) max(x.random.z),stats_r_external);

g_het_max_chi=cellfun(@(x) max(x.heterogeneity.chisq),stats_g);
r_external_het_max_chi=cellfun(@(x) max(x.heterogeneity.chisq),stats_r_external);

trshld.g.min_z=quantile(g_min_z,0.025); %two-tailed!
trshld.g.max_z=quantile(g_max_z,0.975); %two-tailed!
trshld.g.het=quantile(g_het_max_chi,0.95); %one-tailed!

trshld.r_external.min_z=quantile(r_external_min_z,0.025); %two-tailed!
trshld.r_external.max_z=quantile(r_external_max_z,0.975); %two-tailed!
trshld.r_external.het=quantile(r_external_het_max_chi,0.95); %one-tailed!
save('Full_Sample_Permuted_Thresholds.mat','trshld');

