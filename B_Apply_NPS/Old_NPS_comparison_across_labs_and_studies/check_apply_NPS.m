% Basic NPS checks

% Calculate NPS value for a sample image in .hrd/.img format
apply_nps('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/NPS_diagnostics/TestImage.img')
% Calculate NPS value for the same sample image in .nii format
apply_nps('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/NPS_diagnostics/TestImageX1.nii')
% Calculate NPS for the same sample image in .nii format, values in all
% voxels multiplied by 2.
apply_nps('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/NPS_diagnostics/TestImageX2.nii')

% >> image format does not matter, but NPS values follow
% scaling differences in raw data linearly.