function B_select_for_meta_full_sample(datapath)
%% Define cases for the meta-analysis of the full sample
% Add folder with Generic Inverse Variance Methods Functions first
load(fullfile(datapath,'data_frame.mat'),'df')

%% Contrast images selected for meta-analysis:

contrast_select={{'^control_summary',... % atlas
             '^placebo_summary'},...
             {'^control_summary',... % bingel06
             '^placebo_summary'},...
             {'^pain_remi_no_exp',... % bingel11
             '^pain_remi_pos_exp'},...
             {'^Exp1_control_pain_beta.*',... % choi
             '^placebo_summary'},...
             {'^control_summary_.*',... % eippert
             '^placebo_summary_.*'},...
             {'^Painful_touch_control',... % ellingsen
             '^Painful_touch_placebo'},...
             {'^pain_control_0\%_analgesia',... % elsenb
             '^pain_placebo_100\%_analgesia'},...
             {'^pain_post_control_high_pain',... % freeman
             '^pain_post_placebo_high_pain'},...
             {'^control_summary',... % geuter
             '^placebo_summary'},...
             {'^pain_placebo_neg',... % kessner
             '^pain_placebo_pos'},...
             {'^pain_post_control_high_pain',... % kong06
             '^pain_post_placebo_high_pain'},...
             {'^pain_post_control',... % kong09
             '^pain_post_placebo'},...
             {'^pain_control',... % lui
             '^pain_placebo'},...
             {'^Self_Pain_Control_Group',... % ruetgen
             '^Self_Pain_Placebo_Group'},...
             {'^control_summary',... % schenk
             '^placebo_summary'},...
             {'^control_pain',... % they
             '^placebo_pain'},...
             {'^intense-none',... % wager_princeton, pain contrast only >> placebo contrast: '\(intense-none\)control-placebo'
             'NaN'},...
             {'^control_pain',... % wager_michigan
             '^placebo_pain'},...
             {'^control_summary_.*',... % wrobel
             '^placebo_summary_.*'},...
             {'^Pain>NoPain controlling for placebo&interaction',... % zeidan, pain contrast only >> placebo contrast: 'Pla>Control within painful series'
             'NaN'}
        };
       
%% Get data
subject_level_vars={'study_ID','sub_ID','male','age','healthy',...
                    'predictable','real_treat','placebo_first',...
                    'n_imgs'};
contrast_level_vars={'sub_ID','img','pla','pain','cond','rating','rating101',...
                  'stim_intensity','stim_side','i_condition_in_sequence',...
                  'imgs_per_stimulus_block','n_blocks','x_span','con_span'};

df.subjects=repmat({table()},20,1);
for i=1:length(df.study_ID)
    raw=df.raw{i,1}; %Get all images from current study
    %Select control pain and (if existing) placebo pain conditions
    i_control=(~cellfun(@isempty,regexp(raw.cond,contrast_select{i}{1})));
    i_placebo=(~cellfun(@isempty,regexp(raw.cond,contrast_select{i}{2})));
    %Get separate tables
    control_tbl=raw(i_control,:);
    placebo_tbl=raw(i_placebo,:);
    %Get separate tables (contrasts nested in subjects)
    control_tbl2=control_tbl(:,'sub_ID');
    placebo_tbl2=placebo_tbl(:,'sub_ID');
    control_tbl2.pain_control=cell(size(control_tbl,1),1);
    placebo_tbl2.pain_placebo=cell(size(placebo_tbl,1),1);
    for j=1:size(control_tbl)
        control_tbl2{j,'pain_control'}={control_tbl(j,contrast_level_vars)};
    end
    for j=1:size(placebo_tbl)
        placebo_tbl2{j,'pain_placebo'}={placebo_tbl(j,contrast_level_vars)};
    end
    
    % Create "subjec_level" data table by performing a union
    % (important for between-group studies)
    % Note: union lists rows with any NaN entry double. Therefore the union
    % has to be performed on sub_ID, then indices have to be applied to
    % full subject level rows in a second step.
    [~,ia,ib]=union(control_tbl(:,'sub_ID'),...
                      placebo_tbl(:,'sub_ID'));
    subject_tbl=[control_tbl(ia,subject_level_vars);
                 placebo_tbl(ib,subject_level_vars)];      
    subject_tbl2=outerjoin(subject_tbl,control_tbl2,...
                'Keys','sub_ID','MergeKeys',1);
    subject_tbl3=outerjoin(subject_tbl2,placebo_tbl2,...
                'Keys','sub_ID','MergeKeys',1);
    df.subjects{i}=subject_tbl3;
end

%% Add study/variable descriptions needed for meta-analysis
save(fullfile(datapath,'data_frame.mat'),'df');

end
