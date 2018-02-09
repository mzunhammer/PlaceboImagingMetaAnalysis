

%% In the SPM-style fixed-(study-level)-effects analysis between-group studies cannot be included as 
% one summary image of pla>con is needed per participant.

%% Load df containing target images
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets';% Must be explicit path, as SPM's jobman does can't handle relative paths
df_path=fullfile(datapath,'data_frame.mat');
load(df_path,'df');

%% Create fixed-effects summary of pain>baseline images
% (averaged across placebo and control conditions)
anapath_3rd={'/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_3rd_level_summary/fixed_std_no_between_group/pain'};% Must be explicit path, as SPM's jobman does can't handle relative paths
all_study_table=vertcat(df.full(:).mean_pla_con);
in_imgs=fullfile(datapath,all_study_table.std_norm_img);
%Make Atlas et al. reference category to avoid rank-deficient model.
%Create matrix dummy-coding study to account for between-study mean differences. 
%(note that calc_3rd_level does not apply grand mean scaling)
dummy_study_pain=dummyvar(categorical(all_study_table.study_ID));
dummy_study_pain=dummy_study_pain(:,2:end); 
dlmwrite('dummy_study_pain.txt',dummy_study_pain,'delimiter',' ');%must be written, as SPM wants multiple-covariates as a .txt file.
delete(fullfile(anapath_3rd{:},'*.mat'))
delete(fullfile(anapath_3rd{:},'*.nii'))
maskpath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks/brainmask_logical.nii';
matlabbatch{1}.spm.stats.factorial_design.dir = anapath_3rd;
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = in_imgs;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov.files = {'dummy_study_pain.txt'};
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCC = 1;%Options: 1 for standard centering, 5 for "no centering"
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0; % No implicit mask
matlabbatch{1}.spm.stats.factorial_design.masking.em = {maskpath};
% Scaling on third level is unnecessary. Will only make a difference in
% terms of beta-scaling, but not in terms of t-values.    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1; % calculate grand mean for each image 
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
%Estimate model
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
%Create contrasts & t-maps
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '1';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;

spm_jobman('run', matlabbatch);

% "3rd level analysis – permutation test"
%calc_3rd_level_perm(fullfile({anapath_3rd},'/perm'),...
%               fullfile(anapath_2nd,df.study_dir,'beta_0001.nii'));         

%% Create fixed-effects summary of placebo>control images
% (can only be performed for within-subject studies)
anapath_3rd={'/Users/matthiaszunhammer/Dropbox/Boulder_Essen/analysis/G_meta_analysis_whole_brain/SPM_analysis/SPM_3rd_level_summary/fixed_no_between_group/placebo'};% Must be explicit path, as SPM's jobman does can't handle relative paths
all_study_table=[];
for i=1:size(df,1)
    if ~isempty(df.full(i).pla_minus_con)
    all_study_table=[all_study_table;df.full(i).pla_minus_con];
    end
end
in_imgs=fullfile(datapath,all_study_table.std_norm_img);
%Make Atlas et al. reference category to avoid rank-deficient model.
%Create matrix dummy-coding study to account for between-study mean differences. 
%(note that calc_3rd_level does not apply grand mean scaling)
dummy_study_pla=dummyvar(categorical(all_study_table.study_ID));
dummy_study_pla=dummy_study_pla(:,2:end); 
dlmwrite('dummy_study_pla.txt',dummy_study_pla,'delimiter',' ');%must be written, as SPM wants multiple-covariates as a .txt file.
delete(fullfile(anapath_3rd{:},'*.mat'))
delete(fullfile(anapath_3rd{:},'*.nii'))
maskpath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks/brainmask_logical.nii';
matlabbatch{1}.spm.stats.factorial_design.dir = anapath_3rd;
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = in_imgs;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov.files = {'dummy_study_pla.txt'};
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.multi_cov.iCC = 1;%Options: 1 for standard centering, 5 for "no centering"
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 0; % No implicit mask
matlabbatch{1}.spm.stats.factorial_design.masking.em = {maskpath};
% Scaling on third level is unnecessary. Will only make a difference in
% terms of beta-scaling, but not in terms of t-values.    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1; % calculate grand mean for each image 
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
%Estimate model
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
%Create contrasts & t-maps
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '1';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;

spm_jobman('run', matlabbatch);
  