function D_WB_meta_analysis_p_values(datapath)
%% Create p-Values and thresholds:

% Add permutation summary to statistical summary struct
p = mfilename('fullpath');
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
whole_brain_path=fullfile(filesep,splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');

load(fullfile(results_path,'WB_summary_pain_full.mat'));
load(fullfile(results_path,'WB_summary_placebo_full.mat'));

%% Pain
[summary_pain.g.fixed.perm.p_uncorr,...
 summary_pain.g.fixed.perm.p_FWE]=p_perm(summary_pain.g.fixed.z_smooth,... %original stat
                                 summary_pain.g.fixed.perm.z_dist,...    %permutation object
                                 'two-tailed');                               %tails object
[summary_pain.g.random.perm.p_uncorr,...
 summary_pain.g.random.perm.p_FWE]=p_perm(summary_pain.g.random.z_smooth,...
                                  summary_pain.g.random.perm.z_dist,...
                                  'two-tailed');
[summary_pain.g.heterogeneity.perm.p_uncorr,...
 summary_pain.g.heterogeneity.perm.p_FWE]=p_perm(summary_pain.g.heterogeneity.chisq,...
                                         summary_pain.g.heterogeneity.perm.chi_dist,...
                                         'one-tailed-larger');
                                     

% Add FDR thresholds for parametric p-values
summary_pain.g.fixed.p_FDR_thresh=FDR_0(summary_pain.g.fixed.p,0.05);
summary_pain.g.random.p_FDR_thresh=FDR_0(summary_pain.g.random.p,0.05);
summary_pain.g.heterogeneity.p_FDR_thresh=FDR_0(summary_pain.g.heterogeneity.p_het,0.05);

% Add FDR thresholds for permutation-based p-values
summary_pain.g.fixed.perm.pperm_FDR_thresh=FDR_0(summary_pain.g.fixed.perm.p_uncorr,0.05);
summary_pain.g.random.perm.pperm_FDR_thresh=FDR_0(summary_pain.g.random.perm.p_uncorr,0.05);
summary_pain.g.heterogeneity.perm.pperm_FDR_thresh=FDR_0(summary_pain.g.heterogeneity.perm.p_uncorr,0.05);

%% Placebo

% g
[summary_placebo.g.fixed.perm.p_uncorr,...
 summary_placebo.g.fixed.perm.p_FWE]=p_perm(summary_placebo.g.fixed.z_smooth,... %original stat
                                 summary_placebo.g.fixed.perm.z_dist,...    %permutation object
                                 'two-tailed');                               %tails object
[summary_placebo.g.random.perm.p_uncorr,...
 summary_placebo.g.random.perm.p_FWE]=p_perm(summary_placebo.g.random.z_smooth,...
                                  summary_placebo.g.random.perm.z_dist,...
                                  'two-tailed');

[summary_placebo.g.heterogeneity.perm.p_uncorr,...
 summary_placebo.g.heterogeneity.perm.p_FWE]=p_perm(summary_placebo.g.heterogeneity.chisq,...
                                        summary_placebo.g.heterogeneity.perm.chi_dist,...
                                        'one-tailed-larger');
% correlation with behavior
[summary_placebo.r_external.fixed.perm.p_uncorr,...
 summary_placebo.r_external.fixed.perm.p_FWE]=p_perm(summary_placebo.r_external.fixed.z_smooth,... %original stat
                                 summary_placebo.r_external.fixed.perm.z_dist,...    %permutation object
                                 'two-tailed');                               %tails object
[summary_placebo.r_external.random.perm.p_uncorr,...
 summary_placebo.r_external.random.perm.p_FWE]=p_perm(summary_placebo.r_external.random.z_smooth,...
                                  summary_placebo.r_external.random.perm.z_dist,...
                                  'two-tailed');
[summary_placebo.r_external.heterogeneity.perm.p_uncorr,...
summary_placebo.r_external.heterogeneity.perm.p_FWE]=p_perm(summary_placebo.r_external.heterogeneity.chisq,...
                                        summary_placebo.r_external.heterogeneity.perm.chi_dist,...
                                        'one-tailed-larger');


% Add FDR thresholds for parametric p-values (g)
summary_placebo.g.fixed.p_FDR_thresh=FDR_0(summary_placebo.g.fixed.p,0.05);
summary_placebo.g.random.p_FDR_thresh=FDR_0(summary_placebo.g.random.p,0.05);
summary_placebo.g.heterogeneity.p_FDR_thresh=FDR_0(summary_placebo.g.heterogeneity.p_het,0.05);

% Add FDR thresholds for permutation-based p-values (g)
summary_placebo.g.fixed.perm.pperm_FDR_thresh=FDR_0(summary_placebo.g.fixed.perm.p_uncorr,0.05);
summary_placebo.g.random.perm.pperm_FDR_thresh=FDR_0(summary_placebo.g.random.perm.p_uncorr,0.05);
summary_placebo.g.heterogeneity.perm.pperm_FDR_thresh=FDR_0(summary_placebo.g.heterogeneity.perm.p_uncorr,0.05);

% Add FDR thresholds for parametric p-values (r_external)
summary_placebo.r_external.fixed.p_FDR_thresh=FDR_0(summary_placebo.r_external.fixed.p,0.05);
summary_placebo.r_external.random.p_FDR_thresh=FDR_0(summary_placebo.r_external.random.p,0.05);
summary_placebo.r_external.heterogeneity.p_FDR_thresh=FDR_0(summary_placebo.r_external.heterogeneity.p_het,0.05);

% Add FDR thresholds for permutation-based p-values (r_external)
summary_placebo.r_external.fixed.perm.pperm_FDR_thresh=FDR_0(summary_placebo.r_external.fixed.perm.p_uncorr,0.05);
summary_placebo.r_external.random.perm.pperm_FDR_thresh=FDR_0(summary_placebo.r_external.random.perm.p_uncorr,0.05);
summary_placebo.r_external.heterogeneity.perm.pperm_FDR_thresh=FDR_0(summary_placebo.r_external.heterogeneity.perm.p_uncorr,0.05);

%% DELETE PERMUTED DISTRIBUTIONS BEFORE SAVING, TO SAVE DISKSPACE AND LOADING DURATIONS
summary_pain.g.fixed.perm.z_dist=[];
summary_pain.g.random.perm.z_dist=[];
summary_pain.g.heterogeneity.perm.chi_dist=[];


summary_placebo.g.fixed.perm.z_dist=[];
summary_placebo.r_external.fixed.perm.z_dist=[];

summary_placebo.g.random.perm.z_dist=[];
summary_placebo.r_external.random.perm.z_dist=[];

summary_placebo.g.heterogeneity.perm.chi_dist=[];
summary_placebo.r_external.heterogeneity.perm.chi_dist=[];
 
% All has to be overwritten to get rid of large permutation distributions
 save(fullfile(results_path,'WB_summary_pain_full.mat'),...
     'summary_pain','pain_stats','-v7.3');
 save(fullfile(results_path,'WB_summary_placebo_full.mat'),...
     'summary_placebo','placebo_stats','-v7.3');

