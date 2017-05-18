function v=nii2vector(nii_imgs)

%Function to read nii images as double vector (brainmasked)
maskdir=fullfile('../../pattern_masks/brainmask.nii');
% Load mask
maskheader=spm_vol(maskdir);
mask=logical(spm_read_vols(maskheader));
masking=mask(:);

%Load image headers
headers=spm_vol(nii_imgs);
nimg=length(headers);
%Preallocate target matrix
v=NaN(nimg,sum(masking));
tic
for i=1:nimg
    %Load image data
    [currdat,~]=spm_read_vols(headers{i});
    v(i,:)=currdat(mask)';
end
toc/60;

% Replace NaN-Voxels with 0
% I'd prefer NaNs, but in most images this was done beforehand.
v(isnan(v))=0;
end