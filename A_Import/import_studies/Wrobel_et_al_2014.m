function Wrobel_et_al_2014(datapath)

%% Set working environment

basedir = datapath;

%% Collects all behavioral data and absolute img-paths
% in a data frame, saves as .mat

studydir = 'Wrobel_et_al_2014';
wrobeldir = dir(fullfile(basedir, studydir));
beta_img = {wrobeldir(~cellfun(@isempty,regexp({wrobeldir.name},'^sub\d\d.*img'))).name}';

img=cellfun(@(x) fullfile(studydir, x),beta_img,'UniformOutput',0); % The absolute image paths
sub=regexp(img,'sub(\d\d)_beta','tokens');
sub=[sub{:}];
sub=str2double([sub{:}])';                             % The subject number (study specific)

% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo 2 = Other
pla(~cellfun(@isempty,regexp(beta_img,'placebo')),1)=1;
pla(~cellfun(@isempty,regexp(beta_img,'control')),1)=0;
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)=0; 
pain(~cellfun(@isempty,regexp(beta_img,'early_pain')),1)=2;  
pain(~cellfun(@isempty,regexp(beta_img,'late_pain')),1)=3;

cond=regexp(beta_img,'beta_(.*).img','tokens');
cond=[cond{:}]';
cond=[cond{:}]';

% Import behavioral
wrobel_subs=unique(sub);
xls_path=[basedir,filesep, studydir,filesep, 'wrobel_haldol_study.xlsx'];

%Ratings
[num,~,~]=xlsread(xls_path,1,'O:P');
rating_bl  =num(:,2);
rating_pla =num(:,1);

rating_bl_3  =  repmat(rating_bl,1,3)';
rating_pla_3  = repmat(rating_pla,1,3)';
rating_bl_3=rating_bl_3(:);
rating_pla_3=rating_pla_3(:);

rating(~cellfun(@isempty,regexp(beta_img,'control')),1)=rating_bl_3;
rating(~cellfun(@isempty,regexp(beta_img,'placebo')),1)=rating_pla_3;

stim_intensity=xlsread(xls_path,1,'Y:Y');
stim_intensity=repmat(stim_intensity,1,6)';stim_intensity=stim_intensity(:);
stim_intensity(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)=35;

male=xlsread(xls_path,1,'E:E');
male=repmat(male,1,6)';male=male(:);
age=xlsread(xls_path,1,'H:H');
age=repmat(age,1,6)';age=age(:);age(age==999)=NaN;
placebo_first=xlsread(xls_path,1,'G:G');
placebo_first=repmat(placebo_first,1,6)';placebo_first=placebo_first(:);

imgs_per_stimulus_block(~cellfun(@isempty,regexp(beta_img,'pain')),1)            =3.8760;
imgs_per_stimulus_block(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)    =0;

n_blocks(~cellfun(@isempty,regexp(beta_img,'pain')),1)            =13;
n_blocks(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)    =13;

%x_span (from max(SPM.xX.X)-min(SPM.xX.X))
wrobelSPMs = {wrobeldir(~cellfun(@isempty,regexp({wrobeldir.name},'SPM.mat'))).name}';
for i=1:size(wrobelSPMs)
    load(fullfile(basedir, studydir,wrobelSPMs{i,1}));
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    wrobelxSpans(i,:)=xSpanRaw([2 10 4 12 6 14]);
    n_imgs(i,:)=size(SPM.xX.X,1);
end
n_imgs=repmat(n_imgs,1,6)';
n_imgs=n_imgs(:);
wrobelxSpanslong=(wrobelxSpans');
wrobelxSpanslong=wrobelxSpanslong(:);
x_span =wrobelxSpanslong;


%con_span for Cons only
con_span      =ones(size(cond)).*1;

% Create Study-Specific table
wrobel=table(img);
wrobel.img=img;
wrobel.study_ID=repmat({'wrobel'},size(wrobel.img));
wrobel.sub_ID=strcat(wrobel.study_ID,'_',num2str(sub));
wrobel.male=male;
wrobel.age=age;
wrobel.healthy=ones(size(wrobel.img));
wrobel.pla=pla;
wrobel.pain=pain;
wrobel.predictable=zeros(size(wrobel.img)); %Uncertainty: mean 7.5 ? 3.5 sec
wrobel.real_treat=zeros(size(wrobel.img));
wrobel.real_treat(~cellfun(@isempty,regexp(beta_img,'haldol')))=1;
wrobel.cond=vertcat(cond(:));
wrobel.stim_side=repmat({'L'},size(wrobel.img));
wrobel.placebo_first=placebo_first;
wrobel.i_condition_in_sequence=NaN(size(wrobel.img));
wrobel.i_condition_in_sequence(~cellfun(@isempty,regexp(beta_img,'placebo'))&wrobel.placebo_first==1)=1;
wrobel.i_condition_in_sequence(~cellfun(@isempty,regexp(beta_img,'placebo'))&wrobel.placebo_first==0)=2;
wrobel.i_condition_in_sequence(~cellfun(@isempty,regexp(beta_img,'control'))&wrobel.placebo_first==1)=2;
wrobel.i_condition_in_sequence(~cellfun(@isempty,regexp(beta_img,'control'))&wrobel.placebo_first==0)=1;
wrobel.rating=rating;
wrobel.rating101=rating; % a 101-pt rating scale ranging from 0 no pain to 100 unbearable pain was used.
wrobel.stim_intensity=stim_intensity;       
wrobel.imgs_per_stimulus_block =imgs_per_stimulus_block; % According to paper (early and late were each modeled 10 seconds)
wrobel.n_blocks      =n_blocks; % According to SPM
wrobel.n_imgs      =n_imgs; % Images per Participant
wrobel.x_span        =x_span;
wrobel.con_span      =ones(size(wrobel.cond));
%% Save
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_ID,'wrobel')),'raw'}={wrobel};
save(fullfile(basedir,'data_frame.mat'),'df');
end