function stats=create_meta_stats_voxels_pain(df,dfv)
%Preallocate for speed
n_studies=size(df,1);
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

for i=1:size(df,1)
    stats(i)=summarize_within(dfv.placebo_and_control{i},0); % Pain vs baseline contrast within subjects (one-sample test) 
end

end