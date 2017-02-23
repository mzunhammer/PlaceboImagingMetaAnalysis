function Wager_et_al_2004b_michigan_heat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Import Wager_et_al_2004: Study 2 (michigan heat)

studydir = 'Wager_et_al_2004/Study2_Michigan_heat';
load(fullfile(basedir,studydir,'EXPT.mat'));
% Get subject-directorys from EXPT.mat
subdir=EXPT.subdir;

% Determine the betas for placebo/control from the contrasts saved in xCon
for i=1:length(subdir)
    currpath=fullfile(basedir,studydir,subdir{i},'xCon.mat');
    load(currpath);
    pain_pla_cont(i,:)=xCon(15).c';
    anti_pla_cont(i,:)=xCon(11).c';
end

[beta_ID(:,1),~]=find(pain_pla_cont'==1);   % beta images placebo + pain
[beta_ID(:,2),~]=find(pain_pla_cont'==-1);  % beta images control + pain
[beta_ID(:,3),~]=find(anti_pla_cont'==1);   % beta images placebo + pain
[beta_ID(:,4),~]=find(anti_pla_cont'==-1);  % beta images control + pain

for j=1:length(subdir)
     currpath=fullfile(studydir,subdir{j});
     load(fullfile(basedir,currpath,'SPM_fMRIDesMtx.mat')); %For determining xSpan, pre-load the SPM for that subject
     xSpanRaw=max(xX.X)-min(xX.X);
    for i=1:size(beta_ID,2)
        %Get filenames in a (subj,con) matrix
        img{j,i} = fullfile(studydir,subdir{j},sprintf('beta_00%0.2d.img', beta_ID(j,i)));
        sub(j,i)=subdir(j); % The subject number (study specific)
        xSpan(j,i)=xSpanRaw(beta_ID(j,i)); % Gets xSpan for betas one at a time
        nImages(j,i)=size(xX.X,1);
        switch beta_ID(j,i)
            case 2
            imgsPerBlock(j,i)=4/1.5; %not sure where to find block duration in SPM99, using information from paper
            nBlocks(j,i)=length(Sess{1,1}.ons{1,2}); 
            case 4
            imgsPerBlock(j,i)=10/1.5; %not sure where to find block duration in SPM99, using information from paper
            nBlocks(j,i)=length(Sess{1,1}.ons{1,4});
            case 8
            imgsPerBlock(j,i)=4/1.5;
            nBlocks(j,i)=length(Sess{1,2}.ons{1,2});
            case 10
            imgsPerBlock(j,i)=10/1.5;
            nBlocks(j,i)=length(Sess{1,2}.ons{1,4});
        end
    end
end

pla(1:length(subdir),[1 3])=1;    % 0= Any Control 1 = Any Placebo 2 = Other
pla(1:length(subdir),[2 4])=0;    % 0= Any Control 1 = Any Placebo 2 = Other
pain(1:length(subdir),[1 2])=1;   % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(1:length(subdir),[3 4])=0;   % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain

cond(1:length(subdir),1)={'placebo_pain'};         % A string describing the experimental condition
cond(1:length(subdir),2)={'control_pain'};         % A string describing the experimental condition
cond(1:length(subdir),3)={'placebo_anticipation'};         % A string describing the experimental condition
cond(1:length(subdir),4)={'control_anticipation'};         % A string describing the experimental condition

img      = vertcat(img(:)); 
sub      = vertcat(sub(:));
pla      = vertcat(pla(:));
pain     = vertcat(pain(:));
xSpan    = vertcat(xSpan(:));
cond     = vertcat(cond(:));
nBlocks  = vertcat(nBlocks(:));
imgsPerBlock = vertcat(imgsPerBlock(:));


placebo_first=NaN(size(cond));        
rating= NaN(size(cond));
rating(strcmp(cond,'placebo_pain'))=EXPT.behavior; % ATTENTION: Unfortunately for images placebo & control are available as separate conditions, while for behavior only the contrast control-placebo is available...

% Create Study-Specific table

outpath=fullfile(basedir,'Wager_et_al_2004b_michigan_heat.mat');
if exist(outpath)==2
    load(outpath);
else
    wager_michigan=table(img);
end
wager_michigan.img=img;
wager_michigan.imgType=repmat({'fMRI'},size(wager_michigan.img));
wager_michigan.studyType=repmat({'within'},size(wager_michigan.img));
wager_michigan.studyID=repmat({'wager04b_michigan'},size(wager_michigan.img));
wager_michigan.subID=strcat(wager_michigan.studyID,'_',sub);
wager_michigan.male=NaN(size(wager_michigan.img));
wager_michigan.age=NaN(size(wager_michigan.img));
wager_michigan.healthy=ones(size(wager_michigan.img));
wager_michigan.pla=pla;
wager_michigan.pain=pain;
wager_michigan.predictable=zeros(size(wager_michigan.img)); %Uncertainty: mean 9 (1-16) seconds anticipation
wager_michigan.realTreat=zeros(size(wager_michigan.img));
wager_michigan.cond=vertcat(cond(:));
wager_michigan.stimtype=repmat({'heat'},size(wager_michigan.img));
wager_michigan.stimloc=repmat({'L forearm (v)'},size(wager_michigan.img));
wager_michigan.stimside=repmat({'L'},size(wager_michigan.img));
wager_michigan.plaForm=repmat({'Topical Cream/Gel/Patch'},size(wager_michigan.img));
wager_michigan.plaInduct=repmat({'Suggestions + Conditioning'},size(wager_michigan.img));
wager_michigan.plaFirst=NaN(size(wager_michigan.img));
wager_michigan.condSeq=NaN(size(wager_michigan.img));
wager_michigan.rating=rating;
wager_michigan.rating101=rating*10; % an 11 pt-scale ranging from 0 (non painful) to 10 (unbearable) was used.
wager_michigan.stimInt=NaN(size(wager_michigan.img));       

wager_michigan.fieldStrength=ones(size(wager_michigan.img)).*3;
wager_michigan.tr           =ones(size(wager_michigan.img)).*1500;
wager_michigan.te           =ones(size(wager_michigan.img)).*20;
wager_michigan.voxelVolAcq  =ones(size(wager_michigan.img)).*(3.75*3.75*5);
wager_michigan.voxelVolMat  =ones(size(wager_michigan.img)).*(3.75*3.75*5);
wager_michigan.imgsPerBlock =imgsPerBlock;
wager_michigan.nBlocks      =nBlocks; % According to SPM
wager_michigan.nImages      =vertcat(nImages(:)); % Images per Participant
wager_michigan.xSpan        =xSpan;
wager_michigan.conSpan      =ones(size(wager_michigan.cond));
wager_michigan.fsl          =zeros(size(wager_michigan.cond)); %analysis with fsl, rather than SPM

%% Save
save(outpath,'wager_michigan')

end