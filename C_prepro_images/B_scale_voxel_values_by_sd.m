function B_scale_voxel_values_by_sd(datapath)


WARNING! NOT YET WORKING CORRECTLY:
Signal scaling is only needed for SPM-based analyses,
as the GIV method uses standardized effect sizes, anyway.
SPM scales values to mean global in-brain signal for a given study.
This will be a problem for studies where some brain regions have very high
signal values compared to other regions.

PROBLEMS:
WITHIN SUBJECT STUDIES:
placebo>contorl contrasts have to be standardized to the SD of pain>baseline.

BETWEEN SUBJECT STUDIES:
pain_placebo and pain_control vectors have gaps and must be summarized to calculate SD!!



%% Load target images as df
df_path=fullfile(datapath,'data_frame.mat');
load(df_path,'df');

%%
contrasts={'pain_placebo',...
           'pain_control',...
           'placebo_minus_control',...
           'placebo_and_control'};
tic

h = waitbar(0,'Calculating scaled images, studies completed:');
for i=1:size(df,1) %For every study
    for j=1:length(contrasts) %For every contrast in every study
        curr_contrast=df.subjects{i}.(contrasts{j});
        df_curr_contrast=vertcat(curr_contrast{:});
        if ~isempty(df_curr_contrast)
        curr_in_imgs=df_curr_contrast.norm_img;
        %Construct output-path for standardized+resized/masked images and and add to table
        [path,filename,ext]=cellfun(@fileparts,curr_in_imgs,'UniformOutput',0);
        curr_out_imgs=fullfile(path,strcat(strcat('std_',filename),ext));
        %Perform actual by-study standardization, scaling by sd at each
        %voxel
        hdrs=spm_vol(fullfile(datapath,curr_in_imgs));
        hdrs=[hdrs{:}];
        X=spm_read_vols(hdrs);
        X_out=(X./nanstd(X,[],4));
        %Write images
        for k=1:size(X_out,4)
            if ~isempty(df.subjects{i}.(contrasts{j}){k})
            outhdr=hdrs(:,k);
            outhdr.fname=fullfile(datapath,curr_out_imgs{k});
            spm_write_vol(outhdr,X_out(:,:,:,k));
            df.subjects{i}.(contrasts{j}){k}.std_norm_img={curr_out_imgs{k}};
            end
        end
        end
    end
    h = waitbar(i / size(df.subjects,1));
    %% Save updated df
    %save(df_path,'df');
end
close(h)

end