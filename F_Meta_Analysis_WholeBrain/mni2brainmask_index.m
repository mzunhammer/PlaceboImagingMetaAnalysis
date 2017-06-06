function [matrix_coordinate, array_coordinate, masked_array_coordinate]=mni2brainmask_index(mni_coordinate)
%Get brainmak
p = mfilename('fullpath'); %CANlab's apply mask do not like lists with relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
maskdir=fullfile(filesep,splitp{1:end-2},'pattern_masks');
maskpath=fullfile(maskdir,'brainmask_logical_50.nii');

%Transform MNI coordinates in matrix coordinates
[matrix_coordinate, array_coordinate, masked_array_coordinate]=mni2mat(mni_coordinate,maskpath);
end