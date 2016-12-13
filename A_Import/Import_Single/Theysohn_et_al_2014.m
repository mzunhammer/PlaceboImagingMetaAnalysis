function Theysohn_et_al_2014

%% Collects all behavioral data and absolute img-paths for Theyson et al 2014
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Theysohn_et_al_2014';

% According to the published paper:
% Session 1 was always no placebo (adaption)
% >> Always import as placebo
% Session 2 and 3 were placebo or no-placebo (counterbalanced sequence),
% but the contol ("NaCl") session was always enterd as SESSION 2
% and the PLACEBO ("Med") SESSION AS SESSION 3 (ACCORDING TO ALL CONs specified in the SPMs)
beta_IDs = [5 6 8 9];
nbeta=length(beta_IDs);
beta_descriptors= {...
    'placebo_anticipation'...   % beta 5
    'placebo_pain'...           % beta 6
    'control_anticipation'...   % beta 8
    'control_pain'...           % beta 9
    };
%% Load Excel-Sheet first (necessary to identify placebo/control betas)

theyfolders=dir(fullfile(basedir,studydir));
theyfolders={theyfolders.name};
theyfolders=theyfolders(~cellfun(@isempty,...
                            regexpi(theyfolders','^\d\d\d\d','match')));

subs=theyfolders;
nsubj=length(theyfolders);
img={};

for j= 1:nsubj
     currfolder=fullfile(basedir,studydir,theyfolders(j),'1st');
     currSPMpath = fullfile(basedir,studydir,theyfolders(j),'SPM.mat');
     load(currSPMpath{:});
     xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    for i = 1:length(beta_IDs)
        %Get filenames in a (subj,beta) matrix
        img(j,i) = fullfile(studydir,theyfolders(j), sprintf('beta_00%0.2d.img', beta_IDs(i)));
        %Get subject and con ID in the same (subj,beta) matrix format
        i_sub(j,i)=j;
        sub(j,i)=theyfolders(j);
        beta(j,i)=beta_IDs(i);
        %Get description of conditions in a in (subj,beta) matrix format
        cond(j,i)=beta_descriptors(i); 
        %Get xSpan from SPM:
        xSpan(j,i)=xSpanRaw(beta_IDs(i)); %xSpanRaw(logical(SPMcon));
        %conSpan(j,i)=sum(abs(SPMcon)); %sum(abs(SPMcon));
        nImages(j,i)=size(SPM.xX.X,1);
    end
end
img=vertcat(img(:));
beta=vertcat(beta(:));
xSpan=vertcat(xSpan(:));
nImages=vertcat(nImages(:));

% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo  2 = Other
pla(ismember(beta,5),1)=0;% beta 5
pla(ismember(beta,6),1)=0;% beta 6
pla(ismember(beta,8),1)=1;% beta 8
pla(ismember(beta,9),1)=1;% beta 9
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(ismember(beta,5),1)=0;
pain(ismember(beta,6),1)=1;
pain(ismember(beta,8),1)=0;
pain(ismember(beta,9),1)=1;         

%% Collect all Variables in Table
% Create Study-Specific table
theyrxls=fullfile(basedir,studydir,'Theysohn_et_al_NMO_2014 bereignigte Reihenfolge.xlsx');

they=table(img);
they.imgType=repmat({'fMRI'},size(they.img));
they.studyType=repmat({'within'},size(they.img));
they.studyID=repmat({'theysohn'},size(they.img));
they.subID=repmat(strcat('theysohn_',theyfolders)',nbeta,1);
they.male=repmat(xlsread(theyrxls,1,'D:D'),nbeta,1);
they.age=repmat(xlsread(theyrxls,1,'B:B'),nbeta,1);
they.healthy=ones(size(they.img));
they.pla=pla;
they.pain=pain;
they.predictable=zeros(size(they.img)); %Uncertainty: start 2-5s after cue"
they.realTreat=zeros(size(they.img));   %just saline
they.cond=vertcat(cond(:)); 
they.stimtype=repmat({'distension'},size(they.img));
they.stimloc=repmat({'C rectal'},size(they.img));
they.stimside=repmat({'C'},size(they.img));
they.plaForm=repmat({'Intravenous drip'},size(they.img));
they.plaInduct=repmat({'Suggestions'},size(they.img));
they.plaFirst=repmat(xlsread(theyrxls,1,'H:H'),nbeta,1);
they.condSeq=ones(size(they.img));%The baseline run was always first
they.condSeq(they.plaFirst==1&they.pla==0)=3; %The placebo runs were 2nd/3rd according to plaFirst
they.condSeq(they.plaFirst==0&they.pla==0)=2;
they.condSeq(they.plaFirst==0&they.pla==1)=3;
they.rating=[xlsread(theyrxls,1,'F:F');
             xlsread(theyrxls,1,'F:F');
             xlsread(theyrxls,1,'E:E');
             xlsread(theyrxls,1,'E:E')]; %Mean pain ratings control from xls 
they.stimInt=NaN(size(they.img)); %Unfortunately unknown             
they.fieldStrength=ones(size(they.img)).*1.5;
they.tr           =ones(size(they.img)).*2400; %Paper and SPM match
they.te           =ones(size(they.img)).*26;
they.voxelVolAcq  =ones(size(they.img)).*((240/94) *(240/94) *3);
they.voxelVolMat  =ones(size(they.img)).*(2*2*2);
they.meanBlockDur =ones(size(they.cond)).*16.8; % SPM and paper agree
they.nImages      =nImages; % Images per Participant
they.xSpan        =xSpan;
they.conSpan      =ones(size(they.img)); %beta images used

%% Save
outpath=fullfile(basedir,'Theysohn_et_al_2014.mat')
save(outpath,'they')

end