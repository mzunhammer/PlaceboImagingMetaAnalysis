%% Meta-Analysis & Forest Plot
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
datapath='../../Datasets';

load(fullfile(datapath,'AllData_w_NPS_MHE_NOBRAIN.mat'))

studies=unique(df.studyID);   %Get all studies in df
% !!!!! These must be in the same order as listed under "studies" !!!!
studies=studies([1,6,6,8,12,13,14,17]); % Duplicate Ellingsen
studies(2)={[studies{2},'_warm']}; % Duplicate Ellingsen
studies(3)={[studies{3},'_brush']}; % Duplicate Ellingsen
% studyIDtexts={
%             'Atlas et al. 2012: High (VAS 100%, ?47.1?C) vs low (VAS 25%, 41.2?C) heat';...
%             'Ellingsen et al. 2013: Painful hot (VAS 50%, ?47.1?C) vs warm touch (VAS 0%, ~42.5?C)';...
%             'Ellingsen et al. 2013: Painful hot (VAS 50%, ?47.1?C) vs brushstroke (VAS 0%)';...
%             'Freeman et al. 2015: High (VAS 55%) vs low (???) heat (post placebo)';...
%             'Kong et al. 2006: High (VAS ???) vs low (???) heat (post placebo)';...
%             'Kong et al. 2009: High (VAS ???) vs low (???) heat (post placebo)';...
%             'Ruetgen et al. 2015: High (VAS 83%, 0.74mA) vs non-painful (VAS 0%, 0.16 mA), electrical shocks'
%             'Wager et al. 2004, Study 1: Stong (3.75 mA) vs mild (1.44 mA) electrical shock';...
%             };
studyIDtexts={
            'Atlas et al. 2012: Mild heat vs baseline';...
            'Ellingsen et al. 2013: Warm touch vs baseline';...
            'Ellingsen et al. 2013: Brushstroke vs baseline';...
            'Freeman et al. 2015: Mild heat vs baseline';...
            'Kong et al. 2006: Mild heat vs baseline';...
            'Kong et al. 2009: Mild heat vs baseline';...
            'Ruetgen et al. 2015: Mild electrical shocks vs baseline'
            'Wager et al. 2004, Study 1: Mild electrical shock vs baseline';...
            };
% studyIDtexts={
%             'Atlas et al. 2012:';...
%             'Ellingsen et al. 2013: (warmth)';...
%             'Ellingsen et al. 2013: (brushstroke)';...
%             'Freeman et al. 2015:';...
%             'Kong et al. 2006:';...
%             'Kong et al. 2009:';...
%             'Ruetgen et al. 2015:'
%             'Wager et al. 2004, Study 1:';...
%             };
			
        % The asteriks "*" indicates that for these data-sets only rating
        % contrasts were available. Therefore standardized effect sizes (d
        % and hedges g) were imputed using the mean average within-subject
        % correlation for ratings in all other studies, which was: 0.5143
        % (obtained by running the code below with replacing all imputed r's with NaN for all withinMetastats functions, then nanmean([stats.r]))
%% Select data STUDIES

%'Atlas'
hi_pain=mean(...
        [df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Open_Stimulation'))),'NPSraw'},...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimHiPain_Hidden_Stimulation'))),'NPSraw'}],...
        2);
lo_pain=mean(...
        [df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimLoPain_Open_Stimulation'))),'NPSraw'},...
        df{(strcmp(df.studyID,'atlas')&~cellfun(@isempty,regexp(df.cond,'StimLoPain_Hidden_Stimulation'))),'NPSraw'}],...
        2);
i=find(strcmp(studies,'atlas'));
stats(i)=withinMetastats(lo_pain,0);

%'Ellingsen Heat vs Warm'
hi_pain=mean(...
        [df{(strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Painful_touch_placebo')),'NPSraw'},...
         df{(strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Painful_touch_control')),'NPSraw'}],...
        2);
lo_pain=mean(...
        [df{(strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Warm_touch_placebo')),'NPSraw'},...
         df{(strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Warm_touch_control')),'NPSraw'}],...
        2);

i=find(strcmp(studies,'ellingsen_warm'));
stats(i)=withinMetastats(lo_pain,0);

%'Ellingsen Heat vs Brushstroke'
hi_pain=mean(...
        [df{(strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Painful_touch_placebo')),'NPSraw'},...
         df{(strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Painful_touch_control')),'NPSraw'}],...
        2);
lo_pain=mean(...
        [df{(strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Brushstroke_placebo')),'NPSraw'},...
         df{(strcmp(df.studyID,'ellingsen')&strcmp(df.cond,'Brushstroke_control')),'NPSraw'}],...
        2);

i=find(strcmp(studies,'ellingsen_brush'));
stats(i)=withinMetastats(lo_pain,0);

%'Freeman High vs Lowpain'
hi_vs_lowPain= df{(strcmp(df.studyID,'freeman')&strcmp(df.cond,'post-HighpainVsLowpain')),'NPSraw'};
i=find(strcmp(studies,'freeman'));
stats(i)=withinMetastats(NaN,0);

%'Kong06 Heat vs Warm'
hi_pain=mean(...
        [df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_pre_control_high_pain')),'NPSraw'},...
         df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_pre_placebo_high_pain')),'NPSraw'},...
         df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain')),'NPSraw'},...
         df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain')),'NPSraw'}],...
        2);
lo_pain=mean(...
        [df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_pre_control_low_pain')),'NPSraw'},...
         df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_pre_placebo_low_pain')),'NPSraw'},...
         df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_low_pain')),'NPSraw'},...
         df{(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_low_pain')),'NPSraw'}],...
        2);

i=find(strcmp(studies,'kong06'));
stats(i)=withinMetastats(lo_pain,0);

%'Kong09 High vs Lowpain'
hiPain_vs_lowPain= df{(strcmp(df.studyID,'kong09')&strcmp(df.cond,'allHighpainVSLowPain')),'NPSraw'};
i=find(strcmp(studies,'kong09'));
stats(i)=withinMetastats(NaN,0);

%'R?tgen Hi vs Low shock'
hi_pain=[df{(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group')),'NPSraw'};...
         df{(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group')),'NPSraw'}];
lo_pain=[df{(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_NoPain_Control_Group')),'NPSraw'};...
         df{(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_NoPain_Placebo_Group')),'NPSraw'}];

i=find(strcmp(studies,'ruetgen'));
stats(i)=withinMetastats(lo_pain,0);

%'wager_princeton High vs Lowpain'
hi_vs_lowPain= df{(strcmp(df.studyID,'wager04a_princeton')&strcmp(df.cond,'intense-mild')),'NPSraw'};
i=find(strcmp(studies,'wager04a_princeton'));
stats(i)=withinMetastats(NaN,0);


%% Summarize all studies, weigh by SE
% Summary analysis+ Forest Plot
ForestPlotter(stats,...
              'studyIDtexts',studyIDtexts,...
              'outcomelabel','NPS-Response (Hedge''s g)',...
              'type','random',...
              'summarystat','g',...
              'textoffset',0.1,...
              'withoutlier',0,...
              'WIsubdata',1,...
              'boxscaling',1);
          
hgexport(gcf, 'F1_NPS_lo_vs_no_pain_all.svg', hgexport('factorystyle'), 'Format', 'svg'); 
NPS_pos_imgs=vertcat(stats.delta)>0;
perc_pos_NPS=sum(NPS_pos_imgs)/sum(~isnan(NPS_pos_imgs));

disp([num2str(perc_pos_NPS*100),'% of participants showed a positive NPS response.'])