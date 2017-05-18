function printImage_unmasked(stats,outbasename)

p = mfilename('fullpath'); %CANlab's apply mask do not like lists with relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
maskdir=fullfile(filesep,splitp{1:end-2},'pattern_masks');
% Backtransform to image
maskheader=spm_vol(fullfile(maskdir,'/brainmask_logical.nii,1'));
mask=spm_read_vols(maskheader);
outImg=zeros(size(mask));

% Print Pain all
outImg(:)=stats;
outpath=fullfile(outbasename,'.nii');
outheader=maskheader;
outheader.fname=outpath;
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
spm_write_vol(outheader,outImg);

% Print Pain positive effects only
outImg(:)=stats;
outImg(outImg<0)=0;
outpath=fullfile(outbasename,'_pos.nii');
outheader=maskheader;
outheader.fname=outpath;
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
spm_write_vol(outheader,outImg);

% Print Pain negative effects only
outImg(:)=stats.*-1;
outImg(outImg<0)=0;
outpath=fullfile(outbasename,'_neg.nii');
outheader=maskheader;
outheader.fname=outpath;
outheader=rmfield(outheader,'pinfo'); %remove pinfo otherwise there may be scaling problems with the data
spm_write_vol(outheader,outImg);
end