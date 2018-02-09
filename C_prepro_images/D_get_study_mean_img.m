function D_get_study_mean_img(datapath)
%% Attempt to apply equalize smoothing to all images post-hoc

%% Load df
df_path=fullfile(datapath,'data_frame.mat');
load(df_path,'df');

%% Loop through studies, calculate average images across placebo and control
for i=1:size(df,1)
    curr_study=df.subjects{i}.placebo_and_control;
    curr_study=vertcat(curr_study{:});
    if istable(curr_study) && (~isempty(curr_study))
    df.mean_pain_img{i}=fullfile(df.study_dir{i},[df.study_ID{i},'_mean_pain.nii']);
    
    %Perform actual by-study standardization, scaling by sd at each
    %voxel
    hdrs=spm_vol(fullfile(datapath,curr_study.norm_img));
    hdrs=[hdrs{:}];
    X=spm_read_vols(hdrs);
    X_out=nanmean(X,4); %calculate mean, excluding nans
    %Write images
    outhdr=hdrs(:,1);
    outhdr.fname=fullfile(datapath,df.mean_pain_img{i});
    spm_write_vol(outhdr,X_out);
    end
end
%% Save updated df
save(df_path,'df');
