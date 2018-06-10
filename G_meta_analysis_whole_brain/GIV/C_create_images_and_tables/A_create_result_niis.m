function A_create_result_niis(datapath,an_version)
%% Create results images
% an_version can be 'full' or 'conservative'
% Add analysis/permutation summary to statistical summary struct
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,['(?<!^)',filesep], 'DelimiterType','RegularExpression');
whole_brain_path=fullfile(splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');
nii_path=fullfile(whole_brain_path,'nii_results');
mask_path=fullfile(splitp{1:end-4},'pattern_masks','brainmask_logical_50.nii');

load(fullfile(datapath,'data_frame'),'df');
if strcmp(an_version,'full')
    load(fullfile(datapath,['vectorized_images_full_masked_10_percent']),'dfv_masked');
    load(fullfile(results_path,['WB_summary_pain_',an_version,'.mat']));
elseif strcmp(an_version,'conservative')
    load(fullfile(datapath,['vectorized_images_conservative_masked_10_percent']),'dfv_masked');
    load(fullfile(results_path,['WB_summary_placebo_',an_version,'.mat']));
end
%% Pain ALL
if strcmp(an_version,'full')
    print_summary_niis(summary_pain.g,dfv_masked.brainmask,[an_version, '_pain_g'], fullfile(nii_path,[filesep,an_version, filesep,'pain',filesep,'g',filesep]))
end
    %% Placebo ALL
print_summary_niis(summary_placebo.g,dfv_masked.brainmask,[an_version, '_pla_g'], fullfile(nii_path,[filesep,an_version, filesep 'pla', filesep, 'g', filesep]))
print_summary_niis(summary_placebo.r_external,dfv_masked.brainmask,[an_version, '_pla_rrating'], fullfile(nii_path,[filesep,an_version, filesep, 'pla',filesep,'rrating',filesep]))

%% Print single-study PAIN
if strcmp(an_version,'full')
    for i=1:size(df,1)
       template=zeros(size(dfv_masked.brainmask));
       outimg_main=template;
       currstat=pain_stats(i).g; %hedge's g effect size
       if ~isempty(currstat)
           outimg_main(dfv_masked.brainmask)=currstat;
           print_image(outimg_main,mask_path,fullfile(nii_path,[filesep,an_version, filesep,'pain',filesep,'g',filesep,'study_level',filesep],df.study_ID{i}));
       end
    end
end

%% Print single-study summaries g PLACEBO
for i=1:size(df,1)
   template=zeros(size(dfv_masked.brainmask));
   outimg_main=template;
   currstat=placebo_stats(i).g; %hedge's g effect size
   if ~isempty(currstat)
       outimg_main(dfv_masked.brainmask)=currstat;
       print_image(outimg_main,mask_path,fullfile(nii_path,[filesep,an_version, filesep,'pla',filesep, 'g', filesep, 'study_level',filesep],df.study_ID{i}));
   end
end

%% Print single-study summaries r_external PLACEBO
for i=1:size(df,1)
   template=zeros(size(dfv_masked.brainmask));
   outimg_main=template;
   currstat=placebo_stats(i).r_external*-1; %multiply by -1 so the correlation represents placebo effect vs brain activity change rather than rating chage vs brain activity
   if ~isempty(currstat)
       outimg_main(dfv_masked.brainmask)=currstat;
       print_image(outimg_main,mask_path,fullfile(nii_path,[filesep,an_version, filesep,'pla', filesep, 'rrating',filesep,'study_level',filesep],df.study_ID{i}));
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
                        [filesep,an_version, filesep,'pla',filesep,'g',filesep,'subject_level',filesep],...
                        df.subjects{i}.sub_ID{j}));
        end
    end
end