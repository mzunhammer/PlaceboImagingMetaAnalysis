%% Set working environment
clear
datadir = '../../Datasets/';

%% Predefine empty variables and data table
img=cell(1,1);                %path of image relative to basedir
imgType=cell(1,1);            %fMRI, PET, ASL
studyType=cell(1,1);          %Within- or between-subject design
studyID=cell(1,1);            %name of study
subID=cell(1,1);              %unique subj ID
male=NaN(1,1);                %subj gender (1 male, 0 female)
age=NaN(1,1);                 %age in y
healthy=NaN(1,1);             %healthy (1), patient (0)
pla=NaN(1,1);                 %image in some placebo (1), or control condition (0), or other (e.g. nocebo) condition (2)
pain=NaN(1,1);                %image in some pain (1), or control condition (0). Can also be: Early(2) and late(3) pain.
predictable=NaN(1,1);         %stimulus type was reliably cued (1) or more or less unpredictable (0)
realTreat=NaN(1,1);           %an additional treatment condition (e.g. medication) was present (1) or not (0)
cond=cell(1,1);               %a string describing the experimental condition according to the original publication
stimtype=cell(1,1);           %a string describing the experimental pain stimulus
stimloc=cell(1,1);            %a string describing the location of experimental pain stimulation
stimside=cell(1,1);           %a string describing the body-side of experimental pain stimulation (L=left, R=right, C=center)
plaFirst=NaN(1,1);            %was the placebo (1) or control (0) acquired first
plaForm=NaN(1,1);             %type of placebo treatment used
plaInduct=NaN(1,1);           %type of placebo induction used (suggestions or suggestions+experience)
condSeq=NaN(1,1);             %was the condition acquired first, second... etc. during the experiment?
rating=NaN(1,1);              %calcualted as within-study z-Value, to account for between-study differences in scaling of behavioral pain measures
stimInt=NaN(1,1);             %calcualted as within-study z-Value, to account for between-study differences in scaling of pain stimulation method
fieldStrgth=NaN(1,1);         %for fMRI studies in T
tr=NaN(1,1);                  %time of repetition for fMRI studies in ms
te=NaN(1,1);                  %echo time for fMRI studies in ms
voxelVolAcq=NaN(1,1);         %Voxel volume of raw images at acquisition in mm^3
voxelVolMat=NaN(1,1);         %Voxel volume of images used in analysis in mm^3 (voxel size is often changed during normalization)
meanBlockDur=NaN(1,1);        %mean duration of single blocks summarized by the img (from SPM or paper)
stimDur=NaN(1,1);             %actual stimulus duration(from paper)
nImages=NaN(1,1);             %number of images per session (on a by-condition&subject basis based on SPMs)
xSpan=NaN(1,1);               %max-min predictor weight given by SPM when calculating the design matrix... varies according to block length due to HRS-convolution
conSpan=NaN(1,1);             %in case con-images are used: difference in predictor weights between conditions
NPSraw=NaN(1,1);             %in case con-images are used: difference in predictor weights between conditions
NPScorrected=NaN(1,1);             %in case con-images are used: difference in predictor weights between conditions
grey=NaN(1,1);
white=NaN(1,1);
csf=NaN(1,1);
brain=NaN(1,1);
nobrain=NaN(1,1);

% Create empty dataframe
df=table(img,...
imgType,...
studyType,...
studyID,...
subID,...
male,...
age,...
healthy,...
pla,...
pain,...
predictable,...
realTreat,...
cond,...
stimtype,...
stimloc,...
stimside,...
plaFirst,...
plaForm,...
plaInduct,...
condSeq,...
rating,...
stimInt,...
fieldStrgth,...
tr,...
te,...
voxelVolAcq,...
voxelVolMat,...
meanBlockDur,...
stimDur,...
nImages,...
xSpan,...
conSpan,...
NPSraw,...
NPScorrected,...
grey,...
white,...
csf,...
brain,...
nobrain);

%% Import all study df's
load([datadir, 'Atlas_et_al_2012.mat'])
load([datadir, 'Bingel_et_al_2006.mat'])
load([datadir, 'Bingel_et_al_2011.mat'])
load([datadir, 'Choi_et_al_2013.mat'])
load([datadir, 'Eippert_et_al_2009.mat'])
load([datadir, 'Ellingsen_et_al_2013.mat'])
load([datadir, 'Elsenbruch_et_al_2012.mat'])
load([datadir, 'Freeman_et_al_2015.mat'])
load([datadir, 'Geuter_et_al_2013.mat'])
load([datadir, 'Huber_et_al_2013.mat'])
load([datadir, 'Kessner_et_al_201314.mat'])
load([datadir, 'Kong_et_al_2006.mat'])
load([datadir, 'Kong_et_al_2009.mat'])
load([datadir, 'Ruetgen_et_al_2015.mat'])
load([datadir, 'Schenk_et_al_2014.mat'])
load([datadir, 'Theysohn_et_al_2014.mat'])
load([datadir, 'Wager_at_al_2004a_princeton_shock.mat'])
load([datadir, 'Wager_et_al_2004b_michigan_heat.mat'])
load([datadir, 'Wrobel_et_al_2014.mat'])
load([datadir, 'Zeidan_et_al_2015.mat'])



%% Combine the studies
df=[atlas;bingel06;bingel11;choi;eippert;ellingsen;elsenb;freeman;geuter;huber;kessner;kong06;kong09;ruetgen;schenk;they;wager_princeton;wager_michigan;wrobel;zeidan];
%% Save all studies as df
save(fullfile(datadir,'AllData.mat'), 'df')