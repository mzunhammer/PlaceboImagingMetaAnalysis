function df_null=relabel_pain_for_perm(df)
df_null=df;
% randomly relabel IMAGE data in df to generate data-set under the null
 for i=1:length(df.studies) % Calculate for all studies except...
        if df.consOnlyImg(i)==0 %...data-sets where only contrasts are available
            if df.BetweenSubject(i)==0 %For within-subject studies...
                % randomly multiply BOTH placebo & control with 1 or -1 (they will be summarized voxel-wise using the mean in create_meta_stats_voxels_pain)
                curr_n=size(df.pla_img{i},1);
                relabel=random('Discrete Uniform',2,curr_n,1)*2-3; % randomly generate -1 or 1 to invert contrasts
                df_null.pla_img{i}=df.pla_img{i}.*relabel;
                df_null.con_img{i}=df.con_img{i}.*relabel;
            elseif df.BetweenSubject(i)==1 %Between-subject studies
               curr_n=size(df.pla_img{i},1);
               relabel=random('Discrete Uniform',2,curr_n,1)*2-3;
               df_null.pla_img{i}=df.pla_img{i}.*relabel; %relabel each subject in pla group by multiplying with -1 and 1
               curr_n=size(df.con_img{i},1);
               relabel=random('Discrete Uniform',2,curr_n,1)*2-3;
               df_null.con_img{i}=df.con_img{i}.*relabel; %relabel each subject in pla group by multiplying with -1 and 1
            end        
        end
end
    % Calculate for those studies where only pla>con contrasts are available
conOnly=find(df.consOnlyImg==1);
for i=conOnly'
    curr_n=size(df.con_img{i},1);
    relabel=random('Discrete Uniform',2,curr_n,1)*2-3; %randomly invert contrasts
    df_null.con_img{i}=df.con_img{i}.*relabel; %PAIN>BASELINE CONTRASTS ARE STORED IN "CONTROL"
end