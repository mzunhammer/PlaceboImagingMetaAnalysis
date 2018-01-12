function B_check_coverage_NPS()
% Compute NPS (The CAN Toolbox must be added to path!!!!)
addpath(genpath(fullfile(userpath,'/CanlabCore/CanlabCore')));
% This is a binarized version of the NPS
NPS_maskpath=fullfile(userpath,'/CanlabPatternMasks/MasksPrivate/Masks_private/2013_Wager_NEJM_NPS/weights_NSF_grouppred_cvpcr_mask.nii');

nps_voxels_covered_imgs=apply_patternmask('./results/check_coverage_full_sample_pla.nii',...
            NPS_maskpath);
 
% Gets number of NPS-voxels in the brain
nps_voxels_in_brain=apply_patternmask('../../../pattern_masks/brainmask_logical.nii',...
            NPS_maskpath);
        
prop_nps_voxels_covered_imgs=nps_voxels_covered_imgs{:}/nps_voxels_in_brain{:};

disp(['The coverage of the NPS mask for the full sample is ', num2str(prop_nps_voxels_covered_imgs*100),' % of NPS-brain voxels.' ])
end