function calc_3rd_level_perm(out_path,in_imgs)
    %delete(fullfile(out_path{:},'*.mat'))
    %delete(fullfile(out_path{:},'*.nii'))

    maskpath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks/brainmask_logical.nii';
    
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignName = 'MultiSub: One Sample T test on diffs/contrasts';
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.DesignFile = 'snpm_bch_ui_OneSampT';
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.dir = out_path;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.P = in_imgs;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.cov = struct('c', {}, 'cname', {});
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.nPerm = 10000;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.vFWHM = [6 6 6];
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.bVolm = 1;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.ST.ST_none = 0;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.im = 0;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.masking.em = {maskpath};
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalc.g_omit = 1;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.tools.snpm.des.OneSampT.globalm.glonorm = 1;   
    %Estimate model
    matlabbatch{2}.spm.tools.snpm.cp.snpmcfg(1) = cfg_dep('MultiSub: One Sample T test on diffs/contrasts: SnPMcfg.mat configuration file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','SnPMcfg'));
%     %Create contrasts & t-maps
%     matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = '1';
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
%     matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
%     matlabbatch{3}.spm.stats.con.delete = 1;
    spm_jobman('run', matlabbatch);
end