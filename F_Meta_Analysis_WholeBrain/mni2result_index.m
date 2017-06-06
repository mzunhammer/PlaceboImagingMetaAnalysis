function [matrix_coordinate, array_coordinate, masked_array_coordinate]=mni2brainmask_index(mni_coordinate)
%Get brainmak
maskpath=fullfile('.','nii_results','Full_Sample_10_percent_mask.nii');

%Transform MNI coordinates in matrix coordinates
[matrix_coordinate, array_coordinate, masked_array_coordinate]=mni2mat(mni_coordinate,maskpath);
end