%% Meta-Analysis & Forest Plot
% Difference compared to "basic":

% Atlas: None 
% Bingel06: None
% Bingel11: None
% Choi: 100potent AND 1potent vs baseling + First Session + Second (unpublisher) Session
% Eippert: Late + Early and Saline + Naloxone
% Ellingsen: None (non-painful placebo conditions not relevant)
% Elsenbruch: None (50% placebo condition relevant but unavailable)
% Freeman: None
% Geuter: Late + Early Pain, Weak + Strong Placebo
% Huber: None
% Kessner: None
% Kong06: High + Low Pain
% Kong09: None
% R?tgen: None
% Schenk: No Lidocaine & Lidocaine
% Theysohn: None
% Wager06a: None
% Wager06b: None
% Wrobel: Early + Late Pain, Haldol + Saline
% Zeidan: None

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
datapath='../../Datasets';

load(fullfile(datapath,'AllData_w_NPS_MHE_NOBRAIN.mat'))

studies=unique(df.studyID);   %Get all studies in df
% !!!!! These must be in the same order as listed under "studies" !!!!

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
%             'Huber et al. 2013: Red vs green cue signifying sham TENS off vs on | laser';...
%             'Kessner et al. 2014: Negative vs positive treatment expectation group | heat';...
%             'Kong et al. 2006: Control vs placebo acupuncture | heat (high & low)';...
%             'Kong et al. 2009: Control vs placebo sham acupuncture | heat';...
%             'Ruetgen et al. 2015: No treatment vs placebo pill group  | electrical'
%             'Schenk et al. 2015:  Control vs placebo (saline & lidocain) | heat'
%             'Theysohn et al. 2009: No vs certain placebo drip infusion | distension';...
%             'Wager et al. 2004, Study 1: Control vs placebo cream | heat*';...
%             'Wager et al. 2004, Study 2: Control vs placebo cream | electrical*';...
%             'Wrobel et al. 2014: Control vs placebo cream (saline & haldol group) | heat(early & late)'
%             'Zeidan et al. 2015: Control vs placebo cream (placebo group) | heat*';...
%             };

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
            'Huber et al. 2013:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Ruetgen et al. 2015:*'
            'Schenk et al. 2015:'
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:*';...
            'Wrobel et al. 2014:'
            'Zeidan et al. 2015:';...
            };
%% Select data STUDIES

%'Atlas'
%?Pain Placebo NoRemi"      = HiPain Open Stimulation + HiPain Open ExpectationPeriod
%?Pain Placebo Remi"           = HiPain Open Stimulation + HiPain Open ExpectationPeriod + HiPain Open RemiConz
%?Pain NoPlacebo NoRemi"  = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod
%?Pain NoPlacebo Remi"       = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod + HiPain Open RemiConz

placebo=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),'NPSraw'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_RemiConz'))),'NPSraw'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_ExpectationPeriod'))),'NPSraw'};
control=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),'NPSraw'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_RemiConz'))),'NPSraw'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_ExpectationPeriod'))),'NPSraw'};

    
% Effect of remi vs no-remi corresponds to estimated mean plateau effect of
% 0.043 micro-g/kg/min (individual) OR 0.884 ng/ml (absolute)
% across hidden and open administration periods
pla_rating=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),'rating'}+...
           df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_RemiConz'))),'rating'}+...
           df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_ExpectationPeriod'))),'rating'};
con_rating=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),'rating'}+...
           df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_RemiConz'))),'rating'}+...
           df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_ExpectationPeriod'))),'rating'};
%rating_diff=con_rating{:,1}-pla_rating{:,1};
%responders=rating_diff>0;

i=find(strcmp(studies,'atlas'));
stats(i)=withinMetastats(pla_rating,con_rating);

%'bingel06' >> Testing was performed within participants on left and right
%side... summarizine data across hemispheres for NPS and ratings first.
%There were two missing sessions>> Match values according to subID's 
control_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_R'))),{'subID','NPSraw','rating'});
placebo_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_R'))),{'subID','NPSraw','rating'});
control_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_L'))),{'subID','NPSraw','rating'});
placebo_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_L'))),{'subID','NPSraw','rating'});
control=outerjoin(control_R,control_L,'Keys','subID');
placebo=outerjoin(placebo_R,placebo_L,'Keys','subID');

con_NPS=nanmean([control{:,'NPSraw_control_R'},control{:,'NPSraw_control_L'}],2);
pla_NPS=nanmean([placebo{:,'NPSraw_placebo_R'},placebo{:,'NPSraw_placebo_L'}],2);
con_rating=nanmean([control{:,'rating_control_R'},control{:,'rating_control_L'}],2);
pla_rating=nanmean([placebo{:,'rating_placebo_R'},placebo{:,'rating_placebo_L'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'bingel'));
stats(i)=withinMetastats(pla_rating(:),con_rating(:));

%'bingel11'
control=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')),'NPSraw');
placebo=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')),'NPSraw');

con_rating=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')),'rating');
pla_rating=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'bingel11'));
stats(i)=withinMetastats(pla_rating{:,1},con_rating{:,1});

%'choi' (Only data from experiment 1 used, since experiment 2 not mentioned in publication)
control=df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*'))),'NPSraw'};
placebo=mean([df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*'))),'NPSraw'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_1potent_pain_beta.*'))),'NPSraw'}],2);
     
con_rating=df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*'))),'rating'};
pla_rating=mean([df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*'))),'rating'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_1potent_pain_beta.*'))),'rating'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'choi'));
stats(i)=withinMetastats(pla_rating,con_rating);

%'eippert'
control=mean([df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))),'NPSraw'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))),'NPSraw'};...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))),'NPSraw'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_naloxone'))),'NPSraw'}],2);
placebo=mean([df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))),'NPSraw'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))),'NPSraw'};...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))),'NPSraw'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_naloxone'))),'NPSraw'}],2);

con_rating=[df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))),'rating'};...
         df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))),'rating'}];% Same for late and early
pla_rating=[df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))),'rating'};...
        df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))),'rating'}];
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'eippert'));
stats(i)=withinMetastats(pla_rating,con_rating);

%'ellingsen'
control=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))),'NPSraw');
placebo=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))),'NPSraw');

con_rating=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))),'rating');
pla_rating=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'ellingsen'));
stats(i)=withinMetastats(pla_rating{:,1},con_rating{:,1});

%'elsenbruch'
control=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia'))),'NPSraw');
placebo=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia'))),'NPSraw');

con_rating=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia'))),'rating');
pla_rating=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia'))),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'elsenbruch'));
stats(i)=withinMetastats(pla_rating{:,1},con_rating{:,1});

%'freeman'
control=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))),'NPSraw');
placebo=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))),'NPSraw');

con_rating=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))),'rating');
pla_rating=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'freeman'));
stats(i)=withinMetastats(pla_rating{:,1},con_rating{:,1});

%'geuter'
control=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_weak')),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_weak')),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_strong')),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong')),'NPSraw'}],2);

placebo=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_weak')),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_weak')),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_strong')),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong')),'NPSraw'}],2);

con_rating=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_weak')),'rating'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_strong')),'rating'}],2);
pla_rating=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_weak')),'rating'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_strong')),'rating'}],2);
     
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'geuter'));
stats(i)=withinMetastats(pla_rating,con_rating);

%'huber'
control=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl')),'NPSraw');
placebo=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo')),'NPSraw');

con_rating=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl')),'rating');
pla_rating=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'huber'));
stats(i)=withinMetastats(pla_rating{:,1},con_rating{:,1});

%'kessner'
%control_neg=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_control_neg')),'NPSraw');
placebo_neg=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg')),'NPSraw');
%control_pos=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_control_pos')),'NPSraw');
placebo_pos=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos')),'NPSraw');

rating_neg=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg')),'rating');
%control_pos=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_control_pos')),'NPSraw');
rating_pos=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos')),'rating');


i=find(strcmp(studies,'kessner'));
% Get stats for between-subject design
%Here, instead of the placebo-effect, the outcome is the difference in placebo effect in the positive vs the negative expectation group.
%The negative expectation group (no expectation according to experience) is representing the control group,
%the postivie expectation group (expectation of analgesic effect according to experience) represents the placebo group
stats(i)=betweenMetastats(rating_pos{:,1},rating_neg{:,1});

%'kong06'
control=df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')),'NPSraw'};
placebo=df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')),'NPSraw'};   

con_rating=df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')),'rating'};
pla_rating=df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')),'rating'};
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'kong06'));
stats(i)=withinMetastats(pla_rating,con_rating);

%'kong09'
control=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')),'NPSraw');
placebo=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')),'NPSraw');

con_rating=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')),'rating');
pla_rating=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'kong09'));
stats(i)=withinMetastats(pla_rating{:,1},con_rating{:,1});

'ruetgen'
control=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')),'NPSraw');
placebo=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')),'NPSraw');

con_rating=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')),'rating');
pla_rating=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')),'rating');

% BETWEEN SUBJECT DESIGN... no within study differences available, so all
% participants are taken as respondes (R?tgen pre-selected subjects
% according to a test-session)
%rating_diff=con_rating{:,1}-pla_rating{:,1};
%responders=rating_diff>0;

i=find(strcmp(studies,'ruetgen'));
% Get stats for between-subject design
stats(i)=betweenMetastats(NaN(size(pla_rating{:,1})),NaN(size(con_rating{:,1})));

%'Schenk'
control=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_control')),'NPSraw'},...
              df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_control')),'NPSraw'}],2);
placebo=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_placebo')),'NPSraw'},...
              df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_placebo')),'NPSraw'}],2);

con_rating=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_control')),'rating'},...
             df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_control')),'rating'}],2);
pla_rating=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_placebo')),'rating'},...
              df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_placebo')),'rating'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'schenk'));
stats(i)=withinMetastats(pla_rating,con_rating);

%'theysohn'
control=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')),'NPSraw');
placebo=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')),'NPSraw');

con_rating=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')),'rating');
pla_rating=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'theysohn'));
stats(i)=withinMetastats(pla_rating{:,1},con_rating{:,1});

%'wager_princeton (study 1)'
pla_effect=df((strcmp(df.studyID,'wager04a_princeton')&strcmp(df.cond,'(intense-none)control-placebo')),'NPSraw');
pla_effect=pla_effect{:,:};

rating_diff=df((strcmp(df.studyID,'wager04a_princeton')&strcmp(df.cond,'(intense-none)control-placebo')),'rating');
% No ratings are available. Include study anyways?

i=find(strcmp(studies,'wager04a_princeton'));
% WARNING: The standardized effect can only be computed when using betas or
% non-differential cons
stats(i)=withinMetastats(-rating_diff{:,:},0.6654);%NO RATINGS AVAILABLE

%'wager_michigan'
control=df((strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'control_pain')),'NPSraw');
placebo=df((strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'placebo_pain')),'NPSraw');
rating_diff=df((strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'placebo_pain')),'rating');

%NO RAW RATINGS AVAILABLE, ONLY RATING CONTRAST CONTROL-PLACEBO
i=find(strcmp(studies,'wager04b_michigan'));
stats(i)=withinMetastats(NaN(size(-rating_diff{:,:})),0.6654);%NO RAW RATINGS AVAILABLE, ONLY RATING CONTRAST CONTROL-PLACEBO

%'wrobel'
control=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_saline'))),'NPSraw'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline'))),'NPSraw'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_haldol'))),'NPSraw'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_haldol'))),'NPSraw'}],2);         
placebo=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_saline'))),'NPSraw'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline'))),'NPSraw'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_haldol'))),'NPSraw'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_haldol'))),'NPSraw'}],2);
          
con_rating=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_saline'))),'rating'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline'))),'rating'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_haldol'))),'rating'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_haldol'))),'rating'}],2); 
pla_rating=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_saline'))),'rating'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline'))),'rating'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_haldol'))),'rating'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_haldol'))),'rating'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'wrobel'));
stats(i)=withinMetastats(pla_rating,con_rating);

%'zeidan'
pla_effect=df((strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pla>Control within painful series')),'NPSraw');

rating_diff=df((strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pla>Control within painful series')),'rating');
responders=rating_diff{:,1}<0; % INVERSE CONTRAST THAN OTHER STUDIES


i=find(strcmp(studies,'zeidan'));
% WARNING: The standardized effect can only be computed when using betas or
% non-differential cons
stats(i)=withinMetastats(rating_diff,0.6654);

%% Summarize all studies, weigh by SE
% Summary analysis+ Forest Plot
ForestPlotter(stats,...
              'studyIDtexts',studyIDtexts,...
              'outcomelabel','Pain ratings (Hedges'' g)',...
              'type','random',...
              'summarystat','g',...
              'withoutlier',0,...
              'WIsubdata',0,...
              'boxscaling',1);
hgexport(gcf, 'A_Ratings_Meta_Inclusive.eps', hgexport('factorystyle'), 'Format', 'eps'); 
close all;