function Elsenbruch_et_al_2012

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Elsenbruch_et_al_2012';
%beta_IDs = [1 2 3 4 5 6];
beta_IDs = [2 6];
nbeta=length(beta_IDs);
beta_descriptors= {... % Short version with only the available betas
    'pain_control_0%_analgesia'...
    'pain_placebo_100%_analgesia'...
    };
%beta_descriptors= {...
%    'anticipation_placebo_0%_analgesia'...
%    'pain_placebo_0%_analgesia'...
%    'anticipation_placebo_50%_analgesia'...
%    'pain_placebo_50%_analgesia'...
%    'anticipation_control_100%_analgesia'...
%    'pain_control_100%_analgesia'...
%    };
elsenbfolders=dir(fullfile(basedir,studydir));
elsenbfolders={elsenbfolders.name};
elsenbfolders=elsenbfolders(~cellfun(@isempty,...
                            regexpi(elsenbfolders','^\w\w_\d','match')));
nsubj=length(elsenbfolders);

img={};
for j= 1:nsubj
     currfolder=fullfile(basedir,studydir,elsenbfolders(j),'1st');
     currSPMpath = fullfile(basedir,studydir,elsenbfolders(j),'SPM.mat');
     load(currSPMpath{:});
     xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    for i = 1:length(beta_IDs)
        %Get filenames in a (subj,beta) matrix
        img(j,i) = fullfile(studydir,elsenbfolders(j),'1st', sprintf('beta_00%0.2d.img', beta_IDs(i)));
        %Get subject and con ID in the same (subj,beta) matrix format
        i_sub(j,i)=j;
        beta(j,i)=beta_IDs(i);
        %Get description of conditions in a in (subj,beta) matrix format
        cond(j,i)=beta_descriptors(i); 
        %Get xSpan from SPM:
        SPMcon=SPM.xCon(beta(j,i)).c;
        xSpan(j,i)=xSpanRaw(logical(SPMcon)); %xSpanRaw(logical(SPMcon));
        conSpan(j,i)=sum(abs(SPMcon)); %sum(abs(SPMcon));
        nImages(j,i)=size(SPM.xX.X,1);
    end
end
img=vertcat(img(:));
beta=vertcat(beta(:));
xSpan=vertcat(xSpan(:));
conSpan=vertcat(conSpan(:));
nImages=vertcat(nImages(:));
% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo  2 = Other
pla(ismember(beta,2),1)=0;
pla(ismember(beta,6),1)=1;
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(ismember(beta,2),1)=1;
pain(ismember(beta,6),1)=1;          



%% Import behavioral from Excel-Sheet and Collect all Variables in Table

elsenbrxls=fullfile(basedir,studydir,'Elsenbruch_2012_behavioral.xlsx');
% Create Study-Specific table
elsenb=table(img);
elsenb.imgType=repmat({'fMRI'},size(elsenb.img));
elsenb.studyType=repmat({'within'},size(elsenb.img));
elsenb.studyID=repmat({'elsenbruch'},size(elsenb.img));
elsenb.subID=repmat(strcat('elsenbruch_',elsenbfolders)',nbeta,1);
elsenb.male=repmat(xlsread(elsenbrxls,1,'E:E'),nbeta,1);
elsenb.age=repmat(xlsread(elsenbrxls,1,'C:C'),nbeta,1);
elsenb.healthy=ones(size(elsenb.img));
elsenb.pla=pla;
elsenb.pain=pain;
elsenb.predictable=zeros(size(elsenb.img)); %Uncertainty: 7.5?3.873s Distensions in the scanner were preceded by a brief auditory cue (??warning sig- nal??) in the form of a short beep delivered at pseudorandomized intervals (3 seconds, 6 seconds, 9 seconds, 12 seconds) before"
elsenb.realTreat=zeros(size(elsenb.img));   %just saline
elsenb.cond=vertcat(cond(:));
elsenb.stimtype=repmat({'distension'},size(elsenb.img));
elsenb.stimloc=repmat({'C rectal'},size(elsenb.img));
elsenb.stimside=repmat({'C'},size(elsenb.img));
elsenb.plaForm=repmat({'Intravenous drip'},size(elsenb.img));
elsenb.plaInduct=repmat({'Suggestions'},size(elsenb.img));
elsenb.plaFirst=repmat(xlsread(elsenbrxls,1,'H:H'),nbeta,1);

[~,condSeqRaw]=xlsread(elsenbrxls,1,'F2:F37');
conpos=cell2mat(strfind(condSeqRaw,'P')); %confusingly the control condition is called "placebo" in the excel file
plapos=cell2mat(strfind(condSeqRaw,'M')); %confusingly the placebo condition is called "medication" in the excel file
elsenb.condSeq=[conpos;...
               plapos];

elsenb.rating=[%xlsread(elsenbrxls,1,'I:I');...
               xlsread(elsenbrxls,1,'I:I');...
               %NaN(nsubj,1);... % Not in Excel File
               %NaN(nsubj,1);... % Not in Excel File
               %xlsread(elsenbrxls,1,'J:J');
               xlsread(elsenbrxls,1,'J:J')]; %Mean pain ratings control from xls              
elsenb.rating101=elsenb.rating; % A 101-scale ranging from "no-pain" to "very much" pain was used.
elsenb.stimInt=NaN(size(elsenb.img)); %Unfortunately unknown             
elsenb.fieldStrength=ones(size(elsenb.img)).*1.5;
elsenb.tr           =ones(size(elsenb.img)).*3100;
elsenb.te           =ones(size(elsenb.img)).*50;
elsenb.voxelVolAcq  =ones(size(elsenb.img)).*((240/64) *(240/64) *3.3);
elsenb.voxelVolMat  =ones(size(elsenb.img)).*(2*2*2);
elsenb.meanBlockDur =ones(size(elsenb.cond)).*31; % SPM and paper agree
elsenb.nImages      =nImages; % Images per Participant
elsenb.xSpan        =xSpan;
elsenb.conSpan      =ones(size(elsenb.img)); %beta images used
elsenb.fsl          =zeros(size(elsenb.cond)); %analysis with fsl, rather than SPM

%% Save
outpath=fullfile(basedir,'Elsenbruch_et_al_2012.mat')
save(outpath,'elsenb')

end