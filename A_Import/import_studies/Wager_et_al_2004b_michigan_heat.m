function Wager_et_al_2004b_Michigan_heat

%% Set working environment
clear
basedir = '../../../Datasets/';

%% Import Wager_et_al_2004: Study 2 (michigan heat)

studydir = 'Wager_et_al_2004b_Michigan_heat';
load(fullfile(basedir,studydir,'EXPT.mat'));
% Get subject-directorys from EXPT.mat
subdir=EXPT.subdir;

% Determine the betas for placebo/control from the contrasts saved in xCon
for i=1:length(subdir)
    currpath=fullfile(basedir,studydir,subdir{i},'xCon.mat');
    load(currpath);
    pain_pla_cont(i,:)=xCon(15).c';
    anti_pla_cont(i,:)=xCon(11).c';
end

[beta_ID(:,1),~]=find(pain_pla_cont'==1);   % beta images placebo + pain
[beta_ID(:,2),~]=find(pain_pla_cont'==-1);  % beta images control + pain
[beta_ID(:,3),~]=find(anti_pla_cont'==1);   % beta images placebo + pain
[beta_ID(:,4),~]=find(anti_pla_cont'==-1);  % beta images control + pain

for j=1:length(subdir)
     currpath=fullfile(studydir,subdir{j});
     load(fullfile(basedir,currpath,'SPM_fMRIDesMtx.mat')); %For determining x_span, pre-load the SPM for that subject
     xSpanRaw=max(xX.X)-min(xX.X);
    for i=1:size(beta_ID,2)
        %Get filenames in a (subj,con) matrix
        img{j,i} = fullfile(studydir,subdir{j},sprintf('beta_00%0.2d.img', beta_ID(j,i)));
        sub(j,i)=subdir(j); % The subject number (study specific)
        x_span(j,i)=xSpanRaw(beta_ID(j,i)); % Gets x_span for betas one at a time
        n_imgs(j,i)=size(xX.X,1);
        switch beta_ID(j,i)
            case 2
            imgs_per_stimulus_block(j,i)=4/1.5; %not sure where to find block duration in SPM99, using information from paper
            n_blocks(j,i)=length(Sess{1,1}.ons{1,2}); 
            case 4
            imgs_per_stimulus_block(j,i)=10/1.5; %not sure where to find block duration in SPM99, using information from paper
            n_blocks(j,i)=length(Sess{1,1}.ons{1,4});
            case 8
            imgs_per_stimulus_block(j,i)=4/1.5;
            n_blocks(j,i)=length(Sess{1,2}.ons{1,2});
            case 10
            imgs_per_stimulus_block(j,i)=10/1.5;
            n_blocks(j,i)=length(Sess{1,2}.ons{1,4});
        end
    end
end

pla(1:length(subdir),[1 3])=1;    % 0= Any Control 1 = Any Placebo 2 = Other
pla(1:length(subdir),[2 4])=0;    % 0= Any Control 1 = Any Placebo 2 = Other
pain(1:length(subdir),[1 2])=1;   % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(1:length(subdir),[3 4])=0;   % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain

cond(1:length(subdir),1)={'placebo_pain'};         % A string describing the experimental condition
cond(1:length(subdir),2)={'control_pain'};         % A string describing the experimental condition
cond(1:length(subdir),3)={'placebo_anticipation'};         % A string describing the experimental condition
cond(1:length(subdir),4)={'control_anticipation'};         % A string describing the experimental condition

img      = vertcat(img(:)); 
sub      = vertcat(sub(:));
pla      = vertcat(pla(:));
pain     = vertcat(pain(:));
x_span    = vertcat(x_span(:));
cond     = vertcat(cond(:));
n_blocks  = vertcat(n_blocks(:));
imgs_per_stimulus_block = vertcat(imgs_per_stimulus_block(:));


placebo_first=NaN(size(cond));        
rating= NaN(size(cond));
rating(strcmp(cond,'placebo_pain'))=EXPT.behavior; % ATTENTION: Unfortunately for images placebo & control are available as separate conditions, while for behavior only the contrast control-placebo is available...

% Create Study-Specific table
wager_michigan=table(img);
wager_michigan.img=img;
wager_michigan.study_ID=repmat({'wager04b_michigan'},size(wager_michigan.img));
wager_michigan.sub_ID=strcat(wager_michigan.study_ID,'_',sub);
wager_michigan.male=NaN(size(wager_michigan.img));
wager_michigan.age=NaN(size(wager_michigan.img));
wager_michigan.healthy=ones(size(wager_michigan.img));
wager_michigan.pla=pla;
wager_michigan.pain=pain;
wager_michigan.predictable=zeros(size(wager_michigan.img)); %Uncertainty: mean 9 (1-16) seconds anticipation
wager_michigan.real_treat=zeros(size(wager_michigan.img));
wager_michigan.cond=vertcat(cond(:));
wager_michigan.stim_side=repmat({'L'},size(wager_michigan.img));
wager_michigan.placebo_first=NaN(size(wager_michigan.img));
wager_michigan.i_condition_in_sequence=NaN(size(wager_michigan.img));
wager_michigan.rating=rating;
wager_michigan.rating101=rating*10; % an 11 pt-scale ranging from 0 (non painful) to 10 (unbearable) was used.
wager_michigan.stim_intensity=NaN(size(wager_michigan.img));       
wager_michigan.imgs_per_stimulus_block =imgs_per_stimulus_block;
wager_michigan.n_blocks      =n_blocks; % According to SPM
wager_michigan.n_imgs      =vertcat(n_imgs(:)); % Images per Participant
wager_michigan.x_span        =x_span;
wager_michigan.con_span      =ones(size(wager_michigan.cond));
%% Save
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_id,'wager04b_michigan')),'raw'}={wager_michigan};
save(fullfile(basedir,'data_frame.mat'),'df');
end