function G_select_for_meta_hi_vs_lo_pain(datapath)
%% Define cases for the meta-analysis of the full sample
% Add folder with Generic Inverse Variance Methods Functions first
load(fullfile(datapath,'data_frame.mat'),'df')

%% Contrast images selected for meta-analysis:

contrast_select={{'^hi_pain_summary$',... % atlas
             '^lo_pain_summary$'},...
             {'NaN',... % bingel06
             'NaN'},...
             {'NaN',... % bingel11
             'NaN'},...
             {'NaN',... % choi
             'NaN'},...
             {'NaN',... % eippert
             'NaN'},...
             {'^hi_pain_summary',... % ellingsen
             '^lo_pain_summary'},...
             {'NaN',... % elsenb
             'NaN'},...
             {'^High_minus_low_pain',... % freeman
             'NaN'},...
             {'NaN',... % geuter
             'NaN'},...
             {'^pain_control_.*',... % kessner %NOT AN ERROR! the real placebo comparison in kessner et al is between positive and negative conditioning groups, whereas "placebo" and "control" skin-patches were treated with  different temperatures!
             '^pain_placebo_.*'},... % kessner %NOT AN ERROR! the real placebo comparison in kessner et al is between positive and negative conditioning groups, whereas "placebo" and "control" skin-patches were treated with  different temperatures!
             {'^hi_pain_summary',... % kong06
             '^lo_pain_summary'},...
             {'^allHighpainVSLowPain',... % kong09
             'NaN'},...
             {'NaN',... % lui
             'NaN'},...
             {'^Self_Pain_.*',... % ruetgen
             '^Self_NoPain_.*'},...
             {'NaN',... % schenk
             'NaN'},...
             {'NaN',... % they
             'NaN'},...
             {'^intense-mild',... % wager_princeton, pain contrast only >> placebo contrast: '\(intense-none\)control-placebo'
             'NaN'},...
             {'NaN',... % wager_michigan
             'NaN'},...
             {'NaN',... % wrobel
             'NaN'},...
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
    i_control=(~cellfun(@isempty,regexp(raw.cond,contrast_select{i}{1})));
    i_placebo=(~cellfun(@isempty,regexp(raw.cond,contrast_select{i}{2})));
    %Get separate tables
    hi_tbl=raw(i_control,:);
    lo_tbl=raw(i_placebo,:);
    %Get separate tables (contrasts nested in subjects)
    hi_tbl2=hi_tbl(:,'sub_ID');
    lo_tbl2=lo_tbl(:,'sub_ID');
    hi_tbl2.hi_pain=cell(size(hi_tbl,1),1);
    lo_tbl2.lo_pain=cell(size(lo_tbl,1),1);
    for j=1:size(hi_tbl)
        hi_tbl2{j,'hi_pain'}={hi_tbl(j,contrast_level_vars)};
    end
    for j=1:size(lo_tbl)
        lo_tbl2{j,'lo_pain'}={lo_tbl(j,contrast_level_vars)};
    end
    
    % Create "subjec_level" data table by performing a union
    % (important for between-group studies)
    % Note: union lists rows with any NaN entry double. Therefore the union
    % has to be performed on sub_ID, then indices have to be applied to
    % full subject level rows in a second step.
    new_con_tbl=outerjoin(hi_tbl2,lo_tbl2,'Keys','sub_ID','MergeKeys',1);  
    df.subjects{i}=outerjoin(df.subjects{i},new_con_tbl,...
                 'Keys','sub_ID','MergeKeys',1);
end

%% Add study/variable descriptions needed for meta-analysis
save(fullfile(datapath,'data_frame.mat'),'df');

end
