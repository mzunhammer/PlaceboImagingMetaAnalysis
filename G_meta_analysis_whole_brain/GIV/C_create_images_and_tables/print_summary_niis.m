function print_summary_niis(summary,statmask,label,outpath)
addpath(genpath(fullfile(userpath,'/CanlabCore/CanlabCore'))); % Required for FDR thresholding

p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
mask_path=fullfile(filesep,splitp{1:end-4},'pattern_masks','brainmask_logical_50.nii');


template=zeros(size(statmask));

%% Print images for heterogeneity
%I^2 unthresholded
outpath_het=fullfile(outpath,'heterogeneity');
outimg_Isq=template;
outimg_Isq(statmask)=summary.heterogeneity.Isq;
print_image(outimg_Isq,mask_path,fullfile(outpath_het,[label,'_Isq']));
%I^2 thresholded at p<.001 uncorrected
outimg_Isq_p001=template;
outimg_Isq_p001(statmask)=summary.heterogeneity.Isq.*(summary.heterogeneity.p_het<.001);
print_image(outimg_Isq_p001,mask_path,fullfile(outpath_het,[label,'_Isq_p001']))
%I^2 thresholded at pperm<.05 (FWE corrected)
outimg_Isq_pperm_FWE05=template;
outimg_Isq_pperm_FWE05(statmask)=summary.heterogeneity.Isq.*(summary.heterogeneity.perm.p_FWE<.05);
print_image(outimg_Isq_pperm_FWE05,mask_path,fullfile(outpath_het,[label,'_Isq_pperm_FWE05']))
%Tau unthresholded
outimg_tau=template;
outimg_tau(statmask)=sqrt(summary.heterogeneity.tausq);
print_image(outimg_tau,mask_path,fullfile(outpath_het,[label,'_tau']));
%Tau thresholded at p<.001 uncorrected
outimg_tau_p001=template;
outimg_tau_p001(statmask)=sqrt(summary.heterogeneity.tausq).*(summary.heterogeneity.p_het<.001);
print_image(outimg_tau_p001,mask_path,fullfile(outpath_het,[label,'_tau_p001']))
%Tau thresholded at pperm<.05 (FWE corrected)
outimg_tau_pperm_FWE05=template;
outimg_tau_pperm_FWE05(statmask)=sqrt(summary.heterogeneity.tausq).*(summary.heterogeneity.perm.p_FWE<.05);
print_image(outimg_tau_pperm_FWE05,mask_path,fullfile(outpath_het,[label,'_tau_pperm_FWE05']))
%Chi^2 unthresholded
outimg_chisq=template;
outimg_chisq(statmask)=summary.heterogeneity.chisq;
print_image(outimg_chisq,mask_path,fullfile(outpath_het,[label,'_chisq']));
%p heterogeneity uncorrected
outimg_phet=template;
outimg_phet(statmask)=summary.heterogeneity.p_het;
print_image(outimg_phet,mask_path,fullfile(outpath_het,[label,'_phet']));
%p heterogeneity pperm
outimg_phetperm=template;
outimg_phetperm(statmask)=summary.heterogeneity.perm.p_FWE;
print_image(outimg_phetperm,mask_path,fullfile(outpath_het,[label,'_phetperm']));

%% Print supplementary information (same for fixed and random)
%n of outcome unthresholded
outimg_Nmain=template;
outimg_Nmain(statmask)=summary.n;
print_image(outimg_Nmain,mask_path,fullfile(outpath,[label,'_n']));

%df of outcome unthresholded
outimg_df=template;
outimg_df(statmask)=summary.random.df;
print_image(outimg_df,mask_path,fullfile(outpath,[label,'_df']));


%% Print images for main effect FIXED
outpath_fixed=fullfile(outpath,'fixed');

%main (fixed effects) outcome unthresholded
outimg_main=template;
outimg_main(statmask)=summary.fixed.summary;
print_image(outimg_main,mask_path,fullfile(outpath_fixed,[label,'_unthresh']));
%main (fixed effects) outcome at p<.001 uncorrected
outimg_main_p001=template;
outimg_main_p001(statmask)=summary.fixed.summary.*(summary.fixed.p<.001);
print_image(outimg_main_p001,mask_path,fullfile(outpath_fixed,[label,'_p001']))
%main (fixed effects) outcome at p FDR
outimg_main_p_FDR=template;
outimg_main_p_FDR(statmask)=summary.fixed.summary.*(summary.fixed.p<summary.fixed.p_FDR_thresh);
print_image(outimg_main_p_FDR,mask_path,fullfile(outpath_fixed,[label,'_p_FDR']))
%main (fixed effects) outcome at pperm<.001 (uncorrected)
outimg_main_pperm_001=template;
outimg_main_pperm_001(statmask)=summary.fixed.summary.*(summary.fixed.perm.p_uncorr<.05);
print_image(outimg_main_pperm_001,mask_path,fullfile(outpath_fixed,[label,'_pperm_p001']))
%main (fixed effects) outcome at pperm FDR
outimg_main_pperm_FDR=template;
outimg_main_pperm_FDR(statmask)=summary.fixed.summary.*(summary.fixed.perm.p_uncorr<summary.fixed.perm.pperm_FDR_thresh);
print_image(outimg_main_pperm_FDR,mask_path,fullfile(outpath_fixed,[label,'_pperm_FDR']))

%main (fixed effects) outcome at pperm<.05 (FWE corrected)
outimg_main_pperm_FWE05=template;
outimg_main_pperm_FWE05(statmask)=summary.fixed.summary.*(summary.fixed.perm.p_FWE<.05);
print_image(outimg_main_pperm_FWE05,mask_path,fullfile(outpath_fixed,[label,'_pperm_FWE05']))

%SE of main (fixed effects) outcome unthresholded
outimg_SEmain=template;
outimg_SEmain(statmask)=summary.fixed.SEsummary;
print_image(outimg_SEmain,mask_path,fullfile(outpath_fixed,[label,'_SE']));

%SEsmooth of main (fixed effects) outcome unthresholded
outimg_SEsmooth=template;
outimg_SEsmooth(statmask)=summary.fixed.SEsummary_smooth;
print_image(outimg_SEsmooth,mask_path,fullfile(outpath_fixed,[label,'_SE_smooth']));

%z of main (fixed effects) outcome unthresholded
outimg_z=template;
outimg_z(statmask)=summary.fixed.z;
print_image(outimg_z,mask_path,fullfile(outpath_fixed,[label,'_z']));

%(pseudo-)z of main (fixed effects) outcome unthresholded, based on
%smoothed SE
outimg_z_smooth=template;
outimg_z_smooth(statmask)=summary.fixed.z_smooth;
print_image(outimg_z_smooth,mask_path,fullfile(outpath_fixed,[label,'_z_smooth']));

%full p of main (fixed effects) outcome  uncorrected
outimg_p=template;
outimg_p(statmask)=summary.fixed.p;
print_image(outimg_p,mask_path,fullfile(outpath_fixed,[label,'_p_map']));
%full p of main (fixed effects) outcome  pperm
outimg_pperm=template;
outimg_pperm(statmask)=summary.fixed.perm.p_FWE;
print_image(outimg_pperm,mask_path,fullfile(outpath_fixed,[label,'_pmapperm_FWE05']));


%% Print images for main effect RANDOM
outpath_random=fullfile(outpath,'random');

%main (random effects) outcome unthresholded
outimg_main=template;
outimg_main(statmask)=summary.random.summary;
print_image(outimg_main,mask_path,fullfile(outpath_random,[label,'_unthresh']));
%main (random effects) outcome at p<.001 uncorrected
outimg_main_p001=template;
outimg_main_p001(statmask)=summary.random.summary.*(summary.random.p<.001);
print_image(outimg_main_p001,mask_path,fullfile(outpath_random,[label,'_p001']))
%main (random effects) outcome at p FDR
outimg_main_p_FDR=template;
outimg_main_p_FDR(statmask)=summary.random.summary.*(summary.random.p<summary.random.p_FDR_thresh);
print_image(outimg_main_p_FDR,mask_path,fullfile(outpath_random,[label,'_p_FDR']))
%main (random effects) outcome at pperm<.001 (uncorrected)
outimg_main_pperm_001=template;
outimg_main_pperm_001(statmask)=summary.random.summary.*(summary.random.perm.p_uncorr<.05);
print_image(outimg_main_pperm_001,mask_path,fullfile(outpath_random,[label,'_pperm_p001']))
%main (random effects) outcome at pperm FDR
outimg_main_pperm_FDR=template;
outimg_main_pperm_FDR(statmask)=summary.random.summary.*(summary.random.perm.p_uncorr<summary.random.perm.pperm_FDR_thresh);
print_image(outimg_main_pperm_FDR,mask_path,fullfile(outpath_random,[label,'_pperm_FDR']))
%main (random effects) outcome at pperm<.05 (FWE corrected)
outimg_main_pperm_FWE05=template;
outimg_main_pperm_FWE05(statmask)=summary.random.summary.*(summary.random.perm.p_FWE<.05);
print_image(outimg_main_pperm_FWE05,mask_path,fullfile(outpath_random,[label,'_pperm_FWE05']))
%SE of main (random effects) outcome unthresholded
outimg_SEmain=template;
outimg_SEmain(statmask)=summary.random.SEsummary;
print_image(outimg_SEmain,mask_path,fullfile(outpath_random,[label,'_SE']));
%SEsmooth of main (random effects) outcome unthresholded
outimg_SEsmooth=template;
outimg_SEsmooth(statmask)=summary.random.SEsummary_smooth;
print_image(outimg_SEsmooth,mask_path,fullfile(outpath_random,[label,'_SE_smooth']));

%z of main (random effects) outcome unthresholded
outimg_z=template;
outimg_z(statmask)=summary.random.z;
print_image(outimg_z,mask_path,fullfile(outpath_random,[label,'_z']));
%(pseudo-)z of main (random effects) outcome unthresholded, based on
%smoothed SE
outimg_z_smooth=template;
outimg_z_smooth(statmask)=summary.random.z_smooth;
print_image(outimg_z_smooth,mask_path,fullfile(outpath_random,[label,'_z_smooth']));

%full p of main (random effects) outcome  uncorrected
outimg_p=template;
outimg_p(statmask)=summary.random.p;
print_image(outimg_p,mask_path,fullfile(outpath_random,[label,'_p_map']));
%full p of main (random effects) outcome  pperm
outimg_pperm=template;
outimg_pperm(statmask)=summary.random.perm.p_uncorr;
print_image(outimg_pperm,mask_path,fullfile(outpath_random,[label,'_p_map_perm']));
%full p of main (random effects) outcome  pperm FWE
outimg_pperm=template;
outimg_pperm(statmask)=summary.random.perm.p_FWE;
print_image(outimg_pperm,mask_path,fullfile(outpath_random,[label,'_p_map_perm_FWE']));
