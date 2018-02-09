function summary_stat=smooth_SE(summary_stat,mask)
% Function for
% a) smoothing the SE images in GIV summary objects
% and b) obtaining "pseudo-z" maps (z-maps based on smoothened error maps
% for permutation testing.
    SEimg=NaN(size(mask));
    SEimg_out=NaN(size(mask));
    SEimg(mask==1)=summary_stat.fixed.SEsummary;
    spm_smooth(SEimg,SEimg_out,[6,6,6]);
    summary_stat.fixed.SEsummary_smooth=SEimg_out(mask==1)';
    summary_stat.fixed.z_smooth=summary_stat.fixed.summary ./ ...
                                summary_stat.fixed.SEsummary_smooth;
    
    SEimg=NaN(size(mask));
    SEimg_out=NaN(size(mask));
    SEimg(mask==1)=summary_stat.random.SEsummary;
    spm_smooth(SEimg,SEimg_out,[6,6,6]);
    summary_stat.random.SEsummary_smooth=SEimg_out(mask==1)';
    summary_stat.random.z_smooth=summary_stat.random.summary ./ ...
                                summary_stat.random.SEsummary_smooth;                        
end