function printImage(masked_stats,outbasename)

% Backtransform to image
maskheader=spm_vol('../../pattern_masks/brainmask_logical.nii,1');
mask=logical(spm_read_vols(maskheader));
masking=mask(:);
outImg=zeros(size(mask));

% Print Pain all
outImg(masking)=masked_stats;
outpath=fullfile([outbasename,'.nii']);
outheader=maskheader;
outheader.fname=outpath;
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
spm_write_vol(outheader,outImg);

% Print Pain positive effects only
outImg(masking)=masked_stats;
outImg(outImg<0)=0;
outpath=fullfile([outbasename,'_pos.nii']);
outheader=maskheader;
outheader.fname=outpath;
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
spm_write_vol(outheader,outImg);

% Print Pain negative effects only
outImg(masking)=masked_stats.*-1;
outImg(outImg<0)=0;
outpath=fullfile([outbasename,'_neg.nii']);
outheader=maskheader;
outheader.fname=outpath;
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
spm_write_vol(outheader,outImg);

end