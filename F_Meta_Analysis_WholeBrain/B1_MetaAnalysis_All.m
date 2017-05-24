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
tic
%Preallocate stats for speed
n_studies=length(df_full_masked.studies);
stats(n_studies).mu=[];
stats(n_studies).sd_diff=[];
stats(n_studies).sd_pooled=[];
stats(n_studies).se_mu=[];
stats(n_studies).n=[];
stats(n_studies).r=[];
stats(n_studies).d=[];
stats(n_studies).se_d=[];
stats(n_studies).g=[];
stats(n_studies).se_g=[];
stats(n_studies).delta=[];
stats(n_studies).std_delta=[];
stats(n_studies).ICC=[];

for i=1:length(df_full_masked.studies) % Calculate for all studies except...
    if df_full_masked.consOnlyImg(i)==0 %...data-sets where both pla and con is available
        if df_full_masked.BetweenSubject(i)==0 %Within-subject studies
           stats(i)=withinMetastats(df_full_masked.pla_img{i},df_full_masked.con_img{i});
        elseif df_full_masked.BetweenSubject(i)==1 %Between-subject studies
           stats(i)=betweenMetastats(df_full_masked.pla_img{i},df_full_masked.con_img{i});
        end        
    end
end
% Calculate for those studies where only pla>con contrasts are available
conOnly=find(df_full_masked.consOnlyImg==1);
impu_r=nanmean([stats.r]); % impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
stats(i)=withinMetastats(df_full_masked.pla_img{i},impu_r);
end
% Calculate meta-analysis summary
summary=GIVsummary(stats);
toc

outimg_z=zeros(size(df_full_masked.brainmask));
outimg_z(df_full_masked.brainmask)=summary.g.random.z;
printImage(outimg_z,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_z'))

outimg_g=zeros(size(df_full_masked.brainmask));
outimg_g(df_full_masked.brainmask)=summary.g.random.summary;
printImage(outimg_g,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','Full_Sample_Pla_min10perc_g'))

%% Explore peak results

% Best peak around left hippocampus
max_z=find(summary.g.random.z==max(summary.g.random.z))
max_z_stats=stat_reduce(stats,max_z);
max_z_summary=ForestPlotter(max_z_stats,...
                  'studyIDtexts',studyIDtexts,...
                  'outcomelabel','Maximum z Voxel: Hedges'' g)',...
                  'type','random',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0);

outimg_mark_max_z=zeros(size(df_full_masked.brainmask));
out_mark=zeros(size(summary.g.random.summary));
out_mark(max_z)=1;
outimg_mark_max_z(df_full_masked.brainmask)=out_mark;
printImage(outimg_mark_max_z,'../../pattern_masks/brainmask_logical_50.nii',fullfile('./nii_results','max_z'))

hist(all_g(:,max_z));
%% Meta-Analysis: Run repeatedly for permutation test
tic
%Preallocate stats for speed
n_studies=length(df_full_masked.studies);
stats_perm(n_studies).mu=[];
stats_perm(n_studies).sd_diff=[];
stats_perm(n_studies).sd_pooled=[];
stats_perm(n_studies).se_mu=[];
stats_perm(n_studies).n=[];
stats_perm(n_studies).r=[];
stats_perm(n_studies).d=[];
stats_perm(n_studies).se_d=[];
stats_perm(n_studies).g=[];
stats_perm(n_studies).se_g=[];
stats_perm(n_studies).delta=[];
stats_perm(n_studies).std_delta=[];
stats_perm(n_studies).ICC=[];

n_studies=length(stats_perm);
n_multiple=size(stats_perm(1).std_delta,2);
n_perms=20;
g_random_z_min=NaN(n_perms,1);
g_random_z_max=NaN(n_perms,1);

for p=1:n_perms    
    for i=1:length(df_full_masked.studies) % Calculate for all studies except...
        if df_full_masked.consOnlyImg(i)==0 %...data-sets where both pla and con is available
            if df_full_masked.BetweenSubject(i)==0 %Within-subject studies   
                %randomly inverse or not inverse contrasts for each participant
                curr_n=size(df_full_masked.pla_img{i},1);
                relabel=logical(random('Discrete Uniform',2,curr_n,1)-1);
                curr_pla=vertcat(df_full_masked.pla_img{i}(relabel,:),df_full_masked.con_img{i}(~relabel,:));
                curr_con=vertcat(df_full_masked.pla_img{i}(~relabel,:),df_full_masked.con_img{i}(relabel,:));
                stats_perm(i)=withinMetastats(df_full_masked.pla_img{i},df_full_masked.con_img{i});
            elseif df_full_masked.BetweenSubject(i)==1 %Between-subject studies
               
               sample=vertcat(df_full_masked.pla_img{i},df_full_masked.con_img{i}); %pool groups
               sample=sample(randperm(size(sample,1)),:); %shuffle groups
               curr_pla=sample(1:size(df_full_masked.pla_img{i},1),:);
               curr_con=sample(size(df_full_masked.pla_img{i},1)+1:end,:);
               stats_perm(i)=betweenMetastats(curr_pla,curr_con); %redraw and summarize
            end        
        end
    end
    % Calculate for those studies where only pla>con contrasts are available
    conOnly=find(df_full_masked.consOnlyImg==1);
    impu_r=nanmean([stats_perm.r]); % impute the mean within-subject study correlation observed in all other studies
    for i=conOnly'
    curr_n=size(df_full_masked.pla_img{i},1);
    relabel=(random('Discrete Uniform',2,curr_n,1)*2-3); %randomly invert contrasts
    curr_pla=df_full_masked.pla_img{i}.*relabel;
    stats_perm(i)=withinMetastats(curr_pla,impu_r);
    end
    % Calculate meta-analysis summary
    summary_perm=GIVsummary(stats_perm);
    g_random_z_min(p)=min(summary_perm.g.random.z);
    g_random_z_max(p)=max(summary_perm.g.random.z);
    toc
end

hist(g_random_z_max);
quantile(g_random_z_min,0.05);
quantile(g_random_z_max,0.95);

printImage(summary_perm.g.random.z,'Full_Sample_pla_min10perc_z_permuted_null')
% z-max at 95% Quantile w mask 10% no-signal voxels = 6.1620 (100 perms);
% 6.2 (20 perms)
%% Obtain Bayesian Factors

bayesfactor(0.08,0.04,1,[0,0.2]) % Bayes factor for negligible results
bayesfactor(0.08,0.04,1,[0.2,0.5]) % Bayes factor for small results
