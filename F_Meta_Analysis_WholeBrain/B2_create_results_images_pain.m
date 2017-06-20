%% Create results images and analyze FULL sample results

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')
load('B1_Full_Sample_Summary_Pain.mat')
load('Full_Sample_Permuted_Thresholds_Pain.mat')

studyIDtexts={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010';...
            'Ruetgen et al. 2015:';...
            'Schenk et al. 2015:';...
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:';...
            'Zeidan et al. 2015:';...
            };

%% Pain vs baseline maps
%  (NO PERMUTATION TEST YET! Requires different shuffling procedure)
%I^2 unthresholded.
outimg_Isq=zeros(size(df_full_masked.brainmask));
outimg_Isq(df_full_masked.brainmask)=summary_pain.g.heterogeneity.Isq;
printImage(outimg_Isq,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pain_min10perc_Isq'))

%I^2 thresholded at p<.001 uncorrected. 
outimg_Isq_p001=zeros(size(df_full_masked.brainmask));
p001=summary_pain.g.heterogeneity.Isq;
p001(summary_pain.g.heterogeneity.p_het>.001)=0;
outimg_Isq_p001(df_full_masked.brainmask)=p001;
printImage(outimg_Isq_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pain_min10perc_Isq_p001'))

%g:
outimg_g=zeros(size(df_full_masked.brainmask));
outimg_g(df_full_masked.brainmask)=summary_pain.g.random.summary;
printImage(outimg_g,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pain_min10perc_g'))

%SE:
outimg_g=zeros(size(df_full_masked.brainmask));
outimg_g(df_full_masked.brainmask)=summary_pain.g.random.SEsummary;
printImage(outimg_g,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pain_min10perc_SEg'))

%z: Fazit:
outimg_z=zeros(size(df_full_masked.brainmask));
outimg_z(df_full_masked.brainmask)=summary_pain.g.random.z;
printImage(outimg_z,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pain_min10perc_z'))

%z-thresholded at p<.001 uncorrected. Fazit: 
outimg_z_p001=zeros(size(df_full_masked.brainmask));
p001=summary_pain.g.random.z;
p001(summary_pain.g.random.p>.001)=0;
outimg_z_p001(df_full_masked.brainmask)=p001;
printImage(outimg_z_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pain_min10perc_z_p001'))

%z thresholded at pperm<.05 (corrected for multiple comparisons). Fazit: 
pperm05=summary_pain.g.random.z;
sub_supra_treshold=summary_pain.g.random.z<trshld.g.min_z|summary_pain.g.random.z>trshld.g.max_z;
pperm05(~sub_supra_treshold)=0;
outimg_z_pperm05=zeros(size(df_full_masked.brainmask));
outimg_z_pperm05(df_full_masked.brainmask)=pperm05;
printImage(outimg_z_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pain_min10perc_z_pperm05'))
%% Explore VOI PAIN
% Best peak around left hippocampus
VOI=find(summary_pain.g.random.summary==max(summary_pain.g.random.summary));
VOI_stats=stat_reduce(pain_stats,VOI);
VOI_summary=ForestPlotter(VOI_stats,...
                  'studyIDtexts',studyIDtexts,...
                  'outcomelabel','Maximum g Voxel: Hedges'' g',...
                  'type','random',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0);

outimg_mark_VOI=zeros(size(df_full_masked.brainmask));
out_mark=zeros(size(summary_pain.g.heterogeneity.Isq));
out_mark(VOI)=1;
outimg_mark_VOI(df_full_masked.brainmask)=out_mark;
printImage(outimg_mark_VOI,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','VOI'))


min(summary_placebo.g.random.summary)
max(summary_placebo.g.random.summary)
min(summary_placebo.g.random.z)
max(summary_placebo.g.random.z)
min(summary_placebo.g.heterogeneity.Isq)
max(summary_placebo.g.heterogeneity.Isq)
min(summary_placebo.r_external.random.summary)
max(summary_placebo.r_external.random.summary)
min(summary_placebo.r_external.random.z)
max(summary_placebo.r_external.random.z)
