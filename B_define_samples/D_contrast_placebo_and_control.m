function D_contrast_placebo_and_control(datapath, varargin)
% OPTION: argument 'noimcalc' skips actual smoothing of images and just
% updates the df
%% Create contrast images for placebo and control conditons (placebo-control)
% for within-subject studies & add images to data-frame
df_path=fullfile(datapath,'data_frame.mat');
load(df_path,'df');

%% Loop through studies and create contrasts
for i=1:size(df,1)
    %Get current study as table
    n=size(df.subjects{i},1);
    % For all studies add empty contrast-array
    df.subjects{i}.placebo_and_control=cell(n,1);
    if (~logical(df.contrast_imgs_only(i))) && strcmp(df.study_design(i),'within')
        % studies where only contrasts are available, are treated
        % separately, below the loop.
        % & no contrasts will be calculated for between-group designs.        
        % Define outpath
        study_dir=fullfile(df.study_dir{i},'summarized_for_meta/');
        outpath=fullfile(datapath,study_dir);
        for j=1:n
            pla_df=df.subjects{i}.pain_placebo{j};
            con_df=df.subjects{i}.pain_control{j};
            % Prepare creation of contrast images with SPMs jobmanager
            outfilename{j}=[df.subjects{i}.sub_ID{j},'_placebo_and_control.nii'];  
            matlabbatch{j}.spm.util.imcalc.input = [fullfile(datapath,pla_df.img);...
                                                    fullfile(datapath,con_df.img)
                                                    ];
            matlabbatch{j}.spm.util.imcalc.output = outfilename{j};
            matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
            matlabbatch{j}.spm.util.imcalc.expression = 'nanmean(X)';
            matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
            matlabbatch{j}.spm.util.imcalc.options.mask = 0;
            matlabbatch{j}.spm.util.imcalc.options.interp = 1;
            matlabbatch{j}.spm.util.imcalc.options.dtype = 4;

            % Create new subject-level contrast table based on pain_placebo
            new_con_tbl=pla_df;
            new_con_tbl.img={[study_dir,outfilename{j}]};
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
            df.subjects{i}.placebo_and_control{j}=new_con_tbl;
            % Put modified study-level table back  to subject
        end 
        % Actually create contrast images
        if ~any(strcmp(varargin,'noimcalc'))
            spm_jobman('run', matlabbatch);
        end
        matlabbatch=[];
    end
end

%% Manually add contrast-only studies
% (there are no within-subject contrasts for between-group studies)

% For Atlas et al, the placebo-meta analysis is performed with remifentanil
% effects underlying pain_placebo and pain_control. However, given the
% strong remifentanil effect we definitely do not want to have remifentanil
% in the placebo_and_control (= pain) contrast. We use the
% Hi_pain condition (mean of open and hidden but without remifentanil and expectation period) instead.
i=find(strcmp(df.study_ID,'atlas'));
df.subjects{i}.placebo_and_control=df.subjects{i}.hi_pain;

% for contrast-only studies the "pain vs baseline" contrasts were already loaded
% into control_baseline. In both cases, these contrasts represent pain
% controlled for placebo and control effects. So they are not fully
% comparable to the other mean(control_pain,placebo_pain)

%Add to table
i=find(strcmp(df.study_ID,'wager04a_princeton'));
df.subjects{i}.placebo_and_control=df.subjects{i}.pain_control;

i=find(strcmp(df.study_ID,'zeidan'));
df.subjects{i}.placebo_and_control=df.subjects{i}.pain_control;

% for the between-group studies we combine both control_baseline and
% placebo_baseline images to one large sample. The single-subject images
% will not be comparable with the mean(control_pain,placebo_pain) images,
% but summarized across groups results will represent similar conditions

i=find(strcmp(df.study_ID,'ruetgen'));
i_pla=cellfun(@isempty,df.subjects{i}.pain_control);
df.subjects{i}.placebo_and_control(~i_pla)=df.subjects{i}.pain_control(~i_pla);
df.subjects{i}.placebo_and_control(i_pla)=df.subjects{i}.pain_placebo(i_pla);

i=find(strcmp(df.study_ID,'kessner'));
i_pla=cellfun(@isempty,df.subjects{i}.pain_control);
df.subjects{i}.placebo_and_control(~i_pla)=df.subjects{i}.pain_control(~i_pla);
df.subjects{i}.placebo_and_control(i_pla)=df.subjects{i}.pain_placebo(i_pla);

%%
save(fullfile(datapath,'data_frame.mat'),'df');
end