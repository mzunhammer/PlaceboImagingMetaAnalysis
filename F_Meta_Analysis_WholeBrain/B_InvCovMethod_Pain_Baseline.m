clear

% Setup: Load df with paths and variables
datapath='/Volumes/Transcend/Boulder_Essen/Datasets/';
tic
load(fullfile(datapath,'dfMaskedBasicImg.mat'));
addpath('../A_Analysis_GIV_Functions/')
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/E_Meta_Analysis_SPM')
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/MontagePlot')


studies=unique(df.studyID);   %Get all studies in df

%% Step 1: calculate a table of by-study statistics using the standard meta-analysis functions
%Basic

% Atlas
iplacebo_pain=(strcmp(df.studyID,'atlas')&strcmp(df.cond,'StimHiPain_Open_Stimulation'));
icontrol_pain=(strcmp(df.studyID,'atlas')&strcmp(df.cond,'StimHiPain_Hidden_Stimulation'));
meanpain = nanmean(cat(3,Y(iplacebo_pain,:),Y(icontrol_pain,:)),3);
i=find(strcmp(studies,'atlas'));
stats(i)=withinMetastats(meanpain,0);
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
meanpain = nanmean(cat(3,control,placebo),3);
i=find(strcmp(studies,'bingel'));
stats(i)=withinMetastats(meanpain,0);

%Bingel11
icontrol=(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_no_exp'));
iplacebo=(strcmp(df.studyID,'bingel11')&strcmp(df.cond,'pain_remi_pos_exp'));
i=find(strcmp(studies,'bingel11'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Choi
icontrol=(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_control_pain_beta.*')));
iplacebo=(strcmp(df.studyID,'choi')&~cellfun(@isempty,regexp(df.cond,'Exp1_100potent_pain_beta.*')));
i=find(strcmp(studies,'choi'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Eippert
iplacebo=(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: placebo_saline')));
icontrol=(strcmp(df.studyID,'eippert')&~cellfun(@isempty,regexp(df.cond,'pain late: control_saline')));
i=find(strcmp(studies,'eippert'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Ellingsen
icontrol=(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_control')));
iplacebo=(strcmp(df.studyID,'ellingsen')&~cellfun(@isempty,regexp(df.cond,'Painful_touch_placebo')));
i=find(strcmp(studies,'ellingsen'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Elsenbruch
icontrol=(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_placebo_0%_analgesia')));
iplacebo=(strcmp(df.studyID,'elsenbruch')&~cellfun(@isempty,regexp(df.cond,'pain_control_100%_analgesia')));
i=find(strcmp(studies,'elsenbruch'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Freeman
icontrol=(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_control_high_pain')));
iplacebo=(strcmp(df.studyID,'freeman')&~cellfun(@isempty,regexp(df.cond,'pain_post_placebo_high_pain')));
i=find(strcmp(studies,'freeman'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Geuter
icontrol=(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_control_strong'));
iplacebo=(strcmp(df.studyID,'geuter')&strcmp(df.cond,'late_pain_placebo_strong'));
i=find(strcmp(studies,'geuter'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Huber
icontrol=(strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainControl'));
iplacebo=(strcmp(df.studyID,'huber')&strcmp(df.cond,'conPainPlacebo'));
i=find(strcmp(studies,'huber'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Kessner
icontrol=(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_neg'));
iplacebo=(strcmp(df.studyID,'kessner')&strcmp(df.cond,'pain_placebo_pos'));
i=find(strcmp(studies,'kessner'));
stats(i)=withinMetastats([Y(icontrol,:);Y(iplacebo,:)],0); 

%Kong06
icontrol=(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_control_high_pain'));
iplacebo=(strcmp(df.studyID,'kong06')&strcmp(df.cond,'pain_post_placebo_high_pain'));
i=find(strcmp(studies,'kong06'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Kong09
icontrol=(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_control'));
iplacebo=(strcmp(df.studyID,'kong09')&strcmp(df.cond,'pain_post_placebo'));
i=find(strcmp(studies,'kong09'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Ruetgen
iplacebo=(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Placebo_Group'));
icontrol=(strcmp(df.studyID,'ruetgen')&strcmp(df.cond,'Self_Pain_Control_Group'));
i=find(strcmp(studies,'ruetgen'));
stats(i)=withinMetastats([Y(icontrol,:);Y(iplacebo,:)],0); 

%Schenk
iplacebo=(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_placebo'));
icontrol=(strcmp(df.studyID,'schenk')&strcmp(df.cond,'pain_nolidocain_control'));
i=find(strcmp(studies,'schenk'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Theyson
iplacebo=(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'placebo_pain'));
icontrol=(strcmp(df.studyID,'theysohn')&strcmp(df.cond,'control_pain'));
i=find(strcmp(studies,'theysohn'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Wager_michigan
iplacebo=(strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'placebo_pain'));
icontrol=(strcmp(df.studyID,'wager_michigan')&strcmp(df.cond,'control_pain'));
i=find(strcmp(studies,'wager_michigan'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Wager_princeton 
ipain=(strcmp(df.studyID,'wager_princeton')&strcmp(df.cond,'intense-none'));
i=find(strcmp(studies,'wager_princeton'));
% WARNING: Imputed within-subject correlation... mean correlation from all
% other studies
stats(i)=withinMetastats(Y(ipain,:),0); 

%Wrobel
iplacebo=(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_placebo_saline')));
icontrol=(strcmp(df.studyID,'wrobel')&(strcmp(df.cond,'late_pain_control_saline')));
i=find(strcmp(studies,'wrobel'));
meanpain = nanmean(cat(3,Y(icontrol,:),Y(iplacebo,:)),3);
stats(i)=withinMetastats(meanpain,0); 

%Zeidan
% WARNING: Imputed within-subject correlation... mean correlation from all
% other studies

iplacebo=(strcmp(df.studyID,'zeidan')&strcmp(df.cond,'Pain>NoPain controlling for placebo&interaction'));
i=find(strcmp(studies,'zeidan'));
% WARNING: Imputed within-subject correlation... mean correlation from all
% other studies
stats(i)=withinMetastats(Y(ipain,:),0); 


toc

%% Calculate summary statistics
summary_stat=vertcat(stats.g);% Currently uses Hedge's g
se_summary_stat=vertcat(stats.se_g); % Currently uses Hedge's g
n=vertcat(stats.n);
type='random';
[summary.g,summary.SE,summary.rel_weight,summary.z,summary.p,summary.CI_lo,summary.CI_hi,summary.chisq,summary.tausq,summary.df,summary.p_het,summary.Isq]=GIVsummary(summary_stat,se_summary_stat,type);

%% Threshold results
%save ByStudyStats.mat stats summary -v7.3
summary.sig_g=zeros(size(summary.g));
[p_fdr_para,p_fdr_nonpara]=FDR(summary.p,0.05); %FDR correction
summary.sig_g(summary.p<p_fdr_para)=summary.g(summary.p<p_fdr_para);


%% Diagnostics

% g=vertcat(stats.g);
% for i=1:length(studies)
% y=[mean(g(i,:),2),std(g(i,:),[],2)];
% X=[mean(g,2),std(g,[],2)];
% d(i) = mahal(y,X);
% end
%% Plot summary image
printImage(summary.sig_g,'GIV_sig_g_pain')
printImage(summary.g,'GIV_g_pain')
printImage(summary.df/(max(summary.df)),'GIV_n_pain')
printImage(summary.SE,'GIV_SE_pain')

%% summary image by study
for i=1:length(studies)
    try
    printImage(stats(i).g,[studies{i},'_pain'])
    %printImage_unmasked(stats(i).g,[studies{i},'_pain_unmasked'])
    catch
    end
end

%% Plot summary image .tiff orthview
t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/avg152T1.nii';
%t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/single_subj_T1.nii';

outfile='montage_GIV_sig_g_pain_pos_neg'
[~,fname,~]=fileparts(outfile);
plot_nii_results(t,...
                 'overlays',{'GIV_sig_g_pain_neg.nii','GIV_sig_g_pain_pos.nii'},... %Cell array of overlay volumes
                 'ov_color',{fliplr(hot),hot},... %Cell array of overlay colors (RGB)
                 'ov_transparency',[0.6],...
                 'slices',[0,0,0],... %Cell array of slices (MNI)
                 'slice_ori',[1,2,3],...
                 'background',0,...
                 'outfilename',['montage_',fname]); %Scalar or array designating slice orientation (x=1,y=2,z=3)
%%
t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/avg152T1.nii';
%t='/Users/matthiaszunhammer/Documents/MATLAB/spm8/canonical/single_subj_T1.nii';

outfile='montage_GIV_g_pain_pos_neg'
[~,fname,~]=fileparts(outfile);
plot_nii_results(t,...
                 'overlays',{'GIV_g_pain_neg.nii','GIV_g_pain_pos.nii'},... %Cell array of overlay volumes
                 'ov_color',{fliplr(hot),hot},... %Cell array of overlay colors (RGB)
                 'ov_transparency',[0.6],...
                 'slices',[0,0,0],... %Cell array of slices (MNI)
                 'slice_ori',[1,2,3],...
                 'background',0,...
                 'outfilename',['montage_',fname]); %Scalar or array designating slice orientation (x=1,y=2,z=3)

