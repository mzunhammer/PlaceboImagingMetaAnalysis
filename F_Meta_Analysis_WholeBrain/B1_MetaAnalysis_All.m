%% Meta-Analysis for FULL BRAIN ANALYSIS
% Script analog to the full meta-analysis of NPS results
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')

%% Meta-analysis: Effect of pain vs baseline on voxel-by-voxel bold response (sanity check)
pain_stats=create_meta_stats_voxels_pain(df_full_masked);

%% Meta-Analysis: Effect of placebo treatment on voxel-by-voxel bold response
placebo_stats=create_meta_stats_voxels_placebo(df_full_masked);
% Calculate meta-analysis summary

%% Meta-Analysis: Correlation of behavioral effect and voxel-by-voxel bold response
rating_stats=create_meta_stats_behavior(df_full_masked);

for i=1:length(placebo_stats)
    placebo_stats(i).r_external=fastcorrcoef(placebo_stats(i).delta,rating_stats(i).delta,true); % correlate single-subject effect of behavior and voxel signal 
    if ~isempty(placebo_stats(i).delta) % necessary as "sum" returns 0 for [] for some stupid reason
        placebo_stats(i).n_r_external=sum(~(isnan(placebo_stats(i).delta)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                         isnan(rating_stats(i).delta))); % AND non nan-ratings
    end
end
%% Summarize
summary_placebo=GIVsummary(placebo_stats,{'g','r_external'});
save('B1_Full_Sample_Summary_Placebo.mat','summary_placebo','placebo_stats','rating_stats','-v7.3','-append');

summary_pain=GIVsummary(pain_stats,{'g'});
save('B1_Full_Sample_Summary_Pain.mat','summary_pain','pain_stats','-v7.3','-append');


n_pain=vertcat(pain_stats.n);
n_pain_min=min(sum(n_pain))
n_pain_max=max(sum(n_pain))
n_placebo=vertcat(placebo_stats.n);
n_placebo_min=min(sum(n_placebo))
n_placebo_max=max(sum(n_placebo))

n_placebocorr=vertcat(placebo_stats.n_r_external);
n_placebocorr_min=min(sum(n_placebocorr))
n_placebocorr_max=max(sum(n_placebocorr))