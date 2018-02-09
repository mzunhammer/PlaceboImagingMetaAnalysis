function Geuter_et_al_2012(datapath)

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat

%% Set working environment

basedir = datapath;

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
%data in meta is in single-format in some cases!!!
meta.vas=double(meta.vas);
meta.temperature=double(meta.temperature);

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
    %Get x_span from SPM:
    SPMcon=SPM.xCon(con(j,i)).c;
    x_span(j,i)=xSpanRaw(logical(SPMcon));
    con_span(j,i)=sum(abs(SPMcon));
    n_imgs(j,i)=size(SPM.xX.X,1);
    
    % Get sequence of experimental conditions and ratings from meta-file
    if     ~isempty(regexp(con_descriptors{i},'control_weak'))
        i_condition_in_sequence(j,i)=find(strcmp(meta.order(j,:),'cheap control'));
        placebo_first(j,i)=~mod(i_condition_in_sequence(j,i),2);%If control had an uneven sequence number ->placebo NOT first
        rating(j,i)=meta.vas(j,2);
    elseif ~isempty(regexp(con_descriptors{i},'control_strong'))
        i_condition_in_sequence(j,i)=find(strcmp(meta.order(j,:),'expensive control'));
        placebo_first(j,i)=~mod(i_condition_in_sequence(j,i),2);%If control had an uneven sequence number ->placebo NOT first
        rating(j,i)=meta.vas(j,4);
    elseif ~isempty(regexp(con_descriptors{i},'placebo_weak'))
        i_condition_in_sequence(j,i)=find(strcmp(meta.order(j,:),'cheap placebo'));
        placebo_first(j,i)=mod(i_condition_in_sequence(j,i),2);%If placebo had an uneven sequence number ->placebo first
        rating(j,i)=meta.vas(j,1);
    elseif ~isempty(regexp(con_descriptors{i},'placebo_strong'))
        i_condition_in_sequence(j,i)=find(strcmp(meta.order(j,:),'expensive placebo'));
        placebo_first(j,i)=mod(i_condition_in_sequence(j,i),2);%If placebo had an uneven sequence number ->placebo first
        rating(j,i)=meta.vas(j,3);
    end
    
    if ~isempty(regexp(con_descriptors{i},'anti_'))
        temp(j,i)=35;
        imgs_per_stimulus_block(j,i)=1.937984496124031; % Duration from SPM.Sess.U(1).dur (in scans)
        n_blocks(j,i)=15;
    elseif ~isempty(regexp(con_descriptors{i},'pain_')) 
        temp(j,i)=meta.temperature(j);
        imgs_per_stimulus_block(j,i)=3.875968992248062; % Duration from SPM.Sess.U(1).dur (in scans)
        n_blocks(j,i)=15;
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

i_condition_in_sequence=vertcat(i_condition_in_sequence(:)); 
placebo_first=vertcat(placebo_first(:)); 
rating=vertcat(rating(:)); 
temp=vertcat(temp(:));

%x_span (from max(SPM.xX.X)-min(SPM.xX.X)) 
x_span=vertcat(x_span(:));
n_imgs=vertcat(n_imgs(:));
imgs_per_stimulus_block=vertcat(imgs_per_stimulus_block(:));
n_blocks=vertcat(n_blocks(:));
%con_span for Cons only
con_span      =ones(size(cond)).*1;

% Create Study-Specific table
geuter=table(img);
geuter.img=img;
geuter.study_ID=repmat({'geuter'},size(geuter.img));
geuter.sub_ID=strcat(geuter.study_ID,'_',num2str(sub));
geuter.male=ones(size(geuter.img));
geuter.age=repmat(meta.age,length(con_IDs),1);
geuter.healthy=ones(size(geuter.img));
geuter.pla=pla;
geuter.pain=pain;
geuter.predictable=ones(size(geuter.img)); %No uncertainty: Fixed 5 second anticipation
geuter.real_treat=zeros(size(geuter.img));
geuter.cond=vertcat(cond(:));
geuter.stim_side=repmat({'L'},size(geuter.img));
geuter.placebo_first=placebo_first;
geuter.i_condition_in_sequence=i_condition_in_sequence;
geuter.rating=rating;  
geuter.rating101=rating;     % 101-pt VAS scale ranging from "no pain" to "unbearable".       
geuter.stim_intensity=temp;             
geuter.imgs_per_stimulus_block =imgs_per_stimulus_block; % Paper and SPM agree
geuter.n_blocks      =n_blocks; % According to SPM
geuter.n_imgs      =n_imgs; % Images per Participant
geuter.x_span        =x_span;
geuter.con_span      =con_span;

%% Save in data_frame
load(fullfile(basedir,'data_frame.mat'));
df{strcmp(df.study_ID,'geuter'),'raw'}={geuter};
save(fullfile(basedir,'data_frame.mat'),'df');
end