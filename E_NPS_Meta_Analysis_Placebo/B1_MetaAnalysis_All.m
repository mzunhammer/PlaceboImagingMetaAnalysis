%% Meta-Analysis & Forest Plot ? Full Sample (MAIN RESULTS)
clear

% Path to add Forest Plots to:
pubpath='../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/';
% Add folder with Generic Inverse Variance Methods Functions
addpath('../A_Analysis_GIV_Functions/')
load('A1_Full_Sample.mat')

% Labels for Forrest Plots
studyIDtexts={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010';...
            'Ruetgen et al. 2015:';...
            'Schenk et al. 2015:';...
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:';...
            'Zeidan et al. 2015:';...
            };
% Labels extended version, w description for placebo / pain conditions 
% studyIDtexts={
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
        
varselect={'rating','rating101','NPS','MHEraw','SIIPS','stimInt'};
ratingvars={'rating','rating101'};
imagingvars={'NPS','MHEraw','SIIPS','stimInt'};
%% Meta-Analysis Ratings
for j=1:length(varselect) % Loop through all outcome variables
    currvar=varselect{j};
    v=find(strcmp(df_full.variables,currvar));
    for i=1:length(df_full.studies) % Loop through all studies...
        rating_var_and_con_only=(any(strcmp(ratingvars,currvar)) && df_full.consOnlyRating(i)==1);
        img_var_and_con_only=(any(strcmp(imagingvars,currvar)) && df_full.consOnlyNPS(i)==1)
        if  ~rating_var_and_con_only && ~img_var_and_con_only % where both pla and con is available.
            if df_full.BetweenSubject(i)==0 %Use withinMetastats for within-subject studies
               stats.(currvar)(i)=withinMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
            elseif df_full.BetweenSubject(i)==1 %Use betweenMetastats for between-subject studies
               stats.(currvar)(i)=betweenMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
            end        
        end
    end
end

% For some studies (all within-subject) pla>con contrasts are available, only.
% For these studies within-subject correlations have to be imputed (mean of
% all other studies is used. There are some studies where contrasts only
% are available for images, others where this is the case for ratings.

% Loop for studies with contrast-only ratings
conOnly=find(df_full.consOnlyRating==1);
for j=1:length(ratingvars)
    currvar=ratingvars{j};
    v=find(strcmp(df_full.variables,currvar));
    impu_r=nanmean([stats.(currvar).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=conOnly'
        stats.(currvar)(i)=withinMetastats(df_full.pladata{i}(:,v),impu_r);
    end
end

% Loop for studies with contrast-only imaging data
conOnly=find(df_full.consOnlyNPS==1);
for j=1:length(imagingvars)
    currvar=imagingvars{j};
    v=find(strcmp(df_full.variables,currvar));
    impu_r=nanmean([stats.(currvar).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=conOnly'
        stats.(currvar)(i)=withinMetastats(df_full.pladata{i}(:,v),impu_r);
    end
end
%% Meta-Analysis Ratings on 101 VAS scale ? MEAN BASELINE RATING
v=find(strcmp(df_full.variables,'rating101'));
for i=1:length(df_full.studies) % Calculate for all studies except...
    if df_full.consOnlyRating(i)==0 %...only for data-sets where both pla and con is available
           all_control_pain_ratings{i}=df_full.condata{i}(:,v);        
    end
end
% Calculate grand mean
control_mean_rating101=nanmean(vertcat(all_control_pain_ratings{:}));

%% One Forest plot per variable
varnames={'rating'
          'NPS'
          'MHEraw'
          'SIIPS'};
nicevarnames={'Pain ratings',...
              'NPS response',...
              'MHE response',...
              'SIIPS response'};
summary=[];
for i = 1:numel(varnames)
    summary.(varnames{i})=ForestPlotter([stats.(varnames{i})],...
                  'studyIDtexts',studyIDtexts,...
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
    summary.(varnames{i})=ForestPlotter([stats.(varnames{i})],...
                  'studyIDtexts',studyIDtexts,...
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
%% Obtain Bayesian Factors
disp('BAYES FACTORS RATINGS')
effect=abs(summary.rating.g.random.summary)
SEeffect=summary.rating.g.random.SEsummary
bayesfactor(effect,SEeffect,0,[0,0.5,2])

disp('BAYES FACTORS NPS')
effect=abs(summary.NPS.g.random.summary)
SEeffect=summary.NPS.g.random.SEsummary

bayesfactor(effect,SEeffect,0,[0,0.5,2]) % Bayes factor for normal (two-tailed) null prior placing 95% probability for the mean effect being between -1 and 1
bayesfactor(effect,SEeffect,0,[0,0.5,1]) % "Enthusiast" Bayes factor for normal (one-tailed) null prior placing 95% probability for the mean effect being between -1 and 0
bayesfactor(effect,SEeffect,0,[abs(summary.rating.g.random.summary),...
                               summary.rating.g.random.SEsummary,2]) % Bayes factor for normal null prior identical with overall behavioral effect

%% Save study-level meta-stats for comparison with other contrasts (see: effects of hi vs lo temperature)
stats.studies=df_full.studies;
save('Full_Sample_Study_Level_Results_Placebo.mat','stats');


%% Funnel plot for ratings (by SE)
mean_g=mean([stats.rating.g]);
scatter([stats.rating.g],[stats.rating.se_g],[stats.rating.n].*2)
set(gca,'Ydir','reverse')
hold on
% Get y-axis extremes to calculate CIs
ylims=get(gca,'Ylim');
funnel95_h0=0+ylims(2)*icdf('normal',[0.025,0.975],0,1);
funnel95_h1=mean_g+ylims(2)*icdf('normal',[0.025,0.975],0,1);
funnel99_h1=mean_g+ylims(2)*icdf('normal',[0.01,0.99],0,1);

h=patch([funnel95_h0(1),0,0],...%X
     [ylims(2),ylims(2),0],[0.9, 0.9, 0.9],...%Y
     'LineStyle','none');
uistack(h,'bottom');
 
line([funnel95_h1(1),mean_g],[ylims(2),0]);
line([funnel95_h1(2),mean_g],[ylims(2),0]);
line([funnel99_h1(1),mean_g],[ylims(2),0],'LineStyle','--');
line([funnel99_h1(2),mean_g],[ylims(2),0],'LineStyle','--');

line([mean_g,mean_g],...
      [0,ylims(2)],...
  'Color','red','LineStyle','--');

line([0,0],...
      [0,ylims(2)],...
  'Color',' black');

ylabel('Standard error (g)')
xlabel('Effect size (g)')
hold off
hgexport(gcf, fullfile(pubpath,['Funnel_plot_ratings','.svg']), hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, fullfile(pubpath,['Funnel_plot_ratings','.png']), hgexport('factorystyle'), 'Format', 'png'); 
crop(fullfile(pubpath,['Funnel_plot_ratings','.png']));

%close all;

% The analysis of funnel plot asymmetry is computed via regression of
% SND = b1*precision+b0 (Egger 1997, BMJ)
% Whereas:
% SND =standard normal deviate = effect_size / SE_effect
% precision= 1/SE_effect
% b0 = the intercept used as a measure of asymmetry.

SND=([stats.rating.g]./[stats.rating.se_g])';
precision=(1./[stats.rating.se_g])';
mdl_unweighted = fitlm(precision,SND);
disp(['Egger''s test: Funnel_Plot_Assymetry: p = '])
mdl_unweighted.Coefficients.pValue(1)