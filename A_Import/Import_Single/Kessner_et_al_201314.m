function Kessner_et_al_2013114

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir = 'Kessner_et_al_201314';
kessnerdir = dir(fullfile(basedir, studydir));
xls_path=fullfile(basedir, studydir,'Kessner_et_al_behavioral.xlsx');
beta_img = {kessnerdir(~cellfun(@isempty,regexp({kessnerdir.name},'^s.*img'))).name}';
img=cellfun(@(x) fullfile(studydir, x),beta_img,'UniformOutput',0);                                               % The absolute image paths

% Get subject numbers
sub=regexp(img,'sub(\d\d)_beta','tokens');
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
plaFirst=repmat(xlsread(xls_path,1,'BA2:BA40'),1,4);
plaFirst=plaFirst';
plaFirst=plaFirst(:);

condSeq=NaN(size(img));
condSeq(~cellfun(@isempty,regexp(beta_img,'placebo'))&plaFirst==1)=1;
condSeq(~cellfun(@isempty,regexp(beta_img,'placebo'))&plaFirst==0)=2;
condSeq(~cellfun(@isempty,regexp(beta_img,'control'))&plaFirst==1)=2;
condSeq(~cellfun(@isempty,regexp(beta_img,'control'))&plaFirst==0)=1;
temp_c=repmat(xlsread(xls_path,1,'I2:I40'),1,4);
temp_c=temp_c';
temp_c=temp_c(:);

temp_p=repmat(xlsread(xls_path,1,'H2:H40'),1,4);
temp_p=temp_p';
temp_p=temp_p(:);

%xSpan (from max(SPM.xX.X)-min(SPM.xX.X))
kessnerSPMs = {kessnerdir(~cellfun(@isempty,regexp({kessnerdir.name},'SPM.mat'))).name}';
for i=1:size(kessnerSPMs)
    load(fullfile(basedir, studydir,kessnerSPMs{i,1}));
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    kessnerxSpans(i,:)=xSpanRaw([1 4 2 5]); % Attention, alphabetic sorting puts anticipation first in image vector!
    nImages(i,:)=size(SPM.xX.X,1);
end
kessnerxSpanslong=(kessnerxSpans');
kessnerxSpanslong=kessnerxSpanslong(:);
xSpan =kessnerxSpanslong;
nImages=repmat(nImages,1,4)';
nImages=nImages(:);

% Create Study-Specific table
kessner=table(img);
kessner.imgType=repmat({'fMRI'},size(kessner.img));
kessner.studyType=repmat({'between'},size(kessner.img));
kessner.studyID=repmat({'kessner'},size(kessner.img));
kessner.subID=strcat(kessner.studyID,'_',[sub{:}]');
kessner.male=male;
kessner.age=age;
kessner.healthy=ones(size(kessner.img));
kessner.pla=pla;
kessner.pain=pain;
kessner.predictable=zeros(size(kessner.img)); %Uncertainty: mean 7.5 range:4-11 second anticipation
kessner.realTreat=zeros(size(kessner.img));
kessner.cond=vertcat(cond(:));
kessner.stimtype=repmat({'heat'},size(kessner.img));
kessner.stimloc=repmat({'L forearm (v)'},size(kessner.img));
kessner.stimside=repmat({'L'},size(kessner.img));
kessner.plaForm=repmat({'Topical Cream/Gel/Patch'},size(kessner.img));
kessner.plaInduct=repmat({'Conditioning'},size(kessner.img));
kessner.plaFirst=plaFirst;
kessner.condSeq=condSeq;
kessner.rating(~cellfun(@isempty,regexp(beta_img,'placebo')),1)=rating_pla_long;
kessner.rating(~cellfun(@isempty,regexp(beta_img,'control')),1)=rating_bl_long;
kessner.stimInt=temp_p;
kessner.stimInt(~cellfun(@isempty,regexp(beta_img,'control')),1)=temp_c(~cellfun(@isempty,regexp(beta_img,'control')),1);         
kessner.stimInt(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)=32;         
kessner.fieldStrength=ones(size(kessner.img)).*3;
kessner.tr           =ones(size(kessner.img)).*2580;
kessner.te           =ones(size(kessner.img)).*26;
kessner.voxelVolAcq  =ones(size(kessner.img)).*((220/110) *(220/110) *(2+1));
kessner.voxelVolMat  =ones(size(kessner.img)).*(2*2*2);
kessner.meanBlockDur =zeros(size(kessner.cond)); % anticipation epochs were zero in length (events)
kessner.meanBlockDur(~cellfun(@isempty, (regexp(beta_img,'pain')))) =20; % other block durations were 20 seconds
kessner.nImages      =nImages; % Images per Participant
kessner.xSpan        =xSpan;
kessner.conSpan      =ones(size(kessner.cond)).*1;

%% Save
outpath=fullfile(basedir,'Kessner_et_al_201314.mat')
save(outpath,'kessner')

end