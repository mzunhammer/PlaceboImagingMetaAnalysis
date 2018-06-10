function stats=create_meta_stats_voxels_placebo(df,dfv,varargin)
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
    if  df.contrast_imgs_only(i)==0 %...data-sets where only contrasts are available
        if strcmp(df.study_design{i}, 'within') %Calculate within-subject studies
            if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
                curr_n=size(dfv.pain_placebo{i},1);
                relabel=logical(random('Discrete Uniform',2,curr_n,1)-1); % randomly generate 0 or 1 to invert contrasts
                pla=vertcat(dfv.pain_placebo{i}(relabel,:),...
                                                dfv.pain_control{i}(~relabel,:));
                con=vertcat(dfv.pain_placebo{i}(~relabel,:),...
                                                dfv.pain_control{i}(relabel,:));                            
            else % Actual statistic
                pla=dfv.pain_placebo{i};
                con=dfv.pain_control{i};
            end
           stats(i)=summarize_within(pla,con);
        elseif strcmp(df.study_design{i}, 'between') %Calculate between-group studies
            if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
               sample=vertcat(dfv.pain_placebo{i},dfv.pain_control{i}); %pool groups
               sample=sample(randperm(size(sample,1)),:); %shuffle groups
               pla=sample(1:size(dfv.pain_placebo{i},1),:);
               con=sample(size(dfv.pain_placebo{i},1)+1:end,:);   
            else    
                pla=dfv.pain_placebo{i};
                con=dfv.pain_control{i};
            end
           stats(i)=summarize_between(pla,con); % no subjects had to be excluded for between-group studies
        end        
    end
end
% Calculate for those (within-subject) studies where only pla>con contrasts are available
conOnly=find(df.contrast_imgs_only==1);
impu_r=nanmean([stats.r]); % ... impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
    if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
        curr_n=size(dfv.placebo_minus_control{i},1);
        relabel=(random('Discrete Uniform',2,curr_n,1)*2-3); %randomly invert contrasts
        pla=dfv.placebo_minus_control{i}.*relabel;
    else
        pla=dfv.placebo_minus_control{i};
    end
    stats(i)=summarize_within(pla,impu_r); % THE con_img VECTOR INCLUDES PAIN vs BASELINE CONTRAST AND IS NOT TO BE USED USED IN PLACEBO VS CONTROL ANALYSIS
end

%% Correlation of behavioral effect and voxel-by-voxel bold response
for i=1:length(stats)
    if any(strcmp(varargin,'conservative'))
        ex_subj=df.subjects{i}.excluded;
    else
        ex_subj=zeros((size(df.subjects{i}.excluded)));
    end
    if ~isempty(stats(i).delta) % necessary as "sum" returns 0 for [] for some stupid reason
        if any(strcmp(varargin,'perm')) % Optionally create permuted statistic (under the null hypothesis instead of actual statistic)
            % For voxel only the sign of effect has been permuted above.
            % So in respect to the correlation of voxel signal and ratings, data are
            % not fully randomized.
            % Just to make sure we have a completely random null-distribution in
            % respect to correlations, we shuffle ratings as well.
            activity=stats(i).delta;
            ratings=shuffles(df.GIV_stats_rating(i).delta);
            ratings=ratings(~ex_subj,:);
        else
            activity=stats(i).delta;
            ratings=df.GIV_stats_rating(i).delta(~ex_subj,:);
        end
        stats(i).r_external=fastcorrcoef(activity,ratings,'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
        stats(i).n_r_external=sum(~(isnan(activity)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                             isnan(ratings))); % AND non nan-ratings
    else
        stats(i).r_external=[];%NaN(1,n_voxel);
        stats(i).n_r_external=[];%NaN(1,n_voxel);
    end
end

end