function B_check_coverage_NPS()
% Compute NPS (The CAN Toolbox must be added to path!!!!)
addpath(genpath(fullfile(userpath,'/CanlabCore/CanlabCore')));
[currpath,~,~]=fileparts(mfilename('fullpath'));
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
maskdir=fullfile(filesep,splitp{1:end-3},'pattern_masks');


% This is a binarized version of the NPS
NPS_maskpath=fullfile(userpath,'/CanlabPatternMasks/MasksPrivate/Masks_private/2013_Wager_NEJM_NPS/weights_NSF_grouppred_cvpcr_mask.nii');

nps_voxels_covered_imgs=apply_patternmask(fullfile(currpath,'/results/check_coverage_full_sample_pla.nii'),...
            NPS_maskpath);
 
% Gets number of NPS-voxels in the brain
nps_voxels_in_brain=apply_patternmask(fullfile(maskdir,'/brainmask_logical.nii'),...
            NPS_maskpath);
        
prop_nps_voxels_covered_imgs=nps_voxels_covered_imgs{:}/nps_voxels_in_brain{:};

disp(['The coverage of the NPS mask for the full sample is ', num2str(prop_nps_voxels_covered_imgs*100),' % of NPS-brain voxels.' ])
end