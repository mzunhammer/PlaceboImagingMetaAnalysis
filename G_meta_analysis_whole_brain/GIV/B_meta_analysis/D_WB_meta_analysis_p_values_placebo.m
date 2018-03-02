function D_WB_meta_analysis_p_values_placebo(datapath)
%% Create p-Values and thresholds:

% Add permutation summary to statistical summary struct
p = mfilename('fullpath');
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
whole_brain_path=fullfile(filesep,splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');

load(fullfile(results_path,'WB_summary_placebo_full.mat'));

%% Placebo
disp('START: P-Values Placebo g')                                     
% g
[summary_placebo.g.fixed.perm.p_uncorr,...
 summary_placebo.g.fixed.perm.p_FWE]=p_perm(summary_placebo.g.fixed.z_smooth,... %original stat
                                 summary_placebo.g.fixed.perm.z_dist,...    %permutation object
                                 'two-tailed',5);                               %tails object
[summary_placebo.g.random.perm.p_uncorr,...
 summary_placebo.g.random.perm.p_FWE]=p_perm(summary_placebo.g.random.z_smooth,...
                                  summary_placebo.g.random.perm.z_dist,...
                                  'two-tailed',5);
[summary_placebo.g.fixed.perm.p_tfce_uncorr,...
 summary_placebo.g.fixed.perm.p_tfce_FWE]=p_perm(summary_placebo.g.fixed.tfce,... %original stat
                                 summary_placebo.g.fixed.perm.tfce_dist,...    %permutation object
                                 'two-tailed',1);
 [summary_placebo.g.random.perm.p_tfce_uncorr,...
 summary_placebo.g.random.perm.p_tfce_FWE]=p_perm(summary_placebo.g.random.tfce,... %original stat
                                 summary_placebo.g.random.perm.tfce_dist,...    %permutation object
                                 'two-tailed',1); 
[summary_placebo.g.random.perm.p_uncorr,...
 summary_placebo.g.random.perm.p_FWE]=p_perm(summary_placebo.g.random.z_smooth,...
                                  summary_placebo.g.random.perm.z_dist,...
                                  'two-tailed',5);
[summary_placebo.g.heterogeneity.perm.p_uncorr,...
 summary_placebo.g.heterogeneity.perm.p_FWE]=p_perm(summary_placebo.g.heterogeneity.chisq,...
                                        summary_placebo.g.heterogeneity.perm.chi_dist,...
                                        'one-tailed-larger',5);
disp('DONE: P-Values Placebo g')                                     
disp('START: P-Values Placebo r_external')                                     
%% correlation with behavior
[summary_placebo.r_external.fixed.perm.p_uncorr,...
 summary_placebo.r_external.fixed.perm.p_FWE]=p_perm(summary_placebo.r_external.fixed.z_smooth,... %original stat
                                 summary_placebo.r_external.fixed.perm.z_dist,...    %permutation object
                                 'two-tailed',5);                               %tails object
[summary_placebo.r_external.random.perm.p_uncorr,...
 summary_placebo.r_external.random.perm.p_FWE]=p_perm(summary_placebo.r_external.random.z_smooth,...
                                  summary_placebo.r_external.random.perm.z_dist,...
                                  'two-tailed',5);
[summary_placebo.r_external.fixed.perm.p_tfce_uncorr,...
 summary_placebo.r_external.fixed.perm.p_tfce_FWE]=p_perm(summary_placebo.r_external.fixed.tfce,... %original stat
                                 summary_placebo.r_external.fixed.perm.tfce_dist,...    %permutation object
                                 'two-tailed',1);
 [summary_placebo.r_external.random.perm.p_tfce_uncorr,...
 summary_placebo.r_external.random.perm.p_tfce_FWE]=p_perm(summary_placebo.r_external.random.tfce,... %original stat
                                 summary_placebo.r_external.random.perm.tfce_dist,...    %permutation object
                                 'two-tailed',1);
[summary_placebo.r_external.heterogeneity.perm.p_uncorr,...
summary_placebo.r_external.heterogeneity.perm.p_FWE]=p_perm(summary_placebo.r_external.heterogeneity.chisq,...
                                        summary_placebo.r_external.heterogeneity.perm.chi_dist,...
                                        'one-tailed-larger',5);


% Add FDR thresholds for parametric p-values (g)
summary_placebo.g.fixed.p_FDR_thresh=FDR_0(summary_placebo.g.fixed.p,0.05);
summary_placebo.g.random.p_FDR_thresh=FDR_0(summary_placebo.g.random.p,0.05);
summary_placebo.g.heterogeneity.p_FDR_thresh=FDR_0(summary_placebo.g.heterogeneity.p_het,0.05);

% Add FDR thresholds for permutation-based p-values (g)
summary_placebo.g.fixed.perm.p_FDR_thresh=FDR_0(summary_placebo.g.fixed.perm.p_uncorr,0.05);
summary_placebo.g.random.perm.p_FDR_thresh=FDR_0(summary_placebo.g.random.perm.p_uncorr,0.05);
summary_placebo.g.fixed.perm.p_tfce_FDR_thresh=FDR_0(summary_placebo.g.fixed.perm.p_tfce_uncorr,0.05);
summary_placebo.g.random.perm.p_tfce_FDR_thresh=FDR_0(summary_placebo.g.random.perm.p_tfce_uncorr,0.05);
summary_placebo.g.heterogeneity.perm.p_FDR_thresh=FDR_0(summary_placebo.g.heterogeneity.perm.p_uncorr,0.05);

% Add FDR thresholds for parametric p-values (r_external)
summary_placebo.r_external.fixed.p_FDR_thresh=FDR_0(summary_placebo.r_external.fixed.p,0.05);
summary_placebo.r_external.random.p_FDR_thresh=FDR_0(summary_placebo.r_external.random.p,0.05);
summary_placebo.r_external.heterogeneity.p_FDR_thresh=FDR_0(summary_placebo.r_external.heterogeneity.p_het,0.05);

% Add FDR thresholds for permutation-based p-values (r_external)
summary_placebo.r_external.fixed.perm.p_FDR_thresh=FDR_0(summary_placebo.r_external.fixed.perm.p_uncorr,0.05);
summary_placebo.r_external.random.perm.p_FDR_thresh=FDR_0(summary_placebo.r_external.random.perm.p_uncorr,0.05);
summary_placebo.r_external.fixed.perm.p_tfce_FDR_thresh=FDR_0(summary_placebo.r_external.fixed.perm.p_tfce_uncorr,0.05);
summary_placebo.r_external.random.perm.p_tfce_FDR_thresh=FDR_0(summary_placebo.r_external.random.perm.p_tfce_uncorr,0.05);
summary_placebo.r_external.heterogeneity.perm.p_FDR_thresh=FDR_0(summary_placebo.r_external.heterogeneity.perm.p_uncorr,0.05);
disp('DONE: P-Values Placebo r_external')                                     

%% DELETE PERMUTED DISTRIBUTIONS BEFORE SAVING, TO SAVE DISKSPACE AND LOADING DURATIONS
summary_placebo.g.fixed.perm.z_dist=[];
summary_placebo.r_external.fixed.perm.z_dist=[];
summary_placebo.g.fixed.perm.tfce_dist=[];
summary_placebo.r_external.fixed.perm.tfce_dist=[];

summary_placebo.g.random.perm.z_dist=[];
summary_placebo.r_external.random.perm.z_dist=[];
summary_placebo.g.random.perm.tfce_dist=[];
summary_placebo.r_external.random.perm.tfce_dist=[];

summary_placebo.g.heterogeneity.perm.chi_dist=[];
summary_placebo.r_external.heterogeneity.perm.chi_dist=[];
 
% All has to be overwritten to get rid of large permutation distributions
 save(fullfile(results_path,'WB_summary_placebo_full.mat'),...
     'summary_placebo','placebo_stats','-v7.3');

