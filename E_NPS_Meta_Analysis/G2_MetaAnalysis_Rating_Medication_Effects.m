%% Meta-Analysis & Forest Plot

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
datapath='../../Datasets';

load(fullfile(datapath,'AllData_w_NPS_MHE_NOBRAIN.mat'))

studies=unique(df.studyID);   %Get all studies in df
% !!!!! These must be in the same order as listed under "studies" !!!!
studies=studies([1,3,5,15,19]);

% studyIDtexts={
%             'Atlas et al. 2012: Remifentanil (~0.884ng/ml) vs saline infusion (across open & hidden)|heat';...
% 			'Bingel et al. 2011: Remifentanil (~0.8ng/ml) vs saline infusion (baseline vs open & hidden)|heat';...
% 			'Eippert et al. 2009: Naloxone vs saline infusion|heat (late)';...
%             'Schenk et al. 2015:  Lidocain vs control cream | heat'
%             'Wrobel et al. 2014: Haloperidol vs saline pill cream|heat (late)'
%             };

studyIDtexts={
            'Atlas et al. 2012: Remifentanil vs salinet infusion';...
			'Bingel et al. 2011: Remifentanil vs saline infusion';...
			'Eippert et al. 2009: Naloxone vs saline infusion';...
            'Schenk et al. 2015:  Lidocain vs control cream'
            'Wrobel et al. 2014: Haloperidol vs saline pill'
            };

        % The asteriks "*" indicates that for these data-sets only rating
        % contrasts were available. Therefore standardized effect sizes (d
        % and hedges g) were imputed using the mean average within-subject
        % correlation for ratings in all other studies, which was: 0.5143
        % (obtained by running the code below with replacing all imputed r's with NaN for all withinMetastats functions, then nanmean([stats.r]))
%% Select data STUDIES

%'Atlas'
%?Pain Placebo NoRemi"      = HiPain Open Stimulation + HiPain Open ExpectationPeriod
%?Pain Placebo Remi"           = HiPain Open Stimulation + HiPain Open ExpectationPeriod + HiPain Open RemiConz
%?Pain NoPlacebo NoRemi"  = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod
%?Pain NoPlacebo Remi"       = HiPain Hidden Stimulation + HiPain Hidden ExpectationPeriod + HiPain Open RemiConz

% Effect of remi vs no-remi corresponds to estimated mean plateau effect of
% 0.043 micro-g/kg/min (individual) OR 0.884 ng/ml (absolute)
% across hidden and open administration periods

baseline=mean(...
        [df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),'rating'},...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),'rating'}],...
        2);
remi=mean(...
        [df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),'rating'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_RemiConz'))),'rating'},...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),'rating'}+...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_RemiConz'))),'rating'}],...
        2);
i=find(strcmp(studies,'atlas'));
stats(i)=withinMetastats(remi,baseline);

%'bingel11'
baseline=df((strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_baseline')),'rating');
remi=mean(...
        [df{(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_neg_exp')),'rating'},...
         df{(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp')),'rating'},...
         df{(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp')),'rating'}],...
        2);
i=find(strcmp(studies,'bingel11'));
stats(i)=withinMetastats(remi,baseline);

%'eippert'
baseline_subID=df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))),'subID'};
naloxone_subID=df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_naloxone'))),'subID'};

baseline=mean(...
        [df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline'))),'rating'},...
         df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline'))),'rating'}],...
        2);
naloxone=mean(...
        [df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_naloxone'))),'rating'},...
         df{(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_naloxone'))),'rating'}],...
        2);
i=find(strcmp(studies,'eippert'));
stats(i)=betweenMetastats(naloxone,baseline);

%'Schenk'
baseline=mean(...
        [df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_control')),'rating'},...
         df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocaine_placebo')),'rating'}],...
        2);
lidocain=mean(...
        [df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_control')),'rating'},...
         df{(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_lidocaine_placebo')),'rating'}],...
        2);

i=find(strcmp(studies,'schenk'));
stats(i)=withinMetastats(lidocain,baseline);

%'wrobel'
baseline=mean(...
        [df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline'))),'rating'},...
         df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline'))),'rating'}],...
        2);
haldol=mean(...
        [df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_haldol'))),'rating'},...
         df{(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_haldol'))),'rating'}],...
        2);
i=find(strcmp(studies,'wrobel'));
stats(i)=betweenMetastats(haldol,baseline);

%% Summarize all studies, weigh by SE
% Summary analysis+ Forest Plot
ForestPlotter(stats,...
              'studyIDtexts',studyIDtexts,...
              'outcomelabel','Pain Rating (Hedge''s g)',...
              'type','random',...
              'summarystat','g',...
              'NOsummary',1,...
              'textoffset',0.1,...
              'boxscaling',1,...
              'withoutlier',0,...
              'WIsubdata',1);
hgexport(gcf, 'G2_Rating_Meta_Drugs.eps', hgexport('factorystyle'), 'Format', 'eps'); 
