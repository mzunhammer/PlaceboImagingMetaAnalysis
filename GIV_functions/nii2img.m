function img_data=nii2img(nii_path)
if iscellstr(nii_path)
    nii_path=nii_path{:};
end
hdr=spm_vol(nii_path);
img_data=spm_read_vols(hdr);
