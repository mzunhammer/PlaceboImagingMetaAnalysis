%% Only once to get a mask excluding all voxels where signal == 0 in more
% than 5% of cases.
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
load('A1_Full_Img_Data.mat')

alldata=[vertcat(df_full.pladata{:});vertcat(df_full.condata{:})];
null_voxels=sum(alldata==0)/size(alldata,1);
null_trshld=0.08;
mask_exvoxels=null_voxels<null_trshld;
sum(mask_exvoxels)/length(mask_exvoxels);
hist(null_voxels,50);
hold on
vline(null_trshld)
hold off

printImage(mask_exvoxels,'mask_min_8_percent_of_all')
toc/60