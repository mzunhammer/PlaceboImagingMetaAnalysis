function D_WB_meta_analysis_p_values_pain(datapath)
%% Create p-Values and thresholds:

% Add permutation summary to statistical summary struct
p = mfilename('fullpath');
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
whole_brain_path=fullfile(filesep,splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');

load(fullfile(results_path,'WB_summary_pain_full.mat'));

%% Pain
disp('START: P-Values Pain')                                     
[summary_pain.g.fixed.perm.p_uncorr,...
 summary_pain.g.fixed.perm.p_FWE]=p_perm(summary_pain.g.fixed.z_smooth,... %original stat
                                 summary_pain.g.fixed.perm.z_dist,...    %permutation object
                                 'two-tailed',5);                               %tails object
[summary_pain.g.random.perm.p_uncorr,...
 summary_pain.g.random.perm.p_FWE]=p_perm(summary_pain.g.random.z_smooth,...
                                  summary_pain.g.random.perm.z_dist,...
                                  'two-tailed',5);
%[summary_pain.g.fixed.perm.p_tfce_uncorr,...
% summary_pain.g.fixed.perm.p_tfce_FWE]=p_perm(summary_pain.g.fixed.tfce,... %original stat
%                                 summary_pain.g.fixed.perm.tfce_dist,...    %permutation object
%                                 'two-tailed',1);
 %[summary_pain.g.random.perm.p_tfce_uncorr,...
 %summary_pain.g.random.perm.p_tfce_FWE]=p_perm(summary_pain.g.random.tfce,... %original stat
 %                                summary_pain.g.random.perm.tfce_dist,...    %permutation object
 %                                'two-tailed',1); 
[summary_pain.g.heterogeneity.perm.p_uncorr,...
 summary_pain.g.heterogeneity.perm.p_FWE]=p_perm(summary_pain.g.heterogeneity.chisq,...
                                         summary_pain.g.heterogeneity.perm.chi_dist,...
                                         'one-tailed-larger',5);
disp('DONE: P-Values Pain')                                     
% Add FDR thresholds for parametric p-values
summary_pain.g.fixed.p_FDR_thresh=FDR_0(summary_pain.g.fixed.p,0.05);
summary_pain.g.random.p_FDR_thresh=FDR_0(summary_pain.g.random.p,0.05);
summary_pain.g.heterogeneity.p_FDR_thresh=FDR_0(summary_pain.g.heterogeneity.p_het,0.05);

% Add FDR thresholds for permutation-based p-values
summary_pain.g.fixed.perm.p_FDR_thresh=FDR_0(summary_pain.g.fixed.perm.p_uncorr,0.05);
summary_pain.g.random.perm.p_FDR_thresh=FDR_0(summary_pain.g.random.perm.p_uncorr,0.05);
summary_pain.g.heterogeneity.perm.p_FDR_thresh=FDR_0(summary_pain.g.heterogeneity.perm.p_uncorr,0.05);


%% DELETE PERMUTED DISTRIBUTIONS BEFORE SAVING, TO SAVE DISKSPACE AND LOADING DURATIONS
summary_pain.g.fixed.perm.z_dist=[];
summary_pain.g.random.perm.z_dist=[];
%summary_pain.g.fixed.perm.tfce_dist=[];
%summary_pain.g.random.perm.tfce_dist=[];
summary_pain.g.heterogeneity.perm.chi_dist=[];

% All has to be overwritten to get rid of large permutation distributions
 save(fullfile(results_path,'WB_summary_pain_full.mat'),...
     'summary_pain','pain_stats','-v7.3');