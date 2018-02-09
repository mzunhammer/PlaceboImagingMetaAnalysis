function calc_2nd_level(out_path,in_imgs)
    delete(fullfile(out_path{:},'*.mat'))
    delete(fullfile(out_path{:},'*.nii'))

    maskpath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks/brainmask_logical.nii';
    
    matlabbatch{1}.spm.stats.factorial_design.dir = out_path;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = in_imgs{1};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = in_imgs{2};
    matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
    
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0; % No implicit mask
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {maskpath};
    % To disable scaling, comment above and uncomment below (not recommended).
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1; % calculate grand mean for each image 
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    %estimate
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    %create contrasts & t-maps
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'group2-group1';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [-0.5 0.5];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 1;

    spm_jobman('run', matlabbatch);
end