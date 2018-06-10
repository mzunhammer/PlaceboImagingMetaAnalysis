function A_WB_meta_analysis_placebo(datapath, varargin)
%% Meta-Analysis AT WHOLE BRAIN LEVEL USING THE GIV method
% analog to the meta-analysis of NPS results
load(fullfile(datapath,'data_frame'),'df');

p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,['(?<!^)',filesep], 'DelimiterType','RegularExpression');
whole_brain_path=fullfile(splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');

%% Meta-Analysis: Effect of placebo treatment on voxel-by-voxel bold response
if strcmp(varargin,'conservative')
    load(fullfile(datapath,'vectorized_images_conservative_masked_10_percent'),'dfv_masked');
    placebo_stats=create_meta_stats_voxels_placebo(df,dfv_masked,'conservative');
else
    load(fullfile(datapath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
    placebo_stats=create_meta_stats_voxels_placebo(df,dfv_masked);
end

%% Summarize
summary_placebo=GIV_summary(placebo_stats,{'g','r_external'});

%% Save
if strcmp(varargin,'conservative')
    save(fullfile(results_path,'WB_summary_placebo_conservative.mat'),...
        'summary_placebo','placebo_stats','-v7.3');
else
    save(fullfile(results_path,'WB_summary_placebo_full.mat'),...
        'summary_placebo','placebo_stats','-v7.3');
end
% Print out n's to check for errors
n_placebo=vertcat(placebo_stats.n);
n_placebo_min=nanmin(sum(n_placebo))
n_placebo_max=nanmax(sum(n_placebo))

n_placebocorr=vertcat(placebo_stats.n_r_external);
n_placebocorr_min=nanmin(sum(n_placebocorr))
n_placebocorr_max=nanmax(sum(n_placebocorr))
end