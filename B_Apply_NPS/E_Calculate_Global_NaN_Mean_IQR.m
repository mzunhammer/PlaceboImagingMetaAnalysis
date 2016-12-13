clear

%% Load all images and compute NaNcount, ImgMean, IQR
% Takes about 22 minutes for all data
%Load Dataframe
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets/';
cd(datapath)
df_name='AllData_w_NPS_MHE_NOBRAIN';
load([df_name '.mat']);

tic
all_imgs=fullfile(datapath, df.img);

%Get sample images from each dataset:
AllImg_hdr=spm_vol(all_imgs);
AllImg_data=cellfun(@(x) spm_read_vols(x),AllImg_hdr,'UniformOutput',0);

AllImg_NaNcount=cellfun(@isnan, AllImg_data,'UniformOutput',0) ;
AllImg_NaNcount=cellfun(@(x) sum(x(:)), AllImg_NaNcount,'UniformOutput',0);
df.NaNcount=[AllImg_NaNcount{:}]';

AllImg_Mean=cellfun(@(x) nanmean(x(:)), AllImg_data,'UniformOutput',0);
df.AllImg_Mean=[AllImg_Mean{:}]';

AllImg_IQR=cellfun(@(x) iqr(x(:)), AllImg_data,'UniformOutput',0);
df.AllImg_IQR=[AllImg_IQR{:}]';


toc/60

save([df_name '_checks.mat'], 'df')