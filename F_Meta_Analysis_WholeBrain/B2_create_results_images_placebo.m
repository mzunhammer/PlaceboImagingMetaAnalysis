%% Create results images and analyze FULL sample results

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')
load('B1_Full_Sample_Summary_Placebo.mat')
load('Full_Sample_Permuted_Thresholds_Placebo.mat')
%% PLACEBO vs CONTROL
% Sanity check dfs
%df: Fazit: looks ok. df=19 in most grey matter areas of the brain, 18 in
%white matter.
% A minority of voxels (<143) has  df's of 17 or 16. These voxels showed no variance in single
% within-subject studies. No variance estimates could be obtained for these
% studies >> NaN values are set in GIVsummary in these cases.
hist(summary_placebo.g.random.df)
outimg_df=zeros(size(df_full_masked.brainmask));
outimg_df(df_full_masked.brainmask)=summary_placebo.g.random.df;
printImage(outimg_df,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_df'))

% Heterogeneity: Looks legit, INTERESTING maps!
% Fazit:
%   Foci at
%       MPFC/Cingulate
%       medial parietal
%       right parietal
%       DLPFC
%       insula/operculum left
%       SII right
%       Brainstem
%       Striatal/Thalamic
%       Cerebellum
%       left hippocampus, parietal areas, medial
%and dorsolateral prefrontal cortices

hist(summary_placebo.g.heterogeneity.Isq)
%I^2 unthresholded.
outimg_Isq=zeros(size(df_full_masked.brainmask));
outimg_Isq(df_full_masked.brainmask)=summary_placebo.g.heterogeneity.Isq;
printImage(outimg_Isq,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_Isq'))

%I^2 thresholded at p<.001 uncorrected. 
outimg_Isq_p001=zeros(size(df_full_masked.brainmask));
p001=summary_placebo.g.heterogeneity.Isq;
p001(summary_placebo.g.heterogeneity.p_het>.001)=0;
outimg_Isq_p001(df_full_masked.brainmask)=p001;
printImage(outimg_Isq_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_Isq_p001'))

%I^2 thresholded with permuted Chi^2 values at p<.05, corrected for multiple comparisons at whole-brain level. 
i2=summary_placebo.g.heterogeneity.Isq;
i2(summary_placebo.g.heterogeneity.chisq<=trshld.g.het)=0;
outimg_Isq_pperm05=zeros(size(df_full_masked.brainmask));
outimg_Isq_pperm05(df_full_masked.brainmask)=i2;
printImage(outimg_Isq_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_Isq_pperm05'))

%tau^2 unthresholded. Fazit: Foci at left hippocampus, parietal areas, medial
%and dorsolateral prefrontal cortices
outimg_tausq=zeros(size(df_full_masked.brainmask));
outimg_tausq(df_full_masked.brainmask)=summary_placebo.g.heterogeneity.tausq;
printImage(outimg_tausq,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_tausq'))

% Standard error of g in general
%Fazit:
%SE's of g are mostly between 0.03 and 0.10
%The distribution of SE's is skewed towards higher errors

median(summary_placebo.g.random.SEsummary)
hist(summary_placebo.g.random.SEsummary,50)

%SE g:  
outimg_SE_g=zeros(size(df_full_masked.brainmask));
outimg_SE_g(df_full_masked.brainmask)=summary_placebo.g.random.SEsummary;
printImage(outimg_SE_g,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_SE_g'))
% MAIN RESULTS: g and z values >> thresholded using minima and maxima of permuted z-Values

%g: Fazit:
hist(summary_placebo.g.random.summary,50)

outimg_g=zeros(size(df_full_masked.brainmask));
outimg_g(df_full_masked.brainmask)=summary_placebo.g.random.summary;
printImage(outimg_g,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_g'))

%z: Fazit:
hist(summary_placebo.g.random.z,50)

outimg_z=zeros(size(df_full_masked.brainmask));
outimg_z(df_full_masked.brainmask)=summary_placebo.g.random.z;
printImage(outimg_z,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z'))

%g-thresholded at p<.001 uncorrected. Fazit: 
outimg_g_p001=zeros(size(df_full_masked.brainmask));
p001=summary_placebo.g.random.summary;
p001(summary_placebo.g.random.p>.001)=0;
outimg_g_p001(df_full_masked.brainmask)=p001;
printImage(outimg_g_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_g_p001'))

%z-thresholded at p<.001 uncorrected. Fazit: 
outimg_z_p001=zeros(size(df_full_masked.brainmask));
p001=summary_placebo.g.random.z;
p001(summary_placebo.g.random.p>.001)=0;
outimg_z_p001(df_full_masked.brainmask)=p001;
printImage(outimg_z_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z_p001'))

%g thresholded at pperm<.05 (corrected for multiple comparisons). Fazit: 
pperm05=summary_placebo.g.random.summary;
sub_supra_treshold=summary_placebo.g.random.z<trshld.g.min_z|summary_placebo.g.random.z>trshld.g.max_z;
pperm05(~sub_supra_treshold)=0;
outimg_g_pperm05=zeros(size(df_full_masked.brainmask));
outimg_g_pperm05(df_full_masked.brainmask)=pperm05;
printImage(outimg_g_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_g_pperm05'))

%z thresholded at pperm<.05 (corrected for multiple comparisons). Fazit: 
pperm05=summary_placebo.g.random.z;
sub_supra_treshold=summary_placebo.g.random.z<trshld.g.min_z|summary_placebo.g.random.z>trshld.g.max_z;
pperm05(~sub_supra_treshold)=0;
outimg_z_pperm05=zeros(size(df_full_masked.brainmask));
outimg_z_pperm05(df_full_masked.brainmask)=pperm05;
printImage(outimg_z_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z_pperm05'))
% 
% %z-thresholded at p<.001 uncorrected FIXED EFFECTS. Fazit: 
% outimg_z_p001=zeros(size(df_full_masked.brainmask));
% p001=summary_placebo.g.fixed.z;
% p001(summary_placebo.g.fixed.p>.001)=0;
% outimg_z_p001(df_full_masked.brainmask)=p001;
% printImage(outimg_z_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z_fixed_p001'))
%% Explore VOI PLACEBO vs CONTROL
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

% Best peak around left hippocampus
VOI=find(summary_placebo.g.random.z==max(summary_placebo.g.random.z));
VOI_stats=stat_reduce(voxel_stats,VOI);
VOI_summary=ForestPlotter(VOI_stats,...
                  'studyIDtexts',studyIDtexts,...
                  'outcomelabel','Maximum z Voxel: Hedges'' g)',...
                  'type','random',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0);

outimg_mark_VOI=zeros(size(df_full_masked.brainmask));
out_mark=zeros(size(summary_placebo.g.random.z));
out_mark(VOI)=1;
outimg_mark_VOI(df_full_masked.brainmask)=out_mark;
printImage(outimg_mark_VOI,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','VOI'))

%% MAIN RESULTS 2: correlation (r) of activity with behavioral placebo effect

%I^2 unthresholded.
outimg_Isq=zeros(size(df_full_masked.brainmask));
outimg_Isq(df_full_masked.brainmask)=summary_placebo.r_external.heterogeneity.Isq;
printImage(outimg_Isq,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr_Isq'))

%I^2 thresholded at p<.001 uncorrected. 
outimg_Isq_p001=zeros(size(df_full_masked.brainmask));
p001=summary_placebo.r_external.heterogeneity.Isq;
p001(summary_placebo.r_external.heterogeneity.p_het>.001)=0;
outimg_Isq_p001(df_full_masked.brainmask)=p001;
printImage(outimg_Isq_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr_Isq_p001'))

%I^2 thresholded with permuted Chi^2 values at p<.05, corrected for multiple comparisons at whole-brain level. 
i2=summary_placebo.r_external.heterogeneity.Isq;
i2(summary_placebo.r_external.heterogeneity.chisq<=trshld.r_external.het)=0;
outimg_Isq_pperm05=zeros(size(df_full_masked.brainmask));
outimg_Isq_pperm05(df_full_masked.brainmask)=i2;
printImage(outimg_Isq_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr_Isq_pperm05'))




outimg_behav=zeros(size(df_full_masked.brainmask));
outimg_behav(df_full_masked.brainmask)=summary_placebo.r_external.random.summary;
printImage(outimg_behav,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr_r'));

outimg_behav=zeros(size(df_full_masked.brainmask));
outimg_behav(df_full_masked.brainmask)=summary_placebo.r_external.random.SEsummary;
printImage(outimg_behav,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_SEcorr'));

outimg_behav=zeros(size(df_full_masked.brainmask));
outimg_behav(df_full_masked.brainmask)=summary_placebo.r_external.random.z;
printImage(outimg_behav,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr_z'));

%z-thresholded at p<.001 uncorrected. Fazit: 
outimg_behav_p001=zeros(size(df_full_masked.brainmask));
p001=summary_placebo.r_external.random.summary;
p001(summary_placebo.r_external.random.p>.001)=0;
outimg_behav_p001(df_full_masked.brainmask)=p001;
printImage(outimg_behav_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr_p001'))

%z thresholded at pperm<.05 (corrected for multiple comparisons). Fazit: 
pperm05=summary_placebo.r_external.random.z;
sub_supra_treshold=summary_placebo.r_external.random.z<trshld.r_external.min_z|summary_placebo.r_external.random.z>trshld.r_external.max_z;
pperm05(~sub_supra_treshold)=0;
outimg_z_pperm05=zeros(size(df_full_masked.brainmask));
outimg_z_pperm05(df_full_masked.brainmask)=pperm05;
printImage(outimg_z_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr_z_pperm05'))

%r thresholded at pperm<.05 (corrected for multiple comparisons). Fazit: 
pperm05=summary_placebo.r_external.random.summary;
sub_supra_treshold=summary_placebo.r_external.random.z<trshld.r_external.min_z|summary_placebo.r_external.random.z>trshld.r_external.max_z;
pperm05(~sub_supra_treshold)=0;
outimg_z_pperm05=zeros(size(df_full_masked.brainmask));
outimg_z_pperm05(df_full_masked.brainmask)=pperm05;
printImage(outimg_z_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr_r_pperm05'))
%% Explore VOI
% Best peak around left hippocampus
VOI=find(summary_placebo.r_external.random.z==max(summary_placebo.r_external.random.z));
VOI_stats=stat_reduce(voxel_stats,VOI);
VOI_summary=ForestPlotter(VOI_stats,...
                  'studyIDtexts',studyIDtexts,...
                  'outcomelabel','Maximum z Voxel: r)',...
                  'type','random',...
                  'summarystat','r_external',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0);

outimg_mark_VOI=zeros(size(df_full_masked.brainmask));
out_mark=zeros(size(summary_placebo.g.random.z));
out_mark(VOI)=1;
outimg_mark_VOI(df_full_masked.brainmask)=out_mark;
printImage(outimg_mark_VOI,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','VOI'))
