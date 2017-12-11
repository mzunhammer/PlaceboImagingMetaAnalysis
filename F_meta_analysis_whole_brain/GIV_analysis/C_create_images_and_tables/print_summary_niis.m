function print_summary_niis(summary,statmask,label,outpath)

brainmask='../../pattern_masks/brainmask_logical_50.nii';

template=zeros(size(statmask));

%% Print images for heterogeneity
%I^2 unthresholded
outpath_het=fullfile(outpath,'heterogeneity');
outimg_Isq=template;
outimg_Isq(statmask)=summary.heterogeneity.Isq;
printImage(outimg_Isq,brainmask,fullfile(outpath_het,[label,'_Isq']));
%I^2 thresholded at p<.001 uncorrected
outimg_Isq_p001=template;
outimg_Isq_p001(statmask)=summary.heterogeneity.Isq.*(summary.heterogeneity.p_het<.001);
printImage(outimg_Isq_p001,brainmask,fullfile(outpath_het,[label,'_Isq_p001']))
%I^2 thresholded at pperm<.05 
outimg_Isq_pperm05=template;
outimg_Isq_pperm05(statmask)=summary.heterogeneity.Isq.*(summary.heterogeneity.perm.p<.05);
printImage(outimg_Isq_pperm05,brainmask,fullfile(outpath_het,[label,'_Isq_pperm05']))
%Tau unthresholded
outimg_tau=template;
outimg_tau(statmask)=sqrt(summary.heterogeneity.tausq);
printImage(outimg_tau,brainmask,fullfile(outpath_het,[label,'_tau']));
%Tau thresholded at p<.001 uncorrected
outimg_tau_p001=template;
outimg_tau_p001(statmask)=sqrt(summary.heterogeneity.tausq).*(summary.heterogeneity.p_het<.001);
printImage(outimg_tau_p001,brainmask,fullfile(outpath_het,[label,'_tau_p001']))
%Tau thresholded at pperm<.05 
outimg_tau_pperm05=template;
outimg_tau_pperm05(statmask)=sqrt(summary.heterogeneity.tausq).*(summary.heterogeneity.perm.p<.05);
printImage(outimg_tau_pperm05,brainmask,fullfile(outpath_het,[label,'_tau_pperm05']))
%Chi^2 unthresholded
outimg_chisq=template;
outimg_chisq(statmask)=summary.heterogeneity.chisq;
printImage(outimg_chisq,brainmask,fullfile(outpath_het,[label,'_chisq']));
%p heterogeneity uncorrected
outimg_phet=template;
outimg_phet(statmask)=summary.heterogeneity.p_het;
printImage(outimg_phet,brainmask,fullfile(outpath_het,[label,'_phet']));
%p heterogeneity pperm
outimg_phetperm=template;
outimg_phetperm(statmask)=summary.heterogeneity.perm.p;
printImage(outimg_phetperm,brainmask,fullfile(outpath_het,[label,'_phetperm']));

%% Print supplementary information (same for fixed and random)
%n of outcome unthresholded
outimg_Nmain=template;
outimg_Nmain(statmask)=summary.n;
printImage(outimg_Nmain,brainmask,fullfile(outpath,[label,'_n']));

%df of outcome unthresholded
outimg_df=template;
outimg_df(statmask)=summary.random.df;
printImage(outimg_df,brainmask,fullfile(outpath,[label,'_df']));


%% Print images for main effect FIXED
outpath_fixed=fullfile(outpath,'fixed');

%main (fixed effects) outcome unthresholded
outimg_main=template;
outimg_main(statmask)=summary.fixed.summary;
printImage(outimg_main,brainmask,fullfile(outpath_fixed,[label,'_unthreshFixed']));
%main (fixed effects) outcome at p<.001 uncorrected
outimg_main_p001=template;
outimg_main_p001(statmask)=summary.fixed.summary.*(summary.fixed.p<.001);
printImage(outimg_main_p001,brainmask,fullfile(outpath_fixed,[label,'_p001Fixed']))
%main (fixed effects) outcome at pperm<.05 
outimg_main_pperm05=template;
outimg_main_pperm05(statmask)=summary.fixed.summary.*(summary.fixed.perm.p<.05);
printImage(outimg_main_pperm05,brainmask,fullfile(outpath_fixed,[label,'_pperm05Fixed']))

%main (fixed effects) outcome, for summary (g or r) >.1 
outimg_main_g10=template;
outimg_main_g10(statmask)=summary.fixed.summary.*(abs(summary.fixed.summary)>=.10);
printImage(outimg_main_g10,brainmask,fullfile(outpath_fixed,[label,'_g10Fixed']))
%main (fixed effects) outcome, for summary (g or r) >.15
outimg_main_g15=template;
outimg_main_g15(statmask)=summary.fixed.summary.*(abs(summary.fixed.summary)>=.15);
printImage(outimg_main_g15,brainmask,fullfile(outpath_fixed,[label,'_g15Fixed']))
%main (fixed effects) outcome, for summary (g or r) >.20
outimg_main_g20=template;
outimg_main_g20(statmask)=summary.fixed.summary.*(abs(summary.fixed.summary)>=.20);
printImage(outimg_main_g20,brainmask,fullfile(outpath_fixed,[label,'_g20Fixed']))

%SE of main (fixed effects) outcome unthresholded
outimg_SEmain=template;
outimg_SEmain(statmask)=summary.fixed.SEsummary;
printImage(outimg_SEmain,brainmask,fullfile(outpath_fixed,[label,'_SEFixed']));

%z of main (fixed effects) outcome unthresholded
outimg_z=template;
outimg_z(statmask)=summary.fixed.z;
printImage(outimg_z,brainmask,fullfile(outpath_fixed,[label,'_zFixed']));
%full p of main (fixed effects) outcome  uncorrected
outimg_p=template;
outimg_p(statmask)=summary.fixed.p;
printImage(outimg_p,brainmask,fullfile(outpath_fixed,[label,'_pmap001Fixed']));
%full p of main (fixed effects) outcome  pperm
outimg_pperm=template;
outimg_pperm(statmask)=summary.fixed.perm.p;
printImage(outimg_pperm,brainmask,fullfile(outpath_fixed,[label,'_pmapperm05Fixed']));


%% Print images for main effect RANDOM
outpath_random=fullfile(outpath,'random');

%main (random effects) outcome unthresholded
outimg_main=template;
outimg_main(statmask)=summary.random.summary;
printImage(outimg_main,brainmask,fullfile(outpath_random,[label,'_unthresh']));
%main (random effects) outcome at p<.001 uncorrected
outimg_main_p001=template;
outimg_main_p001(statmask)=summary.random.summary.*(summary.random.p<.001);
printImage(outimg_main_p001,brainmask,fullfile(outpath_random,[label,'_p001']))
%main (random effects) outcome at pperm<.05 
outimg_main_pperm05=template;
outimg_main_pperm05(statmask)=summary.random.summary.*(summary.random.perm.p<.05);
printImage(outimg_main_pperm05,brainmask,fullfile(outpath_random,[label,'_pperm05']))
%main (random effects) outcome, for summary (g or r) >.1 
outimg_main_g10=template;
outimg_main_g10(statmask)=summary.random.summary.*(abs(summary.random.summary)>=.10);
printImage(outimg_main_g10,brainmask,fullfile(outpath_random,[label,'_g10']))
%main (random effects) outcome, for summary (g or r) >.15
outimg_main_g15=template;
outimg_main_g15(statmask)=summary.random.summary.*(abs(summary.random.summary)>=.15);
printImage(outimg_main_g15,brainmask,fullfile(outpath_random,[label,'_g15']))
%main (random effects) outcome, for summary (g or r) >.20
outimg_main_g20=template;
outimg_main_g20(statmask)=summary.random.summary.*(abs(summary.random.summary)>=.20);
printImage(outimg_main_g20,brainmask,fullfile(outpath_random,[label,'_g20']))

%SE of main (random effects) outcome unthresholded
outimg_SEmain=template;
outimg_SEmain(statmask)=summary.random.SEsummary;
printImage(outimg_SEmain,brainmask,fullfile(outpath_random,[label,'_SE']));

%z of main (random effects) outcome unthresholded
outimg_z=template;
outimg_z(statmask)=summary.random.z;
printImage(outimg_z,brainmask,fullfile(outpath_random,[label,'_z']));
%full p of main (random effects) outcome  uncorrected
outimg_p=template;
outimg_p(statmask)=summary.random.p;
printImage(outimg_p,brainmask,fullfile(outpath_random,[label,'_pmap001']));
%full p of main (random effects) outcome  pperm
outimg_pperm=template;
outimg_pperm(statmask)=summary.random.perm.p;
printImage(outimg_pperm,brainmask,fullfile(outpath_random,[label,'_pmapperm05']));
