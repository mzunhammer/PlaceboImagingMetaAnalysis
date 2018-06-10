function v=v_masked(nii_imgs)
% Wrapper function used to reduce code in A1_Select_All_and_Conservative
% when loading nii images as brain-masked vectors.
p = mfilename('fullpath'); %CANlab's apply mask do not like lists with relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,['(?<!^)',filesep], 'DelimiterType','RegularExpression');
maskdir=fullfile(splitp{1:end-2},'pattern_masks');
v=nii2vector(nii_imgs,fullfile(maskdir,'brainmask_logical_50.nii')); % brainmask thresholded at a cut-off of 50% brain tissue probability