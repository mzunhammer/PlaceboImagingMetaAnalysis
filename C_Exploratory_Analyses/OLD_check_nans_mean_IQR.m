clear

%% Load all images and compute NaNcount, ImgMean, IQR
% Takes about 22 minutes for all data
%Load Dataframe
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets/';
cd(datapath)
df_path='AllData_w_NPS_MHE_NOBRAIN.mat';
load(df_path);

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

save([df_path '_checks.mat'], 'df')

%% Plot Histogram of NaNs per study/condition
studies=unique(df.studyID);

for i=1:length(studies)
   istudy=strcmp(df.studyID,studies(i)); 
   conditions=unique(df.cond(istudy));
   figure('name',studies{i})
   hold on
   for j=1:length(conditions)
   iscond=strcmp(df.cond,conditions(j));
   istudycond=istudy & iscond;
   histogram(df.NaNcount(istudycond),10)
   end
   hold off
end
%% Plot Histogram of Mean Image Signal per study/condition
for i=1:length(studies)
   istudy=strcmp(df.studyID,studies(i)); 
   conditions=unique(df.cond(istudy));
   figure('name',studies{i})
   hold on
   for j=1:length(conditions)
   iscond=strcmp(df.cond,conditions(j));
   istudycond=istudy & iscond;
        histogram(df.AllImg_Mean(istudycond),10)
   end
   hold off
end

%% Plot Histogram of Inter-Quartile Range per study/condition
for i=1:length(studies)
   istudy=strcmp(df.studyID,studies(i)); 
   conditions=unique(df.cond(istudy));
   figure('name',studies{i})
   hold on
   for j=1:length(conditions)
   iscond=strcmp(df.cond,conditions(j));
   istudycond=istudy & iscond;
        histogram(df.AllImg_IQR(istudycond),10)
   end
   hold off
end