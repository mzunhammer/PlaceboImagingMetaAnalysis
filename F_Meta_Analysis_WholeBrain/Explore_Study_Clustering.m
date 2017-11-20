% Study-clustering
clear
load B1_Full_Sample_Summary_Pain.mat
load B1_Full_Sample_Summary_Placebo.mat

rmpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/CanlabCore/'))
X_pain=vertcat(pain_stats.g);
X_pla=vertcat(placebo_stats.g);
X_pain(isnan(X_pain))=0;
X_pla(isnan(X_pla))=0;

%% k means for pain
k_max=4;
idx_pain=cell(k_max,1);
C_pain=cell(k_max,1);
sumd_pain=cell(k_max,1);
D_pain=cell(k_max,1);
bootsamples=100;
h = waitbar(0,'k_means with boot_sampling');
for k=1:k_max
    %Calculate kmeans for each target k
    [idx_pain{k},C_pain{k},sumd_pain{k},D_pain{k}]=kmeans(X_pain,k,'Replicates',10);
    
    %Calculate bootstrapped ci's for sumd_pain for each k
    for i=1:bootsamples
        random_i=randi(size(X_pain,1),size(X_pain,1),1); % bootstrap rows
        [~,~,curr_sumd_pain,~]=kmeans(X_pain(random_i,:),k,'Replicates',10);
        sum_dist_perm(i)=sum(curr_sumd_pain);
    end
    km(k)=sum(sumd_pain{k});%within-cluster dispersion
    km_perm_lo(k)=quantile(sum_dist_perm,0.05);
    km_perm_hi(k)=quantile(sum_dist_perm,0.95);
    waitbar(i/p_max,h);
end
figure
plot(km)
hold on
errorbar(1:length(km),lm,km_perm_lo,km_perm_hi)

close(h)
hist(sum_dist_perm)
hold on
x_ori=sum(sumd_pain{5});
vline(x_ori);
hold off
%% k means for placebo
idx_pla=cell(k_max,1);
C_pla=cell(k_max,1);
sumd_pla=cell(k_max,1);
D_pla=cell(k_max,1);

for k=1:k_max
    [idx_pla{k},C_pla{k},sumd_pla{k},D_pla{k}]=kmeans(X_pla,k,'Replicates',10);
end
figure
plot(cellfun(@sum,sumd_pla))