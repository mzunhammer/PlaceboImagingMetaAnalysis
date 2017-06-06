%% Meta-Analysis for FULL BRAIN ANALYSIS
% Script analog to the full meta-analysis of NPS results
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')
load('Full_Sample_Permuted_Thresholds.mat')

% !!!!! These must be in the same order as listed under "studies" !!!!

% studyIDtexts={
%             'Atlas et al. 2012: Hidden vs open remifentanil drip infusion (expectation period)| heat';...
% 			'Bingel et al. 2006: Control vs placebo cream | laser';...
% 			'Bingel et al. 2011: No vs positive expectations | heat';...
% 			'Choi et al. 2011: No vs low & high effective placebo drip infusion (Exp1 and 2) | electrical';...
% 			'Eippert et al. 2009: Control vs placebo cream (saline & naloxone group) | heat (early & late)';...
% 			'Ellingsen et al. 2013: Pre vs post placebo nasal spray | heat';...
%             'Elsenbruch et al. 2012: No vs certain placebo drip infusion | distension';...
%             'Freeman et al. 2015: Control vs placebo cream | heat';...
%             'Geuter et al. 2013: Control vs weak & strong placebo cream | heat (early & late)';...
%             'Kessner et al. 2014: Negative vs positive treatment expectation group | heat';...
%             'Kong et al. 2006: Control vs placebo acupuncture | heat (high & low)';...
%             'Kong et al. 2009: Control vs placebo sham acupuncture | heat';...
%             'Lui et al. 2010: Red vs green cue signifying sham TENS off vs on | laser';...
%             'Ruetgen et al. 2015: No treatment vs placebo pill group  | electrical'
%             'Schenk et al. 2015:  Control vs placebo (saline & lidocain) | heat'
%             'Theysohn et al. 2009: No vs certain placebo drip infusion | distension';...
%             'Wager et al. 2004, Study 1: Control vs placebo cream | heat*';...
%             'Wager et al. 2004, Study 2: Control vs placebo cream | electrical*';...
%             'Wrobel et al. 2014: Control vs placebo cream (saline & haldol group) | heat(early & late)'
%             'Zeidan et al. 2015: Control vs placebo cream (placebo group) | heat*';...
%             };

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
%% Meta-Analysis: Effect of placebo treatment on voxel-by-voxel bold response
voxel_stats=create_meta_stats_voxels(df_full_masked);
% Calculate meta-analysis summary

%% Meta-Analysis: Correlation of behavioral effect and voxel-by-voxel bold response
rating_stats=create_meta_stats_behavior(df_full_masked);

for i=1:length(voxel_stats)
    voxel_stats(i).corr_external=fastcorrcoef(voxel_stats(i).delta,rating_stats(i).delta,true); % correlate single-subject effect of behavior and voxel signal 
    voxel_stats(i).n_corr_external=sum(~(isnan(voxel_stats(i).delta)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                         isnan(rating_stats(i).delta))); % AND non nan-ratings
end
    voxel_stats(10).n_corr_external=[]; % exclude between-subject studies
    voxel_stats(14).n_corr_external=[]; % exclude between-subject studies

%% Summarize
summary=GIVsummary(voxel_stats,{'g','corr_external'});
save('B1_Full_Sample_Summary_Results.mat','summary','-v7.3');

%% Explore Results
%% Sanity check dfs

%df: Fazit: looks ok. df=19 in most grey matter areas of the brain, 18 in
%white matter.
% A minority of voxels (<143) has  df's of 17 or 16. These voxels showed no variance in single
% within-subject studies. No variance estimates could be obtained for these
% studies >> NaN values are set in GIVsummary in these cases.
hist(summary.g.random.df)
outimg_df=zeros(size(df_full_masked.brainmask));
outimg_df(df_full_masked.brainmask)=summary.g.random.df;
printImage(outimg_df,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_df'))

%% Heterogeneity: Looks legit, INTERESTING maps!
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

hist(summary.g.heterogeneity.Isq)
%I^2 unthresholded.
outimg_Isq=zeros(size(df_full_masked.brainmask));
outimg_Isq(df_full_masked.brainmask)=summary.g.heterogeneity.Isq;
printImage(outimg_Isq,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_Isq'))

%I^2 thresholded at p<.001 uncorrected. 
outimg_Isq_p001=zeros(size(df_full_masked.brainmask));
p001=summary.g.heterogeneity.Isq;
p001(summary.g.heterogeneity.p_het>.001)=0;
outimg_Isq_p001(df_full_masked.brainmask)=p001;
printImage(outimg_Isq_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_Isq_p001'))

%I^2 thresholded with permuted Chi^2 values at p<.05, corrected for multiple comparisons at whole-brain level. 
i2=summary.g.heterogeneity.Isq;
i2(summary.g.heterogeneity.chisq<=trshld.het)=0;
outimg_Isq_pperm05=zeros(size(df_full_masked.brainmask));
outimg_Isq_pperm05(df_full_masked.brainmask)=i2;
printImage(outimg_Isq_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_Isq_pperm05'))

%tau^2 unthresholded. Fazit: Foci at left hippocampus, parietal areas, medial
%and dorsolateral prefrontal cortices
outimg_tausq=zeros(size(df_full_masked.brainmask));
outimg_tausq(df_full_masked.brainmask)=summary.g.heterogeneity.tausq;
printImage(outimg_tausq,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_tausq'))

%% Standard error of g in general
%Fazit:
%SE's of g are mostly between 0.03 and 0.10
%The distribution of SE's is skewed towards higher errors

median(summary.g.random.SEsummary)
hist(summary.g.random.SEsummary,50)

%SE g:  
outimg_SE_g=zeros(size(df_full_masked.brainmask));
outimg_SE_g(df_full_masked.brainmask)=summary.g.random.SEsummary;
printImage(outimg_SE_g,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_SE_g'))
%% MAIN RESULTS: g and z values >> thresholded using minima and maxima of permuted z-Values

%g: Fazit: 
outimg_g=zeros(size(df_full_masked.brainmask));
outimg_g(df_full_masked.brainmask)=summary.g.random.summary;
printImage(outimg_g,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_g'))

%z: Fazit: 
outimg_z=zeros(size(df_full_masked.brainmask));
outimg_z(df_full_masked.brainmask)=summary.g.random.z;
printImage(outimg_z,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z'))

%g-thresholded at p<.001 uncorrected. Fazit: 
outimg_g_p001=zeros(size(df_full_masked.brainmask));
p001=summary.g.random.summary;
p001(summary.g.random.p>.001)=0;
outimg_g_p001(df_full_masked.brainmask)=p001;
printImage(outimg_g_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_g_p001'))

%z-thresholded at p<.001 uncorrected. Fazit: 
outimg_z_p001=zeros(size(df_full_masked.brainmask));
p001=summary.g.random.z;
p001(summary.g.random.p>.001)=0;
outimg_z_p001(df_full_masked.brainmask)=p001;
printImage(outimg_z_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z_p001'))

%g thresholded at pperm<.05 (corrected for multiple comparisons). Fazit: 
pperm05=summary.g.random.summary;
sub_supra_treshold=summary.g.random.z<trshld.min_z|summary.g.random.z>trshld.max_z;
pperm05(~sub_supra_treshold)=0;
outimg_g_pperm05=zeros(size(df_full_masked.brainmask));
outimg_g_pperm05(df_full_masked.brainmask)=pperm05;
printImage(outimg_g_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_g_pperm05'))

%z thresholded at pperm<.05 (corrected for multiple comparisons). Fazit: 
pperm05=summary.g.random.z;
sub_supra_treshold=summary.g.random.z<trshld.min_z|summary.g.random.z>trshld.max_z;
pperm05(~sub_supra_treshold)=0;
outimg_z_pperm05=zeros(size(df_full_masked.brainmask));
outimg_z_pperm05(df_full_masked.brainmask)=pperm05;
printImage(outimg_z_pperm05,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z_pperm05'))
% 
% %z-thresholded at p<.001 uncorrected FIXED EFFECTS. Fazit: 
% outimg_z_p001=zeros(size(df_full_masked.brainmask));
% p001=summary.g.fixed.z;
% p001(summary.g.fixed.p>.001)=0;
% outimg_z_p001(df_full_masked.brainmask)=p001;
% printImage(outimg_z_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z_fixed_p001'))

%% MAIN RESULTS: correlation (r) of activity with behavioral placebo effect

outimg_behav=zeros(size(df_full_masked.brainmask));
outimg_behav(df_full_masked.brainmask)=summary.r_external.random.summary;
printImage(outimg_behav,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr'));

outimg_behav=zeros(size(df_full_masked.brainmask));
outimg_behav(df_full_masked.brainmask)=summary.r_external.random.SEsummary;
printImage(outimg_behav,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_SEcorr'));

%z-thresholded at p<.001 uncorrected. Fazit: 
outimg_behav_p001=zeros(size(df_full_masked.brainmask));
p001=summary.r_external.random.summary;
p001(summary.r_external.random.p>.001)=0;
outimg_behav_p001(df_full_masked.brainmask)=p001;
printImage(outimg_behav_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_corr_p001'))

outimg_behav=zeros(size(df_full_masked.brainmask));
outimg_behav(df_full_masked.brainmask)=summary.r_external.random.SEsummary;
printImage(outimg_behav,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_rating_SEcorr'));

%% Explore VOI

% Best peak around left hippocampus
VOI=65228;%find(summary.g.random.z==min(summary.g.random.z));
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
out_mark=zeros(size(summary.g.random.z));
out_mark(VOI)=1;
outimg_mark_VOI(df_full_masked.brainmask)=out_mark;
printImage(outimg_mark_VOI,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','VOI'))


%% Create results table

