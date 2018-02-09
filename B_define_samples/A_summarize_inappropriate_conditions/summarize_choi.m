function summarize_choi(datapath)

%% Summarize Choi et al. for meta-analysis
% In Choi et al. two placebo-conditions and a control condition was used.
% The two placebo conditions (strong=(100 potent),weak=(1 potent)) are
% summarized for meta-analysis.
% There was a second run (Exp2) of the experiment that was not published.
% As we limited our meta analysis to published data, a-priori, this data was not analyzed.
tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'choi'));
choi=df.raw{i_study,1};
subjects=unique(choi.sub_ID);
outpath=fullfile(datapath,'Choi_et_al_2011/summarized_for_meta'); %for images

%%
pla_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_placebo.nii'];
    curr_pla_tbl=choi(strcmp(choi.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(choi.cond,'Exp1_control_pain_beta.*'))...
                     |~cellfun(@isempty,regexp(choi.cond,'Exp1_100potent_pain_beta.*'))),:);
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
    pla_tbl.img{j}=['Choi_et_al_2011/summarized_for_meta/',outfilename_pla{j}];
    pla_tbl.pla(j)=1;
    pla_tbl.pain(j)=1;
    pla_tbl.real_treat(j)=0;
    pla_tbl.cond{j}='placebo_summary';
    pla_tbl.rating(j)=mean(curr_pla_tbl.rating);
    pla_tbl.rating101(j)=mean(curr_pla_tbl.rating101);
    pla_tbl.x_span(j)=mean(curr_pla_tbl.x_span);
end

spm_jobman('run', matlabbatch);

%% Add new images w parameters to choi table
df.raw{i_study,1}=[df.raw{i_study,1};pla_tbl];
save(tblpath,'df');
end