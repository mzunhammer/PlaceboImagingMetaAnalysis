function Choi_et_al_2011(datapath)

%% Collects all behavioral data and absolute img-paths for Choi et al. 2011
% in a data frame, saves as .mat

%% Set working environment

basedir = datapath;

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Choi_et_al_2011';

choidir = dir(fullfile(basedir, studydir));
iimg=~cellfun(@isempty,regexp({choidir.name},'^S.*nii')); %actual images in dir
beta_img = {choidir(iimg).name}';
idesignmats=~cellfun(@isempty,regexp({choidir.name},'DesignMatrix')); %actual images in dir
designmats = {choidir(idesignmats).name}';

img=cellfun(@(x) fullfile(studydir, x),beta_img,'UniformOutput',0);
% Get subject numbers from img paths
sub=regexp(beta_img,'Subj_(\w)_.*','tokens');    
sub=[sub{:}];sub=[sub{:}]';
% Assign "placebo condition" to beta image
% 0= Any Control 1 = Any Placebo 2 = Other
pla(~cellfun(@isempty,regexp(beta_img,'_1potent_')),1)=1;
pla(~cellfun(@isempty,regexp(beta_img,'_100potent_')),1)=1;
pla(~cellfun(@isempty,regexp(beta_img,'_control_')),1)=0;

% Pain condition
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
nop=~cellfun(@isempty,regexp(beta_img,'_no_pain'));
anti=~cellfun(@isempty,regexp(beta_img,'anticipation'));
pain=ones(size(sub));
pain(nop,1)=0;
pain(anti,1)=0;

betan(~cellfun(@isempty,regexp(beta_img,'beta1')),1)=1;
betan(~cellfun(@isempty,regexp(beta_img,'beta3')),1)=3;
betan(~cellfun(@isempty,regexp(beta_img,'beta5')),1)=5;
betan(~cellfun(@isempty,regexp(beta_img,'beta7')),1)=7;

%Experiment No.
exp(~cellfun(@isempty,regexp(beta_img,'_Exp1_')),1)=1;
exp(~cellfun(@isempty,regexp(beta_img,'_Exp2_')),1)=2;

expcon=regexp(beta_img,'Exp\d_(\w+?)_','tokens');
expcon=[expcon{:}];expcon=[expcon{:}]';


% According to the feat-design files, beta no's are
%'1' pain_anticipation_beta1;
%'3' pain_beta3;
%'5' no_pain_anticipation_beta5;
%'7' no_pain_beta7;


% According to Choi the data-include a second run of the experiment that was unpublished.
% Since we defined inclusion criteria stating that we include only
% published studies, only the first run will be analyzed.

con_descriptors= regexp(beta_img,'^Subj_\w_(.+?).nii','tokens');
con_descriptors=[con_descriptors{:}];con_descriptors=[con_descriptors{:}]';

unisubs=unique(sub);
nsubj=length(unisubs);

% Load Ratings and Age from Excel
xlspath=fullfile(basedir,studydir,'Behavioral Data_Choi.xlsx'); % Load behavioral data
ageraw=xlsread(xlspath,1,'C3:C17');
rating_control=xlsread(xlspath,1,'D3:D17');
rating_1potent=xlsread(xlspath,1,'E3:E17');
rating_100potent=xlsread(xlspath,1,'F3:F17');

for i= 1:length(beta_img)
    % Select correct Design-File
    iIDexcel=~cellfun(@isempty,strfind(unisubs,sub{i}));
    age(i,1)=ageraw(iIDexcel);
    
    if strcmp(expcon{i},'100potent')
        rating(i,1)=rating_100potent(iIDexcel);
    elseif strcmp(expcon{i},'1potent')
        rating(i,1)=rating_1potent(iIDexcel);
    elseif strcmp(expcon{i},'control')
        rating(i,1)=rating_control(iIDexcel);
    else
        rating(i,1)=NaN;
    end
    
    currdesignpath= fullfile(basedir,studydir,...
        strcat(['DesignMatrix_Subj_',sub{i},...
                '_Exp_', num2str(exp(i)),...
                '_',expcon{i},'.txt']));
    % Note: DesignMatrix_Subj_C_Exp_1_1potent.txt did not exist, duplicated
        % Exp_2 instead.
    % Pull design-matrix from Design-File
    xX=dlmread(currdesignpath,'\t',[5, 0, 304,13]);
    % Calculate X-Span
    xSpanRaw=max(xX)-min(xX);
    % Get X-Span for current beta
    x_span(i,1)=xSpanRaw(betan(i));
    n_imgs(i,1)=size(xX,1);   
end



%% Create Study-Specific table
% If the current table already exists only replace fields (so that NPS values etc. do not have to be re-calculated)
choi=table(img);
choi.img=img;
choi.study_ID=repmat({'choi'},size(choi.img));
choi.sub_ID=strcat(choi.study_ID,'_',sub);
choi.male=ones(size(choi.img));%only males
choi.age=age;
choi.healthy=ones(size(choi.img));%only healthy
choi.pla=pla;
choi.pain=pain;
choi.predictable=ones(size(choi.img)); %No uncertainty
choi.real_treat=zeros(size(choi.img)); %No real treatment
choi.cond=con_descriptors;
choi.stim_side=repmat({'L'},size(choi.img));
choi.placebo_first=NaN(size(choi.img)); %Mixed
choi.i_condition_in_sequence=NaN(size(choi.img));
choi.rating=rating;    
choi.rating101=rating;   %was 101 scale in original ranging from no pain to "maximum imagingable"
choi.stim_intensity=ones(size(choi.img)).*20; %electrical stimulation (2 Hz, 20 mA, duration: 15 s);             
choi.imgs_per_stimulus_block =ones(size(choi.cond)).*5; % 15 s / 3 s TR = 5 ... according to paper
choi.imgs_per_stimulus_block(anti) =ones(size(choi.cond(anti))).*3; % 9 s / 3 s TR = 5 ... according to paper
choi.n_blocks      =ones(size(choi.cond)).*5; % According to paper there were 5 stimulus repetitions for each condition.
choi.n_imgs      =n_imgs; % Images per Participant: Note that separae GLMs were performed for the different experimental placebo conditions AND that exp 2 seems not to be included in the original publications. Therefore the number of images/participant was 300*2=600
choi.x_span        =x_span;
choi.con_span      =ones(size(choi.img));
%% Save in data_frame
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_ID,'choi')),'raw'}={choi};
save(fullfile(basedir,'data_frame.mat'),'df');
end