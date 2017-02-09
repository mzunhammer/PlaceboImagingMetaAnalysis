%% Meta-Analysis & Forest Plot

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
datapath='../../Datasets';

load(fullfile(datapath,'AllData.mat'))

studies={'bingel'
         'lui'};

studyIDtexts={
 			'Bingel et al. 2006: left vs right hand (within-subject) | laser';...
            'Lui et al. 2010: left vs right foot (between-subject) | laser';...
             };

%% Select data STUDIES

%'bingel'
left_pain_control=df((strcmp(df.studyID,'bingel')&...
        ~cellfun(@isempty,regexp(df.cond,'painNoPlacebo'))&...
        strcmp(df.stimside,'L')),:);
right_pain_control=df((strcmp(df.studyID,'bingel')&...
        ~cellfun(@isempty,regexp(df.cond,'painNoPlacebo'))&...
        strcmp(df.stimside,'R')),:);
left_pain_placebo=df((strcmp(df.studyID,'bingel')&...
        ~cellfun(@isempty,regexp(df.cond,'painPlacebo'))&...
        strcmp(df.stimside,'L')),:);
right_pain_placebo=df((strcmp(df.studyID,'bingel')&...
        ~cellfun(@isempty,regexp(df.cond,'painPlacebo'))&...
        strcmp(df.stimside,'R')),:);

left_pain_control=sortrows(left_pain_control,'subID');
right_pain_control=sortrows(right_pain_control,'subID');
left_pain_placebo=sortrows(left_pain_placebo,'subID');
right_pain_placebo=sortrows(right_pain_placebo,'subID');

if ~all(strcmp(left_pain_control.subID,left_pain_placebo.subID))|...
   ~all(strcmp(right_pain_control.subID,right_pain_placebo.subID))
    
    'Subjects not matching for Bingel et al.'
    return
end

left=nanmean([left_pain_control.NPSraw,left_pain_placebo.NPSraw],2);
right=nanmean([right_pain_control.NPSraw,right_pain_placebo.NPSraw],2);

i=find(strcmp(studies,'bingel'));
stats(i)=withinMetastats(left,right);

% 'lui'
% Participants received laser stimulation EITHER at the left OR the right
% foot >> between subject design

left_pain_control=df((strcmp(df.studyID,'lui')&...
        ~cellfun(@isempty,regexp(df.cond,'pain_control'))&...
        strcmp(df.stimside,'L')),:);
right_pain_control=df((strcmp(df.studyID,'lui')&...
        ~cellfun(@isempty,regexp(df.cond,'pain_control'))&...
        strcmp(df.stimside,'R')),:);
left_pain_placebo=df((strcmp(df.studyID,'lui')&...
        ~cellfun(@isempty,regexp(df.cond,'pain_placebo'))&...
        strcmp(df.stimside,'L')),:);
right_pain_placebo=df((strcmp(df.studyID,'lui')&...
        ~cellfun(@isempty,regexp(df.cond,'pain_placebo'))&...
        strcmp(df.stimside,'R')),:);

left_pain_control=sortrows(left_pain_control,'subID');
right_pain_control=sortrows(right_pain_control,'subID');
left_pain_placebo=sortrows(left_pain_placebo,'subID');
right_pain_placebo=sortrows(right_pain_placebo,'subID');

if ~all(strcmp(left_pain_control.subID,left_pain_placebo.subID))|...
   ~all(strcmp(right_pain_control.subID,right_pain_placebo.subID))
    
    'Subjects not matching for Bingel et al.'
    return
end

left=nanmean([left_pain_control.NPSraw,left_pain_placebo.NPSraw],2);
right=nanmean([right_pain_control.NPSraw,right_pain_placebo.NPSraw],2);

i=find(strcmp(studies,'lui'));
stats(i)=betweenMetastats(left,right);
%% Summarize all studies, weigh by SE
% Summary analysis+ Forest Plot
ForestPlotter(stats,...
              'studyIDtexts',studyIDtexts,...
              'outcomelabel','NPS-Response (Hedge''s {\itg})',...
              'type','random',...
              'summarystat','g',...
              'withoutlier',1,...
              'WIsubdata',0,...
              'NOsummary',0,...
              'textoffset',0.1,...
              'boxscaling',1);
          
hgexport(gcf, 'F1_NPS_left_vs_right.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '../../Protocol_and_Manuscript/NPS_validation/Figures/Figure7', hgexport('factorystyle'), 'Format', 'svg');

close all;