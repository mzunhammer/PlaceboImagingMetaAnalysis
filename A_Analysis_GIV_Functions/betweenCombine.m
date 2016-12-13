function [mean_combined,sd_combined]=betweenCombine(group1,group2)

%combines means and sd's of two groups using the formula from http://handbook.cochrane.org/chapter_7/table_7_7_a_formulae_for_combining_groups.htm

m1=nanmean(group1);
m2=nanmean(group2);
n1=sum(~isnan(group1));
n2=sum(~isnan(group2));
sd1=nanstd(group1);
sd2=nanstd(group1);

mean_combined=(n1*m1+n2*m2)/(n1+n2);
sd_combined= sqrt(( ((n1-1)*sd1^2) + ((n2-1)*sd2^2) + (n1*n2/(n1+n2))*(m1^2+m2^2-2*m1*m2)   )/  (n1+n2-1) )  ;
end