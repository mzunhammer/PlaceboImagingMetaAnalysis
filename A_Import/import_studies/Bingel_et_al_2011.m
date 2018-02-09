function Bingel_et_al_2011(datapath)

%% Collects all behavioral data and absolute img-paths for Bingel 2011
% in a data frame, saves as .mat

%% Set working environment

basedir = datapath;

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Bingel_et_al_2011';
bingeldir = dir(fullfile(basedir, studydir));
iimg=~cellfun(@isempty,regexp({bingeldir.name},'^sub.*img')); %actual images in dir
beta_img = {bingeldir(iimg).name}';
img=cellfun(@(x) fullfile(studydir, x),beta_img,'UniformOutput',0);
% Get subject numbers from img paths
sub=regexp(img,'/sub(\d\d)_beta','tokens');    
sub=[sub{:}];
% Assign "placebo condition" to beta image
% 0= Any Control 1 = Any Placebo 2 = Other
pla(~cellfun(@isempty,regexp(beta_img,'ant_baseline')),1)=0;
pla(~cellfun(@isempty,regexp(beta_img,'ant_remi_neg_exp')),1)=2;
pla(~cellfun(@isempty,regexp(beta_img,'ant_remi_no_exp')),1)=0;
pla(~cellfun(@isempty,regexp(beta_img,'ant_remi_pos_exp')),1)=1;

pla(~cellfun(@isempty,regexp(beta_img,'pain_baseline')),1)=0;
pla(~cellfun(@isempty,regexp(beta_img,'pain_remi_neg_exp')),1)=2;
pla(~cellfun(@isempty,regexp(beta_img,'pain_remi_no_exp')),1)=0;
pla(~cellfun(@isempty,regexp(beta_img,'pain_remi_pos_exp')),1)=1;

% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain=zeros(size(beta_img));
pain(~cellfun(@isempty,regexp(beta_img,'pain')),1)=1;

% Get condition names from beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
cond=regexp(beta_img,'beta_(.*).img','tokens');
cond=[cond{:}]';                          
cond=[cond{:}]'; 
% Assign "testing sequence" to beta image
seq=repmat([1 4 2 3 1 4 2 3],22,1)'; % Experiment with fixed sequence
seq=seq(:);

%% Import behavioral from Excel-Sheet
xls_path='/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/Bingel_et_al_2011/Bingel_Remi_Behavioral.xlsx';
% Gender
male=xlsread(xls_path,1,'AH3:AH24');
male=repmat(male,1,8)';male=male(:);
male(male==9999)=NaN;
% Ratings
rating_bl  =xlsread(xls_path,1,'A3:A24');
rating_remi=xlsread(xls_path,1,'B3:B24');
rating_pla =xlsread(xls_path,1,'C3:C24');
rating_noc =xlsread(xls_path,1,'D3:D24');
rating=NaN(size(cond));

rating(~cellfun(@isempty, regexpi(cond','ant_baseline')))=rating_bl;
rating(~cellfun(@isempty, regexpi(cond','ant_remi_neg_exp')))=rating_noc;
rating(~cellfun(@isempty, regexpi(cond','ant_remi_no_exp')))=rating_remi;
rating(~cellfun(@isempty, regexpi(cond','ant_remi_pos_exp')))=rating_pla;
rating(~cellfun(@isempty, regexpi(cond','pain_baseline')))=rating_bl;
rating(~cellfun(@isempty, regexpi(cond','pain_remi_neg_exp')))=rating_noc;
rating(~cellfun(@isempty, regexpi(cond','pain_remi_no_exp')))=rating_remi;
rating(~cellfun(@isempty, regexpi(cond','pain_remi_pos_exp')))=rating_pla;
% Temps
temps_bl  =xlsread(xls_path,1,'AJ3:AJ24');
temps=NaN(size(cond));

temps(~cellfun(@isempty, regexpi(cond','ant_baseline')))=temps_bl;
temps(~cellfun(@isempty, regexpi(cond','ant_remi_neg_exp')))=temps_bl;
temps(~cellfun(@isempty, regexpi(cond','ant_remi_no_exp')))=temps_bl;
temps(~cellfun(@isempty, regexpi(cond','ant_remi_pos_exp')))=temps_bl;

temps(~cellfun(@isempty, regexpi(cond','pain_baseline')))=temps_bl;
temps(~cellfun(@isempty, regexpi(cond','pain_remi_neg_exp')))=temps_bl;
temps(~cellfun(@isempty, regexpi(cond','pain_remi_no_exp')))=temps_bl;
temps(~cellfun(@isempty, regexpi(cond','pain_remi_pos_exp')))=temps_bl;

%Add imaging parameters (all SPMs used the same number and length of blocks)
imgs_per_stimulus_block(~cellfun(@isempty,regexp(beta_img,'ant_')),1)=1.6;
imgs_per_stimulus_block(~cellfun(@isempty,regexp(beta_img,'pain_')),1)=2;
n_blocks(~cellfun(@isempty,regexp(beta_img,'ant_')),1)=10;
n_blocks(~cellfun(@isempty,regexp(beta_img,'pain_')),1)=10;

% Load SPM's to get imaging parameter x_span/con_span
bingelSPMs = {bingeldir(~cellfun(@isempty,regexp({bingeldir.name},'SPM.mat'))).name}';
for i=1:size(bingelSPMs)
    load(fullfile(basedir, studydir,bingelSPMs{i,1}));
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    % Numbers of the beta images (i.e. the predictor numbers) go in here.
    bingelxSpans(i,:)=xSpanRaw([3 9 15 21 4 10 16 22]);
    n_imgs(i,:)=size(SPM.xX.X,1);
end
bingelxSpanslong=(bingelxSpans');
bingelxSpanslong=bingelxSpanslong(:);
x_span =bingelxSpanslong;
%con_span for Cons only
con_span      =ones(size(cond)).*1;
n_imgs=repmat(n_imgs,1,8)';
n_imgs=n_imgs(:);


% In this case the VAS used was a 101-pt scale ranging from no pain to
% unbearable pain
rating101=rating;
%% Collect all Variables in Table
bingel11=table(img);
bingel11.img=img;
bingel11.study_ID=repmat({'bingel11'},size(bingel11.img));
bingel11.sub_ID=strcat(bingel11.study_ID,'_',vertcat(sub{:}));
bingel11.male=male;
bingel11.age=ones(size(bingel11.img))*28; %Unfortunately not available, using group mean
bingel11.healthy=ones(size(bingel11.img));
bingel11.pla=pla;
bingel11.pain=pain;
bingel11.predictable= zeros(size(bingel11.img)); %Uncertainty: 6?2.8284s ???; %This anticipatory phase was 4 to 8 s long.
bingel11.real_treat=~cellfun(@isempty,(regexp(cond,'remi'))); %Mark all blocks w remifentanil
bingel11.cond=cond;
bingel11.stim_side=repmat({'R'},size(bingel11.img));
bingel11.placebo_first=zeros(size(bingel11.img));%all participants had no expectancy first, the positive expectancy
bingel11.i_condition_in_sequence=seq;
bingel11.rating=rating;
bingel11.rating101=rating101;
bingel11.stim_intensity=temps;
bingel11.imgs_per_stimulus_block =imgs_per_stimulus_block;
bingel11.n_blocks      =n_blocks; % According to SPM
bingel11.n_imgs      =n_imgs; % Images per Participant
bingel11.x_span        =x_span;
bingel11.x_span(strcmp(bingel11.sub_ID,'bingel11_14'))=NaN;
% For Subj14 (10th subject in array) one onset for pain has been entered in duplicate: the x-Vector is flawed.
bingel11.con_span      =con_span;
%% Save in data_frame
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_ID,'bingel11')),'raw'}={bingel11};
save(fullfile(basedir,'data_frame.mat'),'df');
end