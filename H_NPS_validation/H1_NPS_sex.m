%% Meta-Analysis & Forest Plot
% Difference compared to "basic":


% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
datapath='../../Datasets';

load(fullfile(datapath,'AllData.mat'))

studies={
    'bingel11'
    'ellingsen'
    'elsenbruch'
    'freeman'
    'kessner'
    'kong06'
    'kong09'
    'lui'
    'ruetgen'
    'schenk'
    'theysohn'
    'wrobel'
    'zeidan'};   %Get all studies in df
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
%             'Kessner et al. 2014: Negative & positive treatment expectation group | heat';...
%             'Kong et al. 2006: Control & placebo acupuncture | heat (high & low)';...
%             'Kong et al. 2009: Control & placebo sham acupuncture | heat';...
%             'Lui et al. 2010: Red & green cue signifying sham TENS off vs on | laser';...
%             'Ruetgen et al. 2015: No treatment & placebo pill group  | electrical'
%             'Schenk et al. 2015:  Control vs placebo (saline & lidocaine) | heat'
%             'Theysohn et al. 2009: No & certain placebo drip infusion | distension';...
%             'Wager et al. 2004b: Control & placebo cream | heat*';...
%             'Wager et al. 2004a: Control & placebo cream | electrical*';...
%             'Wrobel et al. 2014: Control & placebo cream (saline & haldol group) | heat(early & late)'
%             'Zeidan et al. 2015: Control & placebo cream (placebo group) | heat*';...
%             };

        studyIDtexts={
			'Bingel et al. 2011:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Kessner et al. 2014:';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010:';...
            'Ruetgen et al. 2015:'
            'Schenk et al. 2015:'
            'Theysohn et al. 2009:';...
            'Wrobel et al. 2014:'
            'Zeidan et al. 2015:';...
            };

varselect={'male','NPSraw','MHEraw','rating'}
%% Select data STUDIES

%'Atlas'
% No participant sex available

%'bingel06' >> Testing was performed within participants on left and right
%side... summarizine data across hemispheres for NPS and ratings first.
%There were two missing sessions>> Match values according to subID's 

% No participant sex available


%'bingel11'
pain=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_baseline')),:);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'bingel11'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'choi' (Only data from experiment 1 used, since experiment 2 not mentioned in publication)
% 'only men'
%'eippert'
% 'only men'

%'ellingsen'
control=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))),:);
placebo=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))),:);
pain=control;
pain{:,varselect}=mean(cat(3,control{:,varselect},...
                             placebo{:,varselect}),3);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'ellingsen'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'elsenbruch'
control=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_0%_analgesia'))),:);
placebo=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_100%_analgesia'))),:);
pain=control;
pain{:,varselect}=mean(cat(3,control{:,varselect},...
                             placebo{:,varselect}),3);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'elsenbruch'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'freeman'
control=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))),:);
placebo=df((strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))),:);
pain=control;
pain{:,varselect}=mean(cat(3,control{:,varselect},...
                             placebo{:,varselect}),3);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'freeman'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'geuter'
%only men

%'kessner'
control=df((strcmp(df.studyID,'kessner')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_neg'))),:);
placebo=df((strcmp(df.studyID,'kessner')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_pos'))),:);
pain=[control;placebo];
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'kessner'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'kong06'
control=df((strcmp(df.studyID,'kong06')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))),:);
placebo=df((strcmp(df.studyID,'kong06')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))),:);
pain=control;
pain{:,varselect}=mean(cat(3,control{:,varselect},...
                             placebo{:,varselect}),3);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'kong06'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'kong09'
control=df((strcmp(df.studyID,'kong09')&~cellfun(@isempty,regexp(df.cond,'pain_post_control'))),:);
placebo=df((strcmp(df.studyID,'kong09')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo'))),:);
pain=control;
pain{:,varselect}=mean(cat(3,control{:,varselect},...
                             placebo{:,varselect}),3);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'kong09'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'lui'
control=df((strcmp(df.studyID,'lui')&~cellfun(@isempty,regexp(df.cond,'pain_control'))),:);
placebo=df((strcmp(df.studyID,'lui')&~cellfun(@isempty,regexp(df.cond,'pain_placebo'))),:);
pain=control;
pain{:,varselect}=mean(cat(3,control{:,varselect},...
                             placebo{:,varselect}),3);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'lui'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'ruetgen'
control=df((strcmp(df.studyID,'ruetgen')&~cellfun(@isempty,regexp(df.cond,'Self_Pain_Control_Group'))),:);
placebo=df((strcmp(df.studyID,'ruetgen')&~cellfun(@isempty,regexp(df.cond,'Self_Pain_Placebo_Group'))),:);
pain=[control;placebo];
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'ruetgen'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);


%'Schenk'
control=df((strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_nolidocaine_control'))),:);
placebo=df((strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_nolidocaine_placebo'))),:);
pain=control;
pain{:,varselect}=mean(cat(3,control{:,varselect},...
                             placebo{:,varselect}),3);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'schenk'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'theysohn'
control=df((strcmp(df.studyID,'theysohn')&~cellfun(@isempty,regexp(df.cond,'control_pain'))),:);
placebo=df((strcmp(df.studyID,'theysohn')&~cellfun(@isempty,regexp(df.cond,'placebo_pain'))),:);
pain=control;
pain{:,varselect}=mean(cat(3,control{:,varselect},...
                             placebo{:,varselect}),3);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'theysohn'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'wager_princeton'
%Unknown sex

%'wager_michigan'
%Unknown sex

%'wrobel'
control_early=df((strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_control_'))),:);
control_late=df((strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_'))),:);
placebo_early=df((strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_placebo_'))),:);
placebo_late=df((strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_'))),:);

pain=control_early;
pain{:,varselect}=mean(cat(3,control_early{:,varselect},...
                             control_late{:,varselect},...
                             placebo_early{:,varselect},...
                             placebo_late{:,varselect}),3);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'wrobel'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%'zeidan'
pain=df((strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pain>NoPain controlling for placebo&interaction')),:);
male=pain(pain.male==1,:);
female=pain(pain.male==0,:);
i=find(strcmp(studies,'zeidan'));
stats(i)=betweenMetastats(male.NPSraw,female.NPSraw);

%% Summarize all studies, weigh by SE
% Summary analysis+ Forest Plot
ForestPlotter(stats,...
              'studyIDtexts',studyIDtexts,...
              'outcomelabel','NPS-response (Hedges''g)',...
              'type','random',...
              'summarystat','g',...
              'withoutlier',0,...
              'WIsubdata',0,...
              'boxscaling',1);

hgexport(gcf, 'A1_NPS_sex', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/Figure8', hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, '../../Protocol_and_Manuscript/NPS_validation/Figures/Figure8', hgexport('factorystyle'), 'Format', 'svg');

NPS_pos_imgs=vertcat(stats.delta)>0;
perc_pos_NPS=sum(NPS_pos_imgs)/sum(~isnan(NPS_pos_imgs));

disp([num2str(perc_pos_NPS*100),'% of participants showed a positive NPS response.'])