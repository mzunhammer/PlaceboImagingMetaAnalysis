function C4_explore_peak_VOIs(datapath)
% Explore peak activations with Forrest Plots
addpath(fullfile(userpath,'/crop'))
% Add analysis/permutation summary to statistical summary struct
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
whole_brain_path=fullfile(filesep,splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');
nii_path=fullfile(whole_brain_path,'nii_results');
mask_path=fullfile(results_path,'full_masked_10_percent.nii');

%load(fullfile(datapath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
load(fullfile(datapath,'data_frame'),'df');

%load(fullfile(results_path,'WB_summary_pain_conservative.mat'));
load(fullfile(results_path,'WB_summary_placebo_conservative.mat'));
%% Create results tables
%% Explore VOIS FULL SAMPLE PLACEBO G

% VOIs of interest
MNI_pla_g={
[38 8 0]
[-6 -32 12]
[-40 -64 -24]}; %

outpath=fullfile(filesep,splitp{1:end-1},'figure_results/random_negative_peaks');

for i=1:length(MNI_pla_g)
    [~,~,masked_i]=mni2mat(MNI_pla_g{i},mask_path);
    VOI_stats=stat_reduce(placebo_stats,masked_i);                  
   forest_plotter(VOI_stats,...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',sprintf('Hedges'' g at MNI [%d, %d, %d]',MNI_pla_g{i}),...
                  'type','random',...
                  'summary_stat','g',...
                  'with_outlier',0,...%'WI_subdata',0,...
                  'box_scaling',1,...
                  'text_offset',0);  
  curr_svg=sprintf([outpath '/VOI_Full_pla_g_%d_%d_%d_conservative.svg'],MNI_pla_g{i});
  curr_png=sprintf([outpath '/VOI_Full_pla_g_%d_%d_%d_conservative.png'],MNI_pla_g{i});

  hgexport(gcf, curr_svg, hgexport('factorystyle'), 'Format', 'svg'); 
  hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
  crop(curr_png);
end
%close all;


%% Positive peaks (from fixed effects analysis)

MNI_pla_g={
[-34 -80 42]
[46 32 36]
[-8 -68 50]
[28 52 -4]
[30 -50 36]
[64 -20 -18]
[-42 10 32]
[40 -54 42]
[-32 -8 -16]
}; 

outpath=fullfile(filesep,splitp{1:end-1},'figure_results/fixed_positive_peaks');
for i=1:length(MNI_pla_g)
    [~,~,masked_i]=mni2mat(MNI_pla_g{i},mask_path);
    VOI_stats=stat_reduce(placebo_stats,masked_i);                  
   forest_plotter(VOI_stats,...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',sprintf('Hedges'' g at MNI [%d, %d, %d]',MNI_pla_g{i}),...
                  'type','fixed',...
                  'summary_stat','g',...
                  'with_outlier',0,...
                  'box_scaling',1,...
                  'text_offset',0);  
  curr_svg=sprintf([outpath '/VOI_Full_pla_g_%d_%d_%d.svg'],MNI_pla_g{i});
  curr_png=sprintf([outpath '/VOI_Full_pla_g_%d_%d_%d.png'],MNI_pla_g{i});

  hgexport(gcf, curr_svg, hgexport('factorystyle'), 'Format', 'svg'); 
  hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
  crop(curr_png);
end

close all;
%% Explore VOIS FULL SAMPLE PLACEBO R with ratings >> Significant negative correlations

MNI_pla_r={
[10 -18 6]
[-10 -8 12]
[-4 8 40]
[54 20 -6]
[16 -20 40]
[4 6 64]
}; 

outpath=fullfile(filesep,splitp{1:end-1},'figure_results/random_correlation_peaks');
for i=1:length(MNI_pla_r)
   [~,~,masked_i]=mni2mat(MNI_pla_r{i},mask_path);
   VOI_stats=stat_reduce(placebo_stats,masked_i);
   for j=1:length(VOI_stats)
       VOI_stats(j).r_external=VOI_stats(j).r_external*-1; % invert: positive correlations between pain rating change and brain activity
   end
   forest_plotter(VOI_stats,...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',sprintf('Pearson''s r at at MNI [%d, %d, %d]',MNI_pla_r{i}),...
                  'type','random',...
                  'summary_stat','r_external',...
                  'with_outlier',0,...%'WI_subdata',0,...
                  'box_scaling',1,...
                  'text_offset',0);  
  curr_svg=sprintf([outpath '/VOI_Full_pla_g_%d_%d_%d.svg'],MNI_pla_r{i});
  curr_png=sprintf([outpath '/VOI_Full_pla_g_%d_%d_%d.png'],MNI_pla_r{i});

  hgexport(gcf, curr_svg, hgexport('factorystyle'), 'Format', 'svg'); 
  hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
  crop(curr_png);
end
end
