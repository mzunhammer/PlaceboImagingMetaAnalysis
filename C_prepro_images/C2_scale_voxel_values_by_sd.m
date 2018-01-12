clear

%% Load target images as df
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/datasets';% Must be explicit path, as SPM's jobman does can't handle relative paths
df_path=fullfile(datapath,'data_frame.mat');
load(df_path);

tic
h = waitbar(0,'Calculating masked images, studies completed:');
for i=1:size(df,1) %For every study
    curr_fields=fieldnames(df.full(i));
    for j=1:length(curr_fields) %For every contrast in every study
        if istable(df.full(i).(curr_fields{j})) && (~isempty(df.full(i).(curr_fields{j})))
        curr_in_imgs=df.full(i).(curr_fields{j}).norm_img;
        %Construct output-path for standardized+resized/masked images and and add to table
        [path,filename,ext]=cellfun(@fileparts,curr_in_imgs,'UniformOutput',0);
        curr_out_imgs=fullfile(path,strcat(strcat('std_',filename),ext));
        df.full(i).(curr_fields{j}).std_norm_img=curr_out_imgs;
        %Perform actual by-study standardization, scaling by sd at each
        %voxel
        hdrs=spm_vol(fullfile(datapath,curr_in_imgs));
        hdrs=[hdrs{:}];
        X=spm_read_vols(hdrs);
        X_out=(X./nanstd(X,[],4));
        %Write images
        for k=1:size(X_out,4)
            outhdr=hdrs(:,k);
            outhdr.fname=fullfile(datapath,curr_out_imgs{k});
            spm_write_vol(outhdr,X_out(:,:,:,k));
        end
        end
    end
    h = waitbar(i / size(df.full,1));
    %% Save updated df
    save(df_path,'df');
end
close(h)

