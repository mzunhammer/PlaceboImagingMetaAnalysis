function summarize_bingel06(datapath)
%% In the original analysis of Bingel et al. the effects of
% testing was performed within participants on left and right
% side... summarizine placebo & control data across hemispheres.

% NOTE: There were two missing sessions:
% Second session data for participant CK and FK were missing (not recorded) these
% were replaced by all-NaN "dummy" images. >> nanmean will result in
% equivalent of first-session-only

tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'bingel06'));
bingel06=df.raw{i_study,1};
subjects=unique(bingel06.sub_ID);

outpath=fullfile(datapath,'Bingel_et_al_2006/summarized_for_meta'); %for images

keys={'study_ID','sub_ID','male','age', 'healthy',...
      'predictable','real_treat','placebo_first','stim_intensity','imgs_per_stimulus_block',...
      'n_blocks','n_imgs','con_span'}; %variables stable across conditions

%% Placebo
placebo_L=bingel06(~cellfun(@isempty,regexp(bingel06.cond,'painPlacebo_L')),:);
placebo_R=bingel06(~cellfun(@isempty,regexp(bingel06.cond,'painPlacebo_R')),:);
placebo=join(placebo_R,placebo_L,'Keys',keys);

pla_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_placebo.nii'];
    curr_pla_tbl=placebo(strcmp(placebo.sub_ID,subjects(j)),:); %current subject
    matlabbatch{j}.spm.util.imcalc.input = [fullfile(datapath,curr_pla_tbl.img_placebo_R),...
                                            fullfile(datapath,curr_pla_tbl.img_placebo_L)]';
    matlabbatch{j}.spm.util.imcalc.output = outfilename_pla{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = 'nanmean(X)';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    pla_tbl(j,keys)=curr_pla_tbl(:,keys);
    pla_tbl.img{j}=['Bingel_et_al_2006/summarized_for_meta/',outfilename_pla{j}];
    pla_tbl.pla(j)=1;
    pla_tbl.pain(j)=1;
    pla_tbl.cond{j}='placebo_summary';
    pla_tbl.rating(j)=nanmean([curr_pla_tbl.rating_placebo_R,...
                            curr_pla_tbl.rating_placebo_L]);
    pla_tbl.rating101(j)=nanmean([curr_pla_tbl.rating101_placebo_R,...
                            curr_pla_tbl.rating101_placebo_L]);
    pla_tbl.stim_side{j}='L & R';
    pla_tbl.i_condition_in_sequence(j)=...
                       nanmean([curr_pla_tbl.i_condition_in_sequence_placebo_R,...
                            curr_pla_tbl.i_condition_in_sequence_placebo_L]);                 
    pla_tbl.x_span(j)=nanmean([curr_pla_tbl.x_span_placebo_R,...
                            curr_pla_tbl.x_span_placebo_L]);
end

spm_jobman('run', matlabbatch);

%% Control
control_L=bingel06(~cellfun(@isempty,regexp(bingel06.cond,'painNoPlacebo_L')),:);
control_R=bingel06(~cellfun(@isempty,regexp(bingel06.cond,'painNoPlacebo_R')),:);
control=join(control_R,control_L,'Keys',keys);

con_tbl=table();
for j=1:length(subjects)
    outfilename_con{j}=[subjects{j},'_control.nii'];
    curr_con_tbl=control(strcmp(control.sub_ID,subjects(j)),:); %current subject
    matlabbatch{j}.spm.util.imcalc.input = [fullfile(datapath,curr_con_tbl.img_control_R),...
                                            fullfile(datapath,curr_con_tbl.img_control_L)]';
    matlabbatch{j}.spm.util.imcalc.output = outfilename_con{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = 'nanmean(X)';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    con_tbl(j,keys)=curr_con_tbl(:,keys);
    con_tbl.img{j}=['Bingel_et_al_2006/summarized_for_meta/',outfilename_con{j}];
    con_tbl.pla(j)=1;
    con_tbl.pain(j)=1;
    con_tbl.cond{j}='control_summary';
    con_tbl.rating(j)=nanmean([curr_con_tbl.rating_control_R,...
                            curr_con_tbl.rating_control_L]);
    con_tbl.rating101(j)=nanmean([curr_con_tbl.rating101_control_R,...
                            curr_con_tbl.rating101_control_L]);
    con_tbl.stim_side{j}='L & R';
    con_tbl.i_condition_in_sequence(j)=...
                       nanmean([curr_con_tbl.i_condition_in_sequence_control_R,...
                            curr_con_tbl.i_condition_in_sequence_control_L]);                 
    con_tbl.x_span(j)=nanmean([curr_con_tbl.x_span_control_R,...
                            curr_con_tbl.x_span_control_L]);
end

spm_jobman('run', matlabbatch);

%% Add new images w parameters to bingel06 table
df.raw{i_study,1}=[df.raw{i_study,1};con_tbl;pla_tbl];
save(tblpath,'df');
end