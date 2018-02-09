function Kessner_et_al_2013114(datapath)

%% Set working environment

basedir = datapath;

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir = 'Kessner_et_al_201314';
kessnerdir = dir(fullfile(basedir, studydir));
xls_path=fullfile(basedir, studydir,'Kessner_et_al_behavioral.xlsx');
beta_img = {kessnerdir(~cellfun(@isempty,regexp({kessnerdir.name},'^sub\d\d.*img'))).name}';
img=cellfun(@(x) fullfile(studydir, x),beta_img,'UniformOutput',0);                                               % The absolute image paths

% Get subject numbers
sub=regexp(img,'.*/sub(\d\d)_beta','tokens');
sub=[sub{:}]';

% Import behavioral from excel
group=xlsread(xls_path,1,'B2:B40');
group_long=repmat(group,1,4)';
group_long=group_long(:);

rating_bl  =xlsread(xls_path,1,'C2:C40');
rating_pla =xlsread(xls_path,1,'D2:D40');
rating_bl_long= repmat(rating_bl,1,2)';
rating_bl_long=rating_bl_long(:);
rating_pla_long= repmat(rating_pla,1,2)';
rating_pla_long=rating_pla_long(:);

cond=regexp(beta_img,'beta_(.*).img','tokens');
cond=[cond{:}]';
cond=[cond{:}]';
cond(group_long==1)=strcat(cond(group_long==1),'_pos');
cond(group_long==0)=strcat(cond(group_long==0),'_neg');

% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo 2 = Other
pla(~cellfun(@isempty,regexp(beta_img,'placebo')),1)=1;
pla(~cellfun(@isempty,regexp(beta_img,'control')),1)=0;
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(~cellfun(@isempty,regexp(beta_img,'pain')),1)=1;  
pain(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)=0;

male=repmat(xlsread(xls_path,1,'K2:K40'),1,4);male=male';male=male(:);
age=repmat(xlsread(xls_path,1,'J2:J40'),1,4);age=age';age=age(:);
placebo_first=repmat(xlsread(xls_path,1,'BA2:BA40'),1,4);
placebo_first=placebo_first';
placebo_first=placebo_first(:);

i_condition_in_sequence=NaN(size(beta_img));
i_condition_in_sequence(~cellfun(@isempty,regexp(beta_img,'placebo'))&(placebo_first==1))=1;
i_condition_in_sequence(~cellfun(@isempty,regexp(beta_img,'placebo'))&(placebo_first==0))=2;
i_condition_in_sequence(~cellfun(@isempty,regexp(beta_img,'control'))&(placebo_first==1))=2;
i_condition_in_sequence(~cellfun(@isempty,regexp(beta_img,'control'))&(placebo_first==0))=1;
temp_c=repmat(xlsread(xls_path,1,'I2:I40'),1,4);
temp_c=temp_c';
temp_c=temp_c(:);

temp_p=repmat(xlsread(xls_path,1,'H2:H40'),1,4);
temp_p=temp_p';
temp_p=temp_p(:);

%x_span (from max(SPM.xX.X)-min(SPM.xX.X))
kessnerSPMs = {kessnerdir(~cellfun(@isempty,regexp({kessnerdir.name},'SPM.mat'))).name}';
for i=1:size(kessnerSPMs)
    load(fullfile(basedir, studydir,kessnerSPMs{i,1}));
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    kessnerxSpans(i,:)=xSpanRaw([1 4 2 5]); % Attention, alphabetic sorting puts anticipation first in image vector!
    n_imgs(i,:)=size(SPM.xX.X,1);
    imgsPerBlock_anti_control(i,1)=mean(SPM.Sess(1).U(1).dur);
    imgsPerBlock_anti_treatment(i,1)=mean(SPM.Sess(2).U(1).dur);
    imgsPerBlock_pain_control(i,1)=mean(SPM.Sess(1).U(2).dur);
    imgsPerBlock_pain_treatment(i,1)=mean(SPM.Sess(2).U(2).dur);
    nBlocks_anti_control(i,1)=length(SPM.Sess(1).U(1).dur);
    nBlocks_anti_treatment(i,1)=length(SPM.Sess(2).U(1).dur);
    nBlocks_pain_control(i,1)=length(SPM.Sess(1).U(2).dur);
    nBlocks_pain_treatment(i,1)=length(SPM.Sess(2).U(2).dur);
end

kessnerxSpanslong=(kessnerxSpans');
kessnerxSpanslong=kessnerxSpanslong(:);
x_span =kessnerxSpanslong;
n_imgs=repmat(n_imgs,1,4)';
n_imgs=n_imgs(:);

imgs_per_stimulus_block=[imgsPerBlock_anti_control,imgsPerBlock_anti_treatment,imgsPerBlock_pain_control,imgsPerBlock_pain_treatment]';
imgs_per_stimulus_block=imgs_per_stimulus_block(:);
n_blocks=[nBlocks_anti_control,nBlocks_anti_treatment,nBlocks_pain_control,nBlocks_pain_treatment]';
n_blocks=imgs_per_stimulus_block(:);

% Create Study-Specific table
kessner=table(img);
kessner.img=img;
kessner.study_ID=repmat({'kessner'},size(kessner.img));
kessner.sub_ID=strcat(kessner.study_ID,'_',[sub{:}]');
kessner.male=male;
kessner.age=age;
kessner.healthy=ones(size(kessner.img));
kessner.pla=pla;
kessner.pain=pain;
kessner.predictable=zeros(size(kessner.img)); %Uncertainty: mean 7.5 range:4-11 second anticipation
kessner.real_treat=zeros(size(kessner.img));
kessner.cond=vertcat(cond(:));
kessner.stim_side=repmat({'L'},size(kessner.img));
kessner.placebo_first=placebo_first;
kessner.i_condition_in_sequence=i_condition_in_sequence;
kessner.rating(~cellfun(@isempty,regexp(beta_img,'placebo')),1)=rating_pla_long;
kessner.rating(~cellfun(@isempty,regexp(beta_img,'control')),1)=rating_bl_long;
kessner.rating101=kessner.rating; % A 101-pt VAS ranging from "no pain" to "unbearable pain" was used.
kessner.stim_intensity=temp_p;
kessner.stim_intensity(~cellfun(@isempty,regexp(beta_img,'control')),1)=temp_c(~cellfun(@isempty,regexp(beta_img,'control')),1);         
kessner.stim_intensity(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)=32;         
kessner.imgs_per_stimulus_block =imgs_per_stimulus_block; % According to SPM
kessner.n_blocks      =n_blocks; % According to SPM
kessner.n_imgs      =n_imgs; % Images per Participant
kessner.x_span        =x_span;
kessner.con_span      =ones(size(kessner.cond)).*1;

%% Save in data_frame
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_ID,'kessner')),'raw'}={kessner};
save(fullfile(basedir,'data_frame.mat'),'df');
end