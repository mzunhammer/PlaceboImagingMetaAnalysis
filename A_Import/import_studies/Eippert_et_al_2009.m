function Eippert_et_al_2009

%% Collects all behavioral data and absolute img-paths for eippert 2011
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '../../../Datasets/';

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
        
        %Get x_span, con_span from SPM:
        % Array of xSpans, each corresponding to one predictor(x) in the design
        % matrix
        % Retrieve index for x's contributing to con
        SPMcon=SPM.xCon(con(j,i)).c;
        % Finally, select X-Spans according to Con's
        x_span(j,i)=xSpanRaw(logical(SPMcon));
        % conSpans are just the absolute sum of current con weights
        con_span(j,i)=sum(abs(SPMcon));
        % sequence of sessions is easily determined by SPMcon
        % cons in the second sessions have betas >
        seq(j,i)=(find(SPMcon)>4)+1;
        
        n_imgs(j,i)=size(SPM.xX.X,1);
    end
end
%Matrix to array
img=img(:);
subs=subs(:);
con=con(:);
cond=cond(:);
x_span=x_span(:);
con_span=con_span(:);
seq=seq(:);
n_imgs=n_imgs(:);

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
real_treat=xlsread(xls_path,1,'D2:D41');
real_treat=repmat(real_treat,6,1);
% Update condition names with group!
cond(logical(real_treat))=strcat(cond(logical(real_treat)),'_naloxone');
cond(~logical(real_treat))=strcat(cond(~logical(real_treat)),'_saline');

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
imgs_per_stimulus_block=NaN(size(cond));
imgs_per_stimulus_block(~cellfun(@isempty,regexp(cond,'anticipation')),1)=0;
imgs_per_stimulus_block(~cellfun(@isempty,regexp(cond,'pain')),1)=3.8168; % late and early pain are 10 seconds each
% Placebo First
placebo_first=xlsread(xls_path,1,'E2:E41');
placebo_first=repmat(placebo_first,6,1);

%% Collect all Variables in Table
eippert=table(img);
eippert.img=img;
eippert.study_ID=repmat({'eippert'},size(eippert.img));
eippert.sub_ID=strcat(eippert.study_ID,'_',repmat(subfolder',6,1));
eippert.male=male;
eippert.age=age;
eippert.healthy=ones(size(eippert.img));
eippert.pla=pla;
eippert.pain=pain;
eippert.predictable= ones(size(eippert.img)); %The anticipatory phase was always 5 s long.
eippert.real_treat=real_treat; %Mark all participants receiving naloxone
eippert.cond=cond;
eippert.stim_side=repmat({'L'},size(eippert.img));
eippert.placebo_first=placebo_first;
eippert.i_condition_in_sequence=seq;
eippert.rating=rating;
eippert.rating101=rating; %was 101 scale in original ranging from no pain to "unbearable"
eippert.stim_intensity=temps; 
eippert.imgs_per_stimulus_block =imgs_per_stimulus_block;
eippert.n_blocks      =ones(size(eippert.img)).*15; % Number of blocks per condition and session
eippert.n_imgs      =n_imgs; % Images per Participant 
eippert.x_span        =x_span;
eippert.con_span      =con_span;
%% Save in data_frame
load(fullfile(basedir,'data_frame.mat'))
df{find(strcmp(df.study_id,'eippert')),'raw'}={eippert};
save(fullfile(basedir,'data_frame.mat'),'df');
end
