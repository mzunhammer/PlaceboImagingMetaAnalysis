function Elsenbruch_et_al_2012

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '../../../Datasets/';

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
        %Get x_span from SPM:
        SPMcon=SPM.xCon(beta(j,i)).c;
        x_span(j,i)=xSpanRaw(logical(SPMcon)); %xSpanRaw(logical(SPMcon));
        con_span(j,i)=sum(abs(SPMcon)); %sum(abs(SPMcon));
        n_imgs(j,i)=size(SPM.xX.X,1);
    end
end
img=vertcat(img(:));
beta=vertcat(beta(:));
x_span=vertcat(x_span(:));
con_span=vertcat(con_span(:));
n_imgs=vertcat(n_imgs(:));
% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo  2 = Other
pla(ismember(beta,2),1)=0;
pla(ismember(beta,6),1)=1;
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(ismember(beta,2),1)=1;
pain(ismember(beta,6),1)=1;          

elsenbrxls=fullfile(basedir,studydir,'Elsenbruch_2012_behavioral.xlsx');
%% Import behavioral from Excel-Sheet and Collect all Variables in Table
outpath=fullfile(basedir,'Elsenbruch_et_al_2012.mat')
if exist(outpath)==2
    load(outpath);
else
    elsenb=table(img);
end
elsenb.img=img;
% Create Study-Specific table
elsenb.study_ID=repmat({'elsenbruch'},size(elsenb.img));
elsenb.sub_ID=repmat(strcat('elsenbruch_',elsenbfolders)',nbeta,1);
elsenb.male=repmat(xlsread(elsenbrxls,1,'E:E'),nbeta,1);
elsenb.age=repmat(xlsread(elsenbrxls,1,'C:C'),nbeta,1);
elsenb.healthy=ones(size(elsenb.img));
elsenb.pla=pla;
elsenb.pain=pain;
elsenb.predictable=zeros(size(elsenb.img)); %Uncertainty: 7.5?3.873s Distensions in the scanner were preceded by a brief auditory cue (??warning sig- nal??) in the form of a short beep delivered at pseudorandomized intervals (3 seconds, 6 seconds, 9 seconds, 12 seconds) before"
elsenb.real_treat=zeros(size(elsenb.img));   %just saline
elsenb.cond=vertcat(cond(:));
elsenb.stim_side=repmat({'C'},size(elsenb.img));
elsenb.placebo_first=repmat(xlsread(elsenbrxls,1,'H:H'),nbeta,1);

[~,condSeqRaw]=xlsread(elsenbrxls,1,'F2:F37');
conpos=cell2mat(strfind(condSeqRaw,'P')); %the control condition is called "placebo" in the excel file
plapos=cell2mat(strfind(condSeqRaw,'M')); %the placebo condition is called "medication" in the excel file
elsenb.i_condition_in_sequence=[conpos;...
               plapos];
elsenb.rating=[%xlsread(elsenbrxls,1,'I:I');...
               xlsread(elsenbrxls,1,'I:I');...
               %NaN(nsubj,1);... % Not in Excel File
               %NaN(nsubj,1);... % Not in Excel File
               %xlsread(elsenbrxls,1,'J:J');
               xlsread(elsenbrxls,1,'J:J')]; %Mean pain ratings control from xls              
elsenb.rating101=elsenb.rating; % A 101-scale ranging from "no-pain" to "very much" pain was used.
elsenb.stim_intensity=NaN(size(elsenb.img)); %Unfortunately unknown             
elsenb.imgs_per_stimulus_block =ones(size(elsenb.cond)).*10; % SPM and paper agree
elsenb.n_blocks      =ones(size(elsenb.img)).*8; % Number of blocks per condition and session
elsenb.n_imgs      =n_imgs; % Images per Participant
elsenb.x_span        =x_span;
elsenb.con_span      =ones(size(elsenb.img)); %beta images used
%% Save
save(outpath,'elsenb')

end