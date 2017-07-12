clear
% Compute NPS (The CAN Toolbox must be added to path!!!!)
addpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/CanlabCore/CanlabCore'))
addpath(genpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/pattern_masks'))

nps_voxels_covered_imgs=apply_patternmask('../../D_Exploratory_Analyses/A_Check_Image_Alignment/Check_coverage_all_images.nii',...
            '../../../pattern_masks/weights_NSF_grouppred_cvpcr_mask.nii');
        
nps_voxels_missing_subjects=apply_patternmask('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/F_Meta_Analysis_WholeBrain/nii_results/Percent_Missing.nii',...
            '../../../pattern_masks/weights_NSF_grouppred_cvpcr_mask.nii');
          
nps_voxels_in_brain=apply_patternmask('../../../pattern_masks/brainmask.nii',...
            '../../../pattern_masks/weights_NSF_grouppred_cvpcr_mask.nii');

        
prop_nps_voxels_covered_imgs=nps_voxels_covered_imgs{:}/nps_voxels_in_brain{:};
prop_nps_voxels_missing_subs=(nps_voxels_missing_subjects{:})/nps_voxels_in_brain{:};
prop_nps_voxels_covered_subs=(nps_voxels_in_brain{:}-nps_voxels_missing_subjects{:})/nps_voxels_in_brain{:};

disp(['The average coverage of the NPS mask (counting all images) is', num2str(prop_nps_voxels_covered_imgs*100),'%' ])
disp(['The average coverage of the NPS mask (counting all subjects) is ', num2str(prop_nps_voxels_covered_subs*100),'%' ])

rmpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/CanlabCore/CanlabCore'))
