function C_winsorize(datapath)
% Censoring extreme values to 3 standard deviations (most extreme 0.3% of data)
% The 3 SD target is chosen for consistency with earlier Wager studies.
% Winsorizing is performed on a by-study-by-contrast level.

% Load data
load(fullfile(datapath,'vectorized_images_full_masked_10_percent.mat'),'dfv_masked')

% Set windsorizing parameters:
target_sd=3;
p_low=(normcdf(target_sd*-1,0,1))*100;
p_high=(normcdf(target_sd,0,1))*100;

%% Demonstrate necessity of windsorizing
% ... using the placebo_and_control (pooled painful conditions) images:
% Scale images study-wise by grand SD
for i = 1:length(dfv_masked.placebo_and_control)
    dfv_masked.placebo_and_control_scaled{i}=dfv_masked.placebo_and_control{i}./nanstd(dfv_masked.placebo_and_control{i}(:));
end
% Pool all studies in one grand matrix
full_matrix=vertcat(dfv_masked.placebo_and_control_scaled{:});
% Plot histogram.
figure('Name','Standardized voxel signal values before winsorizing')
hist(full_matrix(:),100);

% Description:
% At a total of 603*191119= 115 million voxels, we would expect values within
% +- 6 standard-deviations.
% What we see is that data seem approximately normally distributed, but
% with a few values putting very long tails on the distribution. 
% Some voxels excede >10 SDs, which has a probability of... 7.7*10^-23
% (one in a trivigintizillion...)

% Winsorizing image-wise does only partly solve the problem
c=full_matrix;
for i = 1:size(c,1)
    c(i,c(i,:)>prctile(c(i,:),p_high))=prctile(c(i,:),p_high);
    c(i,c(i,:)<prctile(c(i,:),p_low))=prctile(c(i,:),p_low);
end
figure('Name','Standardized voxel signal values after winsorizing image-wise')
hist(c(:),100)

%% Windsorize data
% So we resort to winsorizing by-study and by-contrast (keeping studies
% and conditions independent):
winsorized.pain_placebo=cell(20,1);
winsorized.pain_control=cell(20,1);
winsorized.placebo_minus_control=cell(20,1);
winsorized.placebo_and_control=cell(20,1);
winsorized.placebo_and_control_scaled=cell(20,1);

cons={'pain_placebo','pain_control','placebo_minus_control','placebo_and_control','placebo_and_control_scaled'};
for j = 1:length(cons)
    for i = 1:length(dfv_masked.(cons{j}))
        curr_matrix=dfv_masked.(cons{j}){i};
        if ~isempty(curr_matrix)
            curr_upper_prctile=prctile(curr_matrix(:),p_high);
            curr_lower_prctile=prctile(curr_matrix(:),p_low);
            winsorized.(cons{j}){i}=(curr_matrix>curr_upper_prctile) + (curr_matrix<curr_lower_prctile);
            curr_matrix(curr_matrix>curr_upper_prctile)=curr_upper_prctile;
            curr_matrix(curr_matrix<curr_lower_prctile)=curr_lower_prctile;
            dfv_masked.(cons{j}){i}=curr_matrix;
        end
    end
end

% This improves the distribution of data a lot:
d=vertcat(dfv_masked.placebo_and_control_scaled{:});
figure('Name','Standardized voxel signal values after winsorizing study-wise')
hist(d(:),100)

% Further, winsorizing does not completely remove single subjects. The
% maximum proportion of winsorized voxels per subject is < 0.05
figure('Name','Proportion of voxels winsorized by subject')
e=vertcat(winsorized.placebo_and_control_scaled{:});
plot(sum(e,2)/size(e,2));

dfv_masked.placebo_and_control_scaled=[];

save(fullfile(datapath,'vectorized_images_full_masked_10_percent.mat'),'dfv_masked','-v7.3')

end