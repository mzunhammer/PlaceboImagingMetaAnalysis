function summarize_ellingsen(datapath)

%% Summarize Ellingsen et al. for meta-analysis

tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'ellingsen'));
ellingsen=df.raw{i_study,1};
subjects=unique(ellingsen.sub_ID);

outpath=fullfile(datapath,'Ellingsen_et_al_2013/summarized_for_meta'); %for images
%% Hi Pain
hi_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_pain_hi.nii'];
    curr_hi_tbl=ellingsen(strcmp(ellingsen.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(ellingsen.cond,'Painful_touch_placebo'))...
                     |~cellfun(@isempty,regexp(ellingsen.cond,'Painful_touch_control'))),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_hi_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_pla{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = 'nanmean(X)';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    hi_tbl(j,:)=curr_hi_tbl(1,:);
    hi_tbl.img{j}=['Ellingsen_et_al_2013/summarized_for_meta/',outfilename_pla{j}];
    hi_tbl.pain(j)=1;
    hi_tbl.cond{j}='hi_pain_summary';
    hi_tbl.rating(j)=nanmean(curr_hi_tbl.rating);
    hi_tbl.rating101(j)=nanmean(curr_hi_tbl.rating101);
    hi_tbl.x_span(j)=mean(curr_hi_tbl.x_span);
end

spm_jobman('run', matlabbatch);

%% Lo Pain
lo_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_pain_lo.nii'];
    curr_lo_tbl=ellingsen(strcmp(ellingsen.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(ellingsen.cond,'Warm_touch_placebo'))...
                     |~cellfun(@isempty,regexp(ellingsen.cond,'Warm_touch_control'))),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_lo_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_pla{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = 'nanmean(X)';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    lo_tbl(j,:)=curr_lo_tbl(1,:);
    lo_tbl.img{j}=['Ellingsen_et_al_2013/summarized_for_meta/',outfilename_pla{j}];
    lo_tbl.pain(j)=1;
    lo_tbl.cond{j}='lo_pain_summary';
    lo_tbl.rating(j)=nanmean(curr_lo_tbl.rating);
    lo_tbl.rating101(j)=nanmean(curr_lo_tbl.rating101);
    lo_tbl.x_span(j)=mean(curr_lo_tbl.x_span);
end

spm_jobman('run', matlabbatch);

%% Add new images w parameters to ellingsen table
df.raw{i_study,1}=[df.raw{i_study,1};hi_tbl;lo_tbl];
save(tblpath,'df');
end