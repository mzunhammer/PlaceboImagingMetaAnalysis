function Ellingsen_et_al_2013

%% Collects all behavioral data and absolute img-paths for Ellingsen et al. 2013
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Ellingsen_et_al_2013';

ellingsendir = dir(fullfile(basedir, studydir));
ellingsendir=regexp({ellingsendir.name},'(\d+\w)','tokens');
ellingsendir=[ellingsendir{:}];ellingsendir=[ellingsendir{:}]';
%unpack images
% raw_images=[fullfile(basedir,studydir,ellingsendir,'stats/cope1_norm.nii.gz'); %Painful touch
%     fullfile(basedir,studydir,ellingsendir,'stats/cope2_norm.nii.gz');  %Brush touch
%     fullfile(basedir,studydir,ellingsendir,'stats/cope3_norm.nii.gz')];  %Warm touch
% for i=1:length(raw_images)
% gunzip(raw_images(i));
% end

%actual images in dir
img=[fullfile(studydir,ellingsendir,'stats/cope1_norm.nii'); %Painful touch
    fullfile(studydir,ellingsendir,'stats/cope2_norm.nii');  %Brush touch
    fullfile(studydir,ellingsendir,'stats/cope3_norm.nii')];  %Warm touch

designmats=[fullfile(basedir,studydir,ellingsendir,'design.mat')';
    fullfile(basedir,studydir,ellingsendir,'design.mat')';
    fullfile(basedir,studydir,ellingsendir,'design.mat')'];%NOT AN ACTUAL .MAT FILE BUT A fsl matrix... analog to xX
confile=[fullfile(basedir,studydir,ellingsendir,'design.con')'; % Contrast vectors
         fullfile(basedir,studydir,ellingsendir,'design.con')';
         fullfile(basedir,studydir,ellingsendir,'design.con')'];
% Get subject numbers from img paths
sub=regexp(img,'Ellingsen_et_al_2013/(\d+)\w/stats/.*','tokens');    
sub=[sub{:}];sub=[sub{:}]';
% Assign "placebo condition" to con image
% 0= Any Control 1 = Any Placebo 2 = Other
plaraw=regexp(img,'Ellingsen_et_al_2013/\d+(\w)/stats/.*','tokens');
plaraw=[plaraw{:}];plaraw=[plaraw{:}]';
pla=strcmp(plaraw,'P');

% Pain condition
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain=[ones(size(ellingsendir)); %Painful touch
    zeros(size(ellingsendir)); %Brush
    zeros(size(ellingsendir))]; %Warm touch;

con_descriptors=[repmat({'Painful_touch'},size(ellingsendir));
                repmat({'Brushstroke'},size(ellingsendir));
                repmat({'Warm_touch'},size(ellingsendir))];

con_descriptors(logical(pla))=strcat(con_descriptors(logical(pla)),'_placebo');
con_descriptors(~logical(pla))=strcat(con_descriptors(~logical(pla)),'_control');
conn=[ones(size(ellingsendir)); %Painful touch
    ones(size(ellingsendir))*2; %Brush
    ones(size(ellingsendir))*3]; %Warm touch;

unisubs=unique(sub);
nsubj=length(unisubs);

% Load Ratings and Age from Excel
xlspath=fullfile(basedir,studydir,'Behavioral_Data_Ellingsen.xlsx'); % Load behavioral data
unimale=xlsread(xlspath,1,'B2:B29');
uniage=xlsread(xlspath,1,'C2:C29');
uniplaFirst=xlsread(xlspath,1,'D2:D29');
unirating_control=xlsread(xlspath,1,'F2:F29');
unirating_placebo=xlsread(xlspath,1,'E2:E29');
unirating_control_brush=xlsread(xlspath,1,'I2:I29');
unirating_placebo_brush=xlsread(xlspath,1,'H2:H29');
unirating_control_warm=xlsread(xlspath,1,'K2:K29');
unirating_placebo_warm=xlsread(xlspath,1,'J2:J29');
unitemp=xlsread(xlspath,1,'G2:G29');

male=NaN(size(img));
age=NaN(size(img));
plaFirst=NaN(size(img));
temp=NaN(size(img));
rating=NaN(size(img));
xSpan=NaN(size(img));

for i= 1:length(img)
    currsub=str2num(sub{i}); % ACHTUNG! Folders may be missorted because strict alphabetic sorting places subs 10c, 11c, 12c ... before 1c, 2c, 3c,...
    % Select correct Design-File
    currdes=designmats(i);
    currconfile=confile(i);
    male(i,1)=unimale(currsub);
    age(i,1)=uniage(currsub);
    plaFirst(i,1)=uniplaFirst(currsub);
    
    
    if strcmp(con_descriptors(i),'Painful_touch_placebo')
        rating(i,1)=unirating_placebo(currsub);
        temp(i,1)=unitemp(currsub);
    elseif strcmp(con_descriptors(i),'Painful_touch_control')
        rating(i,1)=unirating_control(currsub);
        temp(i,1)=unitemp(currsub);
    elseif strcmp(con_descriptors(i),'Brushstroke_placebo')
        rating(i,1)=unirating_placebo_brush(currsub);
        temp(i,1)=32; % Skin temperature
    elseif strcmp(con_descriptors(i),'Brushstroke_control')
        rating(i,1)=unirating_control_brush(currsub);
        temp(i,1)=32; % Skin temperature
    elseif strcmp(con_descriptors(i),'Warm_touch_placebo')
        rating(i,1)=unirating_placebo_warm(currsub);
        temp(i,1)=42.5; % Heat pack was ~42.5?C at the start of the fMRI session
    elseif strcmp(con_descriptors(i),'Warm_touch_control')
        rating(i,1)=unirating_control_warm(currsub);
        temp(i,1)=42.5; % Heat pack was ~42.5?C at the start of the fMRI session
    else
        rating(i,1)=NaN;
    end
    
    % Pull design-matrix from Design-File
    xX=dlmread(currdes{:},'\t',[5, 0, 514,7]); %[Startrow, Starcol, Endrow, Endcol] >> Python-like index starting from 0!!
    % Calculate X-Span
    xSpanRaw=max(xX)-min(xX);
    currcon=dlmread(currconfile{:},' ',[9, 0, 11,7]); %[Startrow, Starcol, Endrow, Endcol] >> Python-like index starting from 0!!
    % Get X-Span for current con
    xSpan(i,1)=xSpanRaw*currcon(conn(i),:)'; %select current con-vector, select xX columns accordingly ;
    nImages(i,1)=size(xX,1);
   
end

% Create a version of ratings on a 101pt-(%)Scale (0%, no pain, 100%, maximum pain)
% Scale was 0 to 4
% 0: no sensation
% 1: nonpainful warmth (the last non-painful (0%) rating)
% 2: pain threshold
% 3: moderate pain
% 4: maximum pain used in experiment
rating101=(rating-5)*100/5;
rating101(rating101<0)=0;

% Create Study-Specific table
ellingsen=table(img);
ellingsen.imgType=repmat({'fMRI'},size(ellingsen.img));
ellingsen.studyType=repmat({'within'},size(ellingsen.img));
ellingsen.studyID=repmat({'ellingsen'},size(ellingsen.img));
ellingsen.subID=strcat(ellingsen.studyID,'_',sub);
ellingsen.male=male;
ellingsen.age=age;
ellingsen.healthy=ones(size(ellingsen.img));%only healthy
ellingsen.pla=pla;
ellingsen.pain=pain;
ellingsen.predictable=zeros(size(ellingsen.img)); %No cues
ellingsen.realTreat=zeros(size(ellingsen.img)); %No real treatment
ellingsen.cond=con_descriptors;
ellingsen.stimtype=repmat({'heat'},size(ellingsen.img));
ellingsen.stimloc=repmat({'L forearm (d)'},size(ellingsen.img));
ellingsen.stimside=repmat({'L'},size(ellingsen.img));
ellingsen.plaForm=repmat({'Nasal spray'},size(ellingsen.img));
ellingsen.plaInduct=repmat({'Suggestions'},size(ellingsen.img));
ellingsen.plaFirst=plaFirst; %Mixed
ellingsen.condSeq=ones(size(ellingsen.img));%All runs always first (Day 1)
ellingsen.condSeq(ellingsen.plaFirst==1&ellingsen.pla==0)=2; %...except placebo 1st no pla
ellingsen.condSeq(ellingsen.plaFirst==0&ellingsen.pla==1)=2; %...except placebo 2nd pla
ellingsen.rating=rating; %These are ratings of HEDONIA (pleasant-unpleasant, not PAIN)... The scale in the paper ranged from -5(unpleasant) to 5 (pleasant). The ratings supplied range from 0 (pleasant) to 10 (unpleasant). To transform apply: (Rating*(-1))+5            
ellingsen.rating101=rating101;
ellingsen.stimInt=temp; %individual from excel;             
ellingsen.fieldStrength=ones(size(ellingsen.img)).*3;
ellingsen.tr           =ones(size(ellingsen.img)).*2000;
ellingsen.te           =ones(size(ellingsen.img)).*30;
ellingsen.voxelVolAcq  =ones(size(ellingsen.img)).*(3*3*3.3);
ellingsen.voxelVolMat  =ones(size(ellingsen.img)).*(2*2*2);
ellingsen.meanBlockDur =ones(size(ellingsen.cond)).*10; % stimulus length according to paper
ellingsen.nImages      =nImages; % Images per Participant
ellingsen.xSpan        =xSpan;
ellingsen.conSpan      =ones(size(ellingsen.img));
ellingsen.fsl          =ones(size(ellingsen.cond)); %analysis with fsl, rather than SPM

%% Save
outpath=fullfile(basedir,'Ellingsen_et_al_2013.mat');
save(outpath,'ellingsen')

end