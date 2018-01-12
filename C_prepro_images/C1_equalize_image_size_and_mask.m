clear

%% Select studies
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets';% Must be explicit path, as SPM's jobman does can't handle relative paths

%% Create logical mask from SPM's brainmask at 50% brain probability
%Load mask
maskheader=spm_vol('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks/brainmask.nii');
mask=spm_read_vols(maskheader);
mask=mask>0.5;
maskpath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks/brainmask_logical.nii';
outheader=maskheader;
outheader.fname=maskpath;
spm_write_vol(outheader,mask);
%% Load target images as df
df_path=fullfile(datapath,'data_frame.mat');
load(df_path);

%% Loop through studies, create 2x2x2 images, add to table 
tic
h = waitbar(0,'Calculating masked images, studies completed:');
for i=1:size(df.full,1)
    %Load struct of all contrasts for a study 
    curr_fields=fieldnames(df.full(i));
    for j=1:length(curr_fields)
        if istable(df.full(i).(curr_fields{j}))
        %Construct output-path for resized/masked images and and add to table
        [path,filename,ext]=cellfun(@fileparts,...
                                    df.full(i).(curr_fields{j}).img,...
                                    'UniformOutput',0);
        df.full(i).(curr_fields{j}).norm_img=fullfile(path,...
                                              strcat(strcat('r_',filename),...
                                              ext));
        for k=1:length(df.full(i).(curr_fields{j}).img) % resize/and mask (imcalc automatically resamples to first input image, the brain mask in this case)
            matlabbatch{k}.spm.util.imcalc.input = {
                                                    maskpath
                                                    fullfile(datapath,df.full(i).(curr_fields{j}).img{k})
                                                    };
            matlabbatch{k}.spm.util.imcalc.output = fullfile(datapath,df.full(i).(curr_fields{j}).norm_img{k});
            matlabbatch{k}.spm.util.imcalc.outdir = {};
            matlabbatch{k}.spm.util.imcalc.expression = 'logical(i1).*i2';
            matlabbatch{k}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{k}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{k}.spm.util.imcalc.options.mask = 0;
            matlabbatch{k}.spm.util.imcalc.options.interp = 1;
            matlabbatch{k}.spm.util.imcalc.options.dtype = 4;
        end
        spm_jobman('run', matlabbatch);
        end
    end
    h = waitbar(i / size(df.full,1));
    %% Save updated df
    save(df_path,'df');
end
close(h)

