function voxel_vals=get_val_from_nii(nii,mni_coordinates)

[matrix_coordinate, array_coordinate, masked_array_coordinate]=mni2mat(mni_coordinates,nii);
hdr=spm_vol(nii);
img_data=spm_read_vols(hdr);
matrix_coordinate=num2cell(matrix_coordinate);%step required to pass array as subscript index
voxel_vals=img_data(matrix_coordinate{:});
