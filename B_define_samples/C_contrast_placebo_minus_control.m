function C_contrast_placebo_minus_control(datapath, varargin)
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
    df.subjects{i}.placebo_minus_control=cell(n,1);
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
            outfilename{j}=[df.subjects{i}.sub_ID{j},'_placebo-control.nii'];  
            matlabbatch{j}.spm.util.imcalc.input = [fullfile(datapath,pla_df.img);...
                                                    fullfile(datapath,con_df.img)
                                                    ];
            matlabbatch{j}.spm.util.imcalc.output = outfilename{j};
            matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
            matlabbatch{j}.spm.util.imcalc.expression = 'i1-i2';
            matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{j}.spm.util.imcalc.options.mask = 0;
            matlabbatch{j}.spm.util.imcalc.options.interp = 1;
            matlabbatch{j}.spm.util.imcalc.options.dtype = 4;

            % Create new subject-level contrast table based on pain_placebo
            new_con_tbl=pla_df;
            new_con_tbl.img={[study_dir,outfilename{j}]};
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
            df.subjects{i}.placebo_minus_control{j}=new_con_tbl;
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
for j=1:size(df.subjects{i},1)
    df.subjects{i}.placebo_minus_control{j}=wager_princeton(j,:);
end

% For wager michigan beta images are available but for
% behavior we have contrasts only.
i=find(strcmp(df.study_ID,'wager04b_michigan'));
%Select contrast images from df raw
for j=1:size(df.subjects{i},1)
    df.subjects{i}.placebo_minus_control{j}.rating = df.subjects{i}.pain_placebo{j}.rating*-1; % Ratings inverted! control>placebo
    df.subjects{i}.placebo_minus_control{j}.rating101 = df.subjects{i}.pain_placebo{j}.rating101*-1; % Ratings inverted! control>placebo
end


i=find(strcmp(df.study_ID,'zeidan'));
%Select contrast images from df raw
zeidan=df.raw{i};
i_pla=~cellfun(@isempty,regexp(zeidan.cond,'Pla>Control within painful series'));
zeidan=zeidan(i_pla,contrast_level_vars);
for j=1:size(df.subjects{i},1)
    df.subjects{i}.placebo_minus_control{j}=zeidan(j,:);
end

%%
save(fullfile(datapath,'data_frame.mat'),'df');
end