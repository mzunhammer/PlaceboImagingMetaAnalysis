function summarize_bingel11(datapath)

%% Summarize Bingel et al. 2011 for meta-analysis
tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'bingel11'));
bingel11=df.raw{i_study,1};
subjects=unique(bingel11.sub_ID);

outpath=fullfile(datapath,'Bingel_et_al_2011/summarized_for_meta'); %for images

%% Contrasts for remifentanil vs baseline
clear matlabbatch;
remi_tbl=table();
for j=1:length(subjects)
    outfilename_con{j}=[subjects{j},'_pain_remi.nii'];
    
    curr_remi_tbl=bingel11(strcmp(bingel11.sub_ID,subjects(j)) & ...% current subject
                    (strcmp(bingel11.cond,'pain_remi_neg_exp')...
                    |strcmp(bingel11.cond,'pain_remi_pos_exp')...
                    |strcmp(bingel11.cond,'pain_remi_no_exp')),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_remi_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_con{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = '((i1+i2+i3))./3';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    remi_tbl(j,:)=curr_remi_tbl(1,:);
    remi_tbl.img{j}=['Bingel_et_al_2011/summarized_for_meta/',outfilename_con{j}];
    remi_tbl.pla(j)=0;
    remi_tbl.pain(j)=1;
    remi_tbl.real_treat(j)=1;
    remi_tbl.cond{j}='pain_remi_summary';
    remi_tbl.rating(j)=mean(curr_remi_tbl.rating);
    remi_tbl.rating101(j)=mean(curr_remi_tbl.rating101);
    remi_tbl.x_span(j)=mean(curr_remi_tbl.x_span);
end
spm_jobman('run', matlabbatch);

%% Add new images w parameters to bingel11 table
df.raw{i_study,1}=[df.raw{i_study,1};remi_tbl];
save(tblpath,'df');
end