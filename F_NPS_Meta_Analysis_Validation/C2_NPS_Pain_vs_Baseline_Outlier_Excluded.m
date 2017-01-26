%% Meta-Analysis & Forest Plot
% Difference compared to "basic":

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
datapath='../../Datasets';

load(fullfile(datapath,'AllData_w_NPS_MHE_NOBRAIN.mat'))

studies=unique(df.studyID);   %Get all studies in df
% !!!!! These must be in the same order as listed under "studies" !!!!

% studyIDtexts={
%             'Atlas et al. 2012: Hidden & open drip infusion (stimulation vector)| heat';...
% 			'Bingel et al. 2006: Control & placebo cream | laser';...
% 			'Bingel et al. 2011: No & positive expectations | heat';...
% 			'Choi et al. 2011: No & low & high effective placebo drip infusion (Exp1 & 2) | electrical';...
% 			'Eippert et al. 2009: Control & placebo cream (saline & naloxone group) | heat (early & late)';...
% 			'Ellingsen et al. 2013: Pre & post placebo nasal spray | heat';...
%             'Elsenbruch et al. 2012: No & certain placebo drip infusion | distension';...
%             'Freeman et al. 2015: Control & placebo cream | heat';...
%             'Geuter et al. 2013: Control & weak & strong placebo cream | heat (early & late)';...
%             'Huber et al. 2013: Red & green cue signifying sham TENS off vs on | laser';...
%             'Kessner et al. 2014: Negative & positive treatment expectation group | heat';...
%             'Kong et al. 2006: Control & placebo acupuncture | heat (high & low)';...
%             'Kong et al. 2009: Control & placebo sham acupuncture | heat';...
%             'Ruetgen et al. 2015: No treatment & placebo pill group  | electrical'
%             'Schenk et al. 2015:  Control vs placebo (saline & lidocaine) | heat'
%             'Theysohn et al. 2009: No & certain placebo drip infusion | distension';...
%             'Wager et al. 2004b: Control & placebo cream | heat*';...
%             'Wager et al. 2004a: Control & placebo cream | electrical*';...
%             'Wrobel et al. 2014: Control & placebo cream (saline & haldol group) | heat(early & late)'
%             'Zeidan et al. 2015: Control & placebo cream (placebo group) | heat*';...
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
            'Ruetgen et al. 2015:'
            'Schenk et al. 2015:'
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:'
            'Zeidan et al. 2015:';...
            };

%% Select data STUDIES

%'Atlas'
%?Pain Placebo NoRemi"      = HiPain Open Stimulation + HiPain Open ExpectationPeriod
%?Pain Placebo Remi"           = HiPain Open Stimulation + HiPain Open ExpectationPeriod + HiPain Open RemiConz
%?Pain NoPlacebo NoRemi"  = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod
%?Pain NoPlacebo Remi"       = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod + HiPain Open RemiConz

placebo=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))&~df.ex_all),'NPSraw'};
control=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))&~df.ex_all),'NPSraw'};

    
% Effect of remi vs no-remi corresponds to estimated mean plateau effect of
% 0.043 micro-g/kg/min (individual) OR 0.884 ng/ml (absolute)
% across hidden and open administration periods
pla_rating=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))&~df.ex_all),'rating'}+...
           df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_RemiConz'))&~df.ex_all),'rating'}+...
           df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_ExpectationPeriod'))&~df.ex_all),'rating'};
con_rating=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))&~df.ex_all),'rating'}+...
           df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_RemiConz'))&~df.ex_all),'rating'}+...
           df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_ExpectationPeriod'))&~df.ex_all),'rating'};
%rating_diff=con_rating{:,1}-pla_rating{:,1};
%responders=rating_diff>0;

i=find(strcmp(studies,'atlas'));
stats(i)=withinMetastats(nanmean([control,placebo],2),0);

%'bingel06' >> Testing was performed within participants on left and right
%side... summarizine data across hemispheres for NPS and ratings first.
%There were two missing sessions>> Match values according to subID's 
control_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_R'))&~df.ex_all),{'subID','NPSraw','rating'});
placebo_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_R'))&~df.ex_all),{'subID','NPSraw','rating'});
control_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_L'))&~df.ex_all),{'subID','NPSraw','rating'});
placebo_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_L'))&~df.ex_all),{'subID','NPSraw','rating'});
control=outerjoin(control_R,control_L,'Keys','subID');
placebo=outerjoin(placebo_R,placebo_L,'Keys','subID');

con_NPS=nanmean([control{:,'NPSraw_control_R'},control{:,'NPSraw_control_L'}],2);
pla_NPS=nanmean([placebo{:,'NPSraw_placebo_R'},placebo{:,'NPSraw_placebo_L'}],2);
con_rating=nanmean([control{:,'rating_control_R'},control{:,'rating_control_L'}],2);
pla_rating=nanmean([placebo{:,'rating_placebo_R'},placebo{:,'rating_placebo_L'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'bingel'));
stats(i)=withinMetastats(nanmean([con_NPS,pla_NPS],2),0);

%'bingel11'
control=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')&~df.ex_all),'NPSraw');
placebo=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')&~df.ex_all),'NPSraw');

con_rating=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')&~df.ex_all),'rating');
pla_rating=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')&~df.ex_all),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'bingel11'));
stats(i)=withinMetastats(nanmean([control{:,:},placebo{:,:}],2),0);

%'choi' (Only data from experiment 1 used, since experiment 2 not mentioned in publication)
control=mean([df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*'))&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp2_control_pain_beta.*'))&~df.ex_all),'NPSraw'}],2);

placebo=mean([df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*'))&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_1potent_pain_beta.*'))&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp2_100potent_pain_beta.*'))&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp2_1potent_pain_beta.*'))&~df.ex_all),'NPSraw'}],2);
     
con_rating=mean([df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*'))&~df.ex_all),'rating'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp2_control_pain_beta.*'))&~df.ex_all),'rating'}],2);
pla_rating=mean([df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*'))&~df.ex_all),'rating'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_1potent_pain_beta.*'))&~df.ex_all),'rating'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp2_100potent_pain_beta.*'))&~df.ex_all),'rating'},...
         df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp2_1potent_pain_beta.*'))&~df.ex_all),'rating'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'choi'));
stats(i)=withinMetastats(nanmean([control,placebo],2),0);

%'eippert'
control=mean([df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))&~df.ex_all),'NPSraw'};...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_naloxone'))&~df.ex_all),'NPSraw'}],2);
placebo=mean([df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))&~df.ex_all),'NPSraw'};...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_naloxone'))&~df.ex_all),'NPSraw'}],2);

con_rating=[df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))&~df.ex_all),'rating'};...
         df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))&~df.ex_all),'rating'}];% Same for late and early
pla_rating=[df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))&~df.ex_all),'rating'};...
        df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))&~df.ex_all),'rating'}];
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'eippert'));
stats(i)=withinMetastats(nanmean([control,placebo],2),0);

%'ellingsen'
control=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))&~df.ex_all),'NPSraw');
placebo=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))&~df.ex_all),'NPSraw');

con_rating=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))&~df.ex_all),'rating');
pla_rating=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))&~df.ex_all),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'ellingsen'));
stats(i)=withinMetastats(nanmean([control{:,:},placebo{:,:}],2),0);

%'elsenbruch'
control=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia'))&~df.ex_all),'NPSraw');
placebo=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia'))&~df.ex_all),'NPSraw');

con_rating=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia'))&~df.ex_all),'rating');
pla_rating=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia'))&~df.ex_all),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'elsenbruch'));
stats(i)=withinMetastats(nanmean([control{:,:},placebo{:,:}],2),0);

%'freeman'
control=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))&~df.ex_all),'NPSraw');
placebo=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))&~df.ex_all),'NPSraw');

con_rating=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))&~df.ex_all),'rating');
pla_rating=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))&~df.ex_all),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'freeman'));
stats(i)=withinMetastats(nanmean([control{:,:},placebo{:,:}],2),0);

%'geuter'
control=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_weak')&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_weak')&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_strong')&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong')&~df.ex_all),'NPSraw'}],2);

placebo=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_weak')&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_weak')&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_strong')&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong')&~df.ex_all),'NPSraw'}],2);

con_rating=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_weak')&~df.ex_all),'rating'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_strong')&~df.ex_all),'rating'}],2);
pla_rating=mean([df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_weak')&~df.ex_all),'rating'},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_strong')&~df.ex_all),'rating'}],2);
     
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'geuter'));
stats(i)=withinMetastats(nanmean([control,placebo],2),0);

%'huber'
control=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl')&~df.ex_all),'NPSraw');
placebo=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo')&~df.ex_all),'NPSraw');

con_rating=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl')&~df.ex_all),'rating');
pla_rating=df((strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo')&~df.ex_all),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'huber'));
stats(i)=withinMetastats(nanmean([control{:,:},placebo{:,:}],2),0);

%'kessner'
%control_neg=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_control_neg')),'NPSraw');
placebo_neg=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg')&~df.ex_all),'NPSraw');
%control_pos=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_control_pos')),'NPSraw');
placebo_pos=df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos')&~df.ex_all),'NPSraw');

i=find(strcmp(studies,'kessner'));
% Get stats for between-subject design
%Here, instead of the placebo-effect, the outcome is the difference in placebo effect in the positive vs the negative expectation group.
%The negative expectation group (no expectation according to experience) is representing the control group,
%the postivie expectation group (expectation of analgesic effect according to experience) represents the placebo group
stats(i)=withinMetastats([placebo_neg{:,:};placebo_pos{:,:}],0);


%'kong06'
control=mean([df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_low_pain')&~df.ex_all),'NPSraw'},...
         df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')&~df.ex_all),'NPSraw'}],2);
placebo=mean([df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_low_pain')&~df.ex_all),'NPSraw'},...
        df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')&~df.ex_all),'NPSraw'}],2);   

con_rating=mean([df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_low_pain')&~df.ex_all),'rating'},...
         df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')&~df.ex_all),'rating'}],2);
pla_rating=mean([df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_low_pain')&~df.ex_all),'rating'},...
        df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')&~df.ex_all),'rating'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'kong06'));
stats(i)=withinMetastats(nanmean([control,placebo],2),0);

%'kong09'
control=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')&~df.ex_all),'NPSraw');
placebo=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')&~df.ex_all),'NPSraw');

con_rating=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')&~df.ex_all),'rating');
pla_rating=df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')&~df.ex_all),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'kong09'));
stats(i)=withinMetastats(nanmean([control{:,:},placebo{:,:}],2),0);

%'ruetgen'
control=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')&~df.ex_all),'NPSraw');
placebo=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')&~df.ex_all),'NPSraw');

con_rating=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')&~df.ex_all),'rating');
pla_rating=df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')&~df.ex_all),'rating');

% BETWEEN SUBJECT DESIGN... no within study differences available, so all
% participants are taken as respondes (R?tgen pre-selected subjects
% according to a test-session)
%rating_diff=con_rating{:,1}-pla_rating{:,1};
%responders=rating_diff>0;

i=find(strcmp(studies,'ruetgen'));
% Get stats for between-subject design
stats(i)=withinMetastats([control{:,:};placebo{:,:}],0);

%'Schenk'
control=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_control')&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_control')&~df.ex_all),'NPSraw'}],2);
placebo=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_placebo')&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_placebo')&~df.ex_all),'NPSraw'}],2);

con_rating=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_control')&~df.ex_all),'rating'},...
             df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_control')&~df.ex_all),'rating'}],2);
pla_rating=mean([df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_placebo')&~df.ex_all),'rating'},...
              df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_placebo')&~df.ex_all),'rating'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'schenk'));
stats(i)=withinMetastats(nanmean([control,placebo],2),0);

%'theysohn'
control=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')&~df.ex_all),'NPSraw');
placebo=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')&~df.ex_all),'NPSraw');

con_rating=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')&~df.ex_all),'rating');
pla_rating=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')&~df.ex_all),'rating');
rating_diff=con_rating{:,1}-pla_rating{:,1};
responders=rating_diff>0;

i=find(strcmp(studies,'theysohn'));
stats(i)=withinMetastats(nanmean([control{:,:},placebo{:,:}],2),0);

%'wager_princeton'
pain_effect=df((strcmp(df.studyID,'wager04a_princeton')&strcmp(df.cond,'intense-none')&~df.ex_all),'NPSraw');
pain_effect=pain_effect{:,:};

rating_diff=df((strcmp(df.studyID,'wager04a_princeton')&strcmp(df.cond,'intense-none')&~df.ex_all),'rating');
% No ratings are available. Include study anyways?

i=find(strcmp(studies,'wager04a_princeton'));
% WARNING: The standardized effect can only be computed when using betas or
% non-differential cons
stats(i)=withinMetastats(pain_effect,0);

%'wager_michigan'
control=df((strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'control_pain')&~df.ex_all),'NPSraw');
placebo=df((strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'placebo_pain')&~df.ex_all),'NPSraw');
% No ratings are available. Include study anyways?
i=find(strcmp(studies,'wager04b_michigan'));
stats(i)=withinMetastats(nanmean([control{:,:},placebo{:,:}],2),0);


%'wrobel'
control=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_saline'))&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline'))&~df.ex_all),'NPSraw'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_haldol'))&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_haldol'))&~df.ex_all),'NPSraw'}],2);         
placebo=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_saline'))&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline'))&~df.ex_all),'NPSraw'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_haldol'))&~df.ex_all),'NPSraw'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_haldol'))&~df.ex_all),'NPSraw'}],2);
          
con_rating=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_saline'))&~df.ex_all),'rating'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline'))&~df.ex_all),'rating'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_haldol'))&~df.ex_all),'rating'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_haldol'))&~df.ex_all),'rating'}],2); 
pla_rating=mean([df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_saline'))&~df.ex_all),'rating'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline'))&~df.ex_all),'rating'};...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_haldol'))&~df.ex_all),'rating'},...
              df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_haldol'))&~df.ex_all),'rating'}],2);
rating_diff=con_rating-pla_rating;
responders=rating_diff>0;

i=find(strcmp(studies,'wrobel'));
stats(i)=withinMetastats(nanmean([control,placebo],2),0);

%'zeidan'
pain_effect=df((strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pain>NoPain controlling for placebo&interaction')&~df.ex_all),'NPSraw');

rating_diff=df((strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pain>NoPain controlling for placebo&interaction')&~df.ex_all),'rating');
responders=rating_diff{:,1}<0; % INVERSE CONTRAST THAN OTHER STUDIES


i=find(strcmp(studies,'zeidan'));
% WARNING: The standardized effect can only be computed when using betas or
% non-differential cons
stats(i)=withinMetastats(pain_effect,0);

%% Summarize all studies, weigh by SE
% Summary analysis+ Forest Plot
ForestPlotter(stats,...
              'studyIDtexts',studyIDtexts,...
              'outcomelabel','NPS-response (Hedge''s g',...
              'type','random',...
              'summarystat','g',...
              'withoutlier',0,...
              'WIsubdata',1,...
              'boxscaling',1);

hgexport(gcf, 'C2_NPS_Pain_vs_Baseline_outlier_excluded.eps', hgexport('factorystyle'), 'Format', 'eps'); 

close all
NPS_pos_imgs=vertcat(stats.delta)>0;
perc_pos_NPS=sum(NPS_pos_imgs)/sum(~isnan(NPS_pos_imgs));

disp([num2str(perc_pos_NPS*100),'% of participants showed a positive NPS response.'])