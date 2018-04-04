function A_create_result_niis(datapath)
%% Create results images

% Add analysis/permutation summary to statistical summary struct
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
whole_brain_path=fullfile(filesep,splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');
nii_path=fullfile(whole_brain_path,'nii_results');
mask_path=fullfile(filesep,splitp{1:end-4},'pattern_masks','brainmask_logical_50.nii');

load(fullfile(datapath,'vectorized_images_full_masked_10_percent'),'dfv_masked');
load(fullfile(datapath,'data_frame'),'df');

load(fullfile(results_path,'WB_summary_pain_full.mat'));
load(fullfile(results_path,'WB_summary_placebo_full.mat'));

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

%% Print single-study PAIN
for i=1:size(df,1)
   template=zeros(size(dfv_masked.brainmask));
   outimg_main=template;
   currstat=pain_stats(i).g; %hedge's g effect size
   if ~isempty(currstat)
       outimg_main(dfv_masked.brainmask)=currstat;
       print_image(outimg_main,mask_path,fullfile(nii_path,'/full/pain/g/study_level/',df.study_ID{i}));
   end
end


%% Print single-study summaries g PLACEBO
for i=1:size(df,1)
   template=zeros(size(dfv_masked.brainmask));
   outimg_main=template;
   currstat=placebo_stats(i).g; %hedge's g effect size
   if ~isempty(currstat)
       outimg_main(dfv_masked.brainmask)=currstat;
       print_image(outimg_main,mask_path,fullfile(nii_path,'/full/pla/g/study_level/',df.study_ID{i}));
   end
end

%% Print single-study summaries r_external PLACEBO
for i=1:size(df,1)
   template=zeros(size(dfv_masked.brainmask));
   outimg_main=template;
   currstat=placebo_stats(i).r_external*-1; %multiply by -1 so the correlation represents placebo effect vs brain activity change rather than rating chage vs brain activity
   if ~isempty(currstat)
       outimg_main(dfv_masked.brainmask)=currstat;
       print_image(outimg_main,mask_path,fullfile(nii_path,'/full/pla/rrating/study_level/',df.study_ID{i}));
   end
end

%% Print single-subject effect size estimates
for i=1:length(placebo_stats)
    currstat=placebo_stats(i).std_delta; %standardized effect differences
    if ~isempty(currstat)
        for j=1:size(currstat,1)
           template=zeros(size(dfv_masked.brainmask));
           outimg_main=template;
           outimg_main(dfv_masked.brainmask)=currstat(j,:);
           print_image(outimg_main,mask_path,...
               fullfile(nii_path,...
                        '/full/pla/g/subject_level/',...
                        df.subjects{i}.sub_ID{j}));
        end
    end
end