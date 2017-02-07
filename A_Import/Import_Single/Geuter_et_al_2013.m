function Geuter_et_al_2012

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Geuter_et_al_2013';
nsubj=1:40;
con_IDs = [1 2 3 4 18 19 20 21 36 37 38 39];
con_descriptors= {...
    'early_pain_placebo_weak'...
    'early_pain_control_weak'...
    'early_pain_placebo_strong'...
    'early_pain_control_strong'...
    'late_pain_placebo_weak'...
    'late_pain_control_weak'...
    'late_pain_placebo_strong'...
    'late_pain_control_strong'...
    'anti_placebo_weak'...
    'anti_control_weak'...
    'anti_placebo_strong'...
    'anti_control_strong'};

load(fullfile(basedir,studydir,'metadata_geuter.mat')); % Load behavioral data

for j= nsubj
    geuterSPMs{j} = fullfile(studydir, ['sub' num2str(j,'%02d')],'SPM.mat');
    load(fullfile(basedir,geuterSPMs{j}));
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    for i = 1:length(con_IDs)
    %Get filenames in a (subj,con) matrix
    img{j,i} = fullfile(studydir, ['sub' num2str(j,'%02d')], sprintf('con_00%0.2d.img', con_IDs(i)));
    %Get subject and con ID in the same (subj,con) matrix format
    i_sub(j,i)=j;
    con(j,i)=con_IDs(i);
    %Get description of conditions in a in (subj,con) matrix format
    cond(j,i)=con_descriptors(i); 
    %Get xSpan from SPM:
    SPMcon=SPM.xCon(con(j,i)).c;
    xSpan(j,i)=xSpanRaw(logical(SPMcon));
    conSpan(j,i)=sum(abs(SPMcon));
    nImages(j,i)=size(SPM.xX.X,1);
    
    % Get sequence of experimental conditions and ratings from meta-file
    if     ~isempty(regexp(con_descriptors{i},'control_weak'))
        condSeq(j,i)=find(strcmp(meta.order(j,:),'cheap control'));
        plaFirst(j,i)=~mod(condSeq(j,i),2);%If control had an uneven sequence number ->placebo NOT first
        rating(j,i)=meta.vas(j,2);
    elseif ~isempty(regexp(con_descriptors{i},'control_strong'))
        condSeq(j,i)=find(strcmp(meta.order(j,:),'expensive control'));
        plaFirst(j,i)=~mod(condSeq(j,i),2);%If control had an uneven sequence number ->placebo NOT first
        rating(j,i)=meta.vas(j,4);
    elseif ~isempty(regexp(con_descriptors{i},'placebo_weak'))
        condSeq(j,i)=find(strcmp(meta.order(j,:),'cheap placebo'));
        plaFirst(j,i)=mod(condSeq(j,i),2);%If placebo had an uneven sequence number ->placebo first
        rating(j,i)=meta.vas(j,1);
    elseif ~isempty(regexp(con_descriptors{i},'placebo_strong'))
        condSeq(j,i)=find(strcmp(meta.order(j,:),'expensive placebo'));
        plaFirst(j,i)=mod(condSeq(j,i),2);%If placebo had an uneven sequence number ->placebo first
        rating(j,i)=meta.vas(j,3);
    end
    
    if ~isempty(regexp(con_descriptors{i},'anti_'))
        temp(j,i)=35;
    elseif ~isempty(regexp(con_descriptors{i},'pain_')) 
        temp(j,i)=meta.temperature(j);
    end
    
    end
end

img=vertcat(img(:));          % The absolute image paths
sub=vertcat(i_sub(:));               % The subject number (study specific)

con=vertcat(con(:));
% Placebo condition
% 0= Any Control 1 = Any Placebo  2 = Other
pla(ismember(con,[1 3 18 20 36 38]),1)=1;    
pla(ismember(con,[2 4 19 21 37 39]),1)=0;    % 0= Any Control 1 = Any Placebo  2 = Other
% Pain condition
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(ismember(con,[36 37 38 39]),1)=0;     
pain(ismember(con,[1 2 3 4]),1)=2;
pain(ismember(con,[18 19 20 21]),1)=3;
cond=vertcat(cond(:));  

condSeq=vertcat(condSeq(:)); 
plaFirst=vertcat(plaFirst(:)); 
rating=vertcat(rating(:)); 
temp=vertcat(temp(:));

%xSpan (from max(SPM.xX.X)-min(SPM.xX.X)) 
xSpan=vertcat(xSpan(:));
nImages=vertcat(nImages(:));
%conSpan for Cons only
conSpan      =ones(size(cond)).*1;

% Create Study-Specific table
geuter=table(img);
geuter.imgType=repmat({'fMRI'},size(geuter.img));
geuter.studyType=repmat({'within'},size(geuter.img));
geuter.studyID=repmat({'geuter'},size(geuter.img));
geuter.subID=strcat(geuter.studyID,'_',num2str(sub));
geuter.male=ones(size(geuter.img));
geuter.age=repmat(meta.age,length(con_IDs),1);
geuter.healthy=ones(size(geuter.img));
geuter.pla=pla;
geuter.pain=pain;
geuter.predictable=ones(size(geuter.img)); %No uncertainty: Fixed 5 second anticipation
geuter.realTreat=zeros(size(geuter.img));
geuter.cond=vertcat(cond(:));
geuter.stimtype=repmat({'heat'},size(geuter.img));
geuter.stimloc=repmat({'L forearm (v)'},size(geuter.img));
geuter.stimside=repmat({'L'},size(geuter.img));
geuter.plaForm=repmat({'Topical Cream/Gel/Patch'},size(geuter.img));
geuter.plaInduct=repmat({'Suggestions + Conditioning'},size(geuter.img));
geuter.plaFirst=plaFirst;
geuter.condSeq=condSeq;
geuter.rating=rating;  
geuter.rating101=rating;     % 101-pt VAS scale ranging from "no pain" to "unbearable".       
geuter.stimInt=temp;             
geuter.fieldStrength=ones(size(geuter.img)).*3;
geuter.tr           =ones(size(geuter.img)).*2580;
geuter.te           =ones(size(geuter.img)).*26;
geuter.voxelVolAcq  =ones(size(geuter.img)).*(2 * 2 *(2+1));
geuter.voxelVolMat  =ones(size(geuter.img)).*(2*2*2);
geuter.meanBlockDur =ones(size(geuter.cond)).*10; % Paper and SPM agree
geuter.nImages      =nImages; % Images per Participant
geuter.xSpan        =xSpan;
geuter.conSpan      =conSpan;

%% Save
outpath=fullfile(basedir,'Geuter_et_al_2013.mat')
save(outpath,'geuter')

end