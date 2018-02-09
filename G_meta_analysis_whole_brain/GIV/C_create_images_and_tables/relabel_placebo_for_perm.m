function [df_null,dfv_null]=relabel_placebo_for_perm(df,dfv)
dfv_null=dfv;
% randomly relabel IMAGE data in df to generate data-set under the null
 for i=1:size(df,1) % Calculate for all studies except...
        if df.contrast_imgs_only(i)==0 %...data-sets where only contrasts are available
            if strcmp(df.study_design{i}, 'within') %For within-subject studies...
                % randomly inverse contrasts for each
                curr_n=size(dfv.pain_placebo{i},1);
                relabel=logical(random('Discrete Uniform',2,curr_n,1)-1); % randomly generate 0 or 1 to invert contrasts
                dfv_null.pain_placebo{i}=vertcat(dfv.pain_placebo{i}(relabel,:),...
                                                dfv.pain_control{i}(~relabel,:));
                dfv_null.pain_control{i}=vertcat(dfv.pain_placebo{i}(~relabel,:),...
                                                dfv.pain_control{i}(relabel,:));
            elseif strcmp(df.study_design{i}, 'between') %Between-subject studies
               sample=vertcat(dfv.pain_placebo{i},dfv.pain_control{i}); %pool groups
               sample=sample(randperm(size(sample,1)),:); %shuffle groups
               dfv_null.pain_placebo{i}=sample(1:size(dfv.pain_placebo{i},1),:);
               dfv_null.pain_control{i}=sample(size(dfv.pain_placebo{i},1)+1:end,:);
            end        
        end
end
    % Calculate for those studies where only pla>con contrasts are available
conOnly=find(df.contrast_imgs_only==1);
for i=conOnly'
    curr_n=size(dfv.placebo_minus_control{i},1);
    relabel=(random('Discrete Uniform',2,curr_n,1)*2-3); %randomly invert contrasts
    dfv_null.placebo_minus_control{i}=dfv.placebo_minus_control{i}.*relabel;
end

% For voxel only the sign of effect has been permuted above.
% So in respect to the correlation of voxel signal and ratings, data are
% not fully randomized.
% Just to make sure we have a completely random null-distribution in
% respect to correlations, we shuffle ratings as well.
df_null=df;
for i=1:size(df,1)
    df_null.GIV_stats_rating(i).delta=shuffles(df_null.GIV_stats_rating(i).delta);
end