function [matrix_coordinate, array_coordinate, masked_array_coordinate]=mni2mat(mni_coordinate,mask_path)
mask_header=spm_vol(mask_path);
img=logical(spm_read_vols(mask_header));
img_v=img(:);
T=mask_header.mat; %Get transformation matrix from img header

matrix_coordinate=[mni_coordinate(:,1) mni_coordinate(:,2) mni_coordinate(:,3) ones(size(mni_coordinate,1),1)]*(inv(T))';
matrix_coordinate(:,4)=[];
matrix_coordinate=round(matrix_coordinate);
array_coordinate=sub2ind(size(img),matrix_coordinate(1),matrix_coordinate(2),matrix_coordinate(3));
masked_array_coordinate=find(find(img_v)==array_coordinate);
end
