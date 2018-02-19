function summary_stat=smooth_SE(summary_stat,mask)
% Function for
% a) smoothing the SE images in GIV summary objects
% and
% b) obtaining "pseudo-z" maps (z-maps based on smoothened error maps
% for permutation testing).
% Smoothing was implemented according to Tom Nichol's "SnPM"
% package (snpm_cp), where a smoothed mask is factored out of the smoothened SE
% to avoid edge effects.

kernel_size=[2,2,2]; % CAVE! FWHM in voxels (and not in mm) as we are working with matrices, not structs!!!

summary_stat.fixed.SEsummary_smooth=smooth_one(summary_stat.fixed.SEsummary);
summary_stat.fixed.z_smooth=summary_stat.fixed.summary ./ ...
                                summary_stat.fixed.SEsummary_smooth;
summary_stat.random.SEsummary_smooth=smooth_one(summary_stat.random.SEsummary);
summary_stat.random.z_smooth=summary_stat.random.summary ./ ...
                                summary_stat.random.SEsummary_smooth;
                            
function img_out=smooth_one(substat)
    TmpVol1=zeros(size(mask));
    TmpVol1(mask==1)=substat;
    SEimg=zeros(size(mask));

    TmpVol2=zeros(size(mask));
    TmpVol2(mask==1)=1;
    MASKimg=zeros(size(mask));
    spm_smooth(TmpVol1,SEimg,kernel_size); %smoothing of mask
    spm_smooth(TmpVol2,MASKimg,kernel_size); %actual smoothing of SE
    img_out=(SEimg(mask==1)./MASKimg(mask==1))';
end
end