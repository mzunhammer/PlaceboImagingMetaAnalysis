clear

% Setup: Load df with paths and variables
basepath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/D_Meta_Analysis';
cd(basepath)
dfpath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets';
load(fullfile(dfpath,'AllData_w_NPS_MHE.mat'));
datapath='/Volumes/Transcend/Boulder_Essen/Datasets/';

%Create logical mask
%Load mask
maskheader=spm_vol('/Users/matthiaszunhammer/Documents/MATLAB/spm8/apriori/brainmask.nii,1');
mask=spm_read_vols(maskheader);
mask=mask>0.5;
maskpath=fullfile(dfpath,'brainmask_logical.nii');
outheader=maskheader;
outheader.fname=maskpath;
spm_write_vol(outheader,mask);

%% By default, SPM will change matrix and voxel size to the first image entered in Imagecalc
for i=3712:length(df.img)
infile=fullfile(datapath,df.img{i});
[path,filename,ext]=fileparts(infile);
outfile=fullfile(path,['r',filename,ext])
disp(['Masking ',outfile])    
matlabbatch{1}.spm.util.imcalc.input = {
                                        maskpath
                                        infile
                                        };
matlabbatch{1}.spm.util.imcalc.output = outfile;
matlabbatch{1}.spm.util.imcalc.outdir = {};
matlabbatch{1}.spm.util.imcalc.expression = 'logical(i1).*i2';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
end
