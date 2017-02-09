function Ruetgen_et_al_2015

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

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

%xSpan (from max(SPM.xX.X)-min(SPM.xX.X)) and mean block length
ruetgenSPMs = {ruetgendir(~cellfun(@isempty,regexp({ruetgendir.name},'SPM.mat'))).name}';
for i=1:size(ruetgenSPMs)
load(fullfile(basedir, studydir,ruetgenSPMs{i,1}));
xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
xLength(i,:)=size(SPM.xX.X,1);
ruetgenxSpansNoPain(i,:)=xSpanRaw(2); % Attention, alphabetic sorting puts anticipation first in image vector!
ruetgenxSpansPain(i,:)=xSpanRaw(1); % Attention, alphabetic sorting puts anticipation first in image vector!
ruetgenMeanBlocklengthsNoPain(i,:)=mean(SPM.Sess.U(2).dur);
ruetgenMeanBlocklengthsPain(i,:)=mean(SPM.Sess.U(1).dur);
end

blockLength(pain==1,1)=ruetgenMeanBlocklengthsPain;
blockLength(pain==0,1)=ruetgenMeanBlocklengthsNoPain;

xSpan(pain==1,1)=ruetgenxSpansPain;
xSpan(pain==0,1)=ruetgenxSpansNoPain;

nImages(pain==1,1)=xLength;
nImages(pain==0,1)=xLength;

conSpan    =ones(size(cond)).*1;

% Import behavioral
xls_path= fullfile(basedir, studydir, 'SubjectDataRuetgen2015.xlsx');

age=[xlsread(xls_path,1,'C2:C103')
     xlsread(xls_path,1,'C2:C103')];
male=[xlsread(xls_path,1,'I2:I103')
     xlsread(xls_path,1,'I2:I103')];
stimInt(pain==1,1)=xlsread(xls_path,1,'D2:D103');
stimInt(pain==0,1)=xlsread(xls_path,1,'E2:E103');
rating(pain==1,1)=xlsread(xls_path,1,'F2:F103');
rating(pain==0,1)=xlsread(xls_path,1,'G2:G103'); 
rating101=rating*(100/6); % SEVEN POINT RATING SCALE WITH MAX 6!!! >> Scale to 100%


% Create Study-Specific table
ruetgen=table(img);
ruetgen.imgType=repmat({'fMRI'},size(ruetgen.img));
ruetgen.studyType=repmat({'between'},size(ruetgen.img));
ruetgen.studyID=repmat({'ruetgen'},size(ruetgen.img));
ruetgen.subID=strcat(ruetgen.studyID,'_',sub);
ruetgen.male=male;
ruetgen.age=age;
ruetgen.healthy=ones(size(ruetgen.img));
ruetgen.pla=pla;
ruetgen.pain=pain;
ruetgen.predictable=zeros(size(ruetgen.img)); %Uncertainty: mean 3.5 range: 2-5 seconds anticipation
ruetgen.realTreat=zeros(size(ruetgen.img));
ruetgen.cond=vertcat(cond(:));
ruetgen.stimtype=repmat({'electrical'},size(ruetgen.img));
ruetgen.stimloc=repmat({'L hand (d)'},size(ruetgen.img));
ruetgen.stimside=repmat({'L'},size(ruetgen.img));
ruetgen.plaForm=repmat({'Pill'},size(ruetgen.img));
ruetgen.plaInduct=repmat({'Suggestions + Conditioning'},size(ruetgen.img));
ruetgen.plaFirst=ones(size(ruetgen.img));% Parallel group design with pill>> placebo always first session
ruetgen.condSeq=ones(size(ruetgen.img));% Parallel group design with pill>>  only first sessions
ruetgen.rating=rating;
ruetgen.rating101=rating101;
ruetgen.stimInt=stimInt;       
ruetgen.fieldStrength=ones(size(ruetgen.img)).*3;
ruetgen.tr           =ones(size(ruetgen.img)).*1800;
ruetgen.te           =ones(size(ruetgen.img)).*33;
ruetgen.voxelVolAcq  =ones(size(ruetgen.img)).*((192/128) *(192/128) *2);
ruetgen.voxelVolMat  =ones(size(ruetgen.img)).*(2*2*2);
ruetgen.meanBlockDur =blockLength; %According to SPMs
ruetgen.nImages      =nImages; % Images per Participant
ruetgen.xSpan        =xSpan;
ruetgen.conSpan      =ones(size(ruetgen.cond)).*1;
ruetgen.fsl          =zeros(size(ruetgen.cond)); %analysis with fsl, rather than SPM


%% Save
outpath=fullfile(basedir,'Ruetgen_et_al_2015.mat')
save(outpath,'ruetgen')

end