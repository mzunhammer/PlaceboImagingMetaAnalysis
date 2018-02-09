function out_img = vector2img(v,mask_img)
maskheader=spm_vol(mask_img);
mask=logical(spm_read_vols(maskheader)); 
out_img=NaN(size(mask));
out_img(mask)=v;
end