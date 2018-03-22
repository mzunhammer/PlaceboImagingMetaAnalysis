function C_meta_analysis_placebo_responder(datapath,pubpath)
%% Meta-Analysis & Forest Plot ? Responder Sample
df_name='data_frame.mat';
load(fullfile(datapath,df_name),'df');

%% Designate responders
% Note: Dichotomization of continuous outcomes is suboptimal in terms of
% statistical power and can yield misleading results (MacCallum et al. 2002).
% Therefore, I think that this responder analysis is superfluous and
% basically shows the same as the correlation analysis of NPS response, vs
% rating response — just with reduced statistical power. 
% 
% However, it seems
% that this type of analysis is so deeply engrained in most heads in placebo
% research that  everybody is asking for it. So here we go....MZ

%% Meta-Analysis
variable_select={'rating','rating101','NPS'}; %'MHEraw','SIIPS',
ratingvars={'rating','rating101'};
imagingvars={'NPS'};

% Loop for studies where both con and pla conditions are available
for j=1:length(variable_select) % Loop through all outcome variables
    currvar=variable_select{j};
    for i=1:size(df,1) % Loop through all studies...
        df_placebo=df.responder_subjects{i}.pain_placebo;
        df_placebo=vertcat(df_placebo{:});
        df_control=df.responder_subjects{i}.pain_control;
        df_control=vertcat(df_control{:});
        rating_var_and_con_only=(any(strcmp(ratingvars,currvar)) && df.contrast_ratings_only(i)==1);
        img_var_and_con_only=(any(strcmp(imagingvars,currvar)) && df.contrast_imgs_only(i)==1);
        if  ~rating_var_and_con_only && ~img_var_and_con_only % where both pla and con is available.
            if strcmp(df.study_design{i},'within') %Use withinMetastats for within-subject studies
               df.(['GIV_stats_responders_',currvar])(i)=summarize_within(df_placebo.(currvar),df_control.(currvar));
            end
        end
    end
end

%% For some (within-subject) studies  pla>con contrasts are available, only.
% % For these studies within-subject correlations have to be imputed (mean of
% % within-subject correlation of all other studies is used).
% 
% Loop for studies with contrast-only ratings
for j=1:length(ratingvars)
    currvar=ratingvars{j};
    impu_r=nanmean([df.(['GIV_stats_responders_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=find(df.contrast_ratings_only==1)'
        df_placebo=df.responder_subjects{i}.placebo_minus_control;
        df_placebo=vertcat(df_placebo{:});
        df.(['GIV_stats_responders_',currvar])(i)=summarize_within(df_placebo.(currvar),impu_r);
    end
end

% Loop for studies with contrast-only imaging data
for j=1:length(imagingvars)
    currvar=imagingvars{j};
    impu_r=nanmean([df.(['GIV_stats_responders_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=find(df.contrast_imgs_only==1)'
        df_placebo=df.responder_subjects{i}.placebo_minus_control;
        df_placebo=vertcat(df_placebo{:});
        df.(['GIV_stats_responders_',currvar])(i)=summarize_within(df_placebo.(currvar),impu_r);
    end
end


%% One Forest plot per variable
varnames={'rating'
          'NPS'};
nicevarnames={'Pain ratings',...
              'NPS response'};
summary=[];
for i = 1:numel(varnames)
    GIV_stats=df.(['GIV_stats_responders_',varnames{i}]);
    for j=1:size(GIV_stats,1)
        if strcmp(df.study_design{j},'between')
        GIV_stats(j).g=NaN;
        GIV_stats(j).se_g=NaN;
        GIV_stats(j).n=NaN;
        end
    end
    
    summary.(varnames{i})=forest_plotter(GIV_stats,...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',[nicevarnames{i},' (Hedges'' g)'],...
                  'type','random',...
                  'summary_stat','g',...
                  'with_outlier',0,... %'WI_subdata',{GIV_stats.std_delta},...
                  'box_scaling',1,...
                  'text_offset',0);
    hgexport(gcf, fullfile(pubpath,['B1_Meta_Responder_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
    hgexport(gcf, fullfile(pubpath,['B1_Meta_Responder_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_Responder_',varnames{i},'.png']));
end
close all;
%% Additional forest plot for pain ratings standardized to 101pt VAS
varnames={'rating101'};
nicevarnames={'Pain ratings'};
for i = 1:numel(varnames)
    GIV_stats=df.(['GIV_stats_responders_',varnames{i}]);
    for j=1:size(GIV_stats,1)
        if strcmp(df.study_design{j},'between')
        GIV_stats(j).mu=NaN;    
        GIV_stats(j).se_mu=NaN;
        GIV_stats(j).n=NaN;
        end
    end
    
    summary.(varnames{i})=forest_plotter(GIV_stats,...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',[nicevarnames{i},' (VAS_1_0_1)'],...
                  'type','random',...
                  'summary_stat','mu',...
                  'with_outlier',0,...%'WI_subdata',{GIV_stats.std_delta},...
                  'box_scaling',1,...
                  'text_offset',0);
    hgexport(gcf, fullfile(pubpath,['B1_Meta_Responder_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg'); 
    hgexport(gcf, fullfile(pubpath,['B1_Meta_Responder_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_Responder_',varnames{i},'.png']));
end

close all
%% Obtain Bayes Factors
disp('BAYES FACTORS RATINGS')
effect=abs(summary.rating.g.random.summary)
SEeffect=summary.rating.g.random.SEsummary
bayes_factor(effect,SEeffect,0,[0,0.5,2])

disp('BAYES FACTORS NPS')
effect=abs(summary.NPS.g.random.summary)
SEeffect=summary.NPS.g.random.SEsummary

bayes_factor(effect,SEeffect,0,[0,0.5,2]) % Bayes factor for normal (two-tailed) null prior placing 95% probability for the mean effect being between -1 and 1
bayes_factor(effect,SEeffect,0,[0,0.5,1]) % "Enthusiast" Bayes factor for normal (one-tailed) null prior placing 95% probability for the mean effect being between -1 and 0
bayes_factor(effect,SEeffect,0,[abs(summary.rating.g.random.summary),...
                               summary.rating.g.random.SEsummary,2]) % Bayes factor for normal null prior identical with overall behavioral effect
save(fullfile(datapath,'data_frame.mat'), 'df');