function A_meta_analysis_pain_all(datapath,pubpath)
%% Meta-Analysis & Forest Plot ? Full Sample (MAIN RESULTS)
df_name='data_frame.mat';
load(fullfile(datapath,df_name),'df');
    
%% Meta-Analysis
% note that standardized effect sizes are based on 
% the between-subject SD of summarized signal (summarized
% across images) at each voxel, not single-image SD (as within-subject
% images were not collected)

variable_select={'rating','rating101','NPS','stim_intensity'}; %'MHEraw','SIIPS',
ratingvars={'rating','rating101'};
imagingvars={'NPS','stim_intensity'};

% Loop for studies where both con and pla conditions are available
for j=1:length(variable_select) % Loop through all outcome variables
    currvar=variable_select{j};
    for i=1:size(df,1) % Loop through all studies...
        df_pain=df.subjects{i}.placebo_and_control;
        df_pain=vertcat(df_pain{:});
        rating_var_and_con_only=(any(strcmp(ratingvars,currvar)) && df.contrast_ratings_only(i)==1);
        img_var_and_con_only=(any(strcmp(imagingvars,currvar)) && df.contrast_imgs_only(i)==1);
        df.(['GIV_stats_pain_',currvar])(i)=summarize_within(df_pain.(currvar),0);
    end
end

% %% For some (within-subject) studies  pla>con contrasts are available, only.
% % % For these studies within-subject correlations have to be imputed (mean of
% % % within-subject correlation of all other studies is used).
% % 
% % Loop for studies with contrast-only ratings
% for j=1:length(ratingvars)
%     currvar=ratingvars{j};
%     impu_r=nanmean([df.(['GIV_stats_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
%     for i=find(df.contrast_ratings_only==1)'
%         df_pain=df.subjects{i}.placebo_minus_control;
%         df_pain=vertcat(df_pain{:});
%         df.(['GIV_stats_',currvar])(i)=summarize_within(df_pain.(currvar),impu_r);
%     end
% end
% 
% % Loop for studies with contrast-only imaging data
% for j=1:length(imagingvars)
%     currvar=imagingvars{j};
%     impu_r=nanmean([df.(['GIV_stats_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
%     for i=find(df.contrast_imgs_only==1)'
%         df_pain=df.subjects{i}.placebo_minus_control;
%         df_pain=vertcat(df_pain{:});
%         df.(['GIV_stats_',currvar])(i)=summarize_within(df_pain.(currvar),impu_r);
%     end
% end


%% One Forest plot per variable
varnames={'rating'
          'NPS'};
nicevarnames={'Pain ratings',...
              'NPS response'};
summary=[];
for i = 1:numel(varnames) 
    summary.(varnames{i})=forest_plotter([df.(['GIV_stats_pain_',varnames{i}])],...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',[nicevarnames{i},' (Hedges'' g)'],...
                  'type','random',...
                  'summary_stat','g',...
                  'with_outlier',0,... %'WI_subdata',{GIV_stats.std_delta},...
                  'box_scaling',1,...
                  'text_offset',0);
    hgexport(gcf, fullfile(pubpath,['B1_Meta_All_Pain',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
    hgexport(gcf, fullfile(pubpath,['B1_Meta_All_Pain',varnames{i},'.eps']), hgexport('factorystyle'), 'Format', 'eps'); 
    hgexport(gcf, fullfile(pubpath,['B1_Meta_All_Pain',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_All_Pain',varnames{i},'.png']));
end
close all;
%% Additional forest plot for pain ratings standardized to 101pt VAS
varnames={'rating101'};
nicevarnames={'Pain ratings'};
for i = 1:numel(varnames)
    summary.(varnames{i})=forest_plotter([df.(['GIV_stats_pain_',varnames{i}])],...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',[nicevarnames{i},' (VAS_1_0_1)'],...
                  'type','random',...
                  'summary_stat','mu',...
                  'with_outlier',0,...%'WI_subdata',{GIV_stats.std_delta},...
                  'box_scaling',1,...
                  'text_offset',0);
%    hgexport(gcf, fullfile(pubpath,['B1_Meta_All_Pain',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
    hgexport(gcf, fullfile(pubpath,['B1_Meta_All_Pain',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_All_Pain',varnames{i},'.png']));
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

ex=vertcat(df.subjects{:});
ex=ex.excluded;
NPS_resp=vertcat(df.GIV_stats_pain_NPS.std_delta);
prop_NPS_pos=sum(NPS_resp>0)./sum(~isnan(NPS_resp));
prop_NPS_pos_clean=sum(NPS_resp(~ex)>0)./sum(~isnan(NPS_resp(~ex)))
sprintf('Positive Placebo Responses: %0.2f%%',prop_NPS_pos*100)
sprintf('Positive Placebo Responses (wo outliers): %0.2f%%',prop_NPS_pos_clean*100)
sprintf('Estimated between-study-heterogeneity (tau) in units of g: %0.2f%%',sqrt(summary.NPS.g.heterogeneity.tausq))
end