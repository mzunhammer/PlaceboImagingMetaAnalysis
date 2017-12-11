clear

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
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets'; % must be explicit as SPMs imcalc does not work w relative paths
load(fullfile(datapath,'Atlas_et_al_2012.mat'));
outpath=[datapath,'/summarized_for_meta/'];

subjects=unique(atlas.sub_ID);

pla_tbl=table();
for j=1:length(subjects)
    outfilename_pla{j}=[subjects{j},'_placebo'];
    
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
clear matlabbatch
for j=1:length(subjects)
    outfilename_con{j}=[subjects{j},'_placebo.nii'];
    
        curr_con_tbl=atlas(strcmp(atlas.sub_ID,subjects(j)) & ...% current subject
                        (strcmp(atlas.cond,'StimHiPain_Hidden_Stimulation')...
                        |strcmp(atlas.cond,'StimHiPain_Hidden_RemiConz')...
                        |strcmp(atlas.cond,'StimHiPain_Hidden_ExpectationPeriod')),:);
    matlabbatch{j}.spm.util.imcalc.input = {fullfile(datapath,curr_con_tbl.img)    };
    matlabbatch{j}.spm.util.imcalc.output = fullfile(outpath,outfilename_con{j});
    matlabbatch{j}.spm.util.imcalc.outdir = {};
    matlabbatch{j}.spm.util.imcalc.expression = 'i1+i2+i3';
    matlabbatch{j}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{j}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{j}.spm.util.imcalc.options.mask = 0;
    matlabbatch{j}.spm.util.imcalc.options.interp = 1;
    matlabbatch{j}.spm.util.imcalc.options.dtype = 4;
    
    con_tbl(j,:)=curr_con_tbl(1,:);
    con_tbl.con(j)=1;
    con_tbl.pain(j)=1;
    con_tbl.real_treat(j)=1;
    con_tbl.cond{j}='control_summary';
    con_tbl.rating(j)=sum(curr_con_tbl.rating);
    con_tbl.rating101(j)=sum(curr_con_tbl.rating101);
    con_tbl.x_span(j)=mean(curr_con_tbl.x_span);
end
spm_jobman('run', matlabbatch);

%% Version for the collective df  (in the end I preferred the single-study version)
% By default, imcalc will change matrix and voxel size to 
% the size of the first image entered... here: the mask's

% load(fullfile(datapath,'AllData.mat'));
% df.norm_img=cell(size(df.img));
% for i=1:length(df.img)
%     infile=fullfile(datapath,df.img{i});
%     [path,filename,ext]=fileparts(df.img{i});
%     df.norm_img{i}=fullfile(path,['r_',filename,ext]);
%     disp(['Masking ',df.norm_img{i}])    
%     matlabbatch{1}.spm.util.imcalc.input = {
%                                             maskpath
%                                             infile
%                                             };
%     matlabbatch{1}.spm.util.imcalc.output = fullfile(datapath,df.norm_img{i});
%     matlabbatch{1}.spm.util.imcalc.outdir = {};
%     matlabbatch{1}.spm.util.imcalc.expression = 'logical(i1).*i2';
%     matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
%     matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
%     matlabbatch{1}.spm.util.imcalc.options.mask = 0;
%     matlabbatch{1}.spm.util.imcalc.options.interp = 1;
%     matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
%     spm_jobman('run', matlabbatch);
% end
% save(fullfile(datapath,'AllData.mat'),'df');
