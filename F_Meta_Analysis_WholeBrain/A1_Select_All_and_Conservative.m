%% Preprocess data for meta-analysis study-wise (summarize equivalent conditions)

clear
tic
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')

datapath='../../Datasets';

load(fullfile(datapath,'AllData.mat'))

studies=unique(df.studyID);   %Get all studies in df
% !!!!! These must be in the same order as listed under "studies" !!!!

% studyIDtexts={
%             'Atlas et al. 2012: Hidden vs open remifentanil drip infusion (expectation period)| heat';...
% 			'Bingel et al. 2006: Control vs placebo cream | laser';...
% 			'Bingel et al. 2011: No vs positive expectations | heat';...
% 			'Choi et al. 2011: No vs low & high effective placebo drip infusion | electrical';...
% 			'Eippert et al. 2009: Control vs placebo cream (saline & naloxone group) | heat (early & late)';...
% 			'Ellingsen et al. 2013: Pre vs post placebo nasal spray | heat';...
%             'Elsenbruch et al. 2012: No vs certain placebo drip infusion | distension';...
%             'Freeman et al. 2015: Control vs placebo cream | heat';...
%             'Geuter et al. 2013: Control vs weak & strong placebo cream | heat (early & late)';...
%             'Kessner et al. 2014: Negative vs positive treatment expectation group | heat';...
%             'Kong et al. 2006: Control vs placebo acupuncture | heat';...
%             'Lui et al. 2010: Red vs green cue signifying sham TENS off vs on | laser';...
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

%% Study-level data
df_full.variables='Normalized Images';

df_full.studies=studies;
%Between-subject studies
df_full.BetweenSubject=zeros(size(studies));
df_full.BetweenSubject(strcmp(studies,'ruetgen'))=1;
df_full.BetweenSubject(strcmp(studies,'kessner'))=1;
%Studies where only contrasts between conditions (e.g. pla>con), rather than conditions themselves (pla pain & con pain separately) are available
%...for imaging data
df_full.consOnlyNPS=zeros(size(studies));
df_full.consOnlyNPS(strcmp(studies,'wager04a_princeton'))=1;
df_full.consOnlyNPS(strcmp(studies,'zeidan'))=1;
%Studies where only contrasts between conditions (e.g. pla>con), rather than conditions themselves (pla pain & con pain separately) are available
%...for rating data
df_full.consOnlyRating=zeros(size(studies));
df_full.consOnlyRating(strcmp(studies,'wager04a_princeton'))=1;
df_full.consOnlyRating(strcmp(studies,'wager04b_michigan'))=1;
df_full.consOnlyRating(strcmp(studies,'zeidan'))=1;
       
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
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),'norm_img'})+... %If norm_img not in df, run B_Prepro_Images/A_Equalize_Image_Size_and_Mask first.
        nii2vector(df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_RemiConz'))),'norm_img'})+...
        nii2vector(df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_ExpectationPeriod'))),'norm_img'});
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),'norm_img'})+...
        nii2vector(df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_RemiConz'))),'norm_img'})+...
        nii2vector(df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_ExpectationPeriod'))),'norm_img'});
%'bingel06'
% >> Testing was performed within participants on left and right
%side... summarizine data across hemispheres for NPS and ratings first.
%There were two missing sessions>> Match values according to subID's 
i=find(strcmp(studies,'bingel'));
control_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painNoPlacebo_R'))),{'subID','norm_img'});
placebo_R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painPlacebo_R'))),{'subID','norm_img'});
control_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painNoPlacebo_L'))),{'subID','norm_img'});
placebo_L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'painPlacebo_L'))),{'subID','norm_img'});
control=outerjoin(control_R,control_L,'Keys','subID');
placebo=outerjoin(placebo_R,placebo_L,'Keys','subID');
control.subID_control_R=[];
placebo.subID_placebo_R=[];
control.subID_control_L=[];
placebo.subID_placebo_L=[];
df_full.pladata{i}= nanmean(cat(3,nii2vector(placebo{:,'norm_img_placebo_R'}),nii2vector(placebo{:,'norm_img_placebo_L'})),3);
df_full.condata{i}= nanmean(cat(3,nii2vector(control{:,'norm_img_control_R'}),nii2vector(control{:,'norm_img_control_L'})),3);

%'bingel11'
i=find(strcmp(studies,'bingel11'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')),'norm_img'});
%'choi' (Only data from experiment 1 used, since experiment 2 not mentioned in publication)
i=find(strcmp(studies,'choi'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*'))),'norm_img'});
df_full.pladata{i}=mean(cat(3,nii2vector(df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*'))),'norm_img'}),...
                              nii2vector(df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_1potent_pain_beta.*'))),'norm_img'})),3);
%'eippert'
i=find(strcmp(studies,'eippert'));
df_full.condata{i}=[mean(cat(3,nii2vector(df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))),'norm_img'}),...
                               nii2vector(df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))),'norm_img'})),3);...
                    mean(cat(3,nii2vector(df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))),'norm_img'}),...
                               nii2vector(df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_naloxone'))),'norm_img'})),3)];

df_full.pladata{i}=[mean(cat(3,nii2vector(df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))),'norm_img'}),...
                               nii2vector(df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))),'norm_img'})),3);...
              mean(cat(3,nii2vector(df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))),'norm_img'}),...
                         nii2vector(df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_naloxone'))),'norm_img'})),3)];
%'ellingsen'
i=find(strcmp(studies,'ellingsen'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control'))),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo'))),'norm_img'});
%'elsenbruch'
i=find(strcmp(studies,'elsenbruch'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_0%_analgesia'))),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_100%_analgesia'))),'norm_img'});
%'freeman'
i=find(strcmp(studies,'freeman'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain'))),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain'))),'norm_img'});
%'geuter'
i=find(strcmp(studies,'geuter'));
df_full.condata{i}=mean(cat(3,nii2vector(df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_weak')),'norm_img'}),...
                              nii2vector(df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_weak')),'norm_img'}),...
                              nii2vector(df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_control_strong')),'norm_img'}),...
                              nii2vector(df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong')),'norm_img'})),3);
df_full.pladata{i}=mean(cat(3,nii2vector(df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_weak')),'norm_img'}),...
                              nii2vector(df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_weak')),'norm_img'}),...
                              nii2vector(df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'early_pain_placebo_strong')),'norm_img'}),...
                              nii2vector(df{(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong')),'norm_img'})),3);
%'kessner'
i=find(strcmp(studies,'kessner'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg')),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos')),'norm_img'});
%'kong06'
i=find(strcmp(studies,'kong06'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')),'norm_img'});   
%'kong09'
i=find(strcmp(studies,'kong09'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')),'norm_img'});
%'lui'
i=find(strcmp(studies,'lui'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'lui')&strcmp(df.cond,'pain_control')),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'lui')&strcmp(df.cond,'pain_placebo')),'norm_img'});
%'ruetgen'
i=find(strcmp(studies,'ruetgen'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')),'norm_img'});
%'schenk'
i=find(strcmp(studies,'schenk'));
df_full.condata{i}=mean(cat(3,nii2vector(df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_control')),'norm_img'}),...
                              nii2vector(df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_control')),'norm_img'})),3);
df_full.pladata{i}=mean(cat(3,nii2vector(df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_placebo')),'norm_img'}),...
                              nii2vector(df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_placebo')),'norm_img'})),3);
%'theysohn'
i=find(strcmp(studies,'theysohn'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')),'norm_img'});
%'wager04a_princeton (study 1): ONLY CONTRASTS AVAILABLE'
% contrasts are Con>Pla, therefore INVERSE ALL VARIABLES: *(-1)
i=find(strcmp(studies,'wager04a_princeton')); 
df_full.pladata{i}=(-1).*nii2vector(df{(strcmp(df.studyID,'wager04a_princeton')&strcmp(df.cond,'(intense-none)control-placebo')),'norm_img'});
df_full.condata{i}=NaN(size(df_full.pladata{i}));
%'wager04b_michigan':  FOR  RATINGS ONLY CONTRAST CONTROL-PLACEBO AVAILABLE
% contrasts are Con>Pla, therefore INVERSE RATNGS: *(-1)
i=find(strcmp(studies,'wager04b_michigan'));
df_full.condata{i}=nii2vector(df{(strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'control_pain')),'norm_img'});
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'placebo_pain')),'norm_img'});

%'wrobel'
i=find(strcmp(studies,'wrobel'));
df_full.condata{i}=[mean(cat(3,nii2vector(df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_saline'))),'norm_img'}),...
                               nii2vector(df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline'))),'norm_img'})),3);...
                    mean(cat(3,nii2vector(df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_control_haldol'))),'norm_img'}),...
                               nii2vector(df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_haldol'))),'norm_img'})),3);]; 
df_full.pladata{i}=[mean(cat(3,nii2vector(df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_saline'))),'norm_img'}),...
                               nii2vector(df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline'))),'norm_img'})),3);...
                    mean(cat(3,nii2vector(df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'early_pain_placebo_haldol'))),'norm_img'}),...
                               nii2vector(df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_haldol'))),'norm_img'})),3);];
        
%'zeidan'
i=find(strcmp(studies,'zeidan'));
df_full.pladata{i}=nii2vector(df{(strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pla>Control within painful series')),'norm_img'});
df_full.condata{i}=NaN(size(df_full.pladata{i}));

%% Add study/variable descriptions needed for meta-analysis

save('A1_Full_Sample_Img_Data.mat','df_full');

%% Conservative SAMPLE
% Difference compared to "ALL":
% Atlas: None 
% Bingel06: None
% Bingel11: None
% Choi: None
% Eippert: None
% Ellingsen: None
% Elsenbruch: None
% Freeman: None
% Geuter: None
% Kessner: None
% Kong06: None
% Kong09: None
% Ruetgen: Excluded bc of responder selection
% Schenk: None
% Theysohn: None
% Wager06a: None
% Wager06b: Excluded bc of responder selection
% Wrobel: None
% Zeidan: None

%%>> Exclude Ruetgen (responder selection), Wager06b (responder selection),
% Bingel 2011 (sequence effects)

df_conserv=df_full;
%'kong06'
i=find(strcmp(studies,'kong06'));
df_conserv.condata{i}=NaN(size(df_full.condata{i}));
df_conserv.pladata{i}=NaN(size(df_full.pladata{i}));
%'ruetgen'
i=find(strcmp(studies,'ruetgen'));
df_conserv.condata{i}=NaN(size(df_full.condata{i}));
df_conserv.pladata{i}=NaN(size(df_full.pladata{i}));
%'wager04b_michigan'
i=find(strcmp(studies,'wager04b_michigan'));
df_conserv.condata{i}=NaN(size(df_full.condata{i}));
df_conserv.pladata{i}=NaN(size(df_full.pladata{i}));
%'bingel11'
i=find(strcmp(studies,'bingel11'));
df_conserv.condata{i}=NaN(size(df_full.condata{i}));
df_conserv.pladata{i}=NaN(size(df_full.pladata{i}));
%'zeidan'
i=find(strcmp(studies,'zeidan'));
df_conserv.condata{i}=NaN(size(df_full.condata{i}));
df_conserv.pladata{i}=NaN(size(df_full.pladata{i}));
save('A1_Conservative_Sample_Img_Data.mat','df_conserv');

