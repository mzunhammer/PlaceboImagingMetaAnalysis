function summary=forest_plotter(meta_stats,varargin)

%% Wrapper for forest_plot.m to obtain summary statistics conveniently from single-study level stats
% meta_stats struct obtained by performing a series of summarize_within.m
% and/or summarize_between.m
% Summarize standardized using the generic inverse-variance weighting method
% Additional advantage: Passes standardized single-subject effects for
% outlier analysis.

summary_stat=varargin{find(strcmp(varargin,'summary_stat'))+1};

% Calculate GIV summary
summary=GIV_summary(meta_stats,summary_stat);

% Select effect+se for forest_plot
if ismember(summary_stat,{'r','ICC','r_external'}) 
    eff=vertcat(meta_stats.(summary_stat));
    n=vertcat(meta_stats.n);
    se_eff=sqrt(1./(n-3)); % SE for FISHER's
else
    eff=vertcat(meta_stats.(summary_stat));
    se_eff=vertcat(meta_stats.(['se_',summary_stat]));
    n=vertcat(meta_stats.n);
end

forest_plot(eff,se_eff,n,...
            summary.(summary_stat),...
            varargin{:});
