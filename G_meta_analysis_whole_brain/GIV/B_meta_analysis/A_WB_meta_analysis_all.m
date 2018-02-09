function A_WB_meta_analysis_all(datapath)
%% Meta-Analysis AT WHOLE BRAIN LEVEL USING THE GIV method
% analog to the meta-analysis of NPS results

load(fullfile(datapath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
load(fullfile(datapath,'data_frame'),'df');

p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
whole_brain_path=fullfile(filesep,splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');

%% Meta-analysis: Effect of pain vs baseline on voxel-by-voxel bold response (sanity check)
pain_stats=create_meta_stats_voxels_pain(df,dfv_masked);

%% Meta-Analysis: Effect of placebo treatment on voxel-by-voxel bold response
placebo_stats=create_meta_stats_voxels_placebo(df,dfv_masked);

%% Summarize
summary_pain=GIV_summary(pain_stats,{'g'});
summary_placebo=GIV_summary(placebo_stats,{'g','r_external'});

%% Save
 save(fullfile(results_path,'WB_summary_pain_full.mat'),...
     'summary_pain','pain_stats','-v7.3');
 save(fullfile(results_path,'WB_summary_placebo_full.mat'),...
     'summary_placebo','placebo_stats','-v7.3');
% Print out n's to check for errors
n_pain=vertcat(pain_stats.n);
n_pain_min=min(sum(n_pain))
n_pain_max=max(sum(n_pain))
n_placebo=vertcat(placebo_stats.n);
n_placebo_min=min(sum(n_placebo))
n_placebo_max=max(sum(n_placebo))

n_placebocorr=vertcat(placebo_stats.n_r_external);
n_placebocorr_min=min(sum(n_placebocorr))
n_placebocorr_max=max(sum(n_placebocorr))
end