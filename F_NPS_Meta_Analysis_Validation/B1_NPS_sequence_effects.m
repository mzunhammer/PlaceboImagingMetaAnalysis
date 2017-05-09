%% Meta-Analysis & Forest Plot
% Difference compared to "basic":

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
datapath='../../Datasets';

load(fullfile(datapath,'AllData.mat'))

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
stats.NPSraw(i)=withinMetastats(sess2.NPSraw,sess1.NPSraw);
stats.MHEraw(i)=withinMetastats(sess2.MHEraw,sess1.MHEraw);
stats.rating(i)=withinMetastats(sess2.rating,sess1.rating);

%'bingel06'
% ?Participants underwent two runs each.
% ?In each run both the left AND the right hand were tested.
% ?In each run both the placebo AND the control group were tested.
% The placebo/control condition switched between right and left inbetween
% sessions.
% ?Left and right hands were modeled as separate regressors and have to be
% summarized
% -Second Session is missing for two participants

% Get pain-images for both sides and treatments
control_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painNoPlacebo_R'))),varselect);
placebo_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painPlacebo_L'))),varselect);
placebo_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painPlacebo_R'))),varselect);
control_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painNoPlacebo_L'))),varselect);

% Check whether control_R and placebo_L can be combined with matching
% subjects and matching runs
if ~all(control_R.condSeq==placebo_L.condSeq)|~all(strcmp(placebo_L.subID,control_R.subID))
    'Warning, Session pairing in Bingel et al. 2006 is wrong.'
    return
end
% Check whether control_L and placebo_R can be combined with matching
% subjects and matching runs
if ~all(control_L.condSeq==placebo_R.condSeq)|~all(strcmp(placebo_R.subID,control_L.subID))
    'Warning, Session pairing in Bingel et al. 2006 is wrong.'
    return
end
% combined control_R and placebo_L
labelscombi1=control_R(:, {'subID','cond'});            
combi1=array2table(...
        mean(cat(3,control_R{:, {'NPSraw','MHEraw','rating','condSeq'}},...
              placebo_L{:, {'NPSraw','MHEraw','rating','condSeq'}}),3),...
              'VariableNames',{'NPSraw','MHEraw','rating','condSeq'});
combi1=[labelscombi1,combi1];
% combined control_L and placebo_R
labelscombi2=placebo_R(:, {'subID','cond'});            
combi2=array2table(...
        mean(cat(3,placebo_R{:, {'NPSraw','MHEraw','rating','condSeq'}},...
              control_L{:, {'NPSraw','MHEraw','rating','condSeq'}}),3),...
              'VariableNames',{'NPSraw','MHEraw','rating','condSeq'});
combi2=[labelscombi2,combi2];

% Get pain-images for both sides and treatments
sess1=[combi1(combi1.condSeq==1,:);combi2(combi2.condSeq==1,:)];
sess2=[combi1(combi1.condSeq==2,:);combi2(combi2.condSeq==2,:)];
sess1=sortrows(sess1,'subID');
sess2=sortrows(sess2,'subID');

i=find(strcmp(studies,'bingel'));
corrcoef(sess1.rating,sess2.rating,'rows','complete')
corrcoef(sess1.NPSraw,sess2.NPSraw,'rows','complete')
stats.NPSraw(i)=withinMetastats(sess2.NPSraw,sess1.NPSraw);
stats.MHEraw(i)=withinMetastats(sess2.MHEraw,sess1.MHEraw);
stats.rating(i)=withinMetastats(sess2.rating,sess1.rating);

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
stats.NPSraw(i)=withinMetastats(sess2.NPSraw,sess1.NPSraw);
stats.MHEraw(i)=withinMetastats(sess2.MHEraw,sess1.MHEraw);
stats.rating(i)=withinMetastats(sess2.rating,sess1.rating);

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
stats.NPSraw(i)=withinMetastats(sess2.NPSraw,sess1.NPSraw);
stats.MHEraw(i)=withinMetastats(sess2.MHEraw,sess1.MHEraw);
stats.rating(i)=withinMetastats(sess2.rating,sess1.rating);

%'elsenbruch'
i=find(strcmp(studies,'elsenbruch'));

control=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_0%_analgesia'))),varselect);
placebo=df((strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_100%_analgesia'))),varselect);
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
stats.NPSraw(i)=withinMetastats(sess2.NPSraw,sess1.NPSraw);
stats.MHEraw(i)=withinMetastats(sess2.MHEraw,sess1.MHEraw);
stats.rating(i)=withinMetastats(sess2.rating,sess1.rating);

%'freeman'
% NOT USEFUL >> Sequence of testing random within sessions


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
stats.NPSraw(i)=withinMetastats(sess2.NPSraw,sess1.NPSraw);
stats.MHEraw(i)=withinMetastats(sess2.MHEraw,sess1.MHEraw);
stats.rating(i)=withinMetastats(sess2.rating,sess1.rating);

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
stats.NPSraw(i)=withinMetastats(sess2.NPSraw,sess1.NPSraw);
stats.MHEraw(i)=withinMetastats(sess2.MHEraw,sess1.MHEraw);
stats.rating(i)=withinMetastats(sess2.rating,sess1.rating);

%'wager_princeton'
%not available

%'wager_michigan'
%not available

%'wrobel'
i=find(strcmp(studies,'wrobel'));
% Take SubjectID's and condition labels from "early pain" (ordering of subIDs and testing sequence is the same for late pain)
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
stats.NPSraw(i)=withinMetastats(sess2.NPSraw,sess1.NPSraw);
stats.MHEraw(i)=withinMetastats(sess2.MHEraw,sess1.MHEraw);
stats.rating(i)=withinMetastats(sess2.rating,sess1.rating);

%'zeidan'
% No info available
%% Summarize all studies, weigh by SE for session differences
% Summary analysis+ Forest Plot
ForestPlotter(stats.NPSraw,...
              'studyIDtexts',studyIDtexts,...
              'outcomelabel','NPS response (Hedge''s {\itg})',...
              'type','random',...
              'summarystat','g',...
              'withoutlier',0,...
              'WIsubdata',1,...
              'boxscaling',1);

hgexport(gcf, 'B1_NPS_sequence_effects.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../../Protocol_and_Manuscript/NPS_validation/Figures/Figure2', hgexport('factorystyle'), 'Format', 'svg');

%% Summarize all studies, weigh by SE for session correlations
% Summary analysis+ Forest Plot
ForestPlotter(stats.NPSraw,...
              'studyIDtexts',studyIDtexts,...
              'outcomelabel','NPS response (Hedge''s {\itg})',...
              'type','random',...
              'summarystat','r',...
              'withoutlier',0,...
              'WIsubdata',1,...
              'boxscaling',1);

hgexport(gcf, 'B2_NPS_reliability.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../../Protocol_and_Manuscript/NPS_validation/Figures/Figure3', hgexport('factorystyle'), 'Format', 'svg');

%% Summarize all studies, weigh by SE for session correlations
%Since ratings were affected by placebo conditions strongly, direct
%comparison of reliability of NPS and rating responses is unfair
%Summary analysis+ Forest Plot
% ForestPlotter(stats.rating,...
%               'studyIDtexts',studyIDtexts,...
%               'outcomelabel','Rating response (Hedge''s {\itg})',...
%               'type','random',...
%               'summarystat','r',...
%               'withoutlier',0,...
%               'WIsubdata',1,...
%               'boxscaling',1);
% 
% hgexport(gcf, 'G_Reliability_rating.svg', hgexport('factorystyle'), 'Format', 'svg'); 
% hgexport(gcf, '../../Protocol_and_Manuscript/NPS_validation/Figures/Figure6b', hgexport('factorystyle'), 'Format', 'svg');


%% Check NPS reliability vs images/participant

% For event related designs, images per block are basically determined by
% the length of the HRF
df.imgsPerBlock(df.imgsPerBlock==0)=15000./df.tr(df.imgsPerBlock==0);

rs=[stats.NPSraw.r]';

for i=1:length(studies)
    currstudy=strcmp(df.studyID,studies(i))
    nImages(i,1)=mean(df.nImages(currstudy))
    nBlocks(i,1)=mean(df.nBlocks(currstudy));
    imgsPerBlock(i,1)=mean(df.imgsPerBlock(currstudy));
    xSpan(i,1)=mean(df.imgsPerBlock(currstudy));
end

[R,P,RLO,RUP]=corrcoef(nImages,rs)
[R,P,RLO,RUP]=corrcoef(nBlocks,rs)
[R,P,RLO,RUP]=corrcoef(imgsPerBlock,rs)
[R,P,RLO,RUP]=corrcoef(imgsPerBlock.*nBlocks,rs)

disp(['Correlation between re-test reliability (within-subject correlations) and number of images per participant: r?= ',...
    num2str(R(2)),...
    ', p?=?',num2str(P(2))]);


%% Plot stimulus-repetitions/session vs reliability estimates
% Plot single-study values
figure %('units','normalized','position',[0 0 1.5 sqrt(1.5)]);
colormapping=cbrewer('qual','Accent',20);
axis([0 max(nBlocks) 0 1])
hold on
for i=1:length(rs)

plot(nBlocks(i),rs(i),'.',...
   'MarkerSize',20,...
   'DisplayName',studyIDtexts{i},...
   'MarkerEdgeColor',colormapping(i,:),...
   'MarkerFaceColor',colormapping(i,:));
end

xlabel('Number of pain stimulus repetitions/session')
ylabel('Correlation (r) Session 1 vs 2')
legend show
 hold off

%% Plot total number of images in design-matrix vs reliability estimates
% Plot single-study values
figure %('units','normalized','position',[0 0 1.5 sqrt(1.5)]);
colormapping=cbrewer('qual','Accent',20);
axis([0 max(nImages) 0 1])
hold on
for i=1:length(rs)

plot(nImages(i),rs(i),'.',...
   'MarkerSize',20,...
   'DisplayName',studyIDtexts{i},...
   'MarkerEdgeColor',colormapping(i,:),...
   'MarkerFaceColor',colormapping(i,:));
end

xlabel('Mean number of images acquired/subject')
ylabel('Correlation (r) Session 1 vs 2')
legend show
 hold off 

%% Plot images/session vs reliability estimates
imgsPerSession=[
            990;... %'Atlas et al. 2012:'
			488;... %'Bingel et al. 2006:'
			329;... %'Eippert et al. 2009:'
			510;... %'Ellingsen et al. 2013:'
            197;... %'Elsenbruch et al. 2012:'
            284;... %'Geuter et al. 2013:'
            206;... %'Theysohn et al. 2009:'
            327.5]%'Wrobel et al. 2014:'
% Plot single-study values
figure %('units','normalized','position',[0 0 1.5 sqrt(1.5)]);
colormapping=cbrewer('qual','Accent',20);
axis([0 max(imgsPerSession) 0 1])
hold on
for i=1:length(rs)

plot(imgsPerSession(i),rs(i),'.',...
   'MarkerSize',20,...
   'DisplayName',studyIDtexts{i},...
   'MarkerEdgeColor',colormapping(i,:),...
   'MarkerFaceColor',colormapping(i,:));
end

xlabel('Number of images/session')
ylabel('Correlation (r) Session 1 vs 2')
legend show
 hold off 

 
% Plot overall fixed effects regression line
% t=table(nBlocks,rs);
% t.sqrt_nBlocks=sqrt(nBlocks);
% mmdl1 = fitlm(t,'rs ~ sqrt_nBlocks');
% fixedB0=mmdl1.Coefficients.Estimate(1);
% fixedB1=mmdl1.Coefficients.Estimate(2);
% 
% xl=[0 50];
% x=linspace(xl(1),xl(2),100);
% overally=sqrt(x).*(fixedB1)+(fixedB0);
% overally=overally.^2;
% plot(x,overally,'--black','LineWidth',2.5)
% 



%hgexport(gcf, ['C_Ratings_vs_NPS.svg'], hgexport('factorystyle'), 'Format', 'svg'); 
%pubpath='../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/';
%hgexport(gcf, fullfile(pubpath,'C_Ratings_vs_NPS.svg'), hgexport('factorystyle'), 'Format', 'svg');