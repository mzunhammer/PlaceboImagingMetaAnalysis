function printImage(masked_stats,outbasename)

p='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/E_Meta_Analysis_SPM';
% Backtransform to image
maskheader=spm_vol('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets/brainmask_logical.nii,1');
mask=logical(spm_read_vols(maskheader));
masking=mask(:);
outImg=zeros(size(mask));

% Print Pain all
outImg(masking)=masked_stats;
outpath=fullfile(p,[outbasename,'.nii']);
outheader=maskheader;
outheader.fname=outpath;
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
spm_write_vol(outheader,outImg);

% Print Pain positive effects only
outImg(masking)=masked_stats;
outImg(outImg<0)=0;
outpath=fullfile(p,[outbasename,'_pos.nii']);
outheader=maskheader;
outheader.fname=outpath;
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
spm_write_vol(outheader,outImg);

% Print Pain negative effects only
outImg(masking)=masked_stats.*-1;
outImg(outImg<0)=0;
outpath=fullfile(p,[outbasename,'_neg.nii']);
outheader=maskheader;
outheader.fname=outpath;
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
spm_write_vol(outheader,outImg);

end