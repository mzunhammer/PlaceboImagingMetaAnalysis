%% Preprocess data for meta-analysis study-wise (summarize equivalent conditions)

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
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
%% VARIABLES TO SELECT
varselect={'studyID','subID','cond','stimtype','stimloc','stimside','plaForm','plaInduct',...
           'pla','pain',...
           'male','age','plaFirst','condSeq','stimInt','rating','rating101',...
           'fieldStrength','tr','te','voxelVolAcq','voxelVolMat','imgsPerBlock','nBlocks','nImages','xSpan','conSpan'...
           'NPSraw','MHEraw',...%'PPR_pain_raw','PPR_anti_raw','brainPPR_anti_raw',...
           'ex_lo_p_ratings','ex_img_artifact','ex_all'};
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
% First get pure pain effect.
paindf{i}=[df((strcmp(df.studyID,'atlas')&strcmp(df.cond,'StimHiPain_Open_Stimulation')),varselect);
          df((strcmp(df.studyID,'atlas')&strcmp(df.cond,'StimHiPain_Hidden_Stimulation')),varselect)];

      
% These variables were partitioned into (orthogonal effects) of
% stimulation, remifentanil and expectation period and have to be re-combined by summing them up
vars2addup={'rating'
'NPSraw'
'MHEraw'}
%'PPR_pain_raw'
%'PPR_anti_raw'
%'brainPPR_anti_raw'};
pladata=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),vars2addup}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_RemiConz'))),vars2addup}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_ExpectationPeriod'))),vars2addup};
condata=df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),vars2addup}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_RemiConz'))),vars2addup}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_ExpectationPeriod'))),vars2addup};
% Replace original variables with summed up variables
paindf{i}{:,vars2addup}=[pladata;condata];
%    
vars2average={'xSpan'};
pladata=mean(...
        cat(3,...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),vars2average},....
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_RemiConz'))),vars2average},...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_ExpectationPeriod'))),vars2average}),...
        3);
condata=mean(...
        cat(3,...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),vars2average},....
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_RemiConz'))),vars2average},...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_ExpectationPeriod'))),vars2average}),...
        3);
% Replace original variables with averaged variables
paindf{i}{:,vars2average}=[pladata;condata];

% Change condition label accordingly
paindf{i}.cond=strcat(paindf{i}.cond, '&expect&remi');
%'bingel06'
% >> Testing was performed within participants on left and right
%side... summarizine data across hemispheres for NPS and ratings first.
%There were two missing sessions>> Match values according to subID's 

i=find(strcmp(studies,'bingel'));
% First get pure pain effect for right side only to get basic data-frame
paindf{i}=[df((strcmp(df.studyID,'bingel')&strcmp(df.cond,'painNoPlacebo_R')),varselect);
          df((strcmp(df.studyID,'bingel')&strcmp(df.cond,'painPlacebo_R')),varselect)];
% These variables are available for right and left side and have to be averaged of
vars2avg={ 'condSeq','stimInt','rating',...
           'imgsPerBlock','nImages','xSpan',...
           'NPSraw','MHEraw',...%'PPR_pain_raw','PPR_anti_raw','brainPPR_anti_raw',...
           };
vars2sum={'nBlocks'};
% Get all Right and Left pain conditions sorted by participant and placebo
% condition
R=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'pain.+_R'))),varselect);
L=df((strcmp(df.studyID,'bingel')&~cellfun(@isempty,regexp(df.cond,'pain.+_L'))),varselect);
R=sortrows(R,{'subID','pla'});
L=sortrows(L,{'subID','pla'});
% Make sure basic df is sorted by subID and pla, too
paindf{i}=sortrows(paindf{i},{'subID','pla'});
% Replace summarized variables
paindf{i}{:,vars2avg}=nanmean(cat(3,R{:,vars2avg},L{:,vars2avg}),3);
paindf{i}{:,vars2sum}=nansum(cat(3,R{:,vars2sum},L{:,vars2sum}),3);

% Update Condition name and Stimside
paindf{i}.cond=strcat(paindf{i}.cond,'&L');
paindf{i}.stimside=strcat(paindf{i}.stimside,'&L');


%'bingel11'
i=find(strcmp(studies,'bingel11'));
paindf{i}=[df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')),varselect);
          df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')),varselect)];

%'choi' (Only data from experiment 1 used, since experiment 2 not mentioned in publication)
% >> Testing was performed within participants for a high (100potent) and
% low (1potent) placebo and a control condition. Hi and lo placebo have to
% be averaged.

i=find(strcmp(studies,'choi'));
% First get pure pain effect for 100potent only to get basic data-frame
paindf{i}=[df((strcmp(df.studyID,'choi')&strcmp(df.cond,'Exp1_control_pain_beta3')),varselect);
          df((strcmp(df.studyID,'choi')&strcmp(df.cond,'Exp1_100potent_pain_beta3')),varselect)];

      
% These variables are available for right and left side and have to be averaged of
vars2avg={ 'condSeq','stimInt','rating',...
           'imgsPerBlock','nImages','xSpan',...
           'NPSraw','MHEraw',...%'PPR_pain_raw','PPR_anti_raw','brainPPR_anti_raw',...
           };   
       
vars2sum={'nBlocks'}; %Number of blocks going into the statistic increases with averaging

% Average variables
avgpladata=nanmean(cat(3,df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta3'))),vars2avg},...
                    df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_1potent_pain_beta3'))),vars2avg}),3);
sumpladata=nansum(cat(3,df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta3'))),vars2sum},...
                    df{(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_1potent_pain_beta3'))),vars2sum}),3);
% Replace placebo condition in df
paindf{i}{strcmp(paindf{i}.cond,'Exp1_100potent_pain_beta3'),vars2avg}=avgpladata;
paindf{i}{strcmp(paindf{i}.cond,'Exp1_100potent_pain_beta3'),vars2sum}=sumpladata;

paindf{i}.cond(strcmp(paindf{i}.cond,'Exp1_100potent_pain_beta3'))=repmat({'Exp1_100&1potent_pain'},15,1);
    
%'eippert'
% Pain vector was split into early and late pain >> average
i=find(strcmp(studies,'eippert'));
% First get pure pain effect for late pain only to get basic data-frame
paindf{i}=[df((strcmp(df.studyID,'eippert')&strcmp(df.cond,'pain late: control_saline')),varselect);
           df((strcmp(df.studyID,'eippert')&strcmp(df.cond,'pain late: control_naloxone')),varselect);
          df((strcmp(df.studyID,'eippert')&strcmp(df.cond,'pain late: placebo_saline')),varselect);
          df((strcmp(df.studyID,'eippert')&strcmp(df.cond,'pain late: placebo_naloxone')),varselect)];
% These variables are available for early and late side and have to be averaged
vars2avg={ 'NPSraw','MHEraw',...%'PPR_pain_raw','PPR_anti_raw','brainPPR_anti_raw','xSpan',....
           };  
vars2sum={'imgsPerBlock'};
% Average variables      
avg_earlynlate=mean(cat(3,[df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))),vars2avg};...
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))),vars2avg}
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))),vars2avg};...
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))),vars2avg}],...
                       [df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))),vars2avg};...
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_naloxone'))),vars2avg}
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))),vars2avg};...
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_naloxone'))),vars2avg}]),3);

sum_earlynlate=sum(cat(3,[df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_saline'))),vars2sum};...
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: control_naloxone'))),vars2sum}
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_saline'))),vars2sum};...
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain early: placebo_naloxone'))),vars2sum}],...
                       [df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))),vars2sum};...
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_naloxone'))),vars2sum}
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))),vars2sum};...
                       df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_naloxone'))),vars2sum}]),3);                  
                   
% Replace placebo condition in df
paindf{i}{:,vars2avg}=avg_earlynlate;
paindf{i}{:,vars2sum}=sum_earlynlate;
paindf{i}.cond=regexprep(paindf{i}.cond,'pain(.*): ','pain: ');
paindf{i}.imgsPerBlock=paindf{i}.imgsPerBlock*2;
                   
%'ellingsen'
i=find(strcmp(studies,'ellingsen'));
paindf{i}=[df((strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Painful_touch_control')),varselect);
          df((strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Painful_touch_placebo')),varselect)];

%'elsenbruch'
i=find(strcmp(studies,'elsenbruch'));
paindf{i}=[df((strcmp(df.studyID,'elsenbruch')&strcmp(df.cond,'pain_control_0%_analgesia')),varselect);
          df((strcmp(df.studyID,'elsenbruch')&strcmp(df.cond,'pain_placebo_100%_analgesia')),varselect)];

%'freeman'
i=find(strcmp(studies,'freeman'));
paindf{i}=[df((strcmp(df.studyID,'freeman')&strcmp(df.cond,'pain_post_control_high_pain')),varselect);
          df((strcmp(df.studyID,'freeman')&strcmp(df.cond,'pain_post_placebo_high_pain')),varselect)];

%'geuter'
% Pain vector was split into early and late pain >> average
% Placebo & Control conditions were split into weak and strong version >> average
i=find(strcmp(studies,'geuter'));
% First get pure pain effect for strong_late only to get basic data-frame
paindf{i}=[df((strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong')),varselect);
          df((strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong')),varselect)];
% These variables are available for right and left side and have to be averaged of
vars2avg={'NPSraw','MHEraw',...%'PPR_pain_raw','PPR_anti_raw','brainPPR_anti_raw','xSpan',....
           };
vars2sum={'imgsPerBlock'};
       
% Average variables      
avg_combined=[mean(cat(3,df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain_control_weak'))),vars2avg},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_weak'))),vars2avg},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain_control_strong'))),vars2avg},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_strong'))),vars2avg}),3);
            mean(cat(3,df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain_placebo_weak'))),vars2avg},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_weak'))),vars2avg},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain_placebo_strong'))),vars2avg},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_strong'))),vars2avg}),3)];
sum_combined=[sum(cat(3,df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain_control_weak'))),vars2sum},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_weak'))),vars2sum},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain_control_strong'))),vars2sum},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_strong'))),vars2sum}),3);
            sum(cat(3,df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain_placebo_weak'))),vars2sum},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_weak'))),vars2sum},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'early_pain_placebo_strong'))),vars2sum},...
                       df{(strcmp(df.studyID,'geuter')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_strong'))),vars2sum}),3)];
% Replace placebo condition in df
paindf{i}{:,vars2avg}=avg_combined;
paindf{i}{:,vars2sum}=sum_combined;
paindf{i}.cond=regexprep(paindf{i}.cond,'late_pain','pain');
paindf{i}.cond=regexprep(paindf{i}.cond,'_strong','');
paindf{i}.imgsPerBlock=paindf{i}.imgsPerBlock*2;

%'kessner'
i=find(strcmp(studies,'kessner'));
paindf{i}=[df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg')),varselect);
          df((strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos')),varselect)];
paindf{i}.pla(strcmp(paindf{i}.cond,'pain_placebo_neg'))=0; %Assign group-level control condition explicitly.

%'kong06'
i=find(strcmp(studies,'kong06'));
paindf{i}=[df((strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')),varselect);
          df((strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')),varselect)];

%'kong09'
i=find(strcmp(studies,'kong09'));
paindf{i}=[df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control')),varselect);
          df((strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo')),varselect)];

%'lui'
i=find(strcmp(studies,'lui'));
paindf{i}=[df((strcmp(df.studyID,'lui')&strcmp(df.cond,'pain_control')),varselect);
          df((strcmp(df.studyID,'lui')&strcmp(df.cond,'pain_placebo')),varselect)];


%'ruetgen'
i=find(strcmp(studies,'ruetgen'));
paindf{i}=[df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')),varselect);
          df((strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')),varselect)];

%'schenk'
% Testing was performed under no-lidocaine and lidocaine conditions >> average
% Placebo & Control conditions were split into weak and strong version >> average
i=find(strcmp(studies,'schenk'));
% First get pure pain effect for strong_late only to get basic data-frame
paindf{i}=[df((strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_control')),varselect);
          df((strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_placebo')),varselect)];
% These variables are available for lidocaine and nolidocaine and have to be averaged of
vars2avg={'NPSraw','MHEraw',...%'PPR_pain_raw','PPR_anti_raw','brainPPR_anti_raw','xSpan',....
           };
vars2sum={'imgsPerBlock'};
% Average variables
avg_combined=[mean(cat(3,df{(strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_nolidocaine_control'))),vars2avg},...
                       df{(strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_lidocaine_control'))),vars2avg}),3);
          mean(cat(3,df{(strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_nolidocaine_placebo'))),vars2avg},...
                       df{(strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_lidocaine_placebo'))),vars2avg}),3)];
sum_combined=[sum(cat(3,df{(strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_nolidocaine_control'))),vars2sum},...
                       df{(strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_lidocaine_control'))),vars2sum}),3);
          sum(cat(3,df{(strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_nolidocaine_placebo'))),vars2sum},...
                       df{(strcmp(df.studyID,'schenk')&~cellfun(@isempty,regexp(df.cond,'pain_lidocaine_placebo'))),vars2sum}),3)];
% Replace placebo condition in df
paindf{i}{:,vars2avg}=avg_combined;
paindf{i}{:,vars2sum}=sum_combined;
paindf{i}.cond=regexprep(paindf{i}.cond,'nolidocaine_','');

        
%'theysohn'
i=find(strcmp(studies,'theysohn'));
paindf{i}=[df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain')),varselect);
          df((strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain')),varselect)];

% %'wager04a_princeton (study 1): ONLY CONTRASTS AVAILABLE'
% % contrasts are Con>Pla, therefore INVERSE ALL VARIABLES: *(-1)
% i=find(strcmp(studies,'wager04a_princeton')); 
% df_full.pladata{i}=(-1)*df{(strcmp(df.studyID,'wager04a_princeton')&strcmp(df.cond,'(intense-none)control-placebo')),varselect};
% df_full.condata{i}=NaN(size(df_full.pladata{i}));
%'wager04b_michigan':  FOR  RATINGS ONLY CONTRAST CONTROL-PLACEBO AVAILABLE
% contrasts are Con>Pla, therefore INVERSE RATNGS: *(-1)

i=find(strcmp(studies,'wager04b_michigan'));
paindf{i}=[df((strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'control_pain')),varselect);
          df((strcmp(df.studyID,'wager04b_michigan')&strcmp(df.cond,'placebo_pain')),varselect)];
paindf{i}.rating=NaN(size(paindf{i}.rating)); %FOR  RATINGS ONLY CONTRAST CONTROL-PLACEBO AVAILABLE

%'wrobel'
% Pain vector was split into early and late pain >> average
i=find(strcmp(studies,'wrobel'));
% First get pure pain effect for late pain only to get basic data-frame
paindf{i}=[df((strcmp(df.studyID,'wrobel')&strcmp(df.cond,'late_pain_control_saline')),varselect);
           df((strcmp(df.studyID,'wrobel')&strcmp(df.cond,'late_pain_control_haldol')),varselect);
          df((strcmp(df.studyID,'wrobel')&strcmp(df.cond,'late_pain_placebo_saline')),varselect);
          df((strcmp(df.studyID,'wrobel')&strcmp(df.cond,'late_pain_placebo_haldol')),varselect)];
% These variables are available for right and left side and have to be averaged of
vars2avg={ 'NPSraw','MHEraw',...%'PPR_pain_raw','PPR_anti_raw','brainPPR_anti_raw','xSpan',....
           };
vars2sum={'imgsPerBlock'};
% Average variables      
avg_earlynlate=mean(cat(3,[df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_control_saline'))),vars2avg};...
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_control_haldol'))),vars2avg}
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_placebo_saline'))),vars2avg};...
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_placebo_haldol'))),vars2avg}],...
                       [df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_saline'))),vars2avg};...
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_haldol'))),vars2avg}
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_saline'))),vars2avg};...
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_haldol'))),vars2avg}]),3);
                   
sum_earlynlate=sum(cat(3,[df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_control_saline'))),vars2sum};...
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_control_haldol'))),vars2sum}
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_placebo_saline'))),vars2sum};...
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'early_pain_placebo_haldol'))),vars2sum}],...
                       [df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_saline'))),vars2sum};...
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_control_haldol'))),vars2sum}
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_saline'))),vars2sum};...
                       df{(strcmp(df.studyID,'wrobel')&~cellfun(@isempty,regexp(df.cond,'late_pain_placebo_haldol'))),vars2sum}]),3);
% Replace placebo condition in df
paindf{i}{:,vars2avg}=avg_earlynlate;
paindf{i}{:,vars2sum}=sum_earlynlate;
paindf{i}.cond=regexprep(paindf{i}.cond,'late_pain_','pain_');
paindf{i}.imgsPerBlock=paindf{i}.imgsPerBlock*2;

%'zeidan'
% i=find(strcmp(studies,'zeidan'));
% df_full.pladata{i}=df{(strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pla>Control within painful series')),varselect};
% df_full.condata{i}=NaN(size(df_full.pladata{i}));

dflong=vertcat(paindf{:});

%% Make all continous variables double precision for mixed model analysis

% Only way that matlab lets me change precision...
dflong.rating=double(dflong.rating);
%% Add study/variable descriptions needed for meta-analysis
save('G_dflong.mat','dflong');
