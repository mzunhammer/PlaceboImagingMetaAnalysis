function volume_coverage(image_vector,outfilename)
% Function that takes an volume vector and looks for all non-zero/nan voxels
% Then creates an output image that shows % of volume having
% non-zero/nan values at every given voxel.

matlabbatch{1}.spm.util.imcalc.input = image_vector;
matlabbatch{1}.spm.util.imcalc.output = outfilename;
matlabbatch{1}.spm.util.imcalc.outdir = pwd;
matlabbatch{1}.spm.util.imcalc.expression = 'sum(abs(X)>0)/size(X,1)';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
end