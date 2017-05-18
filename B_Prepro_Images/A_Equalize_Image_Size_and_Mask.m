clear

% Setup: Load df with paths and variables
datapath='../../Datasets';
load(fullfile(datapath,'AllData.mat'));

%Create logical mask
%Load mask
maskheader=spm_vol('../../pattern_masks/brainmask.nii');
mask=spm_read_vols(maskheader);
mask=mask>0.5;
maskpath='../../pattern_masks/brainmask_logical.nii';
outheader=maskheader;
outheader.fname=maskpath;
spm_write_vol(outheader,mask);

%% By default, imcalc will change matrix and voxel size to 
% the size of the first image entered... here: the mask's

df.norm_img=cell(size(df.img));
for i=1:length(df.img)
infile=fullfile(datapath,df.img{i});
[path,filename,ext]=fileparts(infile);
df.norm_img{i}=fullfile(path,['r_',filename,ext]);
disp(['Masking ',df.norm_img{i}])    
matlabbatch{1}.spm.util.imcalc.input = {
                                        maskpath
                                        infile
                                        };
matlabbatch{1}.spm.util.imcalc.output = df.norm_img{i};
matlabbatch{1}.spm.util.imcalc.outdir = {};
matlabbatch{1}.spm.util.imcalc.expression = 'logical(i1).*i2';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
end
save(fullfile(datapath,'AllData.mat'),'df');
