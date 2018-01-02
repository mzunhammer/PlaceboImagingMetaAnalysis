clear
load A1_Full_Sample.mat

%% Graph theory-style analysis of NPS Sub-Regions
% Assessing co-activation of NPS sub-regions across subjects and comparing
% these between placebo and control conditions.
% Studies where only contrast images are available cannot be included (control-placebo).
%
% Correlation analysis has to be performed on a by-study basis>>
% >> Assumption of independent errors has to be fulfilled
%
% Summary of single-study results via GIV_summary functions.

NPS_subregions={'NPS_Pos_Region1_Region001',...
                'NPS_Pos_Region2_Region002',...
                'NPS_Pos_Region3_Region003',...
                'NPS_Pos_Region4_Region004',...
                'NPS_Pos_Region5_Region005',...
                'NPS_Pos_Region6_Region006',...
                'NPS_Pos_Region7_Region007',...
                'NPS_Pos_Region8_Region008',...
                'NPS_Neg_Region1_Region001',...
                'NPS_Neg_Region2_Region002',...
                'NPS_Neg_Region3_Region003',...
                'NPS_Neg_Region4_Region004',...
                'NPS_Neg_Region5_Region005',...
                'NPS_Neg_Region6_Region006',...
                'NPS_Neg_Region7_Region007'};

m=length(NPS_subregions);
mult_comp=(m*m-m)/2; %unique correlations in matrix, excluding diagonal.
ROIs=ismember(df_full.variables,NPS_subregions);

%% Single-study correlation matrices with n's
% Calculate all between-ROI correlations for placebo and control sessions
% for each study separately.
% Reshape correlation matrix into a 1d array (GIV summary function require 1d
% input arrays)
for i=1:length(df_full.studies)
    if ~df_full.consOnlyNPS(i)
    pla_ROIs=df_full.pladata{i}(:,ROIs);
    pla_corrs=corrcoef(pla_ROIs);
    df_full.pla_ROIs_corrs{i}=pla_corrs(:)';
    
    con_ROIs=df_full.condata{i}(:,ROIs);
    con_corrs=corrcoef(con_ROIs);
    df_full.con_ROIs_corrs{i}=con_corrs(:)';
    
    % Cludgy loop to calculate n's for each ROI correlation pair
    for j=1:length(NPS_subregions)
        for k=1:length(NPS_subregions)
            pla_corr_n(j,k)=sum(~isnan(pla_ROIs(:,j).*pla_ROIs(:,k)));
            con_corr_n(j,k)=sum(~isnan(con_ROIs(:,j).*con_ROIs(:,k)));
        end
    end
    df_full.pla_corr_n{i}=pla_corr_n(:)';
    df_full.con_corr_n{i}=con_corr_n(:)';
    end
end

%% Summarize single-study correlations for placebo runs
Z_corr_pla=r2fishersZ(vertcat(df_full.pla_ROIs_corrs{:}));
seZ_corr_pla=n2fisherZse(vertcat(df_full.pla_corr_n{:}));

[summary_pla.fixed,...
 summary_pla.random,...
 summary_pla.heterogeneity]=GIV_weight(Z_corr_pla,...
                                       seZ_corr_pla);
[summary_pla.fixed,...
 summary_pla.random,...
 summary_pla.heterogeneity]=GIV_weight_fishersZ2r(summary_pla.fixed,...
                                                  summary_pla.random,...
                                                  summary_pla.heterogeneity)
%% Summarize single-study correlations for control runs
Z_corr_con=r2fishersZ(vertcat(df_full.con_ROIs_corrs{:}));
seZ_corr_con=n2fisherZse(vertcat(df_full.con_corr_n{:}));                                             
                                              
[summary_con.fixed,...
 summary_con.random,...
 summary_con.heterogeneity]=GIV_weight(Z_corr_con,...
                                       seZ_corr_con);
[summary_con.fixed,...
 summary_con.random,...
 summary_con.heterogeneity]=GIV_weight_fishersZ2r(summary_con.fixed,...
                                                  summary_con.random,...
                                                  summary_con.heterogeneity);

%% Summarize single-study differences in ROI correlations between control-placebo runs
Z_corr_diff=Z_corr_con-Z_corr_pla;
seZ_corr_diff=max(cat(3,seZ_corr_con,seZ_corr_pla),[],3); %Not sure if correct. How to compute se of differences in Z-transformed correlations...

[summary_diff.fixed,...
 summary_diff.random,...
 summary_diff.heterogeneity]=GIV_weight(Z_corr_diff,...
                                       seZ_corr_con);
[summary_diff.fixed,...
 summary_diff.random,...
 summary_diff.heterogeneity]=GIV_weight_fishersZ2r(summary_diff.fixed,...
                                                  summary_diff.random,...
                                                  summary_diff.heterogeneity);
%% Summarize single-study correlations for pla and con separately


%% Plots
clims=[-1,1];
clims_diff=[-0.2,0.2];
cmap=flipud(cbrewer('div', 'RdBu',200));

figure
subplot(2,2,1)
r_con=reshape(summary_con.random.summary,m,m);
imagesc(r_con,clims)
title('Control')
set(gca, 'YTick', 1:length(NPS_subregions));
set(gca, 'XTick', 1:length(NPS_subregions));
colorbar

subplot(2,2,2)
r_pla=reshape(summary_pla.random.summary,m,m);
imagesc(r_pla,clims)
title('Placebo')
set(gca, 'YTick', 1:length(NPS_subregions));
set(gca, 'XTick', 1:length(NPS_subregions));
colorbar

subplot(2,2,3)
r_diff=reshape(summary_diff.random.summary,m,m);
imagesc(r_diff,clims_diff)
title('Control>Placebo')
set(gca, 'YTick', 1:length(NPS_subregions));
set(gca, 'XTick', 1:length(NPS_subregions));
colorbar
colormap(cmap);

%% Differences
%figure
%imagesc(con_r-pla_r)

%pla_Z=r2fishersZ(pla_r);
%con_Z=r2fishersZ(con_r);



%z = (con_Z-pla_Z)./sqrt(1./(con_n-3)+1./(pla_n-3));
%p = (1-normcdf(abs(z),0,1))*2;
%imagesc(p)

%xticklabels(NPS_subregions)
%xtickangle(45)
%yticklabels(NPS_subregions)

