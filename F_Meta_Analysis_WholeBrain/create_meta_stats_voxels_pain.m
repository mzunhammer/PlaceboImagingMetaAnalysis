function stats=create_meta_stats_voxels_pain(df)
%Preallocate stats for speed
n_studies=length(df.studies);
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

for i=1:length(df.studies) % Calculate for all studies except...
    if df.consOnlyImg(i)==0 %...data-sets where only contrasts are available
        if df.BetweenSubject(i)==0 %Calculate within-subject studies
           stats(i)=withinMetastats(nanmean(cat(3,df.pla_img{i},df.con_img{i}),3),0); % Pain vs baseline contrast within subjects (one-sample test)
        elseif df.BetweenSubject(i)==1 %Calculate between-group studies
           stats(i)=withinMetastats([df.pla_img{i};df.con_img{i}],0); % Pain vs baseline contrast within subjects (one-sample test)
        end        
    end
end
% Calculate for those (within-subject) studies where only pla>con contrasts are available
conOnly=find(df.consOnlyImg==1);
impu_r=nanmean([stats.r]); % ... impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
    stats(i)=withinMetastats(df.con_img{i},0); % THE DATA IN "CONTROL CONDITION" REPRESENT PAIN vs BASELINE ANALYSIS
end

end