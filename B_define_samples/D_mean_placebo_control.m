%% Create mean-summary images for placebo and control conditons mean(placebo,control)
% ... for within-subject studies ony
% the resulting files are used to calculate average pain activation across
% all studies, participants, and conditions.

clear
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets/'; % must be explicit path as SPMs imcalc does not work w relative paths
df_path=fullfile(datapath,'data_frame.mat');
load(df_path);

%variables stable across contrasts
keys={'study_ID','sub_ID','male','age', 'healthy',...
      'predictable','real_treat','placebo_first',...
      'n_imgs'}; 

%% Loop through studies and create contrasts
for i=1%:size(df,1)
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
            df.full(i).mean_pla_con=table(); % create empty table
            
            for j=1:length(subjects)
                % Create contrast image
                outfilename{j}=[subjects{j},'_mean_placebo_control.nii'];  
                matlabbatch{j}.spm.util.imcalc.input = {fullfile(datapath,curr_tbl.img_pla{j});...
                                                        fullfile(datapath,curr_tbl.img_con{j})
                                                        };
                matlabbatch{j}.spm.util.imcalc.output = outfilename{j};
                matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
                matlabbatch{j}.spm.util.imcalc.expression = 'nanmean(X)';
                matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
                matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
                matlabbatch{j}.spm.util.imcalc.options.mask = 0;
                matlabbatch{j}.spm.util.imcalc.options.interp = 1;
                matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
                
                % Add created paths and contrasted variables to df_full
                df.full(i).mean_pla_con(j,keys)=pla(j,keys);
                df.full(i).mean_pla_con.img{j}=[study_dir,outfilename{j}];
                df.full(i).mean_pla_con.pla(j)=1;
                df.full(i).mean_pla_con.pain(j)=0;
                df.full(i).mean_pla_con.cond{j}='mean_placebo_control';
                if strcmp(curr_tbl.stim_side_pla(j),curr_tbl.stim_side_con(j))
                    df.full(i).mean_pla_con.stim_side{j}=curr_tbl.stim_side_pla{j};
                else
                    df.full(i).mean_pla_con.stim_side{j}='L & R';
                end
                df.full(i).mean_pla_con.i_condition_in_sequence(j)=...
                                   nanmean([curr_tbl.i_condition_in_sequence_pla(j),...
                                            curr_tbl.i_condition_in_sequence_con(j)]);  
                df.full(i).mean_pla_con.rating(j)=nanmean([curr_tbl.rating_pla(j),...
                                          curr_tbl.rating_con(j)]);
                df.full(i).mean_pla_con.rating101(j)=nanmean([curr_tbl.rating101_pla(j),...
                                             curr_tbl.rating101_con(j)]);
                df.full(i).mean_pla_con.stim_intensity(j)=nanmean([curr_tbl.stim_intensity_pla(j),...
                                          curr_tbl.stim_intensity_con(j)]);
                df.full(i).mean_pla_con.imgs_per_stimulus_block(j)=nanmean([curr_tbl.imgs_per_stimulus_block_pla(j),...
                                                    curr_tbl.imgs_per_stimulus_block_con(j)]);
                df.full(i).mean_pla_con.n_blocks(j)=nansum([curr_tbl.n_blocks_pla(j),...
                                     curr_tbl.n_blocks_con(j)]);
                df.full(i).mean_pla_con.n_imgs(j)=nansum([curr_tbl.n_imgs_pla(j),...
                                   curr_tbl.n_imgs_con(j)]);
                df.full(i).mean_pla_con.x_span(j)=nanmean([curr_tbl.x_span_pla(j),...
                                   curr_tbl.x_span_con(j)]);
                df.full(i).mean_pla_con.con_span(j)=nanmean([curr_tbl.con_span_pla(j),...
                                   curr_tbl.con_span_con(j)]);   
            end   
           % spm_jobman('run', matlabbatch);
        end
    end
end

%% Manually add contrast-only studies
% (there are no within-subject contrasts for between-group studies)

% for contrast-only studies the "pain vs baseline" contrasts were already loaded
% into control_baseline. In both cases, these contrasts represent pain
% controlled for placebo and control effects. So they are not fully
% comparable to the other mean(control_pain,placebo_pain)

i=find(strcmp(df.study_id,'wager04a_princeton'))
df.full(i).mean_pla_con=df.full(i).con;         

i=find(strcmp(df.study_id,'zeidan'))
df.full(i).mean_pla_con=df.full(i).con;

% for the between-group studies we combine both control_baseline and
% placebo_baseline images to one large sample. The single-subject images
% will not be comparable with the mean(control_pain,placebo_pain) images,
% but summarized across groups results will represent similar conditions

i=find(strcmp(df.study_id,'ruetgen'))
df.full(i).mean_pla_con=[df.full(i).con;...
                                 df.full(i).pla];
i=find(strcmp(df.study_id,'kessner'))
df.full(i).mean_pla_con=[df.full(i).con;...
                                 df.full(i).pla];

%%
save(fullfile(datapath,'data_frame.mat'),'df');
