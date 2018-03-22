function summarize_atlas(datapath)

%% In the original analysis of Atlas et al. the effects of
% stimulation, expectation and remifentanil were modeled separately.
% We want to re-assemple the resulting contrasts for the high pain condition to represent
% the original exerimental open/hidden conditions with/without drug application:
%?Pain Placebo NoRemi"      = HiPain Open Stimulation + HiPain Open ExpectationPeriod
%?Pain Placebo Remi"        = HiPain Open Stimulation + HiPain Open ExpectationPeriod + HiPain Open RemiConz
%?Pain NoPlacebo NoRemi"    = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod
%?Pain NoPlacebo Remi"      = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod + HiPain Open RemiConz

% Effect of remi vs no-remi corresponds to estimated mean plateau effect of
% 0.043 micro-g/kg/min (individual) OR 0.884 ng/ml (absolute)
% across hidden and open administration periods
tblpath=fullfile(datapath,'data_frame.mat'); % must be explicit path as SPMs imcalc does not work w relative paths
load(tblpath);
i_study=find(strcmp(df.study_ID,'atlas'));
atlas=df.raw{i_study,1};
subjects=unique(atlas.sub_ID);

outpath=fullfile(datapath,'Atlas_et_al_2012/summarized_for_meta'); %for images

%% Contrasts for placebo vs control comparison
pla_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_placebo.nii'];
    
    curr_pla_tbl=atlas(strcmp(atlas.sub_ID,subjects(j)) & ...% current subject
                        (strcmp(atlas.cond,'StimHiPain_Open_Stimulation')...
                        |strcmp(atlas.cond,'StimHiPain_Open_RemiConz')...
                        |strcmp(atlas.cond,'StimHiPain_Open_ExpectationPeriod')),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_pla_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_pla{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = 'i1+i2+i3';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    pla_tbl(j,:)=curr_pla_tbl(1,:);
    pla_tbl.img{j}=['Atlas_et_al_2012/summarized_for_meta/',outfilename_pla{j}];
    pla_tbl.pla(j)=1;
    pla_tbl.pain(j)=1;
    pla_tbl.real_treat(j)=1;
    pla_tbl.cond{j}='placebo_summary';
    pla_tbl.rating(j)=sum(curr_pla_tbl.rating);
    pla_tbl.rating101(j)=sum(curr_pla_tbl.rating101);
    pla_tbl.x_span(j)=mean(curr_pla_tbl.x_span);
end

spm_jobman('run', matlabbatch);

%%
clear matlabbatch;
con_tbl=table();
for j=1:length(subjects)
    outfilename_con{j}=[subjects{j},'_control.nii'];
    
    curr_con_tbl=atlas(strcmp(atlas.sub_ID,subjects(j)) & ...% current subject
                    (strcmp(atlas.cond,'StimHiPain_Hidden_Stimulation')...
                    |strcmp(atlas.cond,'StimHiPain_Hidden_RemiConz')...
                    |strcmp(atlas.cond,'StimHiPain_Hidden_ExpectationPeriod')),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_con_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_con{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = 'i1+i2+i3';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    con_tbl(j,:)=curr_con_tbl(1,:);
    con_tbl.img{j}=['Atlas_et_al_2012/summarized_for_meta/',outfilename_con{j}];
    con_tbl.pla(j)=0;
    con_tbl.pain(j)=1;
    con_tbl.real_treat(j)=1;
    con_tbl.cond{j}='control_summary';
    con_tbl.rating(j)=sum(curr_con_tbl.rating);
    con_tbl.rating101(j)=sum(curr_con_tbl.rating101);
    con_tbl.x_span(j)=mean(curr_con_tbl.x_span);
end
spm_jobman('run', matlabbatch);

%% Contrasts for pain hi vs low
clear matlabbatch;
hi_tbl=table();
for j=1:length(subjects)
    outfilename_con{j}=[subjects{j},'_hi_pain.nii'];
    
    curr_hi_tbl=atlas(strcmp(atlas.sub_ID,subjects(j)) & ...% current subject
                    (strcmp(atlas.cond,'StimHiPain_Open_Stimulation')...
                    |strcmp(atlas.cond,'StimHiPain_Hidden_Stimulation')),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_hi_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_con{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = '(i1+i2)./2';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    hi_tbl(j,:)=curr_hi_tbl(1,:);
    hi_tbl.img{j}=['Atlas_et_al_2012/summarized_for_meta/',outfilename_con{j}];
    hi_tbl.pla(j)=0;
    hi_tbl.pain(j)=1;
    hi_tbl.real_treat(j)=1;
    hi_tbl.cond{j}='hi_pain_summary';
    hi_tbl.rating(j)=mean(curr_hi_tbl.rating);
    hi_tbl.rating101(j)=mean(curr_hi_tbl.rating101);
    hi_tbl.x_span(j)=mean(curr_hi_tbl.x_span);
end
spm_jobman('run', matlabbatch);

clear matlabbatch;
lo_tbl=table();
for j=1:length(subjects)
    outfilename_con{j}=[subjects{j},'_lo_pain.nii'];
    
    curr_lo_tbl=atlas(strcmp(atlas.sub_ID,subjects(j)) & ...% current subject
                    (strcmp(atlas.cond,'StimLoPain_Open_Stimulation')...
                    |strcmp(atlas.cond,'StimLoPain_Hidden_Stimulation')),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_lo_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_con{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = '(i1+i2)./2';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    lo_tbl(j,:)=curr_lo_tbl(1,:);
    lo_tbl.img{j}=['Atlas_et_al_2012/summarized_for_meta/',outfilename_con{j}];
    lo_tbl.pla(j)=0;
    lo_tbl.pain(j)=1;
    lo_tbl.real_treat(j)=1;
    lo_tbl.cond{j}='lo_pain_summary';
    lo_tbl.rating(j)=mean(curr_lo_tbl.rating);
    lo_tbl.rating101(j)=mean(curr_lo_tbl.rating101);
    lo_tbl.x_span(j)=mean(curr_lo_tbl.x_span);
end
spm_jobman('run', matlabbatch);

%% Contrasts for remifentanil vs baseline
clear matlabbatch;
remi_tbl=table();
for j=1:length(subjects)
    outfilename_con{j}=[subjects{j},'pain_remi.nii'];
    
    curr_remi_tbl=atlas(strcmp(atlas.sub_ID,subjects(j)) & ...% current subject
                    (strcmp(atlas.cond,'StimHiPain_Open_Stimulation')...
                    |strcmp(atlas.cond,'StimHiPain_Open_RemiConz')...
                    |strcmp(atlas.cond,'StimHiPain_Hidden_Stimulation')...
                    |strcmp(atlas.cond,'StimHiPain_Hidden_RemiConz')),:);
    matlabbatch{j}.spm.util.imcalc.input = fullfile(datapath,curr_remi_tbl.img);
    matlabbatch{j}.spm.util.imcalc.output = outfilename_con{j};
    matlabbatch{j}.spm.util.imcalc.outdir = cellstr(outpath);
    matlabbatch{j}.spm.util.imcalc.expression = '((i1+i2)+(i3+i4))./2';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    remi_tbl(j,:)=curr_remi_tbl(1,:);
    remi_tbl.img{j}=['Atlas_et_al_2012/summarized_for_meta/',outfilename_con{j}];
    remi_tbl.pla(j)=0;
    remi_tbl.pain(j)=1;
    remi_tbl.real_treat(j)=1;
    remi_tbl.cond{j}='pain_remi_summary';
    remi_tbl.rating(j)=sum(curr_remi_tbl.rating)/2;
    remi_tbl.rating101(j)=sum(curr_remi_tbl.rating101)/2;
    remi_tbl.x_span(j)=mean(curr_remi_tbl.x_span);
end
spm_jobman('run', matlabbatch);

%% Add new images w parameters to atlas table
df.raw{i_study,1}=[df.raw{i_study,1};con_tbl;pla_tbl;hi_tbl;lo_tbl;remi_tbl];
save(tblpath,'df');
end