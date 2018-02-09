function C_designate_excluded(datapath)

%% Load Dataframe
df_name='data_frame.mat';
load(fullfile(datapath,df_name));

% Mark participants with pain ratings <5% VAS
for i=1:size(df,1)
    curr_con_df=df.subjects{i}.placebo_and_control;
    curr_con_df=vertcat(curr_con_df{:});
    df.subjects{i}.excluded_low_pain = curr_con_df.rating101<5;
end

% Images identified as potential outliers according to 
% tissue signal estimates and visual screening.
ex_extreme_img_IDs={'bingel11_13','bingel11_14','choi_A','choi_D','choi_F',...
    'eippert_12','freeman_LIDCAP001','geuter_34','lui_28','theysohn_2136',...
    'theysohn_2145','wrobel_42'};
for i=1:size(df,1)
    % Mark outlier images
    df.subjects{i}.excluded_image_quality=ismember(df.subjects{i}.sub_ID,...
                                            ex_extreme_img_IDs);
    df.subjects{i}.excluded = df.subjects{i}.excluded_image_quality |...
                              df.subjects{i}.excluded_low_pain;
end

save(fullfile(datapath,df_name), 'df')