function A_equalize_image_size_and_mask(datapath,varargin)
% OPTION: argument 'noimcalc' skips actual smoothing of images and just
% updates the df

%% Load target images as df
df_path=fullfile(datapath,'data_frame.mat');
load(df_path,'df');
%% Create logical mask from SPM's brainmask at 50% brain probability
%Load mask
maskheader=spm_vol('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks/brainmask.nii');
mask=spm_read_vols(maskheader);
mask=mask>0.5;
maskpath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks/brainmask_logical.nii';
outheader=maskheader;
outheader.fname=maskpath;
spm_write_vol(outheader,mask);

contrasts={'pain_placebo',...
           'pain_control',...
           'placebo_minus_control',...
           'placebo_and_control'};

%% Loop through studies, create 2x2x2 images, add to table 
tic
h = waitbar(0,'Calculating masked images, studies completed:');
for i=1:size(df.subjects,1) % Loop over studies
    for j=1:size(df.subjects{i},1) %Loop over subjects
        for k=1:length(contrasts) % Loop over target contrasts
            curr_tbl=df.subjects{i}.(contrasts{k}){j};
        if ~isempty(curr_tbl)
            infilename=curr_tbl.img{:};
            %Construct output-path for resized/masked images and and add to table
            [path,filename,ext]=fileparts(infilename);
            outfilename=fullfile(path,strcat(strcat('r_',filename),ext));
            df.subjects{i}.(contrasts{k}){j}.norm_img={outfilename};
            matlabbatch{1}.spm.util.imcalc.input = {
                                                    maskpath
                                                    fullfile(datapath,infilename)
                                                    };
            matlabbatch{1}.spm.util.imcalc.output = fullfile(datapath,outfilename);
            matlabbatch{1}.spm.util.imcalc.outdir = {};
            % Image re-slicing to 2x2x2 mm is a side effect of masking, as
            % imcalc always re-slices to the first image entered (the
            % mask).
            matlabbatch{1}.spm.util.imcalc.expression = 'logical(i1).*i2';
            matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
            matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
            matlabbatch{1}.spm.util.imcalc.options.mask = 0;
            matlabbatch{1}.spm.util.imcalc.options.interp = 1;
            matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
            if ~any(strcmp(varargin,'noimcalc'))
                spm_jobman('run', matlabbatch);
            end
        end
        end
    end
    h = waitbar(i / size(df.subjects,1));
    %% Save updated df
    save(df_path,'df');
end
close(h)
end
