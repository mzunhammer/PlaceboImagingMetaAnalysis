function Wrobel_et_al_2014

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Collects all behavioral data and absolute img-paths
% in a data frame, saves as .mat

studydir = 'Wrobel_et_al_2014';
wrobeldir = dir(fullfile(basedir, studydir));
beta_img = {wrobeldir(~cellfun(@isempty,regexp({wrobeldir.name},'^sub\d\d.*img'))).name}';

img=cellfun(@(x) fullfile(studydir, x),beta_img,'UniformOutput',0); % The absolute image paths
sub=regexp(img,'sub(\d\d)_beta','tokens');
sub=[sub{:}];
sub=str2double([sub{:}])';                             % The subject number (study specific)

% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo 2 = Other
pla(~cellfun(@isempty,regexp(beta_img,'placebo')),1)=1;
pla(~cellfun(@isempty,regexp(beta_img,'control')),1)=0;
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)=0; 
pain(~cellfun(@isempty,regexp(beta_img,'early_pain')),1)=2;  
pain(~cellfun(@isempty,regexp(beta_img,'late_pain')),1)=3;

cond=regexp(beta_img,'beta_(.*).img','tokens');
cond=[cond{:}]';
cond=[cond{:}]';

% Import behavioral
wrobel_subs=unique(sub);
xls_path=[basedir, studydir,filesep, 'wrobel_haldol_study.xlsx'];

%Ratings
[num,~,~]=xlsread(xls_path,1,'O:P');
rating_bl  =num(:,2);
rating_pla =num(:,1);

rating_bl_3  =  repmat(rating_bl,1,3)';
rating_pla_3  = repmat(rating_pla,1,3)';
rating_bl_3=rating_bl_3(:);
rating_pla_3=rating_pla_3(:);

rating(~cellfun(@isempty,regexp(beta_img,'control')),1)=rating_bl_3;
rating(~cellfun(@isempty,regexp(beta_img,'placebo')),1)=rating_pla_3;

stimInt=xlsread(xls_path,1,'Y:Y');
stimInt=repmat(stimInt,1,6)';stimInt=stimInt(:);
stimInt(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)=35;

male=xlsread(xls_path,1,'E:E');
male=repmat(male,1,6)';male=male(:);
age=xlsread(xls_path,1,'H:H');
age=repmat(age,1,6)';age=age(:);age(age==999)=NaN;
plaFirst=xlsread(xls_path,1,'G:G');
plaFirst=repmat(plaFirst,1,6)';plaFirst=plaFirst(:);

        blockLength(~cellfun(@isempty,regexp(beta_img,'pain')),1)            =10;
        blockLength(~cellfun(@isempty,regexp(beta_img,'anticipation')),1)    =0;
        
        %xSpan (from max(SPM.xX.X)-min(SPM.xX.X))
        wrobelSPMs = {wrobeldir(~cellfun(@isempty,regexp({wrobeldir.name},'SPM.mat'))).name}';
        for i=1:size(wrobelSPMs)
        load(fullfile(basedir, studydir,wrobelSPMs{i,1}));
        xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
        wrobelxSpans(i,:)=xSpanRaw([2 10 4 12 6 14]);
        nImages(i,:)=size(SPM.xX.X,1);
        end
        nImages=repmat(nImages,1,6)';
        nImages=nImages(:);
        wrobelxSpanslong=(wrobelxSpans');
        wrobelxSpanslong=wrobelxSpanslong(:);
        xSpan =wrobelxSpanslong;

        
        %conSpan for Cons only
        conSpan      =ones(size(cond)).*1;

% Create Study-Specific table
wrobel=table(img);
wrobel.imgType=repmat({'fMRI'},size(wrobel.img));
wrobel.studyType=repmat({'within'},size(wrobel.img));
wrobel.studyID=repmat({'wrobel'},size(wrobel.img));
wrobel.subID=strcat(wrobel.studyID,'_',num2str(sub));

wrobel.male=male;
wrobel.age=age;
wrobel.healthy=ones(size(wrobel.img));
wrobel.pla=pla;
wrobel.pain=pain;
wrobel.predictable=zeros(size(wrobel.img)); %Uncertainty: mean 7.5 ? 3.5 sec
wrobel.realTreat=zeros(size(wrobel.img));
wrobel.realTreat(~cellfun(@isempty,regexp(beta_img,'haldol')))=1;
wrobel.cond=vertcat(cond(:));
wrobel.stimtype=repmat({'heat'},size(wrobel.img));
wrobel.stimloc=repmat({'L forearm (v)'},size(wrobel.img));
wrobel.stimside=repmat({'L'},size(wrobel.img));
wrobel.plaForm=repmat({'Topical Cream/Gel/Patch'},size(wrobel.img));
wrobel.plaInduct=repmat({'Suggestions + Conditioning'},size(wrobel.img));
wrobel.plaFirst=plaFirst;
wrobel.condSeq=NaN(size(wrobel.img));
wrobel.condSeq(~cellfun(@isempty,regexp(beta_img,'placebo'))&wrobel.plaFirst==1)=1;
wrobel.condSeq(~cellfun(@isempty,regexp(beta_img,'placebo'))&wrobel.plaFirst==0)=2;
wrobel.condSeq(~cellfun(@isempty,regexp(beta_img,'control'))&wrobel.plaFirst==1)=2;
wrobel.condSeq(~cellfun(@isempty,regexp(beta_img,'control'))&wrobel.plaFirst==0)=1;
wrobel.rating=rating;
wrobel.rating101=rating; % a 101-pt rating scale ranging from 0 no pain to 100 unbearable pain was used.
wrobel.stimInt=stimInt;       
wrobel.fieldStrength=ones(size(wrobel.img)).*3;
wrobel.tr           =ones(size(wrobel.img)).*2580;
wrobel.te           =ones(size(wrobel.img)).*25;
wrobel.voxelVolAcq  =ones(size(wrobel.img)).*(2*2*2+1);
wrobel.voxelVolMat  =ones(size(wrobel.img)).*(2*2*2);
wrobel.meanBlockDur =ones(size(cond))*10; % According to paper (early and late were each modeled 10 seconds)
wrobel.nImages      =nImages; % Images per Participant
wrobel.xSpan        =xSpan;
wrobel.conSpan      =ones(size(wrobel.cond));

%% Save
outpath=fullfile(basedir,'Wrobel_et_al_2014.mat')
save(outpath,'wrobel')

end