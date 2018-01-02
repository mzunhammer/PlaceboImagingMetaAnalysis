
%% Attempt to apply equalize smoothing to all images post-hoc

% CAVE: This is a post-hoc method and requires that the SPM-style whole brain
% analyses in analysis/F_meta_analysis_whole_brain/SPM_analysis are been
% completed.

% The original analysis involved spatial smoothing with FWHM gaussian
% kernels of various kernel widths (see: 'df_study_level.mat')
% This scripts seeks to equalize studies in terms of emperically observed
% "smoothness" by

% A) loading SPM's smoothness estimates from the second-level SPM-style
% analysis (pain>baseline) and save them in the data-frame

% B) equalizing smoothness to match the largest (rounded up) smoothing
% kernel observed in the sample according to the formula:
% Smooth_total^2 = Smooth_observed^2+Smooth_added^2


SPM_analysis_path='../G_meta_analysis_whole_brain/SPM_analysis/SPM_2nd_level_study_summaries/random/pain/';

%% Load df
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets';% Must be explicit path, as SPM's jobman does can't handle relative paths
df_path=fullfile(datapath,'data_frame.mat');
load(df_path);

%% Loop through studies, get smoothness estimates, add to df
n=size(df,1);
est_smoothness=NaN(n,3);
for i=1:n
    load(fullfile(SPM_analysis_path,df.study_dir{i},'SPM.mat'))
    est_smoothness(i,:)=SPM.xVol.FWHM;
end
df.spatial_smoothing_FWHM_est=est_smoothness;

%% Loop through studies, create images w equal smoothness
% >> Target smoothness the maximum FWHM smoothness estimate in the sample
% (across all three spatial dimensions)

FWHM_target=max(max(df.spatial_smoothing_FWHM_est));
tic
h = waitbar(0,'Smoothing, studies completed:');
for i=1:n
    %Load struct of all contrasts for a study 
    curr_est_FWHM=df.spatial_smoothing_FWHM_est(i,:);
    %Smoothness adds like SD: smoothness_A^2+smoothness_B^2=smoothness_C^2 >>
    FWHM_to_apply=sqrt(FWHM_target^2-curr_est_FWHM.^2);
    
    curr_fields=fieldnames(df.full(i));
    for j=1:length(curr_fields)
        if istable(df.full(i).(curr_fields{j}))
        if ~isempty(df.full(i).(curr_fields{j}))
        %Construct output-path for smoothed images and and add to table
        [path,filename,ext]=cellfun(@fileparts,...
                                    df.full(i).(curr_fields{j}).norm_img,...
                                    'UniformOutput',0);
        df.full(i).(curr_fields{j}).smoothed_norm_img=fullfile(path,...
                                              strcat(strcat('s_',filename),...
                                              ext));
        matlabbatch{1}.spm.spatial.smooth.data = fullfile(datapath,...
                                            df.full(i).(curr_fields{j}).norm_img);
        matlabbatch{1}.spm.spatial.smooth.fwhm = FWHM_to_apply;
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's_';
        spm_jobman('run', matlabbatch);
        end
        end
    end
    h = waitbar(i / size(df.full,1));
    %% Save updated df
    save(df_path,'df');
end
close(h)
