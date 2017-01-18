function Zeidan_et_al_2015

%% Collects all behavioral data and absolute img-paths for Zeidan et al. 2013
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

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
zeidan.imgType=repmat({'ASL'},size(zeidan.img));
zeidan.studyType=repmat({'within'},size(zeidan.img));
zeidan.studyID=repmat({'zeidan'},size(zeidan.img));
zeidan.subID=strcat(zeidan.studyID,'_',sub);
zeidan.male=male;%only males
zeidan.age=age;
zeidan.healthy=ones(size(zeidan.img));%only healthy
zeidan.pla=pla;
zeidan.pain=pain;
zeidan.predictable=ones(size(zeidan.img)); %very regular alternating 12 s stimuli
zeidan.realTreat=zeros(size(zeidan.img)); %No real treatment
zeidan.cond=con_descriptors;
zeidan.stimtype=repmat({'heat'},size(zeidan.img));
zeidan.stimloc=repmat({'R leg (d)'},size(zeidan.img));
zeidan.stimside=repmat({'R'},size(zeidan.img));
zeidan.plaForm=repmat({'Topical Cream/Gel/Patch'},size(zeidan.img));
zeidan.plaInduct=repmat({'Suggestions + Conditioning'},size(zeidan.img));
zeidan.plaFirst=zeros(size(img)); %Placebo sessions were always second
zeidan.condSeq=[ones(size(zeidandir))*1; % Placebo contrasts are Post (Sess 2) - Pre (Sess 1) Placebo = 1
                ones(size(zeidandir))*1.5; % Pain contrasts are mean of (Sess 1) and (Sess 2) = 1.5
                ones(size(zeidandir))*1];% Placebo contrasts are Post (Sess 2) - Pre (Sess 1) Placebo = 1
zeidan.rating=rating; %These are ratings of Pain UNPLEASANTNESS (0-10 pt scale)            
zeidan.stimInt=temp; %either 49 or 35?C;             
zeidan.fieldStrength=ones(size(zeidan.img)).*3;
zeidan.tr           =ones(size(zeidan.img)).*4;
zeidan.te           =ones(size(zeidan.img)).*12;
zeidan.voxelVolAcq  =ones(size(zeidan.img)).*(220/64*220/64*5+1);%22*22cm in a 64*64 grid with 5mm slice thickness +1mm gap
zeidan.voxelVolMat  =ones(size(zeidan.img)).*(2*2*2);% Aligned to the usual 2*2*2 MNI image
zeidan.meanBlockDur =ones(size(zeidan.cond)).*12; % stimulus length according to paper
zeidan.nImages      =ones(size(zeidan.cond)).*8; % Images per Participant
zeidan.xSpan        =ones(size(zeidan.img));% All X's had a maximum span of 1
zeidan.conSpan      =[ones(size(zeidandir))*4;
                      ones(size(zeidandir))*4;
                      ones(size(zeidandir))*4]; %Use design calculator in B_Unpack_and_Contrast_Zeidan to get contrast weights.

%% Save
outpath=fullfile(basedir,'Zeidan_et_al_2015.mat')
save(outpath,'zeidan')

end