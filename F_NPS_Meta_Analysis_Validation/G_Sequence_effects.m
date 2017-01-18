%% Meta-Analysis & Forest Plot
% Difference compared to "basic":

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
datapath='../../Datasets';

load(fullfile(datapath,'AllData_w_NPS_MHE_NOBRAIN.mat'))

studies=unique(df.studyID);   %Get all studies in df
% !!!!! These must be in the same order as listed under "studies" !!!!
studies=studies([1,2,5,6,7,9,16,19]);
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
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Geuter et al. 2013:';...
            'Theysohn et al. 2009:';...
            'Wrobel et al. 2014:'
            };

        

%% Select data STUDIES
varselect={'subID','NPSraw','MHEraw','rating','cond','condSeq'};

%'Atlas'
%?Pain Placebo NoRemi"      = HiPain Open Stimulation + HiPain Open ExpectationPeriod
%?Pain Placebo Remi"           = HiPain Open Stimulation + HiPain Open ExpectationPeriod + HiPain Open RemiConz
%?Pain NoPlacebo NoRemi"  = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod
%?Pain NoPlacebo Remi"       = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod + HiPain Open RemiConz
i=find(strcmp(studies,'atlas'));

sess1=[df((strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))&df.condSeq==1),varselect)
       df((strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))&df.condSeq==1),varselect)];

sess2=[df((strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))&df.condSeq==2),varselect)
       df((strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))&df.condSeq==2),varselect)];

sess1=sortrows(sess1,'subID');
sess2=sortrows(sess2,'subID');
strcmp(sess1.subID,sess2.subID);
corrcoef(sess1.rating,sess2.rating,'rows','complete')
corrcoef(sess1.NPSraw,sess2.NPSraw,'rows','complete')
stats.NPSraw(i)=withinMetastats(sess1.NPSraw,sess2.NPSraw);
stats.MHEraw(i)=withinMetastats(sess1.MHEraw,sess2.MHEraw);
stats.rating(i)=withinMetastats(sess1.rating,sess2.rating);
%'bingel06' >> Testing was performed within participants on left and right
%side... summarizine data across hemispheres for NPS and ratings first.
%There were two missing sessions>> Match values according to subID's 
control_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_R'))),varselect);
placebo_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_R'))),varselect);
control_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_L'))),varselect);
placebo_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_L'))),varselect);
L_all=outerjoin(placebo_L,control_L,'Keys','subID');
R_all=outerjoin(placebo_R,control_R,'Keys','subID');
L_all.NPSraw=nanmean([L_all{:,'NPSraw_placebo_L'},L_all{:,'NPSraw_control_L'}],2);
R_all.NPSraw=nanmean([R_all{:,'NPSraw_placebo_R'},R_all{:,'NPSraw_control_R'}],2);
L_all.MHEraw=nanmean([L_all{:,'MHEraw_placebo_L'},L_all{:,'MHEraw_control_L'}],2);
R_all.MHEraw=nanmean([R_all{:,'MHEraw_placebo_R'},R_all{:,'MHEraw_control_R'}],2);
L_all.rating=nanmean([L_all{:,'rating_placebo_L'},L_all{:,'rating_control_L'}],2);
R_all.rating=nanmean([R_all{:,'rating_placebo_R'},R_all{:,'rating_control_R'}],2);
R_all.subID=R_all.subID_placebo_R;
L_all.subID=L_all.subID_placebo_L;
Bingel_all=outerjoin(L_all,R_all,'Keys','subID');
Bingel_all.subID=Bingel_all.subID_R_all;
Bingel_all.condSeq_placebo_L(isnan(Bingel_all.condSeq_placebo_L))=2;

sess1R=Bingel_all(Bingel_all.condSeq_placebo_R==1,{'subID','rating_R_all','NPSraw_R_all','MHEraw_R_all'});
sess1R.Properties.VariableNames={'subID','rating','NPSraw','MHEraw'};
sess1L=Bingel_all(Bingel_all.condSeq_placebo_L==1,{'subID','rating_L_all','NPSraw_L_all','MHEraw_L_all'});
sess1L.Properties.VariableNames={'subID','rating','NPSraw','MHEraw'};
sess1=sortrows([sess1R;sess1L],'subID')

sess2R=Bingel_all(Bingel_all.condSeq_placebo_R==2,{'subID','rating_R_all','NPSraw_R_all','MHEraw_R_all'});
sess2R.Properties.VariableNames={'subID','rating','NPSraw','MHEraw'};
sess2L=Bingel_all(Bingel_all.condSeq_placebo_L==2,{'subID','rating_L_all','NPSraw_L_all','MHEraw_L_all'});
sess2L.Properties.VariableNames={'subID','rating','NPSraw','MHEraw'};
sess2=sortrows([sess2R;sess2L],'subID')

if sum(~strcmp(sess1.subID,sess2.subID));   
'Warning, Session pairing in Bingel et al. 2006 is wrong.'
end

i=find(strcmp(studies,'bingel'));
corrcoef(sess1.rating,sess2.rating,'rows','complete')
corrcoef(sess1.NPSraw,sess2.NPSraw,'rows','complete')
stats.NPSraw(i)=withinMetastats(sess1.NPSraw,sess2.NPSraw);
stats.MHEraw(i)=withinMetastats(sess1.MHEraw,sess2.MHEraw);
stats.rating(i)=withinMetastats(sess1.rating,sess2.rating);

%'bingel11'
% NOT USEFUL >> Sequence of testing and remifentanil not counterbalanced

%'choi' (Only data from experiment 1 used, since experiment 2 not mentioned in publication)
% NOT USEFUL >> Sequence of conditions unknown


%'eippert'
i=find(strcmp(studies,'eippert'));
labelscontrol=[df((strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))), {'subID','cond'})
              df((strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))), {'subID','cond'})];
control=array2table(...
        [mean(cat(3,df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))), {'NPSraw','MHEraw','rating','condSeq'}},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))), {'NPSraw','MHEraw','rating','condSeq'}}),3);...
              mean(cat(3,df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))), {'NPSraw','MHEraw','rating','condSeq'}},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_naloxone'))), {'NPSraw','MHEraw','rating','condSeq'}}),3)],...
              'VariableNames',{'NPSraw','MHEraw','rating','condSeq'});
control=[labelscontrol,control];
labelsplacebo=[df((strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))), {'subID','cond'})
              df((strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))), {'subID','cond'})];
placebo=array2table(...
             [mean(cat(3,df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))), {'NPSraw','MHEraw','rating','condSeq'}},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))), {'NPSraw','MHEraw','rating','condSeq'}}),3);...
              mean(cat(3,df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))), {'NPSraw','MHEraw','rating','condSeq'}},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_naloxone'))), {'NPSraw','MHEraw','rating','condSeq'}}),3)],...
              'VariableNames',{'NPSraw','MHEraw','rating','condSeq'});
placebo=[labelscontrol,placebo];
 
sess1=[placebo(placebo.condSeq==1,:);control(control.condSeq==1,:)];
sess2=[placebo(placebo.condSeq==2,:);control(control.condSeq==2,:)];
sess1=sortrows(sess1,'subID');
sess2=sortrows(sess2,'subID');
if sum(~strcmp(sess1.subID,sess2.subID));   
'Warning, Session pairing in Eippert et al. is wrong.'
end
corrcoef(sess1.rating,sess2.rating,'rows','complete')
corrcoef(sess1.NPSraw,sess2.NPSraw,'rows','complete')
stats.NPSraw(i)=withinMetastats(sess1.NPSraw,sess2.NPSraw);
stats.MHEraw(i)=withinMetastats(sess1.MHEraw,sess2.MHEraw);
stats.rating(i)=withinMetastats(sess1.rating,sess2.rating);

%'ellingsen'
i=find(strcmp(studies,'ellingsen'));
control=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))),varselect);
placebo=df((strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))),varselect);

sess1=[placebo(placebo.condSeq==1,:);control(control.condSeq==1,:)];
sess2=[placebo(placebo.condSeq==2,:);control(control.condSeq==2,:)];
sess1=sortrows(sess1,'subID');
sess2=sortrows(sess2,'subID');
if sum(~strcmp(sess1.subID,sess2.subID));   
'Warning, Session pairing in Ellingsen et al. is wrong.'
end
corrcoef(sess1.rating,sess2.rating,'rows','complete')
corrcoef(sess1.NPSraw,sess2.NPSraw,'rows','complete')
stats.NPSraw(i)=withinMetastats(sess1.NPSraw,sess2.NPSraw);
stats.MHEraw(i)=withinMetastats(sess1.MHEraw,sess2.MHEraw);
stats.rating(i)=withinMetastats(sess1.rating,sess2.rating);

%'elsenbruch'
i=find(strcmp(studies,'elsenbruch'));

control=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia'))),varselect);
placebo=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia'))),varselect);
% There were three sessions, so assign 1 and 2 relative to each other
control.condSeq=(control.condSeq>placebo.condSeq)+1;
placebo.condSeq=(placebo.condSeq>control.condSeq)+1;

sess1=[placebo(placebo.condSeq==1,:);control(control.condSeq==1,:)];
sess2=[placebo(placebo.condSeq==2,:);control(control.condSeq==2,:)];
sess1=sortrows(sess1,'subID');
sess2=sortrows(sess2,'subID');
if sum(~strcmp(sess1.subID,sess2.subID));   
'Warning, Session pairing in Elsenbruch et al. is wrong.'
end
corrcoef(sess1.rating,sess2.rating,'rows','complete')
corrcoef(sess1.NPSraw,sess2.NPSraw,'rows','complete')
stats.NPSraw(i)=withinMetastats(sess1.NPSraw,sess2.NPSraw);
stats.MHEraw(i)=withinMetastats(sess1.MHEraw,sess2.MHEraw);
stats.rating(i)=withinMetastats(sess1.rating,sess2.rating);

%'freeman'
% NOT USEFUL >> Sequence of testing random within only within sessions


%'geuter' (FOUR SEQUENTIAL SESSIONS!!!! FOR NOW ONLY TAKE TWO)
i=find(strcmp(studies,'geuter'));
geuter_labels=df((strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain*'))), {'subID','cond'})
geuter_all=array2table(...
         mean(cat(3,df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain*'))),{'NPSraw','MHEraw','rating','condSeq'}},...
         df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain*'))),{'NPSraw','MHEraw','rating','condSeq'}}),3),...
         'VariableNames',{'NPSraw','MHEraw','rating','condSeq'});
geuter_all=[geuter_labels,geuter_all];

sess1=[geuter_all(geuter_all.condSeq==1,:);geuter_all(geuter_all.condSeq==1,:)];
sess2=[geuter_all(geuter_all.condSeq==2,:);geuter_all(geuter_all.condSeq==2,:)];
sess1=sortrows(sess1,'subID');
sess2=sortrows(sess2,'subID');
if sum(~strcmp(sess1.subID,sess2.subID));   
'Warning, Session pairing in Geuter et al. is wrong.'
end
corrcoef(sess1.rating,sess2.rating,'rows','complete')
corrcoef(sess1.NPSraw,sess2.NPSraw,'rows','complete')
stats.NPSraw(i)=withinMetastats(sess1.NPSraw,sess2.NPSraw);
stats.MHEraw(i)=withinMetastats(sess1.MHEraw,sess2.MHEraw);
stats.rating(i)=withinMetastats(sess1.rating,sess2.rating);

%'huber'
% all conditions balanced within a session

%'kessner'
% different sequences confounded by temperature


%'kong06'
% all conditions balanced within a session


%'kong09'
% all conditions balanced within a session


%'ruetgen'
% different sequences confounded by placebo

%'Schenk'
% Four separate sessions, but confounded sequences cannot be fully separated from placebo/medication conditions

%'theysohn'
i=find(strcmp(studies,'theysohn'));

control=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')),varselect);
placebo=df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')),varselect);

% There were three sessions, so assign 1 and 2 relative to each other
control.condSeq=(control.condSeq>placebo.condSeq)+1;
placebo.condSeq=(placebo.condSeq>control.condSeq)+1;

sess1=[placebo(placebo.condSeq==1,:);control(control.condSeq==1,:)];
sess2=[placebo(placebo.condSeq==2,:);control(control.condSeq==2,:)];
sess1=sortrows(sess1,'subID');
sess2=sortrows(sess2,'subID');
if sum(~strcmp(sess1.subID,sess2.subID));   
'Warning, Session pairing in Theysohn et al. is wrong.'
end
corrcoef(sess1.rating,sess2.rating,'rows','complete')
corrcoef(sess1.NPSraw,sess2.NPSraw,'rows','complete')
stats.NPSraw(i)=withinMetastats(sess1.NPSraw,sess2.NPSraw);
stats.MHEraw(i)=withinMetastats(sess1.MHEraw,sess2.MHEraw);
stats.rating(i)=withinMetastats(sess1.rating,sess2.rating);

%'wager_princeton'
%not available

%'wager_michigan'
%not available

%'wrobel'
i=find(strcmp(studies,'wrobel'));
wrobel_labels=df((strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain*'))), {'subID','cond'})
wrobel_all=array2table(...
         mean(cat(3,df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain*'))),{'NPSraw','MHEraw','rating','condSeq'}},...
         df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain*'))),{'NPSraw','MHEraw','rating','condSeq'}}),3),...
         'VariableNames',{'NPSraw','MHEraw','rating','condSeq'});
wrobel_all=[wrobel_labels,wrobel_all];

sess1=wrobel_all(wrobel_all.condSeq==1,:);
sess2=wrobel_all(wrobel_all.condSeq==2,:);
sess1=sortrows(sess1,'subID');
sess2=sortrows(sess2,'subID');
if sum(~strcmp(sess1.subID,sess2.subID));   
'Warning, Session pairing in Wrobel et al. is wrong.'
end
corrcoef(sess1.rating,sess2.rating,'rows','complete')
corrcoef(sess1.NPSraw,sess2.NPSraw,'rows','complete')
stats.NPSraw(i)=withinMetastats(sess1.NPSraw,sess2.NPSraw);
stats.MHEraw(i)=withinMetastats(sess1.MHEraw,sess2.MHEraw);
stats.rating(i)=withinMetastats(sess1.rating,sess2.rating);

%'zeidan'
% No info available
%% Summarize all studies, weigh by SE
% Summary analysis+ Forest Plot
ForestPlotter(stats.NPSraw,...
              'studyIDtexts',studyIDtexts,...
              'outcomelabel','NPS Rating (Hedge''s {\itg})',...
              'type','random',...
              'summarystat','g',...
              'withoutlier',0,...
              'WIsubdata',1,...
              'boxscaling',1);

hgexport(gcf, 'G_Sequence_effects_VAS.svg', hgexport('factorystyle'), 'Format', 'svg'); 
