%% Meta-Analysis of sub-Group Differences between studies with and without
% placebo conditioning
% Script includes Permutation test and runs ~35 minutes

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('B1_Full_Sample_Summary_Placebo.mat');

%% Define placebo induction type type
condi=...
   {'Suggestions'               %	'atlas'
    'Suggestions + Conditioning'%   'bingel'
    'Suggestions + Conditioning'%   'bingel11'
    'Suggestions + Conditioning'%   'choi'
    'Suggestions + Conditioning'%   'eippert'
    'Suggestions'               %   'ellingsen'
    'Suggestions'               %   'elsenbruch'
    'Suggestions + Conditioning'%   'freeman'
    'Suggestions + Conditioning'%   'geuter'
    'Conditioning'              %   'kessner'
    'Suggestions + Conditioning'%   'kong06'
    'Suggestions + Conditioning'%   'kong09'
    'Suggestions + Conditioning'%   'lui'
    'Suggestions + Conditioning'%   'ruetgen'
    'Suggestions'               %   'schenk'
    'Suggestions'               %   'theysohn'
    'Suggestions'               %   'wager04a_princeton'
    'Suggestions + Conditioning'%   'wager04b_michigan'
    'Suggestions + Conditioning'%   'wrobel'
    'Suggestions + Conditioning'};%  'zeidan'

conditioning=~cellfun(@isempty,regexp(condi,'Conditioning','match'));

%% Split struct containing single-study summaries into conditioning and suggestion

placebo_stats_cond=placebo_stats(conditioning);
placebo_stats_sugg=placebo_stats(~conditioning);

summary_placebo_cond=GIVsummary(placebo_stats_cond,{'g','r_external'});
summary_placebo_sugg=GIVsummary(placebo_stats_sugg,{'g','r_external'});

summary_c_vs_s=compareGIVsummary(summary_placebo_cond,summary_placebo_sugg);


%% Create permuted sample for thresholding meta-analysis maps
%  As sub-group inferences are performed on study-level, we have to perform
%  study-level permutations, not participant-level permutations.

%% Create permuted sample for thresholding meta-analysis maps
tic
load('A1_Full_Sample_Img_Data_Masked_10_percent.mat')

n_perms=2000; %number of permutations smallest p possible is 1/n_perms

%Preallocate for speed and parfor
g_diff_min_z_fixed=NaN(n_perms,1);
g_diff_max_z_fixed=NaN(n_perms,1);
g_diff_min_z_random=NaN(n_perms,1);
g_diff_max_z_random=NaN(n_perms,1);

r_external_diff_min_z_fixed=NaN(n_perms,1);
r_external_diff_max_z_fixed=NaN(n_perms,1);
r_external_diff_min_z_random=NaN(n_perms,1);
r_external_diff_max_z_random=NaN(n_perms,1);

parfor p=1:n_perms %exchange parfor with for if parallel processing is not possible
    
    % Shuffle placebo/baseline labels 
    c_null_conditioning=conditioning(randperm(length(conditioning)));
    c_placebo_stats_cond=placebo_stats(c_null_conditioning);
    c_placebo_stats_sugg=placebo_stats(~c_null_conditioning);

    % Analyze as in original
    c_summary_placebo_cond=GIVsummary(c_placebo_stats_cond,{'g','r_external'});
    c_summary_placebo_sugg=GIVsummary(c_placebo_stats_sugg,{'g','r_external'});

    c_summary_c_vs_s=compareGIVsummary(c_summary_placebo_cond,c_summary_placebo_sugg);

    g_diff_min_z_fixed(p)=min(c_summary_c_vs_s.g_diff.fixed.z);
    g_diff_max_z_fixed(p)=max(c_summary_c_vs_s.g_diff.fixed.z);
    g_diff_min_z_random(p)=min(c_summary_c_vs_s.g_diff.random.z);
    g_diff_max_z_random(p)=max(c_summary_c_vs_s.g_diff.random.z);
    
    r_external_diff_min_z_fixed(p)=min(c_summary_c_vs_s.r_external_diff.fixed.z);
    r_external_diff_max_z_fixed(p)=max(c_summary_c_vs_s.r_external_diff.fixed.z);
    r_external_diff_min_z_random(p)=min(c_summary_c_vs_s.r_external_diff.random.z);
    r_external_diff_max_z_random(p)=max(c_summary_c_vs_s.r_external_diff.random.z);
end

toc

%% Create thresholds:
summary_c_vs_s.g_diff.fixed.perm.min_z=quantile(g_diff_min_z_fixed,0.025); %two-tailed!
summary_c_vs_s.g_diff.fixed.perm.max_z=quantile(g_diff_max_z_fixed,0.975); %two-tailed!
summary_c_vs_s.g_diff.fixed.perm.min_z_dist=g_diff_min_z_fixed; %two-tailed!
summary_c_vs_s.g_diff.fixed.perm.max_z_dist=g_diff_max_z_fixed; %two-tailed!
summary_c_vs_s.g_diff.fixed.perm.p=p_perm(summary_c_vs_s.g_diff.fixed.z,[g_diff_min_z_fixed;g_diff_max_z_fixed],'monte-carlo','two-tailed');

summary_c_vs_s.g_diff.random.perm.min_z=quantile(g_diff_min_z_random,0.025); %two-tailed!
summary_c_vs_s.g_diff.random.perm.max_z=quantile(g_diff_max_z_random,0.975); %two-tailed!
summary_c_vs_s.g_diff.random.perm.min_z_dist=g_diff_min_z_random; %two-tailed!
summary_c_vs_s.g_diff.random.perm.max_z_dist=g_diff_max_z_random; %two-tailed!
summary_c_vs_s.g_diff.random.perm.p=p_perm(summary_c_vs_s.g_diff.random.z,[g_diff_min_z_random;g_diff_max_z_random],'monte-carlo','two-tailed');

summary_c_vs_s.r_external_diff.fixed.perm.min_z=quantile(r_external_diff_min_z_fixed,0.025); %two-tailed!
summary_c_vs_s.r_external_diff.fixed.perm.max_z=quantile(r_external_diff_max_z_fixed,0.975); %two-tailed!
summary_c_vs_s.r_external_diff.fixed.perm.min_z_dist=r_external_diff_min_z_fixed; %two-tailed!
summary_c_vs_s.r_external_diff.fixed.perm.max_z_dist=r_external_diff_max_z_fixed; %two-tailed!
summary_c_vs_s.r_external_diff.fixed.perm.p=p_perm(summary_c_vs_s.r_external_diff.fixed.z,[r_external_diff_min_z_fixed;r_external_diff_max_z_fixed],'monte-carlo','two-tailed');

summary_c_vs_s.r_external_diff.random.perm.min_z=quantile(r_external_diff_min_z_random,0.025); %two-tailed!
summary_c_vs_s.r_external_diff.random.perm.max_z=quantile(r_external_diff_max_z_random,0.975); %two-tailed!
summary_c_vs_s.r_external_diff.random.perm.min_z_dist=r_external_diff_min_z_random; %two-tailed!
summary_c_vs_s.r_external_diff.random.perm.max_z_dist=r_external_diff_max_z_random; %two-tailed!
summary_c_vs_s.r_external_diff.random.perm.p=p_perm(summary_c_vs_s.r_external_diff.random.z,[r_external_diff_min_z_random;r_external_diff_max_z_random],'monte-carlo','two-tailed');


%% Print .nii images for RANDOM EFFECTS analysis
% 
% template=zeros(size(statmask));
% outpath_random=fullfile(outpath,'random');
% 
% %main (random effects) outcome unthresholded
% outimg_main=template;
% outimg_main(statmask)=summary.random.summary;
% printImage(outimg_main,brainmask,fullfile(outpath_random,[label,'_unthresh']));
% %main (random effects) outcome at p<.001 uncorrected
% outimg_main_p001=template;
% outimg_main_p001(statmask)=summary.random.summary.*(summary.random.p<.001);
% printImage(outimg_main_p001,brainmask,fullfile(outpath_random,[label,'_p001']))
% %main (random effects) outcome at pperm<.05 
% outimg_main_pperm05=template;
% outimg_main_pperm05(statmask)=summary.random.summary.*(summary.random.perm.p<.05);
% printImage(outimg_main_pperm05,brainmask,fullfile(outpath_random,[label,'_pperm05']))
% %main (random effects) outcome, for summary (g or r) >.1 
% outimg_main_g10=template;
% outimg_main_g10(statmask)=summary.random.summary.*(abs(summary.random.summary)>=.10);
% printImage(outimg_main_g10,brainmask,fullfile(outpath_random,[label,'_g10']))
% %main (random effects) outcome, for summary (g or r) >.15
% outimg_main_g15=template;
% outimg_main_g15(statmask)=summary.random.summary.*(abs(summary.random.summary)>=.15);
% printImage(outimg_main_g15,brainmask,fullfile(outpath_random,[label,'_g15']))
% %main (random effects) outcome, for summary (g or r) >.20
% outimg_main_g20=template;
% outimg_main_g20(statmask)=summary.random.summary.*(abs(summary.random.summary)>=.20);
% printImage(outimg_main_g20,brainmask,fullfile(outpath_random,[label,'_g20']))
% 
% %SE of main (random effects) outcome unthresholded
% outimg_SEmain=template;
% outimg_SEmain(statmask)=summary.random.SEsummary;
% printImage(outimg_SEmain,brainmask,fullfile(outpath_random,[label,'_SE']));
% 
% %z of main (random effects) outcome unthresholded
% outimg_z=template;
% outimg_z(statmask)=summary.random.z;
% printImage(outimg_z,brainmask,fullfile(outpath_random,[label,'_z']));
% %full p of main (random effects) outcome  uncorrected
% outimg_p=template;
% outimg_p(statmask)=summary.random.p;
% printImage(outimg_p,brainmask,fullfile(outpath_random,[label,'_pmap001']));
% %full p of main (random effects) outcome  pperm
% outimg_pperm=template;
% outimg_pperm(statmask)=summary.random.perm.p;
% printImage(outimg_pperm,brainmask,fullfile(outpath_random,[label,'_pmapperm05']));