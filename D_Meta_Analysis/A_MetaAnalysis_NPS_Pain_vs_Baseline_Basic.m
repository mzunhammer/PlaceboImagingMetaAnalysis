%% Meta-Analysis & Forest Plot

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
basepath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/D_Meta_Analysis';
cd(basepath)
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets';

load(fullfile(datapath,'AllData_w_NPS_MHE.mat'))

studies=unique(df.studyID);   %Get all studies in df
% !!!!! These must be in the same order as listed under "studies" !!!!

studyIDtexts={
            'Atlas et al. 2012: Pain vs baseline| heat';...
			'Bingel et al. 2006: Control and placebo| laser';...
			'Bingel et al. 2011: No and positive expectations| heat';...
			'Choi et al. 2011: No and highly effective placebo drip infusion| electrical';...
			'Eippert et al. 2009: Control and placebo cream (saline group)| heat (late)';...
			'Ellingsen et al. 2013: Pre and post placebo nasal spray| heat';...
            'Elsenbruch et al. 2012: No and certain placebo drip infusion| distension';...
            'Freeman et al. 2015: Control and placebo cream | heat';...
            'Geuter et al. 2013: Control and strong placebo cream | heat (late)';...
            'Huber et al. 2013: Red and green cue, sham TENS off/on | laser';...
            'Kessner et al. 2014: Negative and positive treatment expectation group | heat';...
            'Kong et al. 2006: Control and placebo acupuncture (post treatment)| heat';...
            'Kong et al. 2009: Control and placebo sham acupuncture (post treatment)| heat';...
            'Ruetgen et al. 2015: No treatment and placebo pill group  | electrical';...
            'Schenk et al. 2015: Control & placebo, no lidocain & lidocain | heat';...
            'Theysohn et al. 2009: No and certain placebo drip infusion| distension';...
            'Wager et al. 2004b: Control and placebo cream | heat';...
            'Wager et al. 2004a: Control and placebo cream | electrical';...
            'Wrobel et al. 2014: Control and placebo cream (saline group) | heat (late)'
            'Zeidan et al. 2015: Control and placebo cream (placebo group) | heat';...
            };

%% Select data STUDIES

%'Atlas'
open_pain=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),'NPScorrected'};
hidden_pain=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),'NPScorrected'};

i=find(strcmp(studies,'atlas'));
stats(i)=withinMetastats(nanmean([open_pain,hidden_pain],2),0);

%'bingel06' >> Testing was performed within participants on left and right
%side... summarizine data across hemispheres for NPS and ratings first.
%There were two missing sessions>> Match values according to subID's 
control_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_R'))),{'subID','NPScorrected','rating'});
placebo_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_R'))),{'subID','NPScorrected','rating'});
control_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_L'))),{'subID','NPScorrected','rating'});
placebo_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_L'))),{'subID','NPScorrected','rating'});
control=outerjoin(control_R,control_L,'Keys','subID');
placebo=outerjoin(placebo_R,placebo_L,'Keys','subID');

con_NPS=nanmean([control{:,'NPScorrected_control_R'},control{:,'NPScorrected_control_L'}],2);
pla_NPS=nanmean([placebo{:,'NPScorrected_placebo_R'},placebo{:,'NPScorrected_placebo_L'}],2);
con_rating=nanmean([control{:,'rating_control_R'},control{:,'rating_control_L'}],2);
pla_rating=nanmean([placebo{:,'rating_placebo_R'},placebo{:,'rating_placebo_L'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'bingel'));
stats(i)=withinMetastats(nanmean([con_NPS,pla_NPS],2),0);

%'bingel11'
control=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')),'NPScorrected');
placebo=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')),'NPScorrected');

con_rating=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')),'rating');
pla_rating=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'bingel11'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'choi' (Only data from experiment 1 used, since experiment 2 not mentioned in publication)
control=df((strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*'))),'NPScorrected');
placebo=df((strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*'))),'NPScorrected');

con_rating=df((strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*'))),'rating');
pla_rating=df((strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*'))),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'choi'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'eippert'
control=df((strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))),'NPScorrected');
placebo=df((strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))),'NPScorrected');

con_rating=df((strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))),'rating');
pla_rating=df((strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'eippert'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'ellingsen'
control=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))),'NPScorrected');
placebo=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))),'NPScorrected');

con_rating=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))),'rating');
pla_rating=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'ellingsen'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'elsenbruch'
control=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia'))),'NPScorrected');
placebo=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia'))),'NPScorrected');

con_rating=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia'))),'rating');
pla_rating=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia'))),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'elsenbruch'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'freeman'
control=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))),'NPScorrected');
placebo=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))),'NPScorrected');

con_rating=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))),'rating');
pla_rating=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'freeman'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'geuter'
control=df((strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong')),'NPScorrected');
placebo=df((strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong')),'NPScorrected');

con_rating=df((strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_strong'))),'rating');
pla_rating=df((strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_strong'))),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'geuter'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'huber'
control=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl')),'NPScorrected');
placebo=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo')),'NPScorrected');

con_rating=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl')),'rating');
pla_rating=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'huber'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'kessner'
%control_neg=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_control_neg')),'NPScorrected');
placebo_neg=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg')),'NPScorrected');
%control_pos=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_control_pos')),'NPScorrected');
placebo_pos=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos')),'NPScorrected');

i=find(strcmp(studies,'kessner'));
% Get stats for between-subject design
%Here, instead of the placebo-effect, the outcome is the difference in placebo effect in the positive vs the negative expectation group.
%The negative expectation group (no expectation according to experience) is representing the control group,
%the postivie expectation group (expectation of analgesic effect according to experience) represents the placebo group
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);


%'kong06'
control=df((strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')),'NPScorrected');
placebo=df((strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')),'NPScorrected');

con_rating=df((strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')),'rating');
pla_rating=df((strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'kong06'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'kong09'
control=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')),'NPScorrected');
placebo=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')),'NPScorrected');

con_rating=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')),'rating');
pla_rating=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'kong09'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'ruetgen'
control=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')),'NPScorrected');
placebo=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')),'NPScorrected');

con_rating=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')),'rating');
pla_rating=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')),'rating');

% BETWEEN SUBJECT DESIGN... no within study differences available, so all
% participants are taken as respondes (Rütgen pre-selected subjects
% according to a test-session)
%rating_diff=con_rating{:,1}-pla_rating{:,1};
%responders=rating_diff>0;

i=find(strcmp(studies,'ruetgen'));
% Get stats for between-subject design
stats(i)=withinMetastats([control;placebo],0);

%'Schenk'
pain=nanmean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_control')),'NPScorrected'},...
         df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_placebo')),'NPScorrected'},...
         df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocain_control')),'NPScorrected'},...
         df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocain_placebo')),'NPScorrected'},...
         ],2);
i=find(strcmp(studies,'schenk'));
stats(i)=withinMetastats(pain,0);

%'theysohn'
control=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')),'NPScorrected');
placebo=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')),'NPScorrected');

con_rating=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')),'rating');
pla_rating=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'theysohn'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'wager_michigan'
control=df((strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'control_pain')),'NPScorrected');
placebo=df((strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'placebo_pain')),'NPScorrected');

% No ratings are available. Include study anyways?
i=find(strcmp(studies,'wager_michigan'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'wager_princeton'
pla_effect=df((strcmp(df.studyID,'wager_princeton')&strcmp(df.cond,'intense-none')),'NPScorrected');
pla_effect=pla_effect{:,:};

rating_diff=df((strcmp(df.studyID,'wager_princeton')&strcmp(df.cond,'intense-none')),'rating');
% No ratings are available. Include study anyways?

i=find(strcmp(studies,'wager_princeton'));
% WARNING: The standardized effect can only be computed when using betas or
% non-differential cons
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'wrobel'
control=df((strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline'))),'NPScorrected');
placebo=df((strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline'))),'NPScorrected');

con_rating=df((strcmp(df.studyID,'wrobel')&strcmp(df.cond,'late_pain_control_saline')),'rating');
pla_rating=df((strcmp(df.studyID,'wrobel')&strcmp(df.cond,'late_pain_placebo_saline')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'wrobel'));
stats(i)=withinMetastats(nanmean([control{:,1},placebo{:,1}],2),0);

%'zeidan'
pla_effect=df((strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pain>NoPain controlling for placebo&interaction')),'NPScorrected');

rating_diff=df((strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pain>NoPain controlling for placebo&interaction')),'rating');
responders=rating_diff{:,1}<0; % INVERSE CONTRAST THAN OTHER STUDIES


i=find(strcmp(studies,'zeidan'));
% WARNING: The standardized effect can only be computed when using betas or
% non-differential cons
stats(i)=withinMetastats(pla_effect,0);

%% Summarize all studies, weigh by SE
% Summary analysis+ Forest Plot
ForestPlotter(stats,studyIDtexts,'NPS-Response (Hedge''s g)','random');

hgexport(gcf, 'NPS_Meta_Pain_vs_Baseline_Basic.eps', hgexport('factorystyle'), 'Format', 'eps'); 
