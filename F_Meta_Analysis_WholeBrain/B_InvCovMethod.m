clear

% Setup: Load df with paths and variables
datapath='/Volumes/Transcend/Boulder_Essen/Datasets/';
tic
load(fullfile(datapath,'dfMaskedBasicImg.mat'));
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/E_Meta_Analysis_SPM')


studies=unique(df.studyID);   %Get all studies in df

%% Step 1: calculate a table of by-study statistics using the standard meta-analysis functions
%Basic

% Atlas
iplacebo_pain=(strcmp(df.studyID,'atlas')&strcmp(df.cond,'StimHiPain_Open_Stimulation'));
iplacebo_expect=(strcmp(df.studyID,'atlas')&strcmp(df.cond,'StimHiPain_Open_ExpectationPeriod'));
icontrol_pain=(strcmp(df.studyID,'atlas')&strcmp(df.cond,'StimHiPain_Hidden_Stimulation'));
icontrol_expect=(strcmp(df.studyID,'atlas')&strcmp(df.cond,'StimHiPain_Hidden_ExpectationPeriod'));
i=find(strcmp(studies,'atlas'));
stats(i)=withinMetastats(Y(iplacebo_pain,:)+Y(iplacebo_expect,:),Y(icontrol_pain,:)+Y(icontrol_expect,:));
%Bingel06
% (two participants were measured right side only in placebo condition...)

% Get participant names
bingelsubs=unique(df.subID(strcmp(df.studyID,'bingel')));
icontrol_R=zeros(height(df),length(bingelsubs));
iplacebo_R=zeros(height(df),length(bingelsubs));
icontrol_L=zeros(height(df),length(bingelsubs));
iplacebo_L=zeros(height(df),length(bingelsubs));
% Get matching indices of every participant for every condition, missing conditions== a columns of zeros
for i=1:length(bingelsubs)
    icontrol_R(:,i)=(strcmp(df.subID,bingelsubs(i))&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_R')));
    iplacebo_R(:,i)=(strcmp(df.subID,bingelsubs(i))&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_R')));
    icontrol_L(:,i)=(strcmp(df.subID,bingelsubs(i))&~cellfun(@isempty,regexp(df.cond,'con_painNoPlacebo_L')));
    iplacebo_L(:,i)=(strcmp(df.subID,bingelsubs(i))&~cellfun(@isempty,regexp(df.cond,'con_painPlacebo_L')));
end
% Mean left and right side
control=zeros(length(bingelsubs),length(Y));
placebo=zeros(length(bingelsubs),length(Y));
for i=1:length(bingelsubs)
  yrawconR=Y(logical(icontrol_R(:,i)),:);
  yrawconL=Y(logical(icontrol_L(:,i)),:);
  yrawplaR=Y(logical(iplacebo_R(:,i)),:);
  yrawplaL=Y(logical(iplacebo_L(:,i)),:);
 control(i,:)=mean([yrawconR;yrawconL],1);
 placebo(i,:)=mean([yrawplaR;yrawplaL],1);
end

i=find(strcmp(studies,'bingel'));
stats(i)=withinMetastats(placebo,control);

%Bingel11
icontrol=(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp'));
iplacebo=(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp'));
i=find(strcmp(studies,'bingel11'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Choi
icontrol=(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*')));
iplacebo=(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*')));
i=find(strcmp(studies,'choi'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Eippert
iplacebo=(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline')));
icontrol=(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline')));
i=find(strcmp(studies,'eippert'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Ellingsen
icontrol=(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control')));
iplacebo=(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo')));
i=find(strcmp(studies,'ellingsen'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Elsenbruch
icontrol=(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia')));
iplacebo=(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia')));
i=find(strcmp(studies,'elsenbruch'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Freeman
icontrol=(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain')));
iplacebo=(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain')));
i=find(strcmp(studies,'freeman'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Geuter
icontrol=(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong'));
iplacebo=(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong'));
i=find(strcmp(studies,'geuter'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Huber
icontrol=(strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl'));
iplacebo=(strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo'));
i=find(strcmp(studies,'huber'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Kessner
% icontrol=(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg'));
% iplacebo=(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos'));
% i=find(strcmp(studies,'kessner'));
% stats(i)=betweenMetastats(Y(iplacebo,:),Y(icontrol,:));

%Kong06
icontrol=(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain'));
iplacebo=(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain'));
i=find(strcmp(studies,'kong06'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Kong09
icontrol=(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control'));
iplacebo=(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo'));
i=find(strcmp(studies,'kong09'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Ruetgen
% iplacebo=(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group'));
% icontrol=(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group'));
% i=find(strcmp(studies,'ruetgen'));
% stats(i)=betweenMetastats(Y(iplacebo,:),Y(icontrol,:));

%Schenk
iplacebo=(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_placebo'));
icontrol=(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_control'));
i=find(strcmp(studies,'schenk'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Theyson
iplacebo=(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain'));
icontrol=(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain'));
i=find(strcmp(studies,'theysohn'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

%Wager_michigan
iplacebo=(strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'placebo_pain'));
icontrol=(strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'control_pain'));
i=find(strcmp(studies,'wager_michigan'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

% Hmm here only contrast available... (strcmp(df.studyID,'wager_princeton')&strcmp(df.cond,'(intense-none)control-placebo'))
%Wrobel
iplacebo=(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline')));
icontrol=(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline')));
i=find(strcmp(studies,'wrobel'));
stats(i)=withinMetastats(Y(iplacebo,:),Y(icontrol,:));

% Hmm here only contrast available, too...(strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pla>Control within painful series'))
toc

%% Calculate summary statistics
summary_stat=vertcat(stats.g);% Currently uses Hedge's g
se_summary_stat=vertcat(stats.se_g); % Currently uses Hedge's g
n=vertcat(stats.n);
type='random';
[summary.g,summary.SE,summary.rel_weight,summary.z,summary.p,summary.CI_lo,summary.CI_hi,summary.chisq,summary.tausq,summary.df,summary.p_het,summary.Isq]=GIVsummary(summary_stat,se_summary_stat,type);

%% Save results
%save ByStudyStats.mat stats summary -v7.3
summary.sig_g=zeros(size(summary.g));
summary.sig_g(summary.p<0.001)=summary.g(summary.p<0.001);

%% Diagnostics

% g=vertcat(stats.g);
% for i=1:length(studies)
% y=[mean(g(i,:),2),std(g(i,:),[],2)];
% X=[mean(g,2),std(g,[],2)];
% d(i) = mahal(y,X);
% end
%% Plot summary image
printImage(summary.sig_g,'GIV_sig_g_placebo')

%% summary image by study
for i=1:length(studies)
try
printImage(stats(i).g,studies{i})
catch
end
end
