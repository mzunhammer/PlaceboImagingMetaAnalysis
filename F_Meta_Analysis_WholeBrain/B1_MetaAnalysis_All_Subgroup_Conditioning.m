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

% compareGIVsummary calculates effects as eff_1-eff_2
% >> Conditioning?Suggestions only
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

parfor p1=1:n_perms %exchange parfor with for if parallel processing is not possible
    
    % Shuffle placebo/baseline labels
    g_null_conditioning=conditioning(randperm(length(conditioning)));

    c_placebo_stats_cond=placebo_stats(g_null_conditioning);
    c_placebo_stats_sugg=placebo_stats(~g_null_conditioning);

    % Analyze as in original
    c_summary_placebo_cond=GIVsummary(c_placebo_stats_cond,{'g'});
    c_summary_placebo_sugg=GIVsummary(c_placebo_stats_sugg,{'g'});

    c_summary_c_vs_s=compareGIVsummary(c_summary_placebo_cond,c_summary_placebo_sugg);

    g_diff_min_z_fixed(p1)=min(c_summary_c_vs_s.g_diff.fixed.z);
    g_diff_max_z_fixed(p1)=max(c_summary_c_vs_s.g_diff.fixed.z);
    g_diff_min_z_random(p1)=min(c_summary_c_vs_s.g_diff.random.z);
    g_diff_max_z_random(p1)=max(c_summary_c_vs_s.g_diff.random.z);
end


%% Placebo correlations are missing for two between-subject studies
% in the conditioning sub-group. Since there are no missing studies and
% only 6 studies in the suggestion sub-group we should not assign missing
% data to the suggestion group.
% Therefore r_external gets its own validation loop with missing studies
% fixed to "conditioning"
i_missing_corr=find(cellfun(@isempty,{placebo_stats.r_external}));
r_external_diff_min_z_fixed=NaN(n_perms,1);
r_external_diff_max_z_fixed=NaN(n_perms,1);
r_external_diff_min_z_random=NaN(n_perms,1);
r_external_diff_max_z_random=NaN(n_perms,1);
parfor p2=1:n_perms %exchange parfor with for if parallel processing is not possible
    % Shuffle placebo/baseline labels
    missing_ok=0;
    while missing_ok==0
        r_null_conditioning=conditioning(randperm(length(conditioning)));
        if all(r_null_conditioning(i_missing_corr)) %Check if missing studies are assigned 1 (i.e. conditioning)
            missing_ok=1;
        else
            missing_ok=0;
        end
    end
    c_placebo_stats_cond=placebo_stats(r_null_conditioning);
    c_placebo_stats_sugg=placebo_stats(~r_null_conditioning);

    % Analyze as in original
    c_summary_placebo_cond=GIVsummary(c_placebo_stats_cond,{'r_external'});
    c_summary_placebo_sugg=GIVsummary(c_placebo_stats_sugg,{'r_external'});

    c_summary_c_vs_s=compareGIVsummary(c_summary_placebo_cond,c_summary_placebo_sugg);
    % note that compareGIVsummary calculates effects as eff1-eff2.
    
    r_external_diff_min_z_fixed(p2)=min(c_summary_c_vs_s.r_external_diff.fixed.z);
    r_external_diff_max_z_fixed(p2)=max(c_summary_c_vs_s.r_external_diff.fixed.z);
    r_external_diff_min_z_random(p2)=min(c_summary_c_vs_s.r_external_diff.random.z);
    r_external_diff_max_z_random(p2)=max(c_summary_c_vs_s.r_external_diff.random.z);
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

save('B1_Full_Sample_Summary_Placebo_Conditioning_vs_Suggestions.mat','summary_c_vs_s','-v7.3','-append');

%% Print .nii images for RANDOM EFFECTS analysis
load('B1_Full_Sample_Summary_Placebo.mat');

brainmask='../../pattern_masks/brainmask_logical_50.nii';
statmask=df_full_masked.brainmask;
template=zeros(size(statmask));

% PRINT G-DIFF
outpath='./nii_results/full/pla_cond_vs_sugg/g_diff/';
outlabel='Cond_vs_Sugg_g_diff';
outpath_random=fullfile(outpath,'random');
 
 %main (random effects) outcome unthresholded
outimg_main=template;
outimg_main(statmask)=summary_c_vs_s.g_diff.random.delta;
printImage(outimg_main,brainmask,fullfile(outpath_random,[outlabel,'_unthresh']));
%main (random effects) outcome at p<.001 uncorrected
outimg_main_p001=template;
outimg_main_p001(statmask)=summary_c_vs_s.g_diff.random.delta.*(summary_c_vs_s.g_diff.random.p<.001);
printImage(outimg_main_p001,brainmask,fullfile(outpath_random,[outlabel,'_p001']));
%main (random effects) outcome at pperm<.05 
outimg_main_pperm05=template;
outimg_main_pperm05(statmask)=summary_c_vs_s.g_diff.random.delta.*(summary_c_vs_s.g_diff.random.perm.p<.05);
printImage(outimg_main_pperm05,brainmask,fullfile(outpath_random,[outlabel,'_pperm05']))

% %SE of main (random effects) outcome unthresholded
outimg_SEmain=template;
outimg_SEmain(statmask)=summary_c_vs_s.g_diff.random.SEdelta;
printImage(outimg_SEmain,brainmask,fullfile(outpath_random,[outlabel,'_SE']));
% 
% %z of main (random effects) outcome unthresholded
outimg_z=template;
outimg_z(statmask)=summary_c_vs_s.g_diff.random.z;
printImage(outimg_z,brainmask,fullfile(outpath_random,[outlabel,'_z']));
% %full p of main (random effects) outcome  uncorrected
outimg_p=template;
outimg_p(statmask)=summary_c_vs_s.g_diff.random.p;
printImage(outimg_p,brainmask,fullfile(outpath_random,[outlabel,'_pmap001']));
% %full p of main (random effects) outcome  pperm
outimg_pperm=template;
outimg_pperm(statmask)=summary_c_vs_s.g_diff.random.perm.p;
printImage(outimg_pperm,brainmask,fullfile(outpath_random,[outlabel,'_pmapperm05']));


% PRINT r_external
outpath='./nii_results/full/pla_cond_vs_sugg/rrating_diff/';
outlabel='Cond_vs_Sugg_rrating';
outpath_random=fullfile(outpath,'random');
 
 %main (random effects) outcome unthresholded
outimg_main=template;
outimg_main(statmask)=summary_c_vs_s.r_external_diff.random.delta;
printImage(outimg_main,brainmask,fullfile(outpath_random,[outlabel,'_unthresh']));
%main (random effects) outcome at p<.001 uncorrected
outimg_main_p001=template;
outimg_main_p001(statmask)=summary_c_vs_s.r_external_diff.random.delta.*(summary_c_vs_s.r_external_diff.random.p<.001);
printImage(outimg_main_p001,brainmask,fullfile(outpath_random,[outlabel,'_p001']));
%main (random effects) outcome at pperm<.05 
outimg_main_pperm05=template;
outimg_main_pperm05(statmask)=summary_c_vs_s.r_external_diff.random.delta.*(summary_c_vs_s.r_external_diff.random.perm.p<.05);
printImage(outimg_main_pperm05,brainmask,fullfile(outpath_random,[outlabel,'_pperm05']))

% %SE of main (random effects) outcome unthresholded
outimg_SEmain=template;
outimg_SEmain(statmask)=summary_c_vs_s.r_external_diff.random.SEdelta;
printImage(outimg_SEmain,brainmask,fullfile(outpath_random,[outlabel,'_SE']));
% 
% %z of main (random effects) outcome unthresholded
outimg_z=template;
outimg_z(statmask)=summary_c_vs_s.r_external_diff.random.z;
printImage(outimg_z,brainmask,fullfile(outpath_random,[outlabel,'_z']));
% %full p of main (random effects) outcome  uncorrected
outimg_p=template;
outimg_p(statmask)=summary_c_vs_s.r_external_diff.random.p;
printImage(outimg_p,brainmask,fullfile(outpath_random,[outlabel,'_pmap001']));
% %full p of main (random effects) outcome  pperm
outimg_pperm=template;
outimg_pperm(statmask)=summary_c_vs_s.r_external_diff.random.perm.p;
printImage(outimg_pperm,brainmask,fullfile(outpath_random,[outlabel,'_pmapperm05']));