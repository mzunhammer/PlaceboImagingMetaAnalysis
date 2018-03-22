function stats=create_meta_stats_voxels_placebo(df,dfv)
%Preallocate stats for speed
n_studies=size(df,1);
n_voxel=sum(dfv.brainmask);
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
stats(n_studies).r_external=[];
stats(n_studies).n_r_external=[];

%% Voxel-by-voxel bold response change due to placebo condition
for i=1:size(df,1) % Calculate for all studies except...
    if df.contrast_imgs_only(i)==0 %...data-sets where only contrasts are available
        if strcmp(df.study_design{i}, 'within') %Calculate within-subject studies
           stats(i)=summarize_within(dfv.pain_placebo{i},dfv.pain_control{i});
        elseif strcmp(df.study_design{i}, 'between') %Calculate between-group studies
           stats(i)=summarize_between(dfv.pain_placebo{i},dfv.pain_control{i});
        end        
    end
end
% Calculate for those (within-subject) studies where only pla>con contrasts are available
conOnly=find(df.contrast_imgs_only==1);
impu_r=nanmean([stats.r]); % ... impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
    stats(i)=summarize_within(dfv.placebo_minus_control{i},impu_r); % THE con_img VECTOR INCLUDES PAIN vs BASELINE CONTRAST AND IS NOT TO BE USED USED IN PLACEBO VS CONTROL ANALYSIS
end

%% Correlation of behavioral effect and voxel-by-voxel bold response
for i=1:length(stats)
    stats(i).r_external=fastcorrcoef(stats(i).delta,df.GIV_stats_rating(i).delta,'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
    if ~isempty(stats(i).delta) % necessary as "sum" returns 0 for [] for some stupid reason
        stats(i).n_r_external=sum(~(isnan(stats(i).delta)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                         isnan(df.GIV_stats_rating(i).delta))); % AND non nan-ratings
    else
        stats(i).r_external=NaN(1,n_voxel);
        stats(i).n_r_external=NaN(1,n_voxel);
    end
end

end