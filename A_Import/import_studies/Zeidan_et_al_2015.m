function Zeidan_et_al_2015

%% Collects all behavioral data and absolute img-paths for Zeidan et al. 2013
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '../../../Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Zeidan_et_al_2015';

zeidandir = dir(fullfile(basedir, studydir));
zeidandir=regexp({zeidandir.name},'^(MR2_L.*)','tokens');
zeidandir=[zeidandir{:}];zeidandir=[zeidandir{:}]';
%actual images in dir
img=[fullfile(studydir,zeidandir,'stats/con_placebo_larger_control_pain.nii'); %placebo>control_pain
    fullfile(studydir,zeidandir,'stats/pe1_norm.nii');  %Pain after controlling for placebo&interaction effects
    fullfile(studydir,zeidandir,'stats/pe3_norm.nii')];   % Placebo>Control, Pain>No Pain

% Get subject numbers from img paths
sub=regexp(img,'Zeidan_et_al_2015/MR2_L(\d+)_4heat.*','tokens');    
sub=[sub{:}];sub=[sub{:}]';
% Assign "placebo condition" to con but not pain image
% 0= Any Control 1 = Any Placebo 2 = Other
pla=[ones(size(zeidandir));
     zeros(size(zeidandir));
     ones(size(zeidandir))];

% Pain condition
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain=[zeros(size(zeidandir)); % This is Pla>Control WITHIN the painful conditon
     ones(size(zeidandir)); % This is Pain>Control EXCLUDING placebo effects or interactions
     ones(size(zeidandir))]; % This is Pla>Control with Pain > NoPain

con_descriptors=[repmat({'Pla>Control within painful series'},size(zeidandir));
                repmat({'Pain>NoPain controlling for placebo&interaction'},size(zeidandir));
                repmat({'Interaction (Pain>NoPain)&(Placebo>Control)'},size(zeidandir))];

unisubs=unique(sub);

% Load Ratings and Age from Excel
xlspath=fullfile(basedir,studydir,'Behavioral_Zeidan.xlsx'); % Load behavioral data
unimale=xlsread(xlspath,1,'C2:C20');
uniage=xlsread(xlspath,1,'B2:B20');

% Ratings in the NoPain conditon can be set to 0 for all participants
% since:
%"One participant provided a rating of 0.30 (pain intensity and unpleasantness) in response to a ?neutral? series. All other sub- jects provided a ?0? to ?neutral? series."
unirating_placebo=xlsread(xlspath,1,'T2:T18'); %UNPLEASANTNESS RATINGS, CONTRAST PLACEBO>CONTROL (PAIN)
unirating_pain=xlsread(xlspath,1,'R2:R18'); %UNPLEASANTNESS RATINGS, CONTRAST PAIN>NoPAIN

male=NaN(size(img));
age=NaN(size(img));
temp=[ones(size(zeidandir))*49; %Always 49?C in all subjects
      ones(size(zeidandir))*35; %Always 35?C in all subjects
      ones(size(zeidandir))*49];%Actually this represents 49-35?C
rating=nan(size(img));
%according to the paper all NoPain stimuli were rated with so for the Pain>No pain contrast mean pain ratings can be used directly
%for the placebo>control contras the appropriate rating differences can be
%used
for i= 1:length(img)
    currsub=sub{i}; % ACHTUNG! Folders may be missorted because strict alphabetic sorting places subs 10c, 11c, 12c ... before 1c, 2c, 3c,...
    icurrsub=find(strcmp(unisubs,currsub));
    % Select correct Design-File
    male(i,1)=unimale(icurrsub);
    age(i,1)=uniage(icurrsub); % Not yet available
    
    if strcmp(con_descriptors(i),'Pla>Control within painful series')
        rating(i,1)=unirating_placebo(icurrsub); %HEAT UNPLEASANTNESS contrast!
    elseif strcmp(con_descriptors(i),'Pain>NoPain controlling for placebo&interaction')
        rating(i,1)=unirating_pain(icurrsub); %HEAT UNPLEASANTNESS contrast!
    elseif strcmp(con_descriptors(i),'Interaction (Pain>NoPain)&(Placebo>Control)')
        rating(i,1)=unirating_placebo(icurrsub); %HEAT UNPLEASANTNESS contrast, same as for pain, because no-pain ratings were always 0.
    end
    
    % In ASL analysis contast-like predictors were used without any HRF
    % therefore all XX amount to 1 (ASL data will be scaled different from fMRI anyways).
 end

% Create Study-Specific table
zeidan=table(img);
zeidan.img=img;
zeidan.study_ID=repmat({'zeidan'},size(zeidan.img));
zeidan.sub_ID=strcat(zeidan.study_ID,'_',sub);
zeidan.male=male;%only males
zeidan.age=age;
zeidan.healthy=ones(size(zeidan.img));%only healthy
zeidan.pla=pla;
zeidan.pain=pain;
zeidan.predictable=ones(size(zeidan.img)); %very regular alternating 12 s stimuli
zeidan.real_treat=zeros(size(zeidan.img)); %No real treatment
zeidan.cond=con_descriptors;
zeidan.stim_side=repmat({'R'},size(zeidan.img));
zeidan.placebo_first=zeros(size(img)); %Placebo sessions were always second
zeidan.i_condition_in_sequence=[ones(size(zeidandir))*1; % Placebo contrasts are Post (Sess 2) - Pre (Sess 1) Placebo = 1
                ones(size(zeidandir))*1.5; % Pain contrasts are mean of (Sess 1) and (Sess 2) = 1.5
                ones(size(zeidandir))*1];% Placebo contrasts are Post (Sess 2) - Pre (Sess 1) Placebo = 1
zeidan.rating=rating; %These are ratings of Pain UNPLEASANTNESS (0-10 pt scale ranging from no pain to most unpleasant pain imaginable)            
zeidan.rating101=rating*10;
zeidan.stim_intensity=temp; %either 49 or 35?C;             
zeidan.imgs_per_stimulus_block =NaN(size(zeidan.cond)); %FSL analysis not comparable with fMRI studies
zeidan.n_blocks      =NaN(size(zeidan.cond)); %FSL analysis not comparable with fMRI studies
zeidan.n_imgs      =ones(size(zeidan.cond)).*8; % Images per Participant
zeidan.x_span        =ones(size(zeidan.img));% All X's had a maximum span of 1
zeidan.con_span      =[ones(size(zeidandir))*4;
                      ones(size(zeidandir))*4;
                      ones(size(zeidandir))*4]; %Use design calculator in B_Unpack_and_Contrast_Zeidan to get contrast weights.
%% Save
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_id,'zeidan')),'raw'}={zeidan};
save(fullfile(basedir,'data_frame.mat'),'df');
end