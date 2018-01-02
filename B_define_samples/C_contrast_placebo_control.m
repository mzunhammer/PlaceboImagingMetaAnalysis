%% Create contrast images for placebo and control conditons (placebo-control)
% for within-subject studies & add images to data-frame
clear
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets/'; % must be explicit path as SPMs imcalc does not work w relative paths
df_path=fullfile(datapath,'data_frame.mat');
load(df_path);

%variables stable across contrasts
keys={'study_ID','sub_ID','male','age', 'healthy',...
      'predictable','real_treat','placebo_first',...
      'n_imgs'}; 

%% Loop through studies and create contrasts
for i=1:size(df,1)
    if ~logical(df.contrast_imgs_only(i)) %studies where contrasts are available only, are treated separately
        if strcmp(df.study_design(i),'within') %no within-subject contrasts for between-group designs.
            % Join control and placebo tables, get sub_IDs
            pla=df.full(i).pla;
            con=df.full(i).con;
            curr_tbl=join(pla,...
                 con,...
                 'Keys','sub_ID');
            subjects=unique(curr_tbl.sub_ID);
            % Define outpath
            study_dir=fullfile(df.study_dir{i},'summarized_for_meta/');
            outpath=fullfile(datapath,study_dir);
            df_full.placebo_control{i}=table(); % create empty table
            
            for j=1:length(subjects)
                % Create contrast image
                outfilename{j}=[subjects{j},'_placebo-control.nii'];  
                matlabbatch{j}.spm.util.imcalc.input = {fullfile(datapath,curr_tbl.img_pla{j});...
                                                        fullfile(datapath,curr_tbl.img_con{j})
                                                        };
                matlabbatch{j}.spm.util.imcalc.output = outfilename{j};
                matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
                matlabbatch{j}.spm.util.imcalc.expression = 'i1-i2';
                matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
                matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
                matlabbatch{j}.spm.util.imcalc.options.mask = 0;
                matlabbatch{j}.spm.util.imcalc.options.interp = 1;
                matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
                
                % Add created paths and contrasted variables to df_full
                df.full(i).pla_minus_con(j,keys)=pla(j,keys);
                df.full(i).pla_minus_con.img{j}=[study_dir,outfilename{j}];
                df.full(i).pla_minus_con.pla(j)=1;
                df.full(i).pla_minus_con.pain(j)=0;
                df.full(i).pla_minus_con.cond{j}='placebo-control';
                if strcmp(curr_tbl.stim_side_pla(j),curr_tbl.stim_side_con(j))
                    df.full(i).pla_minus_con.stim_side{j}=curr_tbl.stim_side_pla{j};
                else
                    df.full(i).pla_minus_con.stim_side{j}='L & R';
                end
                df.full(i).pla_minus_con.i_condition_in_sequence(j)=...
                                   nanmean([curr_tbl.i_condition_in_sequence_pla(j),...
                                            curr_tbl.i_condition_in_sequence_con(j)]);  
                df.full(i).pla_minus_con.rating(j)=curr_tbl.rating_pla(j)-...
                                  curr_tbl.rating_con(j);
                df.full(i).pla_minus_con.rating101(j)=curr_tbl.rating101_pla(j)-...
                                     curr_tbl.rating101_con(j);
                df.full(i).pla_minus_con.stim_intensity(j)=curr_tbl.stim_intensity_pla(j)-...
                                          curr_tbl.stim_intensity_con(j);
                df.full(i).pla_minus_con.imgs_per_stimulus_block{j}=[curr_tbl.imgs_per_stimulus_block_pla(j),...
                                                    curr_tbl.imgs_per_stimulus_block_con(j)];
                df.full(i).pla_minus_con.n_blocks{j}=[curr_tbl.n_blocks_pla(j),...
                                     curr_tbl.n_blocks_con(j)];
                df.full(i).pla_minus_con.n_imgs(j)=nansum([curr_tbl.n_imgs_pla(j),...
                                   curr_tbl.n_imgs_con(j)]);
                df.full(i).pla_minus_con.x_span(j)=nanmean([curr_tbl.x_span_pla(j),...
                                   curr_tbl.x_span_con(j)]);
                df.full(i).pla_minus_con.con_span{j}=nanmean([curr_tbl.con_span_pla(j),...
                                   curr_tbl.con_span_con(j)]);   
            end   
            spm_jobman('run', matlabbatch);
        end
    end
end

%% Manually add contrast-only studies
% (there are no within-subject contrasts for between-group studies)

% CAVE: For WAGER_PRINCETON contrasts are opposite to the other subjects
i=find(strcmp(df.study_id,'wager04a_princeton'))
wager_princeton=df.raw{i}
%Load the variably named table into "df"
i_pla=~cellfun(@isempty,regexp(wager_princeton.cond,'\(intense-none\)placebo-control'));
df.full(i).pla_minus_con=wager_princeton(i_pla,:);         

i=find(strcmp(df.study_id,'zeidan'))
zeidan=df.raw{i}
%Load the variably named table into "df"
i_pla=~cellfun(@isempty,regexp(zeidan.cond,'Pla>Control within painful series'));
df.full(i).pla_minus_con=zeidan(i_pla,:);

%%
save(fullfile(datapath,'data_frame.mat'),'df');
