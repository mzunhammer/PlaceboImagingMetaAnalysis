function [stats_out]=within_study_summary(stats,varargin)
% Method to summarize continuous effect size statistics WITHIN studies
% For now: Will only work with within-subject meta-stats objects.

% Calculations are according to Borenstein, Chapter 24, formulas 24.4 and
% 24.5.

% Input:
% stats: objects from withinMetastats or betweenMetastats analysis of N conditions from ONE study.

% Output:
% stats_out: also a stats object with same inputs, but reduced to one entry

% Per default, all calculations are performed for these effect size
% measures:
if ~exist('outputs')
    outputs={'mu','d','g'};
end

%means
if any(strcmp(outputs,'mu'))
[stats_out.mu,stats_out.se_mu]=WI_summary(vertcat(stats.mu),vertcat(stats.se_mu),horzcat(stats.std_delta));
end
%d
if any(strcmp(outputs,'d'))
[stats_out.d,stats_out.se_d]=WI_summary(vertcat(stats.d),vertcat(stats.se_d),horzcat(stats.std_delta));
end
%g
if any(strcmp(outputs,'g'))
[stats_out.g,stats_out.se_g]=WI_summary(vertcat(stats.g),vertcat(stats.se_g),horzcat(stats.std_delta));
end


stats_out.n=min(vertcat(stats.n))
stats_out.delta=mean(horzcat(stats.delta),2);
stats_out.std_delta=mean(horzcat(stats.std_delta),2);

% Actual GIV function, used since same formula applies for all outcomes... (means,d,g,r)
    function [summary_effect,summary_error]=WI_summary(effects,SEs,std_diffs)
       %Exclude invalid values...
       effects(isinf(effects))=NaN; % exclude studies with infinite values (can occur in fisher's z transformation of perfect correlations (r=1 or r=-1) >> e.g. due to a lack of variance
       SEs(isinf(effects))=NaN;         % exclude studies with 0 error (due to lack of variance), otherwise we will get inf values
       effects(SEs==0)=NaN;         % exclude studies with 0 error (due to lack of variance), otherwise we will get inf values
       SEs(SEs==0)=NaN;         % exclude studies with 0 error (due to lack of variance), otherwise we will get inf values
       
       m=length(effects);
       % Summary effect (easy)
       summary_effect=sum(effects)/m; % number of conditions

       % Summary variance (24.5)... pretty complicated
       v1=sum(SEs);
       
       all_corrs=corrcoef(std_diffs); % correlation matrix of all outcomes
       [SEsX,SEsY]=meshgrid(SEs,SEs);
       all_v_squared=sqrt(SEsX).*sqrt(SEsY); %Cartesian product of sqrt(V)
       all_v_squared_corr=all_corrs.*all_v_squared; % Correlation and cartesian sqrt(V) combined.
       v2=sum(all_v_squared_corr(~eye(size(all_v_squared_corr)))); % Sum of all combinations excluding identity (the diagnoal).
              
       summary_error=(v1+v2).*(1./m).^2;
    end
end