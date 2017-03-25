function v=nii2vector(nii_imgs)

%% Step 2: Import all images in 2d vector, masked with brainmask.
%% USE THE IMAGES (r attached to name) THAT WERE EQUALZED IN DIMENSIONS WITH A_Equalize_Image_Size_and_Mask.m

% Load mask
maskheader=spm_vol('mask_min_10_percent_of_all.nii,1');
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
toc/60

% Replace NaN-Voxels with 0
% I'd prefer NaNs, but in most images this was done beforehand.
v(isnan(v))=0;
end