%% Run once to get a mask excluding all voxels where signal == 0 in more
% than X% of cases.
clear

null_trshld=0.1; %PROPORTION OF MISSING CASES NECESSARY TO EXCLUDE A VOXEL

%% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/MontagePlot')
load('A1_Full_Sample_Img_Data.mat')

alldata=[vertcat(df_full.pla_img{:});vertcat(df_full.con_img{:})];
null_voxels=sum(alldata==0)./size(alldata,1);%get proportions of participants with a value of 0 for each voxel.
mask_exvoxels=null_voxels<null_trshld;
disp(sum(mask_exvoxels)./length(mask_exvoxels)) % print percen
hist(null_voxels,50);
hold on
vline(null_trshld)
hold off

toc/60

df_full_masked=df_full;
df_full_masked.pla_img=cellfun(@(x) x(:,mask_exvoxels),df_full.pla_img,'UniformOutput',0)
df_full_masked.con_img=cellfun(@(x) x(:,mask_exvoxels),df_full.con_img,'UniformOutput',0)

save('A1_Full_Sample_Img_Data_Masked_10_percent.mat','df_full_masked');

printImage(mask_exvoxels,'../../pattern_masks/brainmask_logical_50.nii','./nii_results/Full_Sample_10_percent_mask')
%%

load('A1_Conservative_Sample_Img_Data.mat')

alldata=[vertcat(df_conserv.pla_img{:});vertcat(df_conserv.con_img{:})];
null_voxels=sum(alldata==0)./size(alldata,1);
conserv_mask_exvoxels=null_voxels<null_trshld;
sum(conserv_mask_exvoxels)./length(conserv_mask_exvoxels);
hist(null_voxels,50);
hold on
vline(null_trshld)
hold off

df_conserv_masked=df_conserv;
df_conserv_masked.pla_img=cellfun(@(x) x(:,conserv_mask_exvoxels),df_conserv.pla_img,'UniformOutput',0);
df_conserv_masked.con_img=cellfun(@(x) x(:,conserv_mask_exvoxels),df_conserv.con_img,'UniformOutput',0);

save('A1_Conservative_Sample_Img_Data_Masked_10_percent.mat','df_conserv_masked');
toc/60
printImage(mask_exvoxels,'../../pattern_masks/brainmask_logical_50.nii','./nii_results/Full_Sample_10_percent_mask')