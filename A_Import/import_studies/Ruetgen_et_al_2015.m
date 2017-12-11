function Ruetgen_et_al_2015

%% Set working environment
clear
basedir = '../../../Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir = 'Ruetgen_et_al_2015';
ruetgendir = dir(fullfile(basedir, studydir));
con_img = {ruetgendir(~cellfun(@isempty,regexp({ruetgendir.name},'^\w\d\d\d.*img'))).name}';
img=cellfun(@(x) fullfile(studydir, x),con_img,'UniformOutput',0);                                               % The absolute image paths

% Get subjects
subc=regexp(img,'Ruetgen_et_al_2015/c(\d\d\d)_con','tokens'); % Make separate IDs for control and placebo group
subc=[subc{:}];subc=strcat('c',[subc{:}]');
subp=regexp(img,'Ruetgen_et_al_2015/p(\d\d\d)_con','tokens');
subp=[subp{:}];subp=strcat('p',[subp{:}]');
sub=[subc;subp];

pla(ismember(sub,subc),1)=0;       % 0= Any Control 1 = Any Placebo 2 = Other
pla(ismember(sub,subp),1)=1;       % 0= Any Control 1 = Any Placebo 2 = Other

pain=~cellfun(@isempty,regexp(con_img,'con_0001'));         % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain  

cond=cell(size(pain));
cond(pain==0&pla==0)={'Self_NoPain_Control_Group'};
cond(pain==1&pla==0)={'Self_Pain_Control_Group'};
cond(pain==0&pla==1)={'Self_NoPain_Placebo_Group'};
cond(pain==1&pla==1)={'Self_Pain_Placebo_Group'};

%x_span (from max(SPM.xX.X)-min(SPM.xX.X)) and mean block length
ruetgenSPMs = {ruetgendir(~cellfun(@isempty,regexp({ruetgendir.name},'SPM.mat'))).name}';
for i=1:size(ruetgenSPMs)
load(fullfile(basedir, studydir,ruetgenSPMs{i,1}));
xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
xLength(i,:)=size(SPM.xX.X,1);
ruetgenxSpansNoPain(i,:)=xSpanRaw(2); % Attention, alphabetic sorting puts anticipation first in image vector!
ruetgenxSpansPain(i,:)=xSpanRaw(1); % Attention, alphabetic sorting puts anticipation first in image vector!
ruetgenMeanimgsPerBlocksNoPain(i,:)=mean(SPM.Sess.U(2).dur)/SPM.xY.RT; % R?tgen used seconds as a unit of analysis  
ruetgenMeanimgsPerBlocksPain(i,:)=mean(SPM.Sess.U(1).dur)/SPM.xY.RT; % R?tgen used seconds as a unit of analysis
ruetgennBlocksNoPain(i,:)=length(SPM.Sess.U(2).dur); % R?tgen used seconds as a unit of analysis  
ruetgennBlocksBlocksPain(i,:)=length(SPM.Sess.U(1).dur); % R?tgen used seconds as a unit of analysis
end

imgs_per_stimulus_block(pain==1,1)=ruetgenMeanimgsPerBlocksPain;
imgs_per_stimulus_block(pain==0,1)=ruetgenMeanimgsPerBlocksNoPain;

n_blocks(pain==1,1)=ruetgennBlocksBlocksPain;
n_blocks(pain==0,1)=ruetgennBlocksNoPain;

x_span(pain==1,1)=ruetgenxSpansPain;
x_span(pain==0,1)=ruetgenxSpansNoPain;

n_imgs(pain==1,1)=xLength;
n_imgs(pain==0,1)=xLength;

con_span    =ones(size(cond)).*1;

% Import behavioral
xls_path= fullfile(basedir, studydir, 'SubjectDataRuetgen2015.xlsx');

age=[xlsread(xls_path,1,'C2:C103')
     xlsread(xls_path,1,'C2:C103')];
male=[xlsread(xls_path,1,'I2:I103')
     xlsread(xls_path,1,'I2:I103')];
stim_intensity(pain==1,1)=xlsread(xls_path,1,'D2:D103');
stim_intensity(pain==0,1)=xlsread(xls_path,1,'E2:E103');
rating(pain==1,1)=xlsread(xls_path,1,'F2:F103');
rating(pain==0,1)=xlsread(xls_path,1,'G2:G103'); 
rating101=rating*(100/6); % SEVEN POINT RATING SCALE WITH MAX 6!!! >> Scale to 100%


% Create Study-Specific table
outpath=fullfile(basedir,'Ruetgen_et_al_2015.mat');
if exist(outpath)==2
    load(outpath);
else
    ruetgen=table(img);
end
ruetgen.img=img;
ruetgen.study_ID=repmat({'ruetgen'},size(ruetgen.img));
ruetgen.sub_ID=strcat(ruetgen.study_ID,'_',sub);
ruetgen.male=male;
ruetgen.age=age;
ruetgen.healthy=ones(size(ruetgen.img));
ruetgen.pla=pla;
ruetgen.pain=pain;
ruetgen.predictable=zeros(size(ruetgen.img)); %Uncertainty: mean 3.5 range: 2-5 seconds anticipation
ruetgen.real_treat=zeros(size(ruetgen.img));
ruetgen.cond=vertcat(cond(:));
ruetgen.stim_side=repmat({'L'},size(ruetgen.img));
ruetgen.placebo_first=ones(size(ruetgen.img));% Parallel group design with pill>> placebo always first session
ruetgen.i_condition_in_sequence=ones(size(ruetgen.img));% Parallel group design with pill>>  only first sessions
ruetgen.rating=rating;
ruetgen.rating101=rating101;
ruetgen.stim_intensity=stim_intensity;       
ruetgen.imgs_per_stimulus_block =imgs_per_stimulus_block; %According to SPMs
ruetgen.n_blocks      =n_blocks; % According to SPM
ruetgen.n_imgs      =n_imgs; % Images per Participant
ruetgen.x_span        =x_span;
ruetgen.con_span      =ones(size(ruetgen.cond)).*1;

%% Save
save(outpath,'ruetgen')

end