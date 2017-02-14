function Eippert_et_al_2009

%% Collects all behavioral data and absolute img-paths for eippert 2011
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Eippert_et_al_2009';
eippertdir = dir(fullfile(basedir, studydir));
dirnames={eippertdir.name};
isubfolder=regexp(dirnames,'\d\d');
isubfolder=~cellfun(@isempty,isubfolder); %actual images in dir
% Get paths of subjects as string
subfolder=dirnames(isubfolder);
sub=cellfun(@str2num,dirnames(isubfolder),'UniformOutput',0);
sub=[sub{:}];
con_IDs = [1 2 5 6 9 10]; %define cons of interest
con_descriptors= {...
    'anticipation: placebo'... % con_1
    'anticipation: control'...%con_2
    'pain early: placebo'...% con_5
    'pain early: control'...%con_6
    'pain late: placebo'...%con_9
    'pain late: control'...%con_10
    };
% Get all img-paths
for j=1:length(subfolder)
    currfolder=fullfile(basedir,studydir,subfolder(j));
    load(fullfile(currfolder{:},'SPM.mat')); %Load subject's SPM
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    for i=1:length(con_IDs)
        %Get filenames in a (subj,con) matrix
        img(j,i) = fullfile(studydir,subfolder(j), sprintf('con_00%0.2d.img', con_IDs(i)));
        %Get subject and con ID in the same (subj,con) matrix format
        subs(j,i)=sub(j);
        con(j,i)=con_IDs(i);
        %Get description of conditions in a in (subj,con) matrix format
        cond(j,i)=con_descriptors(i); 
        
        %Get xSpan, conSpan from SPM:
        % Array of xSpans, each corresponding to one predictor(x) in the design
        % matrix
        % Retrieve index for x's contributing to con
        SPMcon=SPM.xCon(con(j,i)).c;
        % Finally, select X-Spans according to Con's
        xSpan(j,i)=xSpanRaw(logical(SPMcon));
        % conSpans are just the absolute sum of current con weights
        conSpan(j,i)=sum(abs(SPMcon));
        % sequence of sessions is easily determined by SPMcon
        % cons in the second sessions have betas >
        seq(j,i)=(find(SPMcon)>4)+1;
        
        nImages(j,i)=size(SPM.xX.X,1);
    end
end
%Matrix to array
img=img(:);
subs=subs(:);
con=con(:);
cond=cond(:);
xSpan=xSpan(:);
conSpan=conSpan(:);
seq=seq(:);
nImages=nImages(:);

% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo 2 = Other
pla(~cellfun(@isempty,regexp(cond,'control')),1)=0;   % 0= Any Control 1 = Any Placebo 2 = Other
pla(~cellfun(@isempty,regexp(cond,'placebo')),1)=1;  % 0= Any Control 1 = Any Placebo 2 = Other
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain=zeros(size(cond));
pain(~cellfun(@isempty,regexp(cond,'pain early')),1)=2;  % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(~cellfun(@isempty,regexp(cond,'pain late')),1)=3;  % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain

%% Import behavioral from Excel-Sheet
xls_path=fullfile(basedir, studydir,'Eippert_wo_missing.xlsx');
xlsid=xlsread(xls_path,1,'A2:A41');
% Gender
male=xlsread(xls_path,1,'B2:B41');
male=repmat(male,6,1);
% Age
age=xlsread(xls_path,1,'C2:C41');
age=repmat(age,6,1);
% Real Treat
realTreat=xlsread(xls_path,1,'D2:D41');
realTreat=repmat(realTreat,6,1);
% Update condition names with group!
cond(logical(realTreat))=strcat(cond(logical(realTreat)),'_naloxone');
cond(~logical(realTreat))=strcat(cond(~logical(realTreat)),'_saline');

% Ratings
rating=NaN(size(cond));
rating_con=xlsread(xls_path,1,'G2:G41');
rating_pla=xlsread(xls_path,1,'H2:H41');
rating(~logical(pla))=repmat(rating_con,3,1);
rating(logical(pla))=repmat(rating_pla,3,1);
% Temps
temps=xlsread(xls_path,1,'F2:F41');
temps=repmat(temps,6,1);
%Add imaging parameters
imgsPerBlock=NaN(size(cond));
imgsPerBlock(~cellfun(@isempty,regexp(cond,'anticipation')),1)=0;
imgsPerBlock(~cellfun(@isempty,regexp(cond,'pain')),1)=3.8168; % late and early pain are 10 seconds each
% Placebo First
plaFirst=xlsread(xls_path,1,'E2:E41');
plaFirst=repmat(plaFirst,6,1);

%% Collect all Variables in Table
outpath=fullfile(basedir,'Eippert_et_al_2009.mat');
if exist(outpath)==2
    load(outpath);
else
    eippert=table(img);
end
eippert.img=img;
eippert.imgType=repmat({'fMRI'},size(eippert.img));
eippert.studyType=repmat({'within'},size(eippert.img));
eippert.studyID=repmat({'eippert'},size(eippert.img));
eippert.subID=strcat(eippert.studyID,'_',repmat(subfolder',6,1));
eippert.male=male;
eippert.age=age;
eippert.healthy=ones(size(eippert.img));
eippert.pla=pla;
eippert.pain=pain;
eippert.predictable= ones(size(eippert.img)); %The anticipatory phase was always 5 s long.
eippert.realTreat=realTreat; %Mark all participants receiving naloxone
eippert.cond=cond;
eippert.stimtype=repmat({'heat'},size(eippert.img));
eippert.stimloc=repmat({'L forearm (v)'},size(eippert.img));
eippert.stimside=repmat({'L'},size(eippert.img));
eippert.plaForm=repmat({'Topical Cream/Gel/Patch'},size(eippert.img));
eippert.plaInduct=repmat({'Suggestions + Conditioning'},size(eippert.img));
eippert.plaFirst=plaFirst;
eippert.condSeq=seq;
eippert.rating=rating;
eippert.rating101=rating; %was 101 scale in original ranging from no pain to "unbearable"
eippert.stimInt=temps; 

eippert.fieldStrength=ones(size(cond)).*3;
eippert.tr           =ones(size(cond)).*2620; %ACCORDING TO SPM, 2.58 according to paper
eippert.te           =ones(size(cond)).*26;
eippert.voxelVolAcq  =ones(size(eippert.img)).*((208/104) *(208/104) *(2+1));
eippert.voxelVolMat  =ones(size(eippert.img)).*(2*2*2);
eippert.imgsPerBlock =imgsPerBlock;
eippert.nBlocks      =ones(size(eippert.img)).*15; % Number of blocks per condition and session
eippert.nImages      =ones(size(eippert.img)).*(2*2*2); % Images per Participant 
eippert.xSpan        =xSpan;
eippert.conSpan      =conSpan;
eippert.fsl          =zeros(size(eippert.cond)); %analysis with fsl, rather than SPM

%% Save
save(outpath,'eippert');

end
