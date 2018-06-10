function print_summary_niis(summary,statmask,label,outpath)
addpath(genpath(fullfile(userpath,'/CanlabCore/CanlabCore'))); % Required for FDR thresholding

p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,['(?<!^)',filesep], 'DelimiterType','RegularExpression');
mask_path=fullfile(splitp{1:end-4},'pattern_masks','brainmask_logical_50.nii');

%% Print supplementary information
print_img(outpath,summary.n,'_n')
print_img(outpath,summary.random.df,'_df') %number of study degrees-of-freedom/voxel, same for fixed and random

%% Print images for heterogeneity
%I^2 unthresholded
outpath_het=fullfile(outpath,'heterogeneity');
print_img(outpath_het,summary.heterogeneity.Isq,'_Isq');
%I^2 thresholded at p<.001 uncorrected
print_img(outpath_het,summary.heterogeneity.Isq,'_Isq_p001',summary.heterogeneity.p_het<.001);
print_img(outpath_het,summary.heterogeneity.Isq,'_Isq_pperm_FWE05',summary.heterogeneity.perm.p_FWE<.05);
%Tau unthresholded
print_img(outpath_het,sqrt(summary.heterogeneity.tausq),'_tau');
print_img(outpath_het,summary.heterogeneity.tausq,'_tausq');
print_img(outpath_het,summary.heterogeneity.tausq,'_tausq_p001',summary.heterogeneity.p_het<.001);
print_img(outpath_het,summary.heterogeneity.tausq,'_tausq_pperm_FDR',summary.heterogeneity.perm.p_uncorr<summary.heterogeneity.perm.p_FDR_thresh); 
print_img(outpath_het,sqrt(summary.heterogeneity.tausq),'_tau_pperm_FWE05',summary.heterogeneity.perm.p_FWE<.05); 
print_img(outpath_het,summary.heterogeneity.tausq,'_tausq_pperm_FWE05',summary.heterogeneity.perm.p_FWE<.05); 
print_img(outpath_het,summary.heterogeneity.chisq,'_chisq'); 
%full p maps
print_img(outpath_het,summary.heterogeneity.p_het,'_p_map'); 
print_img(outpath_het,summary.heterogeneity.perm.p_uncorr,'_p_map_perm'); 
print_img(outpath_het,summary.heterogeneity.perm.p_FWE,'_p_map_perm_FWE'); 

%% Print images for main effect FIXED
outpath_fixed=fullfile(outpath,'fixed');
if ~isempty(regexp(label,'rrating','once'))
    eff_size_fixed=summary.fixed.summary*-1; % Correlation between brain activity and behavior was determine as the contrast pla-con. Therefore positive correlations represent brain regions where more brain activity is associated with more pain(!) under placebo conditions. Correlations are inverted so that positive correlations denote more brain activity AND more placebo effect (i.e. less pain under placebo conditions) 
else
    eff_size_fixed=summary.fixed.summary;
end
print_img(outpath_fixed,eff_size_fixed,'_unthresh'); 
print_img(outpath_fixed,eff_size_fixed,'_p001',summary.fixed.p<.001);
print_img(outpath_fixed,eff_size_fixed,'_p_FDR',summary.fixed.p<summary.fixed.p_FDR_thresh) 
print_img(outpath_fixed,eff_size_fixed,'_pperm_p001',summary.fixed.perm.p_uncorr<.001) 
print_img(outpath_fixed,eff_size_fixed,'_pperm_FDR',summary.fixed.perm.p_uncorr<summary.fixed.perm.p_FDR_thresh) 
print_img(outpath_fixed,eff_size_fixed,'_pperm_FWE05',summary.fixed.perm.p_FWE<.05)

if isfield(summary.fixed.perm,'p_tfce_uncorr')
    print_img(outpath_fixed,eff_size_fixed,'_pperm_tfce_p001',summary.fixed.perm.p_tfce_uncorr<.001) 
    print_img(outpath_fixed,eff_size_fixed,'_pperm_tfce_FDR',summary.fixed.perm.p_tfce_uncorr<summary.fixed.perm.p_tfce_FDR_thresh) 
    print_img(outpath_fixed,eff_size_fixed,'_pperm_tfce_FWE05',summary.fixed.perm.p_tfce_FWE<.05) 
end
print_img(outpath_fixed,summary.fixed.SEsummary,'_SE') 
print_img(outpath_fixed,summary.fixed.SEsummary_smooth,'_SE_smooth') 
print_img(outpath_fixed,summary.fixed.z,'_z') 
print_img(outpath_fixed,summary.fixed.z_smooth,'_z_smooth') 
%full p maps
print_img(outpath_fixed,summary.fixed.p,'_p_map') 
print_img(outpath_fixed,summary.fixed.perm.p_uncorr,'_p_map_perm') 
print_img(outpath_fixed,summary.fixed.perm.p_FWE,'_p_map_perm_FWE') 

%% Print images for main effect RANDOM
outpath_random=fullfile(outpath,'random');
if ~isempty(regexp(label,'rrating','once'))
    eff_size_random=summary.random.summary*-1; % Correlation between brain activity and behavior was determine as the contrast pla-con. Therefore positive correlations represent brain regions where more brain activity is associated with more pain(!) under placebo conditions. Correlations are inverted so that positive correlations denote more brain activity AND more placebo effect (i.e. less pain under placebo conditions) 
else
    eff_size_random=summary.random.summary;
end
print_img(outpath_random,eff_size_random,'_unthresh') 
print_img(outpath_random,eff_size_random,'_p001',summary.random.p<.001) 
print_img(outpath_random,eff_size_random,'_p_FDR',summary.random.p<summary.random.p_FDR_thresh) 
print_img(outpath_random,eff_size_random,'_pperm_p001',summary.random.perm.p_uncorr<.001) 
print_img(outpath_random,eff_size_random,'_pperm_FDR',summary.random.perm.p_uncorr<summary.random.perm.p_FDR_thresh) 
print_img(outpath_random,eff_size_random,'_pperm_FWE05',summary.random.perm.p_FWE<.05)
if isfield(summary.random.perm,'p_tfce_uncorr')
    print_img(outpath_random,eff_size_random,'_pperm_tfce_p001',summary.random.perm.p_tfce_uncorr<.001) 
    print_img(outpath_random,eff_size_random,'_pperm_tfce_FDR',summary.random.perm.p_tfce_uncorr<summary.random.perm.p_tfce_FDR_thresh) 
    print_img(outpath_random,eff_size_random,'_pperm_tfce_FWE05',summary.random.perm.p_tfce_FWE<.05) 
end
print_img(outpath_random,summary.random.SEsummary,'_SE') 
print_img(outpath_random,summary.random.SEsummary_smooth,'_SE_smooth') 
print_img(outpath_random,summary.random.z,'_z') 
print_img(outpath_random,summary.random.z_smooth,'_z_smooth') 
%full p maps
print_img(outpath_random,summary.random.p,'_p_map') 
print_img(outpath_random,summary.random.perm.p_uncorr,'_p_map_perm') 
print_img(outpath_random,summary.random.perm.p_FWE,'_p_map_perm_FWE') 
    
function print_img(outpath,stat,suffix,threshold_index)    
    if ~exist('threshold_index','var')
        threshold_index=ones(size(stat)); % if not threshold_index is supplied, the threshold will be set so high, that it will not apply
    end
    
    if ismember(suffix,{'p_map','p_map_perm','p_map_perm_FWE'})
        outimg=ones(size(statmask)); % For p-maps the default should be values of 1, as very low p-values are sometimes printed as plain 0's.
    else
        outimg=zeros(size(statmask));
    end
    
    outimg(statmask)=stat.*threshold_index;
    print_image(outimg,mask_path,fullfile(outpath,[label,suffix]));
end
end