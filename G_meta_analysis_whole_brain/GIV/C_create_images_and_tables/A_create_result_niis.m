function A_create_result_niis(datapath)
%% Create results images

% Add analysis/permutation summary to statistical summary struct
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
whole_brain_path=fullfile(filesep,splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');
nii_path=fullfile(whole_brain_path,'nii_results');

load(fullfile(datapath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
load(fullfile(datapath,'data_frame'),'df');

load(fullfile(results_path,'WB_summary_pain_full.mat'),...
    'summary_pain');
load(fullfile(results_path,'WB_summary_placebo_full.mat'),...
    'summary_placebo');


%% Pain ALL
print_summary_niis(summary_pain.g,dfv_masked.brainmask,'Full_pain_g', fullfile(nii_path,'/full/pain/g/'))
%% Placebo ALL
print_summary_niis(summary_placebo.g,dfv_masked.brainmask,'Full_pla_g', fullfile(nii_path,'/full/pla/g/'))
print_summary_niis(summary_placebo.r_external,dfv_masked.brainmask,'Full_pla_rrating', fullfile(nii_path,'/full/pla/rrating/'))

%% Pain Conservative
% load('A1_Conservative_Sample_Img_Data_Masked_10_percent.mat')
% load('B1_Conservative_Sample_Summary_Pain.mat')
% load('B1_Conservative_Sample_Summary_Placebo.mat')
% 
% print_summary_niis(summary_pain.g,df_conserv_masked.brainmask,'Conservative_pain_g', fullfile(nii_path,'/conservative/pain/g/'))

% %% Placebo Conservative
% print_summary_niis(summary_placebo.g,df_conserv_masked.brainmask,'Conservative_pla_g', fullfile(nii_path,'/conservative/pla/g/'))
% print_summary_niis(summary_placebo.r_external,df_conserv_masked.brainmask,'Conservative_pla_rrating', fullfile(nii_path,'/conservative/pla/rrating/'))
% 

% %% Print single-study summaries
% brainmask='../../pattern_masks/brainmask_logical_50.nii';
% 
% for i=1:length(placebo_stats)
%    template=zeros(size(dfv_masked.brainmask));
%    outimg_main=template;
%    if ~isempty(placebo_stats(i).g)
%        outimg_main(dfv_masked.brainmask)=placebo_stats(i).g;
%        printImage(outimg_main,brainmask,fullfile(nii_path,'/full/pla/g/study_level/',dfv_masked.studies{i}));
%    end
% end
% 
% for i=1:length(placebo_stats)
%    a(i)=nanmean(placebo_stats(i).g);
% end
% plot(a)
% xticks(1:20)
% xticklabels(dfv_masked.studies)
% %% Print single-subject contasts
% for i=1:length(placebo_stats)
%     if ~isempty(placebo_stats(i).g)
%         for j=1:size(placebo_stats(i).std_delta,1)
%            template=zeros(size(dfv_masked.brainmask));
%            outimg_main=template;
%            outimg_main(dfv_masked.brainmask)=placebo_stats(i).std_delta(j,:);
%            printImage(outimg_main,brainmask,fullfile(nii_path,'/full/pla/g/subject_level/',dfv_masked.studies{i},'_idx_',num2str(j)));
%         end
%     end
% end