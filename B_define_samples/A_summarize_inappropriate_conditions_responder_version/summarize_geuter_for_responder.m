function summarize_geuter_for_responder(datapath)

%% Summarize Geuter et al. for meta-analysis
% In Geuter et al. pain was modeled as an early and a late phase.
% Further there was a weak and a strong placebo condition.
% All of these conditions were averaged (mean) for the main analysis into one
% placebo and one control image.
tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'geuter'));
geuter=df.raw{i_study,1};
subjects=unique(geuter.sub_ID);

outpath=fullfile(datapath,'Geuter_et_al_2013/summarized_for_meta'); %for images

%% Placebo
pla_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_placebo_for_responder.nii'];
    curr_pla_tbl=geuter(strcmp(geuter.sub_ID,subjects(j)) & ...% current subject
                     (~cellfun(@isempty,regexp(geuter.cond,'.*pain_placebo_strong'))),:);
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
    pla_tbl.img{j}=['Geuter_et_al_2013/summarized_for_meta/',outfilename_pla{j}];
    pla_tbl.pain(j)=1;
    pla_tbl.placebo_first(j)=mean(curr_pla_tbl.placebo_first);
    pla_tbl.cond{j}='placebo_summary_for_responder';
    pla_tbl.i_condition_in_sequence(j)=mean(curr_pla_tbl.i_condition_in_sequence);
    pla_tbl.rating(j)=mean(curr_pla_tbl.rating);
    pla_tbl.rating101(j)=mean(curr_pla_tbl.rating101);
    pla_tbl.imgs_per_stimulus_block(j)=mean(curr_pla_tbl.imgs_per_stimulus_block);
    pla_tbl.x_span(j)=mean(curr_pla_tbl.x_span);
end

spm_jobman('run', matlabbatch);

%% Add new images w parameters to geuter table
df.raw{i_study,1}=[df.raw{i_study,1};pla_tbl];
save(tblpath,'df');

end