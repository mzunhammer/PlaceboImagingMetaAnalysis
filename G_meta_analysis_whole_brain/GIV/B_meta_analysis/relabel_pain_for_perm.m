function dfv_null=relabel_pain_for_perm(df,dfv)
dfv_null=dfv;
% randomly relabel IMAGE data in df to generate data-set under the null
 for i=1:size(df,1)
    curr_n=size(dfv.placebo_and_control{i},1);
    relabel=random('Discrete Uniform',2,curr_n,1)*2-3; %randomly invert contrasts
    dfv_null.placebo_and_control{i}=dfv.placebo_and_control{i}.*relabel; %PAIN>BASELINE CONTRASTS ARE STORED IN "CONTROL"
end