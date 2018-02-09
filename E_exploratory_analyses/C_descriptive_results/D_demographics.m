function D_dempographics(datapath)

df_name='data_frame.mat';
load(fullfile(datapath,df_name));
addpath(genpath(fullfile(userpath,'/tight_subplot')));
%addpath(genpath(fullfile(userpath,'/cbrewer')));

% Use mean_pla_con, bc this includes images for each participant in  within and between group studies
df_all=vertcat(df.subjects{:});

% Get df with only first entry per subject for demographics
fprintf('Total number of independent subjects: %d\n',length(df_all.sub_ID))


df_by_subID=varfun(@mean,df_all,'InputVariables',{'excluded_low_pain','excluded_image_quality','excluded'},...
    'GroupingVariables','sub_ID');

['Total number of independent subjects excluded for near-zero ratings: ', num2str(sum(df_by_subID.mean_excluded_low_pain))]
['Total number of independent subjects excluded for suspected image artifacts: ', num2str(sum(df_by_subID.mean_excluded_image_quality))]

f1=figure('position', [100, 100, 1049*2, 895*0.5],...
        'PaperPositionMode', 'auto'); %'Units','centimeters','position',[0 0 17 3]

%% Figure 1: Study features, overview
[subplothandle, pos] =tight_subplot(1,7,0,[0.01 0.1],0.01);

dfs=vertcat(df.subjects{:});
dfs=outerjoin(df(:,1:23),dfs,'MergeKeys',true);
% for atlas and bingel06 these are only known on group level from the published manuscript,
gender=dfs.male;
gender(strcmp(dfs.study_ID,'atlas'))=[ones(10,1);zeros(11,1)];
gender(strcmp(dfs.study_ID,'bingel06'))=[ones(15,1);zeros(4,1)];
gender(isnan(gender))=2;

genderlabels={'Female';'Male';'Unknown'};
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

a=categorical(dfs.study_design);
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

a=categorical(dfs.field_strength);
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
a=categorical(dfs.stim_type);
a=renamecats(a ,stimlbl);

%subs_by_study=renamecats(subs_by_study ,T);

%g4=nicepie(a);
axes(subplothandle(4))
g4=nicebar(a, 'Pain stimulus');
%saveas(g4,'/Graphs/StimulusType.fig')

%% STIMSIDE
% CORRECT: BINGEL ET AL AND SCHENK AT AL STIMULATED BOTH SIDES!

dfs.stim_side=cellfun(@(x) x.stim_side,dfs.placebo_and_control,'UniformOutput',0);
dfs.stim_side(strcmp(dfs.study_ID,'bingel06'))={'both'};
dfs.stim_side(strcmp(dfs.study_ID,'schenk'))={'both'};
LR={'Midline';...
    'Left';...
    'Right';...
    'Left & right';...
   };
a=categorical(vertcat(dfs.stim_side{:}));
a=renamecats(a ,LR);

%subs_by_study=renamecats(subs_by_study ,T);

%g5=nicepie(a);
axes(subplothandle(5))
g5=nicebar(a, 'Stimulus side');
%saveas(g5,'/Graphs/StimulusSide.fig')


%by_study_meanages = grpstats(df.stimside, df.study_ID, {'mean'});

%% Placebo Form
stud_labels={
    'Sham acupuncture'
    'Intravenous'
    'Nasal spray'
    'Pill'
    'Sham TENS'
    'Topical'};

a=categorical(dfs.placebo_form);
%subs_by_study=renamecats(subs_by_study ,T);
a=renamecats(a ,stud_labels);

%g6=nicepie(a);
axes(subplothandle(6))
g6=nicebar(a, 'Placebo treatment');

%saveas(g6,'/Graphs/PlaceboForm.fig')

%% Placebo Induction
Indu={
    sprintf('Conditioning only\n')
    sprintf('Suggestions only\n')
    sprintf('Suggestions &\nconditioning')}
a=categorical(dfs.placebo_induction);
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

print('Descriptive.pdf','-dpdf','-bestfit')

%% Stimulus sites
stim_location=categorical(dfs.stim_location);
table(categories(stim_location),...
    countcats(stim_location))

%% Mean age and gender by study
by_study_meanages = grpstats( dfs.age, dfs.study_ID, {'mean'})
by_study_propmale = grpstats( dfs.male, dfs.study_ID, {'mean'})


%close all;

end