function v=nii2vector(nii_imgs,mask_img)

if (exist('mask_img'))
    % Load mask
    maskheader=spm_vol(mask_img);
    mask=logical(spm_read_vols(maskheader)); 
else
    sample_img=spm_read_vols(spm_vol(nii_imgs{1}));
    mask=ones(size(sample_img));
end
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
    v(i,:)=currdat(masking)';
end
toc/60;

% Replace NaN-Voxels with 0
% I'd prefer NaNs, but in most images this was done beforehand.
v(isnan(v))=0;
end