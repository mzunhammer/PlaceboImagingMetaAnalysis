clear
addpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/CAN/'));
% Compute NPS (The CAN Toolbox must be added to path!!!!)
nps_voxels_covered=apply_brainmask('Check_coverage_all_images.nii',...
            '/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/B_Apply_NPS/pattern_masks/weights_NSF_grouppred_cvpcr_mask.nii');

nps_voxels_in_brain=apply_brainmask('/Users/matthiaszunhammer/Documents/MATLAB/spm8/apriori/brainmask.nii',...
            '/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/B_Apply_NPS/pattern_masks/weights_NSF_grouppred_cvpcr_mask.nii');


prop_nps_voxels_covered=nps_voxels_covered{:}/nps_voxels_in_brain{:}