function A_vectorize_all(datapath)
df_name='data_frame.mat';
load(fullfile(datapath,df_name),'df');
%% Preprocess data for meta-analysis study-wise
% >> sorts image and rating data into struct
% >> summarizes equivalent condition

%% Get data
%Preallocate struct for vectorized data
dfv.pain_placebo = cell(size(df,1),1);
dfv.pain_control = cell(size(df,1),1);
dfv.placebo_minus_control = cell(size(df,1),1);
dfv.placebo_and_control = cell(size(df,1),1);

for i=1:size(df,1)
    curr_df_control=df.subjects{i}.pain_control;
    curr_df_control=vertcat(curr_df_control{:});
    curr_df_placebo=df.subjects{i}.pain_placebo;
    curr_df_placebo=vertcat(curr_df_placebo{:});
    curr_df_placebo_and_control=df.subjects{i}.placebo_and_control;
    curr_df_placebo_and_control=vertcat(curr_df_placebo_and_control{:});
    curr_df_placebo_minus_control=df.subjects{i}.placebo_minus_control;
    curr_df_placebo_minus_control=vertcat(curr_df_placebo_minus_control{:});

   
    if  ~df.contrast_imgs_only(i)==1 % only vectorize where both pla and con is available.
        dfv.pain_control{i}=v_masked(fullfile(datapath,curr_df_control.norm_img));
        dfv.pain_placebo{i}=v_masked(fullfile(datapath,curr_df_placebo.norm_img));        
    end
    
    dfv.placebo_and_control{i}=v_masked(fullfile(datapath,curr_df_placebo_and_control.norm_img));
    
    if  strcmp(df.study_design(i),'within') && df.contrast_imgs_only(i)==1
        dfv.placebo_minus_control{i}=v_masked(fullfile(datapath,curr_df_placebo_minus_control.norm_img));
    end    
end
%% Add study/variable descriptions needed for meta-analysis
save(fullfile(datapath,'vectorized_images_full'),'dfv','-v7.3');
end