%% Condition Select
% Script to select the correct experimental conditions for each comparison

clear
basepath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/D_Meta_Analysis';
cd(basepath)
datapath='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets';
load(fullfile(datapath,'AllData_w_NPS_MHE.mat'))

%% Inlcusive Placebo>Control
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
% Rütgen: None
% Schenk: No Lidocaine & Lidocaine
% Theysohn: None
% Wager06a: None
% Wager06b: None
% Wrobel: Early + Late Pain, Haldol + Saline
% Zeidan: None

%'atlas'
placebo=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),'NPScorrected'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_RemiConz'))),'NPScorrected'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_ExpectationPeriod'))),'NPScorrected'};
control=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),'NPScorrected'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_RemiConz'))),'NPScorrected'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_ExpectationPeriod'))),'NPScorrected'};
%'bingel06'
control_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_R'))),{'subID','NPScorrected','rating'});
placebo_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_R'))),{'subID','NPScorrected','rating'});
control_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_L'))),{'subID','NPScorrected','rating'});
placebo_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_L'))),{'subID','NPScorrected','rating'});
control=outerjoin(control_R,control_L,'Keys','subID');
placebo=outerjoin(placebo_R,placebo_L,'Keys','subID');
%'bingel11'
control=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')),'NPScorrected');
placebo=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')),'NPScorrected');
%'choi' (Only data from experiment 1 used, since experiment 2 not mentioned in publication)
control=mean([df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*'))),'NPScorrected'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp2_control_pain_beta.*'))),'NPScorrected'}],2);
placebo=mean([df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*'))),'NPScorrected'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_1potent_pain_beta.*'))),'NPScorrected'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp2_100potent_pain_beta.*'))),'NPScorrected'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp2_1potent_pain_beta.*'))),'NPScorrected'}],2);
%'eippert'
control=mean([df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))),'NPScorrected'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))),'NPScorrected'};...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))),'NPScorrected'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_naloxone'))),'NPScorrected'}],2);
placebo=mean([df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))),'NPScorrected'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))),'NPScorrected'};...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))),'NPScorrected'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_naloxone'))),'NPScorrected'}],2);
%'ellingsen'
control=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))),'NPScorrected');
placebo=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))),'NPScorrected');
%'elsenbruch'
control=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia'))),'NPScorrected');
placebo=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia'))),'NPScorrected');
%'freeman'
control=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))),'NPScorrected');
placebo=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))),'NPScorrected');
%'geuter'
control=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_weak')),'NPScorrected'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_weak')),'NPScorrected'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_strong')),'NPScorrected'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong')),'NPScorrected'}],2);
placebo=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_weak')),'NPScorrected'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_weak')),'NPScorrected'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_strong')),'NPScorrected'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong')),'NPScorrected'}],2);
%'huber'
control=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl')),'NPScorrected');
placebo=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo')),'NPScorrected');
%'kessner'
placebo_neg=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg')),'NPScorrected');
placebo_pos=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos')),'NPScorrected');
%'kong06'
control=mean([df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_low_pain')),'NPScorrected'},...
         df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')),'NPScorrected'}],2);
placebo=mean([df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_low_pain')),'NPScorrected'},...
        df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')),'NPScorrected'}],2);   
%'kong09'
control=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')),'NPScorrected');
placebo=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')),'NPScorrected');
%'ruetgen'
control=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')),'NPScorrected');
placebo=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')),'NPScorrected');
%'Schenk'
control=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_control')),'NPScorrected'},...
              df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocain_control')),'NPScorrected'}],2);
placebo=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_placebo')),'NPScorrected'},...
              df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocain_placebo')),'NPScorrected'}],2);
%'theysohn'
control=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')),'NPScorrected');
placebo=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')),'NPScorrected');
%'wager_michigan'
control=df((strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'control_pain')),'NPScorrected');
placebo=df((strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'placebo_pain')),'NPScorrected');
%'wager_princeton'
pla_effect=df((strcmp(df.studyID,'wager_princeton')&strcmp(df.cond,'(intense-none)control-placebo')),'NPScorrected');
%'wrobel'
control=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_saline'))),'NPScorrected'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline'))),'NPScorrected'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_haldol'))),'NPScorrected'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_haldol'))),'NPScorrected'}],2);         
placebo=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_saline'))),'NPScorrected'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline'))),'NPScorrected'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_haldol'))),'NPScorrected'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_haldol'))),'NPScorrected'}],2);
%'zeidan'
pla_effect=df((strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pla>Control within painful series')),'NPScorrected');