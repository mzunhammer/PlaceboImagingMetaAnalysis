function Theysohn_et_al_2014

%% Collects all behavioral data and absolute img-paths for Theyson et al 2014
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '../../../Datasets/';

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
        %Get x_span from SPM:
        x_span(j,i)=xSpanRaw(beta_IDs(i)); %xSpanRaw(logical(SPMcon));
        %con_span(j,i)=sum(abs(SPMcon)); %sum(abs(SPMcon));
        n_imgs(j,i)=size(SPM.xX.X,1);
        switch i
            case 1 %beta 5 'placebo_anticipation'
             imgs_per_stimulus_block(j,i)=mean(SPM.Sess(2).U(2).dur);
             n_blocks(j,i)=length(SPM.Sess(2).U(2).dur);
            case 2 %beta 6 'placebo_pain'
             imgs_per_stimulus_block(j,i)=mean(SPM.Sess(2).U(3).dur);
             n_blocks(j,i)=length(SPM.Sess(2).U(3).dur);
            case 3 %beta 8 'control_anticipation'
             imgs_per_stimulus_block(j,i)=mean(SPM.Sess(3).U(2).dur);
             n_blocks(j,i)=length(SPM.Sess(3).U(2).dur);
            case 4 %beta 9 'control_pain'
             imgs_per_stimulus_block(j,i)=mean(SPM.Sess(3).U(3).dur);
             n_blocks(j,i)=length(SPM.Sess(3).U(3).dur);
        end
    end
end
img=vertcat(img(:));
beta=vertcat(beta(:));
x_span=vertcat(x_span(:));
n_imgs=vertcat(n_imgs(:));
imgs_per_stimulus_block=vertcat(imgs_per_stimulus_block(:));
n_blocks=vertcat(n_blocks(:));

% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo  2 = Other
pla(ismember(beta,5),1)=1;% beta 5
pla(ismember(beta,6),1)=1;% beta 6
pla(ismember(beta,8),1)=0;% beta 8
pla(ismember(beta,9),1)=0;% beta 9
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(ismember(beta,5),1)=0;
pain(ismember(beta,6),1)=1;
pain(ismember(beta,8),1)=0;
pain(ismember(beta,9),1)=1;         

theyrxls=fullfile(basedir,studydir,'Theysohn_et_al_NMO_2014 bereignigte Reihenfolge.xlsx');

%% Collect all Variables in Table
% Create Study-Specific table
they=table(img);
they.img=img;
they.study_ID=repmat({'theysohn'},size(they.img));
they.sub_ID=repmat(strcat('theysohn_',theyfolders)',nbeta,1);
they.male=repmat(xlsread(theyrxls,1,'D:D'),nbeta,1);
they.age=repmat(xlsread(theyrxls,1,'B:B'),nbeta,1);
they.healthy=ones(size(they.img));
they.pla=pla;
they.pain=pain;
they.predictable=zeros(size(they.img)); %Uncertainty: start 2-5s after cue"
they.real_treat=zeros(size(they.img));   %just saline
they.cond=vertcat(cond(:)); 
they.stim_side=repmat({'C'},size(they.img));
they.placebo_first=repmat(xlsread(theyrxls,1,'H:H'),nbeta,1);
they.i_condition_in_sequence=ones(size(they.img));%The baseline run was always first
they.i_condition_in_sequence(they.placebo_first==1&they.pla==0)=3; %The placebo runs were 2nd/3rd according to placebo_first
they.i_condition_in_sequence(they.placebo_first==0&they.pla==0)=2;
they.i_condition_in_sequence(they.placebo_first==0&they.pla==1)=3;
they.rating=[xlsread(theyrxls,1,'F:F');
             xlsread(theyrxls,1,'F:F');
             xlsread(theyrxls,1,'E:E');
             xlsread(theyrxls,1,'E:E')]; %Mean pain ratings control from xls 
they.rating101=they.rating; % A 101-scale ranging from "no-pain" to "very much" pain was used.
they.stim_intensity=NaN(size(they.img)); %Unfortunately unknown             
they.imgs_per_stimulus_block =imgs_per_stimulus_block; % SPM and paper agree
they.n_blocks      =n_blocks; % According to SPM
they.n_imgs      =n_imgs; % Images per Participant
they.x_span        =x_span;
they.con_span      =ones(size(they.img)); %beta images used
%% Save
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_id,'theysohn')),'raw'}={they};
save(fullfile(basedir,'data_frame.mat'),'df');
end