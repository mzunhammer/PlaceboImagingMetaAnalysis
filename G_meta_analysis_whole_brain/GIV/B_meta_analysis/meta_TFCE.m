function summary_stat=meta_TFCE(summary_stat,mask)
addpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/MatlabTFCE'))
% Function for
% obtaining TFCE-thresholded images based on markallenthornton/MatlabTFCE

summary_stat.fixed.tfce=TFCE_one(summary_stat.fixed.z_smooth);
summary_stat.random.tfce=TFCE_one(summary_stat.random.z_smooth);
                  
function stat_out=TFCE_one(stat)
    % Image has to be transformed to 3d before thresholding
    stat_img=zeros(size(mask));
    stat_img(mask==1)=stat;
    tfce_img=matlab_tfce_transform_twotailed(stat_img,...
                          2,0.5,26,.1);% default TFCE parameters, see matlab_tfce
    stat_out=tfce_img(mask==1)';
end
end