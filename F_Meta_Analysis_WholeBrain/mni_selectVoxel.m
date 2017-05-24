function [voxel_coordinate, array_coordinate]=mni_selectVoxel(mni_coordinate,maskpath)
maskheader=spm_vol(maskpath);
mask=logical(spm_read_vols(maskheader));
masking=mask(:);
T=maskheader.mat; %Get transformation matrix from mask header

voxel_coordinate=[mni_coordinate(:,1) mni_coordinate(:,2) mni_coordinate(:,3) ones(size(mni_coordinate,1),1)]*(inv(T))';
voxel_coordinate(:,4)=[];
voxel_coordinate=round(voxel_coordinate);
array_coordinate=sub2ind(size(mask),voxel_coordinate(1),voxel_coordinate(2),voxel_coordinate(3));
end
