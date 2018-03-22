function H_select_for_meta_meds(datapath)
%% Define cases for the meta-analysis of the full sample
% Add folder with Generic Inverse Variance Methods Functions first
load(fullfile(datapath,'data_frame.mat'),'df')

%% Contrast images selected for meta-analysis:

contrast_select={{'^pain_remi_summary$',... % atlas
             '^hi_pain_summary$'},...
             {'NaN',... % bingel06
             'NaN'},...
             {'^pain_remi_summary$',... % bingel11
             '^pain_baseline$'},...
             {'NaN',... % choi
             'NaN'},...
             {'^control_summary_naloxone$',... % eippert
             '^control_summary_saline$'},...
             {'NaN',... % ellingsen
             'NaN'},...
             {'NaN',... % elsenb
             'NaN'},...
             {'NaN',... % freeman
             'NaN'},...
             {'NaN',... % geuter
             'NaN'},...
             {'NaN',... % kessner %NOT AN ERROR! the real placebo comparison in kessner et al is between positive and negative conditioning groups, whereas "placebo" and "control" skin-patches were treated with  different temperatures!
             'NaN'},... % kessner %NOT AN ERROR! the real placebo comparison in kessner et al is between positive and negative conditioning groups, whereas "placebo" and "control" skin-patches were treated with  different temperatures!
             {'NaN',... % kong06
             'NaN'},...
             {'NaN',... % kong09
             'NaN'},...
             {'NaN',... % lui
             'NaN'},...
             {'NaN',... % ruetgen
             'NaN'},...
             {'^pain_lidocaine_control',... % schenk pain_lidocaine_
             '^pain_nolidocaine_control'},... %pain_nolidocaine_
             {'NaN',... % they
             'NaN'},...
             {'NaN',... % wager_princeton, pain contrast only >> placebo contrast: '\(intense-none\)control-placebo'
             'NaN'},...
             {'NaN',... % wager_michigan
             'NaN'},...
             {'^control_summary_haldol$',... % wrobel
             '^control_summary_saline$'},...
             {'NaN',... % zeidan, pain contrast only >> placebo contrast: 'Pla>Control within painful series'
             'NaN'}
        };
       
%% Get data
subject_level_vars={'study_ID','sub_ID','male','age','healthy',...
                    'predictable','real_treat','placebo_first',...
                    'n_imgs'};
contrast_level_vars={'sub_ID','img','pla','pain','cond','rating','rating101',...
                  'stim_intensity','stim_side','i_condition_in_sequence',...
                  'imgs_per_stimulus_block','n_blocks','x_span','con_span'};

for i=1:length(df.study_ID)
    raw=df.raw{i,1}; %Get all images from current study
    %Select control pain and (if existing) placebo pain conditions
    i_med=(~cellfun(@isempty,regexp(raw.cond,contrast_select{i}{1})));
    i_nomed=(~cellfun(@isempty,regexp(raw.cond,contrast_select{i}{2})));
    %Get separate tables
    med_tbl=raw(i_med,:);
    nomed_tbl=raw(i_nomed,:);
    %Get separate tables (contrasts nested in subjects)
    med_tbl2=med_tbl(:,'sub_ID');
    nomed_tbl2=nomed_tbl(:,'sub_ID');
    med_tbl2.med_pain=cell(size(med_tbl,1),1);
    nomed_tbl2.nomed_pain=cell(size(nomed_tbl,1),1);
    for j=1:size(med_tbl)
        med_tbl2{j,'med_pain'}={med_tbl(j,contrast_level_vars)};
    end
    for j=1:size(nomed_tbl)
        nomed_tbl2{j,'nomed_pain'}={nomed_tbl(j,contrast_level_vars)};
    end
    
    % Create "subjec_level" data table by performing a union
    % (important for between-group studies)
    % Note: union lists rows with any NaN entry double. Therefore the union
    % has to be performed on sub_ID, then indices have to be applied to
    % full subject level rows in a second step.
    new_con_tbl=outerjoin(med_tbl2,nomed_tbl2,'Keys','sub_ID','MergeKeys',1);  
    df.subjects{i}=outerjoin(df.subjects{i},new_con_tbl,...
                 'Keys','sub_ID','MergeKeys',1);
end

%% Add study/variable descriptions needed for meta-analysis
save(fullfile(datapath,'data_frame.mat'),'df');

end
