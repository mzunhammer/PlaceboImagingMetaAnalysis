clear
% Compute NPS (The CAN Toolbox must be added to path!!!!)
nps_voxels_covered=apply_patternmask('../../D_Exploratory_Analyses/A_Check_Image_Alignment/Check_coverage_all_images.nii',...
            '../../../pattern_masks/weights_NSF_grouppred_cvpcr_mask.nii');

nps_voxels_in_brain=apply_patternmask('../../.../pattern_masks/brainmask.nii',...
            '../../.../pattern_masks/weights_NSF_grouppred_cvpcr_mask.nii');

        
prop_nps_voxels_covered=nps_voxels_covered{:}/nps_voxels_in_brain{:};

disp(['The average coverage of the NPS mask is ', num2str(prop_nps_voxels_covered*100),'%' ])