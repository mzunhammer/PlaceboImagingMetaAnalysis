function Schenk_et_al_2014(datapath)

%% Collects all behavioral data and absolute img-paths for schenk 2011
% in a data frame, saves as .mat

%% Set working environment

basedir = datapath;

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Schenk_et_al_2014';
schenkdir = dir(fullfile(basedir, studydir));
dirnames={schenkdir.name};
isubfolder=regexp(dirnames,'sub\d\d');
isubfolder=~cellfun(@isempty,isubfolder); %actual images in dir
% Get paths of subjects as string^
subfolder=dirnames(isubfolder);
sub=cellfun(@str2num,dirnames(isubfolder),'UniformOutput',0);
sub=[sub{:}];
beta_IDs = [3,4,8,9,13,14,18,19]; %define betas of interest
beta_descriptors= {...
    'anti_lidocaine_control'... % beta_3
    'pain_lidocaine_control'... % beta_4
    'anti_nolidocaine_control'...%beta_8
    'pain_nolidocaine_control'...%beta_9
    'anti_lidocaine_placebo'...% beta_13
    'pain_lidocaine_placebo'...% beta_14
    'anti_nolidocaine_placebo'...%beta_18
    'pain_nolidocaine_placebo'...%beta_19
    };
nbetas=length(beta_descriptors);
% Get all img-paths
for j=1:length(subfolder)
    currfolder=fullfile(basedir,studydir,subfolder(j));
    load(fullfile(currfolder{:},'SPM.mat')); %Load subject's SPM
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    for i=1:nbetas
        %Get filenames in a (subj,beta) matrix
        img(j,i) = fullfile(studydir,subfolder(j), sprintf('beta_00%0.2d.img', beta_IDs(i)));
        beta(j,i)=beta_IDs(i);
        %Get description of conditions in a in (subj,beta) matrix format
        cond(j,i)=beta_descriptors(i); 
        
        %Get x_span, betaSpan from SPM:
        % Array of xSpans, each corresponding to one predictor(x) in the design
        % matrix
        x_span(j,i)=xSpanRaw(beta_IDs(i));
        n_imgs(j,i)=size(SPM.xX.X,1);
    end
end
%Matrix to array
img=img(:);
cond=cond(:);
x_span=x_span(:);
n_imgs=n_imgs(:);

% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo 2 = Other
pla=NaN(size(cond));
pla(~cellfun(@isempty,regexp(cond,'control')),1)=0;   % 0= Any Control 1 = Any Placebo 2 = Other
pla(~cellfun(@isempty,regexp(cond,'placebo')),1)=1;  % 0= Any Control 1 = Any Placebo 2 = Other
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain=NaN(size(cond));
pain(~cellfun(@isempty,regexp(cond,'anti')),1)=0;  % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(~cellfun(@isempty,regexp(cond,'pain')),1)=1;  % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain

real_treat=NaN(size(cond));
real_treat(~cellfun(@isempty,regexp(cond,'nolidocaine')),1)=0;  % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
real_treat(~cellfun(@isempty,regexp(cond,'_lidocaine')),1)=1;  % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain

%% Import behavioral from Excel-Sheet
xls_path=fullfile(basedir, studydir,'SchenkBehavioral.xlsx');
xlsid=xlsread(xls_path,1,'A2:A33');

% Gender
male=xlsread(xls_path,1,'BG2:BG33');
male=repmat(male,nbetas,1);

% Age
age=xlsread(xls_path,1,'BF2:BF33');
age=repmat(age,nbetas,1);

% Ratings
rating_LN=xlsread(xls_path,1,'BI2:BI33');
rating_NN=xlsread(xls_path,1,'BJ2:BJ33');
rating_LP=xlsread(xls_path,1,'BK2:BK33');
rating_NP=xlsread(xls_path,1,'BL2:BL33');
rating=[repmat(rating_LN,2,1);
        repmat(rating_NN,2,1);
        repmat(rating_LP,2,1);
        repmat(rating_NP,2,1)]; % Repeat ratings for anticipation and pain
% Temps
temps=xlsread(xls_path,1,'BH2:BH33');
temps=repmat(temps,nbetas,1);

%Add imaging parameters
imgs_per_stimulus_block=NaN(size(cond));
imgs_per_stimulus_block(~cellfun(@isempty,regexp(cond,'anti')),1)=1.937984496124031;
imgs_per_stimulus_block(~cellfun(@isempty,regexp(cond,'pain')),1)=7.751937984496124;

% Sequence
seq_LN=xlsread(xls_path,1,'BB2:BB33');
seq_NN=xlsread(xls_path,1,'BC2:BC33');
seq_LP=xlsread(xls_path,1,'BD2:BD33');
seq_NP=xlsread(xls_path,1,'BE2:BE33');
seq=[repmat(seq_LN,2,1);
     repmat(seq_NN,2,1);
     repmat(seq_LP,2,1);
     repmat(seq_NP,2,1)]; % Repeat session numbers for anticipation and pain

% Placebo First
placebo_first=[repmat(seq_LN>seq_LP,2,1); %Placebo-first and second is a little tricky here, because open and hidden treatment alternated.
          repmat(seq_NN>seq_NP,2,1); %Therefore Placebo first was defined in respect to lido and nolido conditions separately
          repmat(seq_LN>seq_LP,2,1);
          repmat(seq_NN>seq_NP,2,1)];

% stim_side: "Variablen HS1-4: 1 Rechts oben, 2 rechts unten, 3 links oben, 4 links unten. Z.b. wenn HS1=3 bedeuted dass, dass zuerst links oben stimuliert wurde. Ich merke gerade dass du noch die Kodierung fur die Reihenfolge der Bedigungen brauchst. Werde ich heute abend noch in Dropbox reinstellen."  
% i.e. stim_side is encoded by seq in Excel file.
stimside_1=xlsread(xls_path,1,'AX2:AX33');
stimside_2=xlsread(xls_path,1,'AY2:AY33');
stimside_3=xlsread(xls_path,1,'AZ2:AZ33');
stimside_4=xlsread(xls_path,1,'BA2:BA33');

stimside_raw=repmat(NaN,size(img));
stimside_raw(seq==1&pain==1)=stimside_1;
stimside_raw(seq==1&pain==0)=stimside_1;
stimside_raw(seq==2&pain==1)=stimside_2;
stimside_raw(seq==2&pain==0)=stimside_2;
stimside_raw(seq==3&pain==1)=stimside_3;
stimside_raw(seq==3&pain==0)=stimside_3;
stimside_raw(seq==4&pain==1)=stimside_4;
stimside_raw(seq==4&pain==0)=stimside_4;

stim_side=cell(size(img));
stim_side(stimside_raw<=2)={'R'};
stim_side(stimside_raw>=3)={'L'};
%% Collect all Variables in Table
schenk=table(img);
schenk.img=img;
schenk.study_ID=repmat({'schenk'},size(schenk.img));
schenk.sub_ID=strcat(schenk.study_ID,'_',repmat(subfolder',nbetas,1));
schenk.male=male;
schenk.age=age;
schenk.healthy=ones(size(schenk.img));
schenk.pla=pla;
schenk.pain=pain;
schenk.predictable= ones(size(schenk.img)); %The anticipatory phase was always 5 s long.
schenk.real_treat=real_treat; %Mark all participants receiving lidocaine
schenk.cond=cond;
schenk.stim_side=stim_side;
schenk.placebo_first=placebo_first;
schenk.i_condition_in_sequence=seq;
schenk.rating=rating;
schenk.rating101=rating*10; %a 11pt rating scale ranging from 0 "no pain" to 10 "unbearable pain" was used.
schenk.stim_intensity=temps; 
schenk.imgs_per_stimulus_block =imgs_per_stimulus_block; % According to SPM
schenk.n_blocks      =ones(size(cond))*12; % According to SPM
schenk.n_imgs      =n_imgs; % Images per Participant
schenk.x_span        =x_span;
schenk.con_span      =ones(size(cond));

%% Save
%% Save
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_ID,'schenk')),'raw'}={schenk};
save(fullfile(basedir,'data_frame.mat'),'df');
end
