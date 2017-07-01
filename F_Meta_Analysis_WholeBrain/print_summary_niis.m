function print_summary_niis(summary,statmask,label)

outpath='./nii_results';
brainmask='../../pattern_masks/brainmask_logical_50.nii';

template=zeros(size(statmask));

%% Print images for heterogeneity
%I^2 unthresholded
outimg_Isq=template;
outimg_Isq(statmask)=summary.heterogeneity.Isq;
printImage(outimg_Isq,brainmask,fullfile(outpath,[label,'_Isq']));
%I^2 thresholded at p<.001 uncorrected
outimg_Isq_p001=template;
outimg_Isq_p001(statmask)=summary.heterogeneity.Isq.*(summary.heterogeneity.p_het<.001);
printImage(outimg_Isq_p001,brainmask,fullfile(outpath,[label,'_Isq_p001']))
%I^2 thresholded at pperm<.05 
outimg_Isq_pperm05=template;
outimg_Isq_pperm05(statmask)=summary.heterogeneity.Isq.*(summary.heterogeneity.perm.p<.05);
printImage(outimg_Isq_pperm05,brainmask,fullfile(outpath,[label,'_Isq_pperm05']))
%Chi^2 unthresholded
outimg_chisq=template;
outimg_chisq(statmask)=summary.heterogeneity.chisq;
printImage(outimg_chisq,brainmask,fullfile(outpath,[label,'_chisq']));
%p heterogeneity uncorrected
outimg_phet=template;
outimg_phet(statmask)=summary.heterogeneity.p_het;
printImage(outimg_phet,brainmask,fullfile(outpath,[label,'_phet']));
%p heterogeneity pperm
outimg_phetperm=template;
outimg_phetperm(statmask)=summary.heterogeneity.perm.p;
printImage(outimg_phetperm,brainmask,fullfile(outpath,[label,'_phetperm']));

%% Print images for main effect
%main (random effects) outcome unthresholded
outimg_main=template;
outimg_main(statmask)=summary.random.summary;
printImage(outimg_main,brainmask,fullfile(outpath,[label,'_unthresh']));
%main (random effects) outcome at p<.001 uncorrected
outimg_main_p001=template;
outimg_main_p001(statmask)=summary.random.summary.*(summary.random.p<.001);
printImage(outimg_main_p001,brainmask,fullfile(outpath,[label,'_p001']))
%main (random effects) outcome at pperm<.05 
outimg_main_pperm05=template;
outimg_main_pperm05(statmask)=summary.random.summary.*(summary.random.perm.p<.05);
printImage(outimg_main_pperm05,brainmask,fullfile(outpath,[label,'_pperm05']))

%% Print supplementary information 
%n of outcome unthresholded
outimg_Nmain=template;
outimg_Nmain(statmask)=summary.n;
printImage(outimg_Nmain,brainmask,fullfile(outpath,[label,'_n']));

%df of outcome unthresholded
outimg_df=template;
outimg_df(statmask)=summary.random.df;
printImage(outimg_df,brainmask,fullfile(outpath,[label,'_df']));

%SE of main (random effects) outcome unthresholded
outimg_SEmain=template;
outimg_SEmain(statmask)=summary.random.SEsummary;
printImage(outimg_SEmain,brainmask,fullfile(outpath,[label,'_SE']));

%z of main (random effects) outcome unthresholded
outimg_z=template;
outimg_z(statmask)=summary.random.z;
printImage(outimg_z,brainmask,fullfile(outpath,[label,'_z']));
%full p of main (random effects) outcome  uncorrected
outimg_p=template;
outimg_p(statmask)=summary.random.p;
printImage(outimg_p,brainmask,fullfile(outpath,[label,'_pmap001']));
%full p of main (random effects) outcome  pperm
outimg_pperm=template;
outimg_pperm(statmask)=summary.random.perm.p;
printImage(outimg_pperm,brainmask,fullfile(outpath,[label,'_pmapperm05']));
