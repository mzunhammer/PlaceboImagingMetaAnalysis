%% Meta-Analysis for FULL BRAIN ANALYSIS
% Script analog to the full meta-analysis of NPS results
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')

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
%% Meta-Analysis: Run once for plain analysis
stats=create_meta_stats(df_full_masked)
% Calculate meta-analysis summary
summary=GIVsummary(stats);

%% Meta-Analysis: Run repeatedly for permutation test
n_perms=1000;
%g_random_z_min=NaN(n_perms,1);
%g_random_z_max=NaN(n_perms,1);
summary_perm(n_perms)=struct('g',[]);
for p=1:n_perms    
    curr_df_null=relabel_df_for_perm(df_full_masked);
    curr_null_stats=create_meta_stats(curr_df_null);
    % Calculate meta-analysis summary
    curr_perm_summary_stats=GIVsummary(curr_null_stats,{'g'});           % use output-argument to only compute stats for "g"
    curr_perm_summary_stats.g.fixed=[]; % remove fixed effects to reduce size of results matrix
    curr_perm_summary_stats.g.random.weight=[]; % remove weight to reduce size of results matrix
    curr_perm_summary_stats.g.random.rel_weight=[]; % remove rel_weight effects to reduce size of results matrix   
    summary_perm(p)=curr_perm_summary_stats;
end

% SAVE PERMUTED SUMMARY (... COMPUTE ONLY ONCE)
save('Full_Sample_Permuted_Summary_Results.mat','summary_perm','-v7.3');



%g_random_z_min(p)=min(summary_perm(p).g.random.z);
%g_random_z_max(p)=max(summary_perm(p).g.random.z);

%hist(g_random_z_max);
%quantile(g_random_z_min,0.025)
%quantile(g_random_z_max,0.975)
%printImage(summary_perm(p).g.random.z,'../../pattern_masks/brainmask_logical_50.nii','Full_Sample_pla_min10perc_z_permuted_null')
% z-max at 95% Quantile w mask 10% no-signal voxels = 6.1620 (100 perms);
% 6.2 (20 perms)
% %% Obtain Bayesian Factors
% 
% bayesfactor(0.08,0.04,1,[0,0.2]) % Bayes factor for negligible results
% bayesfactor(0.08,0.04,1,[0.2,0.5]) % Bayes factor for small results
% 
% 
% 
% 
% 
% 
% %% Explore Results
% 
% %heterogeneity: Fazit looks ok. df=19 in most grey matter areas of the brain, but 17 in white matter
% %areas
% hist(summary.g.heterogeneity.Isq)
% hist(summary.g.heterogeneity.p_het)
% 
% %I^2 unthresholded. Fazit: Foci at left hippocampus, parietal areas, medial
% %and dorsolateral prefrontal cortices
% outimg_Isq=zeros(size(df_full_masked.brainmask));
% outimg_Isq(df_full_masked.brainmask)=summary.g.heterogeneity.Isq;
% printImage(outimg_Isq,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_Isq'))
% 
% %I^2 thresholded at p<.001 uncorrected. Fazit: 
% outimg_Isq_p001=zeros(size(df_full_masked.brainmask));
% p001=summary.g.heterogeneity.Isq;
% p001(summary.g.heterogeneity.p_het>.001)=0;
% outimg_Isq_p001(df_full_masked.brainmask)=p001;
% printImage(outimg_Isq_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_Isq_p001'))
% 
% %tau^2 unthresholded. Fazit: Foci at left hippocampus, parietal areas, medial
% %and dorsolateral prefrontal cortices
% outimg_tausq=zeros(size(df_full_masked.brainmask));
% outimg_tausq(df_full_masked.brainmask)=summary.g.heterogeneity.tausq;
% printImage(outimg_tausq,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_tausq'))
% 
% %df: Fazit looks ok. df=19 in most grey matter areas of the brain, but 17 in white matter
% %areas
% hist(summary.g.random.df)
% outimg_df=zeros(size(df_full_masked.brainmask));
% outimg_df(df_full_masked.brainmask)=summary.g.random.df;
% printImage(outimg_df,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_df'))
% 
% %SE g: Fazit: 
% outimg_SE_g=zeros(size(df_full_masked.brainmask));
% outimg_SE_g(df_full_masked.brainmask)=summary.g.random.SEsummary;
% printImage(outimg_SE_g,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_SE_g'))
% 
% %g: Fazit: 
% outimg_g=zeros(size(df_full_masked.brainmask));
% outimg_g(df_full_masked.brainmask)=summary.g.random.summary;
% printImage(outimg_g,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_g'))
% 
% %z: Fazit: 
% outimg_z=zeros(size(df_full_masked.brainmask));
% outimg_z(df_full_masked.brainmask)=summary.g.random.z;
% printImage(outimg_z,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z'))
% 
% %z-thresholded at p<.001 uncorrected. Fazit: 
% outimg_z_p001=zeros(size(df_full_masked.brainmask));
% p001=summary.g.random.z;
% p001(summary.g.random.p>.001)=0;
% outimg_z_p001(df_full_masked.brainmask)=p001;
% printImage(outimg_z_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z_p001'))
% 
% %z-thresholded at p<.001 uncorrected FIXED EFFECTS. Fazit: 
% outimg_z_p001=zeros(size(df_full_masked.brainmask));
% p001=summary.g.fixed.z;
% p001(summary.g.fixed.p>.001)=0;
% outimg_z_p001(df_full_masked.brainmask)=p001;
% printImage(outimg_z_p001,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z_fixed_p001'))
% 
% %% Explore peak results
% 
% % Best peak around left hippocampus
% VOI=find(summary.g.random.z==max(summary.g.random.z));
% VOI_stats=stat_reduce(stats,VOI);
% VOI_summary=ForestPlotter(VOI_stats,...
%                   'studyIDtexts',studyIDtexts,...
%                   'outcomelabel','Maximum z Voxel: Hedges'' g)',...
%                   'type','random',...
%                   'summarystat','g',...
%                   'withoutlier',0,...
%                   'WIsubdata',0,...
%                   'boxscaling',1,...
%                   'textoffset',0);
% 
% outimg_mark_VOI=zeros(size(df_full_masked.brainmask));
% out_mark=zeros(size(summary.g.random.z));
% out_mark(VOI)=1;
% outimg_mark_VOI(df_full_masked.brainmask)=out_mark;
% printImage(outimg_mark_VOI,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','VOI'))
