datapath='/Volumes/Transcend/Boulder_Essen/Datasets/';
tic
load(fullfile(datapath,'dfMaskedBasicImg.mat'));
toc

%addpath /Applications/MATLAB_R2015b.app/toolbox/stats/stats/

% Temporarily remove spm8 and spm12, since their tcdf does not go well with
% the lmer functions
% rmpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/spm8/'));
% rmpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/spm12/'));

% Display NaN-Voxels (Vertical lines indicate import problems
%imagesc(isnan(Y))
%Y(isnan(Y))=0;

% Make sure that placebo-vector contains 1 and 0 - Values only
df.pla=logical(df.pla);


% Create mean, sd and d' maps across all images (corresponds to simplified effect size of pain-activation)
meanY=mean(Y,1);
sdY=std(Y,1);
zY=meanY./sdY;

% Create mean_difference, sd and d' maps placebo vs control (corresponds to simplified effect size of placebo-activation)
meanPla=mean(Y(df.pla,:),1);
meanCon=mean(Y(~df.pla,:),1);
zPlaY=(meanPla-meanCon)./sdY;



% Backtransform to image
maskheader=spm_vol('/Users/matthiaszunhammer/Documents/MATLAB/spm8/apriori/brainmask.nii,1');
mask=spm_read_vols(maskheader);
masking=logical(mask>0);
outImg=zeros(size(mask));

% Print Pain all
outImg(masking)=zY;
outpath=fullfile(datapath,'z_image_pain.nii');
outheader=maskheader;
outheader.fname=outpath;
spm_write_vol(outheader,outImg);

% Print Pain positive effects only
outImg(masking)=zY;
outImg(outImg<0)=0;
outpath=fullfile(datapath,'z_image_pain_pos.nii');
outheader=maskheader;
outheader.fname=outpath;
spm_write_vol(outheader,outImg);

% Print Pain negative effects only
outImg(masking)=zY.*-1;
outImg(outImg<0)=0;
outpath=fullfile(datapath,'z_image_pain_neg.nii');
outheader=maskheader;
outheader.fname=outpath;
spm_write_vol(outheader,outImg);

% Print Placebo all
outImg(masking)=zPlaY;
outpath=fullfile(datapath,'z_image_placebo.nii');
outheader=maskheader;
outheader.fname=outpath;
spm_write_vol(outheader,outImg);

outImg(masking)=zPlaY;
outImg(outImg<0)=0;
outpath=fullfile(datapath,'z_image_placebo_pos.nii');
outheader=maskheader;
outheader.fname=outpath;
spm_write_vol(outheader,outImg);

outImg(masking)=zPlaY.*-1;
outImg(outImg<0)=0;
outpath=fullfile(datapath,'z_image_placebo_neg.nii');
outheader=maskheader;
outheader.fname=outpath;
spm_write_vol(outheader,outImg);