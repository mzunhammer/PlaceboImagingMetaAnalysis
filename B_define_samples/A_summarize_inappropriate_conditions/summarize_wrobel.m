function summarize_wrobel(datapath)

%% Summarize Wrobel et al. for meta-analysis
% In Wrobel et al. pain was modeled as an early and a late phase.
% Early and late pain are summarized (mean) for the main analysis into one
% placebo and one control image.

tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'wrobel'));
wrobel=df.raw{i_study,1};
subjects=unique(wrobel.sub_ID);
outpath=fullfile(datapath,'Wrobel_et_al_2014/summarized_for_meta'); %for images

%% Placebo
pla_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_placebo.nii'];
    curr_pla_tbl=wrobel(strcmp(wrobel.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(wrobel.cond,'.*_pain_placebo_.*'))),:);
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
    pla_tbl.img{j}=['Wrobel_et_al_2014/summarized_for_meta/',outfilename_pla{j}];
    pla_tbl.pain(j)=1;
    pla_tbl.rating(j)=mean(curr_pla_tbl.rating);
    pla_tbl.rating101(j)=mean(curr_pla_tbl.rating101);
    if pla_tbl.real_treat(j)==0
        pla_tbl.cond{j}='placebo_summary_saline';
    elseif pla_tbl.real_treat(j)==1
        pla_tbl.cond{j}='placebo_summary_haldol';
    end
    pla_tbl.x_span(j)=mean(curr_pla_tbl.x_span);
end

spm_jobman('run', matlabbatch);

%% Control
con_tbl=table();
for j=1:length(subjects)
    outfilename_con{j}=[subjects{j},'_control.nii'];
    curr_con_tbl=wrobel(strcmp(wrobel.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(wrobel.cond,'.*_pain_control_.*'))),:);
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
    con_tbl.img{j}=['Wrobel_et_al_2014/summarized_for_meta/',outfilename_con{j}];
    con_tbl.pain(j)=1;
    con_tbl.rating(j)=nanmean(curr_con_tbl.rating);
    con_tbl.rating101(j)=nanmean(curr_con_tbl.rating101);
    if con_tbl.real_treat(j)==0
        con_tbl.cond{j}='control_summary_saline';
    elseif con_tbl.real_treat(j)==1
        con_tbl.cond{j}='control_summary_haldol';
    end
    con_tbl.x_span(j)=mean(curr_con_tbl.x_span);
end

spm_jobman('run', matlabbatch);

%% Add new images w parameters to wrobel table
df.raw{i_study,1}=[df.raw{i_study,1};con_tbl;pla_tbl];
save(tblpath,'df');
end