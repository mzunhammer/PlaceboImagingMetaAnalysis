function summarize_freeman(datapath)

%% Summarize freeman et al. for meta-analysis
% No SPM file available for freeman et al. therefore we could not
% double-check the contrast of HighvsLow pain.
% Jian Kong: Mail 20.06.2017: "see attachment for the low pain vs high pain data, please be noted to we used low pain minus high pain."

tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'freeman'));
freeman=df.raw{i_study,1};
subjects=unique(freeman.sub_ID);

outpath=fullfile(datapath,'Freeman_et_al_2015/summarized_for_meta'); %for images

%% Inverse contrasts control-placebo >> placebo-control
pla_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_high_minus_low_pain.nii'];
    curr_pla_tbl=freeman(strcmp(freeman.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(freeman.cond,'^post-HighpainVsLowpain'))),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_pla_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_pla{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = 'X.*-1';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 1;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    pla_tbl(j,:)=curr_pla_tbl(1,:);
    pla_tbl.img{j}=['Freeman_et_al_2015/summarized_for_meta/',outfilename_pla{j}];
    pla_tbl.cond{j}='High_minus_low_pain';
    pla_tbl.rating(j)=curr_pla_tbl.rating.*-1;
    pla_tbl.rating101(j)=curr_pla_tbl.rating101.*-1;
end

spm_jobman('run', matlabbatch);

%% Add new images w parameters to freeman table
df.raw{i_study,1}=[df.raw{i_study,1};pla_tbl];
save(tblpath,'df');
end