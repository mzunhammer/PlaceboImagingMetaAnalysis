function C_WB_meta_analysis_permute_placebo(datapath,n_perms,varargin)
%% Create permuted sample for thresholding meta-analysis maps
% Function analog to the conservative meta-analysis of NPS results
% for creating a permuted (null) distribution of statistics
% Duration for 1000 permutations: >6 hours!
% smallest p possible is 1/n_perms
addpath(genpath(fullfile(userpath,'CanlabCore')));
addpath(genpath(fullfile(userpath,'MatlabTFCE')));

p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,['(?<!^)',filesep], 'DelimiterType','RegularExpression');
whole_brain_path=fullfile(splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');

if any(strcmp(varargin,'conservative'))
    load_a=load(fullfile(datapath,'vectorized_images_conservative_masked_10_percent'),'dfv_masked');
    else
    load_a=load(fullfile(datapath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
end
load_b=load(fullfile(datapath,'data_frame'),'df');
dfv_masked=load_a.dfv_masked; % Cludge necessary for parfor
df=load_b.df; % Cludge necessary for parfor
clear load_a load_b
%% Meta-Analysis for FULL BRAIN ANALYSIS
g_z_fixed=NaN(n_perms,sum(dfv_masked.brainmask));
g_z_random=NaN(n_perms,sum(dfv_masked.brainmask));
g_tfce_fixed=NaN(n_perms,sum(dfv_masked.brainmask));
g_tfce_random=NaN(n_perms,sum(dfv_masked.brainmask));
g_het=NaN(n_perms,sum(dfv_masked.brainmask));

r_external_z_fixed=NaN(n_perms,sum(dfv_masked.brainmask));
r_external_z_random=NaN(n_perms,sum(dfv_masked.brainmask));
r_external_tfce_fixed=NaN(n_perms,sum(dfv_masked.brainmask));
r_external_tfce_random=NaN(n_perms,sum(dfv_masked.brainmask));
r_het=NaN(n_perms,sum(dfv_masked.brainmask));

tic
h = waitbar(0,'Permuting placebo...');
for p=1:n_perms %exchange parfor with for if parallel processing is not possible
    % Shuffle placebo/baseline labels 
    % NOTE: Originally, I've shuffled labels for permutation testing using a separate function
    % however, it turned out that creating a full second shuffled copy of the data would occupy too much memory.
    %[curr_df_null, curr_dfv_null]=relabel_placebo_for_perm(df,dfv_masked);
    %
    % Analyze as in original
    if any(strcmp(varargin,'conservative'))
        curr_null_stats_voxels_placebo=create_meta_stats_voxels_placebo(df, dfv_masked,'conservative','perm');
    else
        curr_null_stats_voxels_placebo=create_meta_stats_voxels_placebo(df, dfv_masked,'perm');
    end
        % Summarize
    curr_perm_summary_stats=GIV_summary(curr_null_stats_voxels_placebo,{'g','r_external'});           % use output-argument to only compute stats for "g" and "r_external"
    % Obtained smoothed error image and smoothed z-Distribution
    curr_perm_summary_stats.g=smooth_SE(curr_perm_summary_stats.g,dfv_masked.brainmask3d);
    curr_perm_summary_stats.r_external=smooth_SE(curr_perm_summary_stats.r_external,dfv_masked.brainmask3d);

    % TFCE based on z-smooth
    curr_perm_summary_stats.g=meta_TFCE(curr_perm_summary_stats.g,dfv_masked.brainmask3d);
    curr_perm_summary_stats.r_external=meta_TFCE(curr_perm_summary_stats.r_external,dfv_masked.brainmask3d);
    
    g_z_fixed(p,:)=curr_perm_summary_stats.g.fixed.z_smooth;
    g_z_random(p,:)=curr_perm_summary_stats.g.random.z_smooth;
    g_tfce_fixed(p,:)=curr_perm_summary_stats.g.fixed.tfce;
    g_tfce_random(p,:)=curr_perm_summary_stats.g.random.tfce;
    g_het(p,:)=curr_perm_summary_stats.g.heterogeneity.chisq;

    r_external_z_fixed(p,:)=curr_perm_summary_stats.r_external.fixed.z_smooth;
    r_external_z_random(p,:)=curr_perm_summary_stats.r_external.random.z_smooth;
    r_external_tfce_fixed(p,:)=curr_perm_summary_stats.r_external.fixed.tfce;
    r_external_tfce_random(p,:)=curr_perm_summary_stats.r_external.random.tfce;
    r_het(p,:)=curr_perm_summary_stats.r_external.heterogeneity.chisq;
    waitbar(p / n_perms)
end
close(h) 
toc
%% Add permuted null-distributions to statistical summary struct

if any(strcmp(varargin,'conservative'))
    load(fullfile(results_path,'WB_summary_placebo_conservative.mat'),...
    'summary_placebo');
else
    load(fullfile(results_path,'WB_summary_placebo_full.mat'),...
    'summary_placebo');
end

summary_placebo.g.fixed.perm.z_dist=g_z_fixed;
summary_placebo.g.random.perm.z_dist=g_z_random;
summary_placebo.g.fixed.perm.tfce_dist=g_tfce_fixed;
summary_placebo.g.random.perm.tfce_dist=g_tfce_random;
summary_placebo.g.heterogeneity.perm.chi_dist=g_het;

summary_placebo.r_external.fixed.perm.z_dist=r_external_z_fixed;
summary_placebo.r_external.random.perm.z_dist=r_external_z_random;
summary_placebo.r_external.fixed.perm.tfce_dist=r_external_tfce_fixed;
summary_placebo.r_external.random.perm.tfce_dist=r_external_tfce_random;
summary_placebo.r_external.heterogeneity.perm.chi_dist=r_het;

%% Add smoothened errors, pseudo-z and TFCE to statistical summary struct
summary_placebo.g=smooth_SE(summary_placebo.g,dfv_masked.brainmask3d);
summary_placebo.g=meta_TFCE(summary_placebo.g,dfv_masked.brainmask3d);

summary_placebo.r_external=smooth_SE(summary_placebo.r_external,dfv_masked.brainmask3d);
summary_placebo.r_external=meta_TFCE(summary_placebo.r_external,dfv_masked.brainmask3d);


if any(strcmp(varargin,'conservative'))
    save(fullfile(results_path,'WB_summary_placebo_conservative.mat'),...
    'summary_placebo','-append');
else
    save(fullfile(results_path,'WB_summary_placebo_full.mat'),...
    'summary_placebo','-append');
end
