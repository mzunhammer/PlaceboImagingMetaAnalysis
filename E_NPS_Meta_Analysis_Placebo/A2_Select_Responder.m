%% Preprocess data for meta-analysis study-wise (summarize equivalent conditions)
% Difference compared to "ALL/Inclusive":

% 1.) Only participants with placeby-control ratings <0 are selected
% 2.) Only participants that were not marked as outliers are selected (df.ex_all)
% 3.) Only experimental conditions with max-chance of placebo effect were
% selected, i.e.:

% Atlas: No remifentanil effect 
% Bingel06: None
% Bingel11: None
% Choi: Only hi and lo (not low) expectation condition
% Eippert: No naloxone group
% Ellingsen: None
% Elsenbruch: None
% Freeman: None
% Geuter: Only control vs strong placebo (no weak placebo)
% Kessner: None
% Kong06: None
% Kong09: None
% Lui: None
% Ruetgen: Included despite responder selection
% Schenk: Only saline condition (no lidocaine)
% Theysohn: None
% Wager06a: None
% Wager06b: No haldol group
% Wrobel: None
% Zeidan: None


clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
datapath='../../Datasets';

load(fullfile(datapath,'AllData.mat'))

studies=unique(df.studyID);   %Get all studies in df
% !!!!! These must be in the same order as listed under "studies" !!!!

% studyIDtexts={
%             'Atlas et al. 2012: Hidden vs open remifentanil drip infusion (expectation period, remifentanil effect partialled out)| heat';...
% 			  'Bingel et al. 2006: Control vs placebo cream | laser';...
% 			  'Bingel et al. 2011: No vs positive expectations | heat';...
% 			  'Choi et al. 2011: No vs high effective placebo drip infusion | electrical';...
% 			  'Eippert et al. 2009: Control vs placebo cream (saline group) | heat (early & late)';...
% 			  'Ellingsen et al. 2013: Pre vs post placebo nasal spray | heat';...
%             'Elsenbruch et al. 2012: No vs certain placebo drip infusion | distension';...
%             'Freeman et al. 2015: Control vs placebo cream | heat';...
%             'Geuter et al. 2013: Control vs strong placebo cream | heat (early & late)';...
%             'Kessner et al. 2014: Negative vs positive treatment expectation group | heat';...
%             'Kong et al. 2006: Control vs placebo acupuncture | heat (high)';...
%             'Kong et al. 2009: Control vs placebo sham acupuncture | heat';...
%             'Lui et al. 2010: Red vs green cue signifying sham TENS off vs on | laser';...
%             'Ruetgen et al. 2015: No treatment vs placebo pill group  | electrical'
%             'Schenk et al. 2015:  Control vs placebo (saline only) | heat'
%             'Theysohn et al. 2009: No vs certain placebo drip infusion | distension';...
%             'Wager et al. 2004, Study 1: Control vs placebo cream | heat*';...
%             'Wager et al. 2004, Study 2: Control vs placebo cream | electrical*';...
%             'Wrobel et al. 2014: Control vs placebo cream (saline group only) | heat(early & late)'
%             'Zeidan et al. 2015: Control vs placebo cream (placebo group only) | heat*';...
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
            'Kessner et al. 2014:';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010:';...
            'Ruetgen et al. 2015:'
            'Schenk et al. 2015:'
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:'
            'Zeidan et al. 2015:';...
            };
%% VARIABLES TO SELECT

varselect={'NPSraw','rating','MHEraw',...
           'stimInt'};
           %'ex_lo_p_ratings','ex_img_artifact','ex_all'};

%% Study-level data
% these are needed to automatically apply the correct analysis functions
% for studies with data that deviate from the norm (wi-subject data).
df_resp.variables=varselect;
df_resp.studies=studies;
%Between-subject studies
df_resp.BetweenSubject=zeros(size(studies));
df_resp.BetweenSubject(strcmp(studies,'ruetgen'))=1;
df_resp.BetweenSubject(strcmp(studies,'kessner'))=1;
%Studies where only contrasts between conditions (e.g. pla>con), rather than conditions themselves (pla pain & con pain separately) are available
%...for imaging data
df_resp.consOnlyNPS=zeros(size(studies));
df_resp.consOnlyNPS(strcmp(studies,'wager04a_princeton'))=1;
df_resp.consOnlyNPS(strcmp(studies,'zeidan'))=1;
%Studies where only contrasts between conditions (e.g. pla>con), rather than conditions themselves (pla pain & con pain separately) are available
%...for rating data
df_resp.consOnlyRating=zeros(size(studies));
df_resp.consOnlyRating(strcmp(studies,'wager04a_princeton'))=1;
df_resp.consOnlyRating(strcmp(studies,'wager04b_michigan'))=1;
df_resp.consOnlyRating(strcmp(studies,'zeidan'))=1;
       
%% Get data
%'Atlas'
%?Pain Placebo NoRemi"      = HiPain Open Stimulation + HiPain Open ExpectationPeriod
%?Pain Placebo Remi"           = HiPain Open Stimulation + HiPain Open ExpectationPeriod + HiPain Open RemiConz
%?Pain NoPlacebo NoRemi"  = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod
%?Pain NoPlacebo Remi"       = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod + HiPain Open RemiConz

% Effect of remi vs no-remi corresponds to estimated mean plateau effect of
% 0.043 micro-g/kg/min (individual) OR 0.884 ng/ml (absolute)
% across hidden and open administration periods
i=find(strcmp(studies,'atlas'));
df_resp.pladata{i}=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))&~df.ex_all),varselect}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_ExpectationPeriod'))&~df.ex_all),varselect};
df_resp.condata{i}=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))&~df.ex_all),varselect}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_ExpectationPeriod'))&~df.ex_all),varselect};
%'bingel06'
% >> Testing was performed within participants on left and right
%side... summarizine data across hemispheres for NPS and ratings first.
%There were two missing sessions>> Match values according to subID's 
i=find(strcmp(studies,'bingel'));
control_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painNoPlacebo_R'))&~df.ex_all),['subID',varselect]);
placebo_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painPlacebo_R'))&~df.ex_all),['subID',varselect]);
control_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painNoPlacebo_L'))&~df.ex_all),['subID',varselect]);
placebo_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painPlacebo_L'))&~df.ex_all),['subID',varselect]);
control=outerjoin(control_R,control_L,'Keys','subID');
placebo=outerjoin(placebo_R,placebo_L,'Keys','subID');
control.subID_control_R=[];
placebo.subID_placebo_R=[];
control.subID_control_L=[];
placebo.subID_placebo_L=[];
df_resp.pladata{i}=NaN(height(control),length(varselect));
df_resp.condata{i}=NaN(height(control),length(varselect));
for j=1:length(varselect)
    currvar=varselect{j};
    df_resp.pladata{i}(:,j)= nanmean([placebo{:,[currvar, '_placebo_R']},placebo{:,[currvar, '_placebo_L']}],2);
    df_resp.condata{i}(:,j)= nanmean([control{:,[currvar, '_control_R']},control{:,[currvar, '_control_L']}],2);
end
%'bingel11'
i=find(strcmp(studies,'bingel11'));
df_resp.condata{i}=df{(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')&~df.ex_all),varselect};
%'choi' (Only data from experiment 1 used, since experiment 2 not mentioned in publication)
i=find(strcmp(studies,'choi'));
df_resp.condata{i}=df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*'))&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*'))&~df.ex_all),varselect};
%'eippert'
i=find(strcmp(studies,'eippert'));
df_resp.condata{i}=mean(cat(3,df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))&~df.ex_all),varselect},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))&~df.ex_all),varselect}),3);
df_resp.pladata{i}=mean(cat(3,df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))&~df.ex_all),varselect},...
              df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))&~df.ex_all),varselect}),3);
%'ellingsen'
i=find(strcmp(studies,'ellingsen'));
df_resp.condata{i}=df{(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))&~df.ex_all),varselect};
%'elsenbruch'
i=find(strcmp(studies,'elsenbruch'));
df_resp.condata{i}=df{(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_0%_analgesia'))&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_100%_analgesia'))&~df.ex_all),varselect};
%'freeman'
i=find(strcmp(studies,'freeman'));
df_resp.condata{i}=df{(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))&~df.ex_all),varselect};
%'geuter'
i=find(strcmp(studies,'geuter'));
df_resp.condata{i}=mean(cat(3,df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_strong')&~df.ex_all),varselect},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong')&~df.ex_all),varselect}),3);
df_resp.pladata{i}=mean(cat(3,df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_strong')&~df.ex_all),varselect},...
         df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong')&~df.ex_all),varselect}),3);
%'kessner' (will be ignored in responder selection later)
i=find(strcmp(studies,'kessner'));
df_resp.condata{i}=df{(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg')&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos')&~df.ex_all),varselect};
%'kong06'
i=find(strcmp(studies,'kong06'));
df_resp.condata{i}=df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')&~df.ex_all),varselect};   
%'kong09'
i=find(strcmp(studies,'kong09'));
df_resp.condata{i}=df{(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')&~df.ex_all),varselect};
%'lui'
i=find(strcmp(studies,'lui'));
df_resp.condata{i}=df{(strcmp(df.studyID,'lui')&strcmp(df.cond,'pain_control')&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'lui')&strcmp(df.cond,'pain_placebo')&~df.ex_all),varselect};
%'ruetgen'
i=find(strcmp(studies,'ruetgen'));
df_resp.condata{i}=df{(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')&~df.ex_all),varselect};
%'schenk'
i=find(strcmp(studies,'schenk'));
df_resp.condata{i}=df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_control')&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_placebo')&~df.ex_all),varselect};
%'theysohn'
i=find(strcmp(studies,'theysohn'));
df_resp.condata{i}=df{(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')&~df.ex_all),varselect};
%'wager04a_princeton (study 1): ONLY CONTRASTS AVAILABLE'
% contrasts are Con>Pla, therefore INVERSE ALL VARIABLES: *(-1)
i=find(strcmp(studies,'wager04a_princeton')); 
df_resp.pladata{i}=(-1)*df{(strcmp(df.studyID,'wager04a_princeton')&strcmp(df.cond,'(intense-none)control-placebo')&~df.ex_all),varselect};
df_resp.condata{i}=NaN(size(df_resp.pladata{i}));
%'wager04b_michigan':  FOR  RATINGS ONLY CONTRAST CONTROL-PLACEBO AVAILABLE
% contrasts are Con>Pla, therefore INVERSE RATNGS: *(-1)
i=find(strcmp(studies,'wager04b_michigan'));
df_resp.condata{i}=df{(strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'control_pain')&~df.ex_all),varselect};
df_resp.pladata{i}=df{(strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'placebo_pain')&~df.ex_all),varselect};
df_resp.pladata{i}(:,find(strcmp(varselect,'rating')))=(-1)*df_resp.pladata{i}(:,find(strcmp(varselect,'rating')));

%'wrobel'
i=find(strcmp(studies,'wrobel'));
df_resp.condata{i}=[mean(cat(3,df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_saline'))&~df.ex_all),varselect},...
                          df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline'))&~df.ex_all),varselect}),3)]; 
df_resp.pladata{i}=[mean(cat(3,df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_saline'))&~df.ex_all),varselect},...
                          df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline'))&~df.ex_all),varselect}),3)];
%'zeidan' FOR  RATINGS and IMAGES ONLY CONTRAST PLACEBO-CONTROL AVAILABLE
i=find(strcmp(studies,'zeidan'));
df_resp.pladata{i}=df{(strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pla>Control within painful series')&~df.ex_all),varselect};
df_resp.condata{i}=NaN(size(df_resp.pladata{i}));


%% Replace placebo-non-responders with nan
% Define responders
v=find(strcmp(df_resp.variables,'rating'));
for i=1:length(df_resp.studies) % Calculate for all studies except...
    if df_resp.consOnlyRating(i)==0 %...data-sets where only rating contrasts are available
        if df_resp.BetweenSubject(i)==0 %For within-subject studies
           df_resp.responder{i}=(df_resp.pladata{i}(:,v)-df_resp.condata{i}(:,v))<0;
        elseif df_resp.BetweenSubject(i)==1 %Between-subject studies
           % Responder-selection according to ratings not possible post-hoc in between-subject studies 
        end
    elseif df_resp.consOnlyRating(i)==1 %... for data-sets where only rating contrasts are available
           df_resp.responder{i}=(df_resp.pladata{i}(:,v))<0; % contrast was already computed
    end
end

% Exclude non-responders
for i=1:length(df_resp.studies) % Calculate for all studies except...
    df_resp.pladata{i}(~df_resp.responder{i},:)=NaN;
    df_resp.condata{i}(~df_resp.responder{i},:)=NaN;
end

% Exclude Kessner et al (between-subject without responder selection manually)
% (Ruetgen et al was also between subject, but with responder pre-selection
% and so it is included
i=find(strcmp(studies,'kessner'));
df_resp.condata{i}=NaN(size(df_resp.condata{i}));
df_resp.pladata{i}=NaN(size(df_resp.pladata{i}));
%% Add study/variable descriptions needed for meta-analysis

save('A3_Responder_Sample.mat','df_resp');