function summarize_wager_princeton(datapath)

%% Summarize wager_princeton et al. for meta-analysis
% For wager_princeton et al. only contrasts between control - placebo were
% available. This script creates the opposite contrasts placebo - control
% for consistency with the other studies.

tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'wager04a_princeton'));
wager_princeton=df.raw{i_study,1};
subjects=unique(wager_princeton.sub_ID);

outpath=fullfile(datapath,'Wager_et_al_2004a_Princeton_shock/summarized_for_meta'); %for images

%% Inverse contrasts control-placebo >> placebo-control
pla_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_placebo-control.nii'];
    curr_pla_tbl=wager_princeton(strcmp(wager_princeton.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(wager_princeton.cond,'\(intense-none\)control-placebo'))),:);
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
    pla_tbl.img{j}=['Wager_et_al_2004a_Princeton_shock/summarized_for_meta/',outfilename_pla{j}];
    pla_tbl.cond{j}='(intense-none)placebo-control';
    pla_tbl.rating(j)=curr_pla_tbl.rating.*-1;
    pla_tbl.rating101(j)=curr_pla_tbl.rating101.*-1;
end

spm_jobman('run', matlabbatch);

%% Add new images w parameters to wager_princeton table
df.raw{i_study,1}=[df.raw{i_study,1};pla_tbl];
save(tblpath,'df');
end