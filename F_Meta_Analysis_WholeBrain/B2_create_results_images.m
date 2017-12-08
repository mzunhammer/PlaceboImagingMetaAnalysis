%% Create results images and analyze FULL sample results

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')
load('B1_Full_Sample_Summary_Pain.mat')
load('B1_Full_Sample_Summary_Placebo.mat')

studyIDtexts={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010';...
            'Ruetgen et al. 2015:';...
            'Schenk et al. 2015:';...
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:';...
            'Zeidan et al. 2015:';...
            };

%% Pain ALL
print_summary_niis(summary_pain.g,df_full_masked.brainmask,'Full_pain_g', './nii_results/full/pain/g/')

%% Placebo ALL
print_summary_niis(summary_placebo.g,df_full_masked.brainmask,'Full_pla_g', './nii_results/full/pla/g/')
print_summary_niis(summary_placebo.r_external,df_full_masked.brainmask,'Full_pla_rrating', './nii_results/full/pla/rrating/')
% %% Pain Conservative
load('A1_Conservative_Sample_Img_Data_Masked_10_percent.mat')
load('B1_Conservative_Sample_Summary_Pain.mat')
load('B1_Conservative_Sample_Summary_Placebo.mat')

print_summary_niis(summary_pain.g,df_conserv_masked.brainmask,'Conservative_pain_g', './nii_results/conservative/pain/g/')

%% Placebo Conservative
print_summary_niis(summary_placebo.g,df_conserv_masked.brainmask,'Conservative_pla_g', './nii_results/conservative/pla/g/')
print_summary_niis(summary_placebo.r_external,df_conserv_masked.brainmask,'Conservative_pla_rrating', './nii_results/conservative/pla/rrating/')


%% Print single-study summaries
brainmask='../../pattern_masks/brainmask_logical_50.nii';

for i=1:length(placebo_stats)
   template=zeros(size(df_full_masked.brainmask));
   outimg_main=template;
   if ~isempty(placebo_stats(i).g)
       outimg_main(df_full_masked.brainmask)=placebo_stats(i).g;
       printImage(outimg_main,brainmask,fullfile(['./nii_results/full/pla/g/study_level/',df_full_masked.studies{i}]));
   end
end

for i=1:length(placebo_stats)
   a(i)=nanmean(placebo_stats(i).g);
end
plot(a)
xticks(1:20)
xticklabels(df_full_masked.studies)
%% Print single-subject contasts
for i=1:length(placebo_stats)
    if ~isempty(placebo_stats(i).g)
        for j=1:size(placebo_stats(i).std_delta,1)
           template=zeros(size(df_full_masked.brainmask));
           outimg_main=template;
           outimg_main(df_full_masked.brainmask)=placebo_stats(i).std_delta(j,:);
           printImage(outimg_main,brainmask,fullfile(['./nii_results/full/pla/g/subject_level/',df_full_masked.studies{i},'_idx_',num2str(j)]));
        end
    end
end