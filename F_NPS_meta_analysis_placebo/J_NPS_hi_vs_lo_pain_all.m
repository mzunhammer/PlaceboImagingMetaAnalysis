function J_NPS_hi_vs_lo_pain_all(datapath,pubpath)
%% Meta-Analysis & Forest Plot ? Full Sample (MAIN RESULTS)
df_name='data_frame.mat';
load(fullfile(datapath,df_name),'df');

study_ID_texts={
            'Atlas et al. 2012: High vs low noxious heat';...
            'Ellingsen et al. 2013: Noxious heat vs non-noxious warm touch';...
            %'Ellingsen et al. 2013: Noxious heat vs non-noxious brushstroke';...
            'Freeman et al. 2015: High vs low noxious heat';...
            'Kessner et al. 2013: High vs moderate noxious heat';...
            'Kong et al. 2006: High vs low noxious heat';...
            'Kong et al. 2009: High vs low noxious heat';... % CONTRASTS ONLY FOR NPS! NO RATINGS FOR HI VS LOW AVAILABLE
            'Ruetgen et al. 2015: High vs mild noxious electrical shocks'
            'Wager et al. 2004, Study 1: High vs mild noxious electrical shocks';... % CONTRASTS ONLY FOR NPS! NO RATINGS FOR HI VS LOW AVAILABLE
            };
%% Meta-Analysis
% note that standardized effect sizes are based on 
% the between-subject SD of summarized signal (summarized
% across images) at each voxel, not single-image SD (as within-subject
% images were not collected)

variable_select={'rating','NPS','rating101'}; %'MHEraw','SIIPS',,

% Loop for df.study_ID where both con and pla conditions are available
for j=1:length(variable_select) % Loop through all outcome variables
    currvar=variable_select{j};
    for i=1:size(df,1) % Loop through all studies...
        df_hi=df.subjects{i}.hi_pain;
        df_hi=vertcat(df_hi{:});
        df_lo=df.subjects{i}.lo_pain;
        df_lo=vertcat(df_lo{:});
        if ~isempty(df_hi)&&~isempty(df_lo)
        df.(['GIV_stats_hi_vs_lo_',currvar])(i)=summarize_within(df_hi.(currvar),df_lo.(currvar));
        end
    end
    
    % Manually get summaries for Kong 2009 and Wager 2004 (Hi>lo contrasts available only
    impu_r=nanmean([df.(['GIV_stats_hi_vs_lo_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
    i=find(strcmp(df.study_ID,'freeman'));
    df_hi=df.subjects{i}.hi_pain;
    df_hi=vertcat(df_hi{:});
    df.(['GIV_stats_hi_vs_lo_',currvar])(i)=summarize_within(df_hi.(currvar),impu_r);
    
    i=find(strcmp(df.study_ID,'kong09'));
    df_hi=df.subjects{i}.hi_pain;
    df_hi=vertcat(df_hi{:});
    df.(['GIV_stats_hi_vs_lo_',currvar])(i)=summarize_within(df_hi.(currvar),impu_r);

    i=find(strcmp(df.study_ID,'wager04a_princeton'));
    df_hi=df.subjects{i}.hi_pain;
    df_hi=vertcat(df_hi{:});
    df.(['GIV_stats_hi_vs_lo_',currvar])(i)=summarize_within(df_hi.(currvar),impu_r);
end



%% One Forest plot per variable
varnames={'rating'
          'NPS'};
nicevarnames={'Pain ratings',...
              'NPS response'};
summary=[];

for i = 1:numel(varnames)
    meta_stats=[df.(['GIV_stats_hi_vs_lo_',varnames{i}])];
    meta_stats=meta_stats([1,6,8,10,11,12,14,17]);
    summary.(varnames{i})=forest_plotter(meta_stats,...
                  'study_ID_texts',study_ID_texts,...
                  'outcome_labels',[nicevarnames{i},' (Hedges'' g)'],...
                  'type','random',...
                  'summary_stat','g',...
                  'with_outlier',1,... %'WI_subdata',{GIV_stats.std_delta},...
                  'box_scaling',1,...
                  'text_offset',0,...
                  'X_scale',6);
    hgexport(gcf, fullfile(pubpath,['B1_Meta_HiLo_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
    hgexport(gcf, fullfile(pubpath,['B1_Meta_HiLo_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_HiLo_',varnames{i},'.png']));
end
close all;

%% Additional forest plot for pain ratings standardized to 101pt VAS
varnames={'rating101'};
nicevarnames={'Pain ratings'};
for i = 1:numel(varnames)
    meta_stats=[df.(['GIV_stats_hi_vs_lo_',varnames{i}])];
    meta_stats=meta_stats([1,6,8,10,11,12,14,17]);
    summary.(varnames{i})=forest_plotter(meta_stats,...
                  'study_ID_texts',study_ID_texts,...
                  'outcome_labels',[nicevarnames{i},' (VAS_1_0_1)'],...
                  'type','random',...
                  'summary_stat','mu',...
                  'with_outlier',0,...%'WI_subdata',{GIV_stats.std_delta},...
                  'WI_subdata',{meta_stats.delta},...
                  'box_scaling',1,...
                  'text_offset',0);
    hgexport(gcf, fullfile(pubpath,['B1_Meta_HiLo_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg'); 
    hgexport(gcf, fullfile(pubpath,['B1_Meta_HiLo_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_HiLo_',varnames{i},'.png']));
end

close all
save(fullfile(datapath,'data_frame.mat'), 'df');

sum(vertcat(meta_stats.std_delta)>0)/sum(~isnan(vertcat(meta_stats.std_delta)));
meta_stats.std_delta;
%sprintf('The proportion of NPS responder: %0.2d',)
end