function summarize_schenk(datapath)

%% Summarize Schenk et al. for meta-analysis
% In Schenk et al. placebo effects were tested for lidocaine and non-lidocaine conditions.
% These conditions were averaged (mean) for the main analysis into one
% placebo and one control image.
tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'schenk'));
schenk=df.raw{i_study,1};
subjects=unique(schenk.sub_ID);

outpath=fullfile(datapath,'Schenk_et_al_2014/summarized_for_meta'); %for images

%% Placebo
pla_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_placebo.nii'];
    curr_pla_tbl=schenk(strcmp(schenk.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(schenk.cond,'pain_.*_placebo'))),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_pla_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_pla{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = 'nanmean(X)';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    pla_tbl(j,:)=curr_pla_tbl(1,:);
    pla_tbl.img{j}=['Schenk_et_al_2014/summarized_for_meta/',outfilename_pla{j}];
    pla_tbl.pain(j)=1;
    pla_tbl.placebo_first(j)=mean(curr_pla_tbl.placebo_first);
    pla_tbl.real_treat(j)=0.5;
    pla_tbl.cond{j}='placebo_summary';
    if strcmp(curr_pla_tbl.stim_side(1),curr_pla_tbl.stim_side(2))
        pla_tbl.stim_side(j)=curr_pla_tbl.stim_side(1);
    else
        pla_tbl.stim_side(j)={'L & R'};
    end    
    pla_tbl.i_condition_in_sequence(j)=mean(curr_pla_tbl.i_condition_in_sequence);
    pla_tbl.rating(j)=mean(curr_pla_tbl.rating);
    pla_tbl.rating101(j)=mean(curr_pla_tbl.rating101);
    pla_tbl.imgs_per_stimulus_block(j)=mean(curr_pla_tbl.imgs_per_stimulus_block);
    pla_tbl.x_span(j)=mean(curr_pla_tbl.x_span);
end

spm_jobman('run', matlabbatch);

%% Control
con_tbl=table();
for j=1:length(subjects)
    outfilename_con{j}=[subjects{j},'_control.nii'];
    curr_con_tbl=schenk(strcmp(schenk.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(schenk.cond,'pain_.*_control'))),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_con_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_con{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = 'nanmean(X)';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    con_tbl(j,:)=curr_con_tbl(1,:);
    con_tbl.img{j}=['Schenk_et_al_2014/summarized_for_meta/',outfilename_con{j}];
    con_tbl.pain(j)=1;
    con_tbl.placebo_first(j)=mean(curr_con_tbl.placebo_first);
    con_tbl.real_treat(j)=0.5;
    con_tbl.cond{j}='control_summary';
    if strcmp(curr_con_tbl.stim_side(1),curr_con_tbl.stim_side(2))
        con_tbl.stim_side(j)=curr_con_tbl.stim_side(1);
    else
        con_tbl.stim_side(j)={'L & R'};
    end    
    con_tbl.i_condition_in_sequence(j)=mean(curr_con_tbl.i_condition_in_sequence);
    con_tbl.rating(j)=mean(curr_con_tbl.rating);
    con_tbl.rating101(j)=mean(curr_con_tbl.rating101);
    con_tbl.imgs_per_stimulus_block(j)=mean(curr_con_tbl.imgs_per_stimulus_block);
    con_tbl.x_span(j)=mean(curr_con_tbl.x_span);
end

spm_jobman('run', matlabbatch);

%% Add new images w parameters to schenk table
df.raw{i_study,1}=[df.raw{i_study,1};con_tbl;pla_tbl];
save(tblpath,'df');
end