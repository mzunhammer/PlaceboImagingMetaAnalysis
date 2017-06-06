%% Print and label results cluster-wise
clear
load('Full_Sample_Permuted_Thresholds.mat')

% Available atlases (see: https://brainder.org/2012/07/30/automatic-atlas-queries-in-fsl/, or atlasquery --dumpatlases)
%     ?Cerebellar Atlas in MNI152 space after normalization with FLIRT?
%     ?Cerebellar Atlas in MNI152 space after normalization with FNIRT?
%     ?Harvard-Oxford Cortical Structural Atlas?
%     ?Harvard-Oxford Subcortical Structural Atlas?
%     ?JHU ICBM-DTI-81 White-Matter Labels?
%     ?JHU White-Matter Tractography Atlas?
%     ?Juelich Histological Atlas?
%     ?MNI Structural Atlas?
%     ?Oxford Thalamic Connectivity Probability Atlas?
%     ?Oxford-Imanova Striatal Connectivity Atlas 3 sub-regions?
%     ?Oxford-Imanova Striatal Connectivity Atlas 7 sub-regions?
%     ?Oxford-Imanova Striatal Structural Atlas?
%     ?Talairach Daemon Labels?

% Tabulate and label results full sample, negative and positive
print_clusters('./nii_results/Full_Sample_Pla_min10perc_z_neg.nii',...
               abs(trshld.min_z),...
               'MNI Structural Atlas',...
               './figure_results/Full_Sample_Pla_min10perc_z_neg.txt')
print_clusters('./nii_results/Full_Sample_Pla_min10perc_z_neg.nii',...
                abs(trshld.min_z),...
                'MNI Structural Atlas',...
                './figure_results/Full_Sample_Pla_min10perc_z_neg_cerebellar.txt')

print_clusters('./nii_results/Full_Sample_Pla_min10perc_z_pos.nii',...
                abs(trshld.max_z),...
                'MNI Structural Atlas',...
                './figure_results/Full_Sample_Pla_min10perc_z_pos.txt')


% Tabulate and label results full sample, heterogeneity
print_clusters('./nii_results/Full_Sample_Pla_min10perc_Isq_pperm05.nii',...
                1,... %image was pre-thresholded
                'Harvard-Oxford Cortical Structural Atlas',...
                './figure_results/Full_Sample_Pla_min10perc_Isq.nii.txt')
