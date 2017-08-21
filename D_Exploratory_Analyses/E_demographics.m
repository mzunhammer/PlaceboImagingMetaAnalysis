clear

datapath='../../Datasets/';
df_name='AllData';
load(fullfile(datapath,[df_name '.mat']));

% Get df with only first entry per subject for demographics
[uniquesubs,ia,ic]=unique(df.subID);
dfs=df(ia,:);      %dataframe single-data-point-per-subject
[ustuds,ia,ic]=unique(df.studyID);
dfstud=df(ia,:);      %dataframe single-data-point-per-subject

['Total number of independent subjects:' num2str(height(dfs))]



df_by_subID=varfun(@mean,df,'InputVariables',{'ex_lo_p_ratings','ex_img_artifact','ex_all'},...
    'GroupingVariables','subID')

['Total number of independent subjects excluded for near-zero ratings: ', num2str(sum(df_by_subID.mean_ex_lo_p_ratings))]
['Total number of independent subjects excluded for suspected image artifacts: ', num2str(sum(df_by_subID.mean_ex_img_artifact))]

f1=figure('position', [100, 100, 1049*2, 895*0.5],...
        'PaperPositionMode', 'auto'); %'Units','centimeters','position',[0 0 17 3]
[subplothandle, pos] =tight_subplot(1,7,0,[0.01 0.1],0.01);

%% Subjects/Study
% studlabels={
%     'Atlas ''12';...
%     'Bingel ''06';...
%     'Bingel ''11';...
%     'Choi ''11';...
%     'Eippert ''09';...
%     'Ellingsen ''13';...
%     'Elsenbruch ''12';...
%     'Freeman ''15';...
%     'Geuter ''13';...
%     'Huber ''13';...
%     'Kessner ''13';...
%     'Kong ''06';...
%     'Kong ''09';...
%     'Ruetgen ''15';...
%     'Schenk ''15';...
%     'Theysohn ''14';...
%     'Wager ''04b';...
%     'Wager ''04a';...
%     'Wrobel ''14';...
%     'Zeidan ''14'};
% 
% a=categorical(dfs.studyID);
% a=renamecats(a ,studlabels);
% 
%axes(subplothandle(1))
% g1=nicebar(a,'Studies');

%g1=nicepie(a);
%saveas(g1,'/Graphs/Studies.fig')
%% Subjects/Study
% for atlas and bingel these are only known on group level from the published manuscript,
gender=dfs.male;
gender(strcmp(dfs.studyID,'atlas'))=[ones(10,1);zeros(11,1)];
gender(strcmp(dfs.studyID,'bingel'))=[ones(15,1);zeros(4,1)];
gender(isnan(gender))=2;

genderlabels={'Female';'Male';'Unknown'}
% 
a=categorical(gender);
a=renamecats(a ,genderlabels);
% 
axes(subplothandle(1))
g1=nicebar(a,'Sex');

%g1=nicepie(a);
%saveas(g1,'/Graphs/Studies.fig')
%% DESIGN
designlabels={'Between-group';'Within-subject'};

a=categorical(dfs.studyType);
a=renamecats(a ,designlabels);

%g3=nicepie(a);
axes(subplothandle(2))
g3=nicebar(a,'Study design');
%saveas(g3,'/Graphs/StudyDesign.fig')
%% MALE/FEMALE
genderlabels={'Male';'Female'};

% Pie
prop_male=nanmean(dfs.male)*100;
prop_female=(1-nanmean(dfs.male))*100;

%g2=nicepie([prop_male,1-prop_male],genderlabels);

% Bar

%axes(subplothandle(2))
%g2=nicebar([prop_male;prop_female],'Gender',genderlabels);

%saveas(g2,fullfile(basepath,'/Graphs/Gender.fig'))

%% FIELD STRENGTH 
T={'1.5 Tesla';...
   '3 Tesla'};

a=categorical(dfs.fieldStrength);
a=renamecats(a ,T);

%g3=nicepie(a);
axes(subplothandle(3))
g3=nicebar(a,'Field strength');
%saveas(g3,'/Graphs/Tesla.fig')

%% STIMTYPE
stimlbl={'Heat+Capsaicin';...
    'Distension';...
    'Electric shock';...
    'Heat';...
    'Laser'};
a=categorical(dfs.stimtype);
a=renamecats(a ,stimlbl);

%subs_by_study=renamecats(subs_by_study ,T);

%g4=nicepie(a);
axes(subplothandle(4))
g4=nicebar(a, 'Pain stimulus');
%saveas(g4,'/Graphs/StimulusType.fig')

%% STIMSIDE
% CORRECT: BINGEL ET AL AND SCHENK AT AL STIMULATED BOTH SIDES!
dfs.stimside(strcmp(dfs.studyID,'bingel'))={'both'};
dfs.stimside(strcmp(dfs.studyID,'schenk'))={'both'};

LR={'Midline';...
    'Left';...
    'Right';...
    'Left & right';...
   };
a=categorical(dfs.stimside);
a=renamecats(a ,LR);

%subs_by_study=renamecats(subs_by_study ,T);

%g5=nicepie(a);
axes(subplothandle(5))
g5=nicebar(a, 'Stimulus side');
%saveas(g5,'/Graphs/StimulusSide.fig')


%by_study_meanages = grpstats(df.stimside, df.studyID, {'mean'});

%% Placebo Form
studlabels={
    'Sham acupuncture'
    'Intravenous'
    'Nasal spray'
    'Pill'
    'Sham TENS'
    'Topical'};

a=categorical(dfs.plaForm);
%subs_by_study=renamecats(subs_by_study ,T);
a=renamecats(a ,studlabels);

%g6=nicepie(a);
axes(subplothandle(6))
g6=nicebar(a, 'Placebo treatment');

%saveas(g6,'/Graphs/PlaceboForm.fig')

%% Placebo Induction
Indu={
    sprintf('Conditioning only\n')
    sprintf('Suggestions only\n')
    sprintf('Suggestions &\nconditioning')}
a=categorical(dfs.plaInduct);
a=renamecats(a ,Indu);

%g7=nicepie(a);
axes(subplothandle(7))
g7=nicebar(a, 'Placebo induction');


%saveas(gcf,fullfile(basepath,'/Graphs/Descriptive.svg'))
print('Descriptive.svg','-dsvg')
%    'PaperUnits','centimeters','PaperSize',[17,6])

%gcf.PaperUnits='centimeters';
%gcf.PaperSize=[17,3];
print('Descriptive.png','-f1','-dpng')

print('Descriptive.pdf','-dpdf')

%% Stimulus sites
stimloc=categorical(dfs.stimloc);
table(categories(stimloc),...
    countcats(stimloc))

%% Number of participants
categorical(dfs.plaInduct);
for i=1:length(ustuds)
   istud=strcmp(df.studyID,ustuds(i));
   n(i,1)=length(unique(df.subID(istud)));
end
n
%% Mean age and gender by study
by_study_meanages = grpstats( df.age, df.studyID, {'mean'})
by_study_propmale = grpstats( df.male, df.studyID, {'mean'})

df_pain=df(logical(df.pain),:);
close all;

