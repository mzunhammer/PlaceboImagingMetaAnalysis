function df_null=relabel_df_for_perm(df)
df_null=df;
% randomly relabels df to generate data-set under the null
 for i=1:length(df.studies) % Calculate for all studies except...
        if df.consOnlyImg(i)==0 %...data-sets where only contrasts are available
            if df.BetweenSubject(i)==0 %For within-subject studies...
                % randomly inverse contrasts for each
                % participant by multiplying with 1 or -1
                curr_n=size(df.pla_img{i},1);
                relabel=logical(random('Discrete Uniform',2,curr_n,1)-1); % randomly generate -1 or 1 to invert contrasts
                df_null.pla_img{i}=vertcat(df.pla_img{i}(relabel,:),df.con_img{i}(~relabel,:));
                df_null.con_img{i}=vertcat(df.pla_img{i}(~relabel,:),df.con_img{i}(relabel,:));
            elseif df.BetweenSubject(i)==1 %Between-subject studies
               sample=vertcat(df.pla_img{i},df.con_img{i}); %pool groups
               sample=sample(randperm(size(sample,1)),:); %shuffle groups
               df_null.pla_img{i}=sample(1:size(df.pla_img{i},1),:);
               df_null.con_img{i}=sample(size(df.pla_img{i},1)+1:end,:);
            end        
        end
    end
    % Calculate for those studies where only pla>con contrasts are available
    conOnly=find(df.consOnlyImg==1);
    for i=conOnly'
        curr_n=size(df.pla_img{i},1);
        relabel=(random('Discrete Uniform',2,curr_n,1)*2-3); %randomly invert contrasts
        df_null.pla_img{i}=df.pla_img{i}.*relabel;
    end