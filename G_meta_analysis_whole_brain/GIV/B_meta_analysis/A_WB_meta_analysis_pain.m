function A_WB_meta_analysis_pain(datapath)
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


%% Summarize
summary_pain=GIV_summary(pain_stats,{'g'});

%% Save
 save(fullfile(results_path,'WB_summary_pain_full.mat'),...
     'summary_pain','pain_stats','-v7.3');
 
% Print out n's to check for errors
n_pain=vertcat(pain_stats.n);
n_pain_min=min(sum(n_pain))
n_pain_max=max(sum(n_pain))
end