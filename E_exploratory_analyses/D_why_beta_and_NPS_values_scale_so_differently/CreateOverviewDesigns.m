% Overview on of all study designs
% Script graphs all block parameters provided by the respective paper 
% BIG AG-Bingel external hard drive needed.


%Basic Graphing Features
h_px=1400;
font_size=20;
font_name='Arial';
nsubplots=5;
vmargin=0.05; %size of vertical plot margins in % of Figure
vplotsize=(1-nsubplots*vmargin)/nsubplots;


figure('Name','Study Design Overview','Position', [0, 0, h_px/sqrt(2), h_px]);

%% Bingel_et_al_2011
paths={
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj02/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj03/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj04/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj05/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj07/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj09/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj11/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj12/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj13/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj14/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj17/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj18/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj19/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj20/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj21/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj22/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj23/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj24/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj25/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj26/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj27/analyse_04/SPM.mat'
'/Volumes/Bingel_Mac/opioids/fmri/opioids3/analysen/subj28/analyse_04/SPM.mat'}

TR=3; % Enter TR

% Get design matrices entered (Note: If there were several runs/participant, only one is extracted as an example)
for i=1:length(paths)
load(paths{i})
Designs{i}=SPM.Sess.U;    
end

condition_names={'RTCue';'ReactionTaskTarget';'Anticipation';'Pain';'Rating';'Checker';'ITIends'}
% Get by-block timing parameters
for i=1:length(Designs)
onsets=[Designs{1,i}.ons];

tcondition=onsets-repmat(onsets(:,1),1,size(onsets,2));
%Add ITI (which is not an explicit condition)
ITI=[onsets(1,1);onsets(2:end,1)-onsets(1:end-1,end)];
tcondition=([tcondition tcondition(:,end)+ITI])*TR;
DesignTiming{i}=tcondition;
DesignDurs{i}=[Designs{1,i}.dur zeros(size(ITI))]*TR;;
end

insub_mean_timing=cellfun(@mean,DesignTiming,'UniformOutput',0)';
insub_min_timing =cellfun(@min,DesignTiming,'UniformOutput',0)';
insub_max_timing =cellfun(@max,DesignTiming,'UniformOutput',0)';

all_mean_timing=mean(vertcat(insub_mean_timing{:}));
all_min_timing =min(vertcat(insub_min_timing{:}));
all_max_timing =max(vertcat(insub_max_timing{:}));

insub_mean_dur=cellfun(@mean,DesignDurs,'UniformOutput',0)';
insub_min_dur =cellfun(@min,DesignDurs,'UniformOutput',0)';
insub_max_dur =cellfun(@max,DesignDurs,'UniformOutput',0)';

all_mean_dur=mean(vertcat(insub_mean_dur{:}));
all_min_dur =min(vertcat(insub_min_dur{:}));
all_max_dur =max(vertcat(insub_max_dur{:}));

% Graph
%figure('Name','Bingel');
h1=subplot(5,1,1);
axis([-5 90 0 1.1]);
title('Bingel','Position',[0 1.1],'HorizontalAlignment','left')
hold on
for i=1:length(all_mean_timing)
% a=area([all_min_timing(i) all_max_timing(i)], [1 0],'FaceColor',[0.9 0.9 0.9]);
% child=get(a,'Children');
% set(child,'FaceAlpha',1);
b=area([all_mean_timing(i) all_mean_timing(i)+all_mean_dur(i)], [1 1],'FaceColor',[0.9 0.9 0.9]);
child=get(b,'Children');
set(child,'FaceAlpha',0.5);
a=line([all_mean_timing(i) all_mean_timing(i)], [0 1],'Color',[0.5 0.5 0.5],'LineWidth',3);
end

nudge=cumsum(ones(size(all_mean_timing)))/-8;
text(all_mean_timing+1,ones(size(all_mean_timing))+nudge,condition_names','Interpreter','none','HorizontalAlignment','left')
text(0.8,1.05,'*according to SPM-files','units','normalized','Interpreter','none','HorizontalAlignment','left')

xlabel('Block Time (s)');
set(gca,'YTick',[]);
hold off

%% Geuter_et_al_2013
all_mean_timing=[0 5 15 28.5 47.5];
all_mean_dur=   [5 10 10 5 0];
condition_names={'Anticipation';'EarlyPain';'LatePain';'Rating';'ITIends'};

% Graph
%figure('Name','Geuter');
h2=subplot(5,1,2);
axis([-5 90 0 1.1]);
title('Geuter','Position',[0 1.1],'HorizontalAlignment','left') 

hold on
for i=1:length(all_mean_timing)
% a=area([all_min_timing(i) all_max_timing(i)], [1 0],'FaceColor',[0.9 0.9 0.9]);
% child=get(a,'Children');
% set(child,'FaceAlpha',1);
b=area([all_mean_timing(i) all_mean_timing(i)+all_mean_dur(i)], [1 1],'FaceColor',[0.9 0.9 0.9]);
child=get(b,'Children');
set(child,'FaceAlpha',0.5);
a=line([all_mean_timing(i) all_mean_timing(i)], [0 1],'Color',[0.5 0.5 0.5],'LineWidth',3);
end

nudge=cumsum(ones(size(all_mean_timing)))/-8;
text(all_mean_timing+1,ones(size(all_mean_timing))+nudge,condition_names','Interpreter','none','HorizontalAlignment','left')
text(0.8,1.05,'*according to paper','units','normalized','Interpreter','none','HorizontalAlignment','left')

xlabel('Block Time (s)');
set(gca,'YTick',[]);
hold off

%% Kessner_et_al_201314
paths={
'/Volumes/Bingel_Mac/carryover/sub01/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub03/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub04/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub05/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub06/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub07/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub08/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub09/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub10/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub11/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub12/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub13/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub14/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub15/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub16/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub17/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub18/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub19/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub20/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub21/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub22/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub23/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub24/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub25/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub26/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub27/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub28/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub29/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub30/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub31/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub32/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub33/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub34/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub35/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub36/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub37/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub38/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub39/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'
'/Volumes/Bingel_Mac/carryover/sub40/first_level/model5_Fullpain_bpBlock_ncoreg888swuaf_23112010/SPM.mat'}

TR=2.58; % Enter TR

% Get design matrices entered (Note: If there were several runs/participant, only one is extracted as an example)
for i=1:length(paths)
load(paths{i})
Designs{i}=SPM.Sess.U;    
end

condition_names={'Cue';'Pain';'Rating';'ITIends'}
% Get by-block timing parameters
for i=1:length(Designs)
onsets=[Designs{1,i}.ons];

tcondition=onsets-repmat(onsets(:,1),1,size(onsets,2));
%Add ITI (which is not an explicit condition)
ITI=[onsets(1,1);onsets(2:end,1)-onsets(1:end-1,end)];
tcondition=([tcondition tcondition(:,end)+ITI])*TR;
DesignTiming{i}=tcondition;
DesignDurs{i}=[Designs{1,i}.dur zeros(size(ITI))]*TR;;
end

insub_mean_timing=cellfun(@mean,DesignTiming,'UniformOutput',0)';
insub_min_timing =cellfun(@min,DesignTiming,'UniformOutput',0)';
insub_max_timing =cellfun(@max,DesignTiming,'UniformOutput',0)';

all_mean_timing=mean(vertcat(insub_mean_timing{:}));
all_min_timing =min(vertcat(insub_min_timing{:}));
all_max_timing =max(vertcat(insub_max_timing{:}));

insub_mean_dur=cellfun(@mean,DesignDurs,'UniformOutput',0)';
insub_min_dur =cellfun(@min,DesignDurs,'UniformOutput',0)';
insub_max_dur =cellfun(@max,DesignDurs,'UniformOutput',0)';

all_mean_dur=mean(vertcat(insub_mean_dur{:}));
all_min_dur =min(vertcat(insub_min_dur{:}));
all_max_dur =max(vertcat(insub_max_dur{:}));

% Graph
h3=subplot(5,1,3);
axis([-5 90 0 1.1]);
hold on
title('Kessner','Position',[0 1.1],'HorizontalAlignment','left') 

for i=1:length(all_mean_timing)
% a=area([all_min_timing(i) all_max_timing(i)], [1 0],'FaceColor',[0.9 0.9 0.9]);
% child=get(a,'Children');
% set(child,'FaceAlpha',1);
b=area([all_mean_timing(i) all_mean_timing(i)+all_mean_dur(i)], [1 1],'FaceColor',[0.9 0.9 0.9]);
child=get(b,'Children');
set(child,'FaceAlpha',0.5);
a=line([all_mean_timing(i) all_mean_timing(i)], [0 1],'Color',[0.5 0.5 0.5],'LineWidth',3);
end

nudge=cumsum(ones(size(all_mean_timing)))/-8;
text(all_mean_timing+1,ones(size(all_mean_timing))+nudge,condition_names','Interpreter','none','HorizontalAlignment','left')
text(0.8,1.05,'*according to SPM-files','units','normalized','Interpreter','none','HorizontalAlignment','left')

xlabel('Block Time (s)');
set(gca,'YTick',[]);
hold off

%% Wager_et_al_2004
% basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';
% studydir = 'Wager_et_al_2004/Study2_Michigan_heat';
% load(fullfile(basedir,studydir,'EXPT.mat'));
% subdir=EXPT.subdir;
% paths=fullfile(basedir,studydir,subdir,'SPM_fMRIDesMtx.mat');
% 
% TR=1; % Enter TR (or 1, in case the design matrix is given in seconds)
% 
% % Get design matrices entered (Note: If there were several runs/participant, only one is extracted as an example)
% for i=1:length(paths)
% load(paths{i})
% Designs{i}=Sess{1,1}.ons;    
% end
% 
% condition_names={'cue';'antic';'heatonset';'heatpain';'heatoffset';'response';'ITIends'}
% Get by-block timing parameters

all_mean_timing=[0 1 10 36 81];
all_mean_dur=   [1 9 20 4 0];
condition_names={'Cue';'Anticipation';'Heat';'Rating';'ITIends'};

% Graph
h4=subplot(5,1,4);
axis([-5 90 0 1.1]);
title('Wager Michigan','Position',[0 1.1],'HorizontalAlignment','left') 

hold on
for i=1:length(all_mean_timing)
% a=area([all_min_timing(i) all_max_timing(i)], [1 0],'FaceColor',[0.9 0.9 0.9]);
% child=get(a,'Children');
% set(child,'FaceAlpha',1);
b=area([all_mean_timing(i) all_mean_timing(i)+all_mean_dur(i)], [1 1],'FaceColor',[0.9 0.9 0.9]);
child=get(b,'Children');
set(child,'FaceAlpha',0.5);
a=line([all_mean_timing(i) all_mean_timing(i)], [0 1],'Color',[0.5 0.5 0.5],'LineWidth',3);
end

nudge=cumsum(ones(size(all_mean_timing)))/-8;
text(all_mean_timing+1,ones(size(all_mean_timing))+nudge,condition_names','Interpreter','none','HorizontalAlignment','left')
text(0.8,1.05,'*according to paper','units','normalized','Interpreter','none','HorizontalAlignment','left')

xlabel('Block Time (s)');
set(gca,'YTick',[]);
hold off

%% Wrobel_et_al_2014

paths={
'/Volumes/Bingel_Mac/haldol/fmri/sub12/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub13/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub14/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub17/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub19/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub20/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub21/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub22/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub23/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub24/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub26/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub27/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub28/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub29/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub30/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub32/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub33/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub34/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub35/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub37/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub38/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub39/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub40/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub41/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub42/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub43/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub44/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub45/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub46/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub47/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub48/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub49/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub50/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub51/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub52/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub55/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub56/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub57/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub58/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub59/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub60/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'
'/Volumes/Bingel_Mac/haldol/fmri/sub61/first_level/model4_bpBLOCK_latepain_2trialsregressor_ncoreg888swuaf/SPM.mat'}

TR=2.58; % Enter TR

% Get design matrices entered (Note: If there were several runs/participant, only one is extracted as an example)
for i=1:length(paths)
load(paths{i})
Designs{i}=SPM.Sess(1).U(2:2:8);    
end

condition_names={'Cue';'EarlyPain';'LatePain';'Rating';'ITIends'}
% Get by-block timing parameters
for i=1:length(Designs)
onsets=[Designs{1,i}.ons];
tcondition=onsets-repmat(onsets(:,1),1,size(onsets,2));
%Add ITI (which is not an explicit condition)
ITI=[onsets(1,1);onsets(2:end,1)-onsets(1:end-1,end)];
tcondition=([tcondition tcondition(:,end)+ITI])*TR;
DesignTiming{i}=tcondition;
DesignDurs{i}=[Designs{1,i}.dur zeros(size(ITI))]*TR;;
end

insub_mean_timing=cellfun(@mean,DesignTiming,'UniformOutput',0)';
insub_min_timing =cellfun(@min,DesignTiming,'UniformOutput',0)';
insub_max_timing =cellfun(@max,DesignTiming,'UniformOutput',0)';

all_mean_timing=mean(vertcat(insub_mean_timing{:}));
all_min_timing =min(vertcat(insub_min_timing{:}));
all_max_timing =max(vertcat(insub_max_timing{:}));

insub_mean_dur=cellfun(@mean,DesignDurs,'UniformOutput',0)';
insub_min_dur =cellfun(@min,DesignDurs,'UniformOutput',0)';
insub_max_dur =cellfun(@max,DesignDurs,'UniformOutput',0)';

all_mean_dur=mean(vertcat(insub_mean_dur{:}));
all_min_dur =min(vertcat(insub_min_dur{:}));
all_max_dur =max(vertcat(insub_max_dur{:}));

% Graph
h5=subplot(5,1,5);
axis([-5 90 0 1.1]);
hold on
title('Wrobel','Position',[0 1.1],'HorizontalAlignment','left') 

for i=1:length(all_mean_timing)
% a=area([all_min_timing(i) all_max_timing(i)], [1 0],'FaceColor',[0.9 0.9 0.9]);
% child=get(a,'Children');
% set(child,'FaceAlpha',1);
b=area([all_mean_timing(i) all_mean_timing(i)+all_mean_dur(i)], [1 1],'FaceColor',[0.9 0.9 0.9]);
child=get(b,'Children');
set(child,'FaceAlpha',0.5);
a=line([all_mean_timing(i) all_mean_timing(i)], [0 1],'Color',[0.5 0.5 0.5],'LineWidth',3);
end

nudge=cumsum(ones(size(all_mean_timing)))/-8;
text(all_mean_timing+1,ones(size(all_mean_timing))+nudge,condition_names','Interpreter','none','HorizontalAlignment','left')
text(0.8,1.05,'*according to SPM-files','units','normalized','Interpreter','none','HorizontalAlignment','left')

xlabel('Block Time (s)');
set(gca,'YTick',[]);
hold off


%%
saveas(gcf,'DesignOverview.jpg')