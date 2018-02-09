function A_meta_analysis_all(datapath,pubpath)
%% Meta-Analysis & Forest Plot ? Full Sample (MAIN RESULTS)
% Path to add Forest Plots to:
% Add folder with Generic Inverse Variance Methods Functions
df_name='data_frame.mat';
load(fullfile(datapath,df_name),'df');

% Labels extended version, w description for placebo / pain conditions 
% df.study_citations={
%             'Atlas et al. 2012: Hidden vs open remifentanil drip infusion (expectation period)| heat';...
% 			'Bingel et al. 2006: Control vs placebo cream | laser';...
% 			'Bingel et al. 2011: No vs positive expectations | heat';...
% 			'Choi et al. 2011: No vs low & high effective placebo drip infusion (Exp1 and 2) | electrical';...
% 			'Eippert et al. 2009: Control vs placebo cream (saline & naloxone group) | heat (early & late)';...
% 			'Ellingsen et al. 2013: Pre vs post placebo nasal spray | heat';...
%             'Elsenbruch et al. 2012: No vs certain placebo drip infusion | distension';...
%             'Freeman et al. 2015: Control vs placebo cream | heat';...
%             'Geuter et al. 2013: Control vs weak & strong placebo cream | heat (early & late)';...
%             'Kessner et al. 2014: Negative vs positive treatment expectation group | heat';...
%             'Kong et al. 2006: Control vs placebo acupuncture | heat (high & low)';...
%             'Kong et al. 2009: Control vs placebo sham acupuncture | heat';...
%             'Lui et al. 2010: Red vs green cue signifying sham TENS off vs on | laser';...
%             'Ruetgen et al. 2015: No treatment vs placebo pill group  | electrical'
%             'Schenk et al. 2015:  Control vs placebo (saline & lidocain) | heat'
%             'Theysohn et al. 2009: No vs certain placebo drip infusion | distension';...
%             'Wager et al. 2004, Study 1: Control vs placebo cream | heat*';...
%             'Wager et al. 2004, Study 2: Control vs placebo cream | electrical*';...
%             'Wrobel et al. 2014: Control vs placebo cream (saline & haldol group) | heat(early & late)'
%             'Zeidan et al. 2015: Control vs placebo cream (placebo group) | heat*';...
%             };
        

%% Meta-Analysis
% problem: standardized effect sizes cannot be obtained correcty, as the SD
% of the imaging signal is not known on single-image, single-subject level.
% What is known is the between-subject SD of summarized signal (summarized
% across images) at each voxel.

contrast_select={'placebo_and_control','placebo_minus_control'}; %'MHEraw','SIIPS',
variable_select={'rating','rating101','NPS','stim_intensity'}; %'MHEraw','SIIPS',
ratingvars={'rating','rating101'};
imagingvars={'NPS','stim_intensity'};

% Loop for studies where both con and pla conditions are available
for j=1:length(variable_select) % Loop through all outcome variables
    currvar=variable_select{j};
    for i=1:size(df,1) % Loop through all studies...
        df_placebo=df.subjects{i}.pain_placebo;
        df_placebo=vertcat(df_placebo{:});
        df_control=df.subjects{i}.pain_control;
        df_control=vertcat(df_control{:});
        rating_var_and_con_only=(any(strcmp(ratingvars,currvar)) && df.contrast_ratings_only(i)==1);
        img_var_and_con_only=(any(strcmp(imagingvars,currvar)) && df.contrast_imgs_only(i)==1);
        if  ~rating_var_and_con_only && ~img_var_and_con_only % where both pla and con is available.
            if strcmp(df.study_design{i},'within') %Use withinMetastats for within-subject studies
               df.(['GIV_stats_',currvar])(i)=summarize_within(df_placebo.(currvar),df_control.(currvar));
            elseif strcmp(df.study_design{i},'between') %Use betweenMetastats for between-subject studies
               df.(['GIV_stats_',currvar])(i)=summarize_between([df_placebo.(currvar)],[df_control.(currvar)]);
            end
        end
    end
end

%% For some studies (all within-subject) pla>con contrasts are available, only.
% % For these studies within-subject correlations have to be imputed (mean of
% % all other studies is used. There are some studies where contrasts only
% % are available for images, others where this is the case for ratings.
% 
% Loop for studies with contrast-only ratings
for j=1:length(ratingvars)
    currvar=ratingvars{j};
    impu_r=nanmean([df.(['GIV_stats_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=find(df.contrast_ratings_only==1)'
        df_placebo=df.subjects{i}.placebo_minus_control;
        df_placebo=vertcat(df_placebo{:});
        df.(['GIV_stats_',currvar])(i)=summarize_within(df_placebo.(currvar),impu_r);
    end
end

% Loop for studies with contrast-only imaging data
for j=1:length(imagingvars)
    currvar=imagingvars{j};
    impu_r=nanmean([df.(['GIV_stats_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=find(df.contrast_imgs_only==1)'
        df_placebo=df.subjects{i}.placebo_minus_control;
        df_placebo=vertcat(df_placebo{:});
        df.(['GIV_stats_',currvar])(i)=summarize_within(df_placebo.(currvar),impu_r);
    end
end


%% One Forest plot per variable
varnames={'rating'
          'NPS'};
nicevarnames={'Pain ratings',...
              'NPS response'};
summary=[];
for i = 1:numel(varnames) 
    summary.(varnames{i})=forest_plotter([df.(['GIV_stats_',varnames{i}])],...
                  'studyIDtexts',df.study_citations,...
                  'outcomelabel',[nicevarnames{i},' (Hedges'' g)'],...
                  'type','random',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0);
    hgexport(gcf, fullfile(pubpath,['B1_Meta_All_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
    hgexport(gcf, fullfile(pubpath,['B1_Meta_All_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_All_',varnames{i},'.png']));
end
close all;
%% Additional forest plot for pain ratings standardized to 101pt VAS
varnames={'rating101'};
nicevarnames={'Pain ratings'};
for i = 1:numel(varnames)
    summary.(varnames{i})=forest_plotter([df.(['GIV_stats_',varnames{i}])],...
                  'studyIDtexts',df.study_citations,...
                  'outcomelabel',[nicevarnames{i},' (VAS_1_0_1)'],...
                  'type','random',...
                  'summarystat','mu',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0);
    hgexport(gcf, fullfile(pubpath,['B1_Meta_All_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg'); 
    hgexport(gcf, fullfile(pubpath,['B1_Meta_All_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_All_',varnames{i},'.png']));
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
end