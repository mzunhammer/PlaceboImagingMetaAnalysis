function F_select_responder_sample(datapath)
%% Define cases for the meta-analysis of the full sample
% Add folder with Generic Inverse Variance Methods Functions first
load(fullfile(datapath,'data_frame.mat'),'df')

%% Select contrast images for meta-analysis of responders
% ... similar to full analysis, but deliberately selecting contrasts only,
% that are expected to yield maximum placebo effects.

% Note: Dichotomization of continuous outcomes is suboptimal in terms of
% statistical power and can yield misleading results (MacCallum et al. 2002).
% Therefore, I think that this responder analysis is superfluous and
% basically shows the same as the correlation analysis of NPS response, vs
% rating response — just with reduced statistical power. 
% 
% However, it seems
% that this type of analysis is so deeply engrained in most heads in placebo
% research that  everybody is asking for it.
%
% The responder analysis aims at a different experimental conditions
% ("clean, maximized placebo") and a different sample
% ("outlier cleaned responders").
%
% It is therefore necessary to repeat all contrasting,
% outlier/non-responder exclusion... 
% Please excuse the ugly, long script below.
% MZ

contrast_select={{'^control_summary_for_responder',... % atlas
             '^placebo_summary_for_responder'},...
             {'^control_summary',... % bingel06
             '^placebo_summary'},...
             {'^pain_remi_no_exp',... % bingel11
             '^pain_remi_pos_exp'},...
             {'^Exp1_control_pain_beta.*',... % choi
             '^Exp1_100potent_pain_beta.*'},...
             {'^control_summary_saline',... % eippert
             '^placebo_summary_saline'},...
             {'^Painful_touch_control',... % ellingsen
             '^Painful_touch_placebo'},...
             {'^pain_control_0\%_analgesia',... % elsenb
             '^pain_placebo_100\%_analgesia'},...
             {'^pain_post_control_high_pain',... % freeman
             '^pain_post_placebo_high_pain'},...
             {'^control_summary',... % geuter
             '^placebo_summary_for_responder'},...
             {'NaN',... % kessner
              'NaN'},...
             {'^pain_post_control_high_pain',... % kong06
             '^pain_post_placebo_high_pain'},...
             {'^pain_post_control',... % kong09
             '^pain_post_placebo'},...
             {'^pain_control',... % lui
             '^pain_placebo'},...
             {'NaN',... % rütgen
              'NaN'},...
             {'^pain_nolidocaine_control',... % schenk
             '^pain_nolidocaine_placebo'},...
             {'^control_pain',... % they
             '^placebo_pain'},...
             {'^intense-none',... % wager_princeton, pain contrast only >> placebo contrast: '\(intense-none\)control-placebo'
             'NaN'},...
             {'^control_pain',... % wager_michigan
             '^placebo_pain'},...
             {'^control_summary_saline',... % wrobel
             '^placebo_summary_saline'},...
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

df.responder_subjects=repmat({table()},20,1);
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
    df.responder_subjects{i}=subject_tbl3;
end

%% Loop through studies and create placebo-control contrasts (behavioral data only)
% GIV-meta-analysis is based on separate placebo and control images, where available)
for i=1:size(df,1)
    %Get current study as table
    n=size(df.responder_subjects{i},1);
    % For all studies add empty contrast-array
    df.responder_subjects{i}.placebo_minus_control=cell(n,1);
    if (~logical(df.contrast_imgs_only(i))) && strcmp(df.study_design(i),'within')
        % studies where only contrasts are available, are treated
        % separately, below the loop.
        % & no contrasts will be calculated for between-group designs.        
        % Define outpath
        study_dir=fullfile(df.study_dir{i},'summarized_for_meta/');
        for j=1:n
            pla_df=df.responder_subjects{i}.pain_placebo{j};
            con_df=df.responder_subjects{i}.pain_control{j};
            % Create new subject-level contrast table based on pain_placebo
            new_con_tbl=pla_df;
            new_con_tbl.pla=1;
            new_con_tbl.pain=0;
            new_con_tbl.cond={'placebo-control'};
            %Only change stimside if placebo and control were not performed
            %on the same sides
            if ~strcmp(pla_df.stim_side, con_df.stim_side)
                new_con_tbl.stim_side='L & R';
            end
            new_con_tbl.i_condition_in_sequence=...
                               nanmean([pla_df.i_condition_in_sequence,...
                                        con_df.i_condition_in_sequence]);  
            new_con_tbl.rating=pla_df.rating-con_df.rating;
            new_con_tbl.rating101=pla_df.rating101-con_df.rating101;
            new_con_tbl.stim_intensity=pla_df.stim_intensity-con_df.stim_intensity;
            new_con_tbl.imgs_per_stimulus_block=...
                               nanmean([pla_df.imgs_per_stimulus_block,...
                                        con_df.imgs_per_stimulus_block]);
            new_con_tbl.n_blocks=nansum([pla_df.n_blocks,...
                                        con_df.n_blocks]);
            new_con_tbl.x_span=nanmean([pla_df.x_span,...
                                        con_df.x_span]);
            new_con_tbl.con_span=nanmean([pla_df.con_span,...
                                          con_df.con_span]);   
            % Add new subject-level contrast table to subject
            df.responder_subjects{i}.placebo_minus_control{j}=new_con_tbl;
            % Put modified study-level table back  to subject
        end
    end
end

% Manually add contrast-only studies
% (there are no within-subject contrasts for between-group studies)
i=find(strcmp(df.study_ID,'wager04a_princeton'));
%Select contrast images from df raw
wager_princeton=df.raw{i};
i_pla=~cellfun(@isempty,regexp(wager_princeton.cond,'\(intense-none\)placebo-control'));
%Select contrasts variables
contrast_level_vars={'sub_ID','img','pla','pain','cond','rating','rating101',...
                  'stim_intensity','stim_side','i_condition_in_sequence',...
                  'imgs_per_stimulus_block','n_blocks','x_span','con_span'};
wager_princeton=wager_princeton(i_pla,contrast_level_vars);
%Add to table
for j=1:size(df.responder_subjects{i},1)
    df.responder_subjects{i}.placebo_minus_control{j}=wager_princeton(j,:);
end

% For wager michigan beta images are available but for
% behavior we have contrasts only.
i=find(strcmp(df.study_ID,'wager04b_michigan'));
%Select contrast images from df raw
for j=1:size(df.responder_subjects{i},1)
    df.responder_subjects{i}.placebo_minus_control{j}.rating = df.responder_subjects{i}.pain_placebo{j}.rating*-1; % Ratings inverted! control>placebo
    df.responder_subjects{i}.placebo_minus_control{j}.rating101 = df.responder_subjects{i}.pain_placebo{j}.rating101*-1; % Ratings inverted! control>placebo
end

i=find(strcmp(df.study_ID,'zeidan'));
%Select contrast images from df raw
zeidan=df.raw{i};
i_pla=~cellfun(@isempty,regexp(zeidan.cond,'Pla>Control within painful series'));
zeidan=zeidan(i_pla,contrast_level_vars);
for j=1:size(df.responder_subjects{i},1)
    df.responder_subjects{i}.placebo_minus_control{j}=zeidan(j,:);
end

%% Loop through studies and create placebo & control contrasts (behavioral data only)
for i=1:size(df,1)
    %Get current study as table
    n=size(df.responder_subjects{i},1);
    % For all studies add empty contrast-array
    df.responder_subjects{i}.placebo_and_control=cell(n,1);
    if (~logical(df.contrast_imgs_only(i))) && strcmp(df.study_design(i),'within')
        % studies where only contrasts are available, are treated
        % separately, below the loop.
        % & no contrasts will be calculated for between-group designs.        
        % Define outpath
        study_dir=fullfile(df.study_dir{i},'summarized_for_meta/');
        outpath=fullfile(datapath,study_dir);
        for j=1:n
            pla_df=df.responder_subjects{i}.pain_placebo{j};
            con_df=df.responder_subjects{i}.pain_control{j};
            % Create new subject-level contrast table based on pain_placebo
            new_con_tbl=pla_df;
            new_con_tbl.pla=1;
            new_con_tbl.pain=0;
            new_con_tbl.cond={'mean_placebo_and_control'};
            %Only change stimside if placebo and control were not performed
            %on the same sides
            if ~strcmp(pla_df.stim_side, con_df.stim_side)
                new_con_tbl.stim_side='L & R';
            end
            new_con_tbl.i_condition_in_sequence=...
                               nanmean([pla_df.i_condition_in_sequence,...
                                        con_df.i_condition_in_sequence]);  
            new_con_tbl.rating=nanmean([pla_df.rating,con_df.rating]);
            new_con_tbl.rating101=nanmean([pla_df.rating101,con_df.rating101]);
            new_con_tbl.stim_intensity=nanmean([pla_df.stim_intensity,con_df.stim_intensity]);
            new_con_tbl.imgs_per_stimulus_block=...
                               nanmean([pla_df.imgs_per_stimulus_block,...
                                        con_df.imgs_per_stimulus_block]);
            new_con_tbl.n_blocks=nansum([pla_df.n_blocks,...
                                        con_df.n_blocks]);
            new_con_tbl.x_span=nanmean([pla_df.x_span,...
                                        con_df.x_span]);
            new_con_tbl.con_span=nanmean([pla_df.con_span,...
                                          con_df.con_span]);   
            % Add new subject-level contrast table to subject
            df.responder_subjects{i}.placebo_and_control{j}=new_con_tbl;
            % Put modified study-level table back  to subject
        end 
    end
end

% Manually add contrast-only studies
% (there are no within-subject contrasts for between-group studies)

% for contrast-only studies the "pain vs baseline" contrasts were already loaded
% into control_baseline. In both cases, these contrasts represent pain
% controlled for placebo and control effects. So they are not fully
% comparable to the other mean(control_pain,placebo_pain)

%Add to table
i=find(strcmp(df.study_ID,'wager04a_princeton'));
df.responder_subjects{i}.placebo_and_control=df.responder_subjects{i}.pain_control;

i=find(strcmp(df.study_ID,'zeidan'));
df.responder_subjects{i}.placebo_and_control=df.responder_subjects{i}.pain_control;

% for the between-group studies we combine both control_baseline and
% placebo_baseline images to one large sample. The single-subject images
% will not be comparable with the mean(control_pain,placebo_pain) images,
% but summarized across groups results will represent similar conditions

i=find(strcmp(df.study_ID,'ruetgen'));
i_pla=cellfun(@isempty,df.responder_subjects{i}.pain_control);
df.responder_subjects{i}.placebo_and_control(~i_pla)=df.responder_subjects{i}.pain_control(~i_pla);
df.responder_subjects{i}.placebo_and_control(i_pla)=df.responder_subjects{i}.pain_placebo(i_pla);
%% Drop outliers
%  participants with pain ratings <5% VAS and questionable image quality
ex_extreme_img_IDs={'bingel11_13','bingel11_14','choi_A','choi_D','choi_F',...
    'eippert_12','freeman_LIDCAP001','geuter_34','lui_28','theysohn_2136',...
    'theysohn_2145','wrobel_42'};

for i=1:size(df,1)
    if strcmp(df.study_design{i},'within')
    curr_df=df.responder_subjects{i}.placebo_and_control;
    curr_df=vertcat(curr_df{:});
    
    df.responder_subjects{i}.excluded_low_pain = curr_df.rating101 < 5;                                                 
    df.responder_subjects{i}.excluded_image_quality=ismember(curr_df.sub_ID,...
                                            ex_extreme_img_IDs);
    df.responder_subjects{i}.excluded = df.responder_subjects{i}.excluded_image_quality |...
                                        df.responder_subjects{i}.excluded_low_pain;
    df.responder_subjects{i} =df.responder_subjects{i}(df.responder_subjects{i}.excluded==0,:);
    end
end
%% Drop non-responders subjects
% Finally, select responders by dropping subjects with below-median placebo
% effects .
% Note that this step can only be performed for within-subject
% studies!
for i=1:size(df,1)
    if strcmp(df.study_design{i},'within')
    curr_df=df.responder_subjects{i}.placebo_minus_control;
    curr_df=vertcat(curr_df{:});
    df.responder_subjects{i}.responder = curr_df.rating < nanmedian(curr_df.rating);
    df.responder_subjects{i}=df.responder_subjects{i}(df.responder_subjects{i}.responder,:);
    end
end


%% Add study/variable descriptions needed for meta-analysis
save(fullfile(datapath,'data_frame.mat'),'df');

end
