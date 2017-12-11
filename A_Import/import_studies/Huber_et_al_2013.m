function Huber_et_al_2013

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '../../../Datasets/';
studydir= 'Huber_et_al_2013';

%% Load images paths

%% Combine Betas to Cons representing the experimental conditions:
% CAVE: FOR SOME PARTICIPANTS THERE WERE EXTRA PREDICTORS ON  SESSIONS 1 and 2
% (the unimportant ones)... therefore the beta-numbers are
% not identical for all participants and have to be calculated based on the
% names of the design-matrix columns given in the SPM.xX.name
% The usual participant has 53 beta images.
% The columns of interest are:
% "Sn(3) A_R_3*bf(1)" (Anticipation Control)
% "Sn(3) A_G_3*bf(1)" (Anticipation Placebo)
% "Sn(3) P_3*bf(1)" (Pain Control) (P stands for PAIN not PLACEBO!)
% "Sn(3) NoP_3*bf(1)"(Pain Placebo) (P stands for PAIN not PLACEBO!)

beta_IDs = [1,3,5,7];
beta_descriptors= {...
   'antic_control_red'...
   'antic_placebo_green'...
   'pain_control'...
   'pain_placebo'};
% Beta terms as listed in SPM.xX.name used to search the correct betas-numbers for
% each participant
beta_term= {...
 'Sn(3) A_R_3*bf(1)'...  %(Anticipation Control)
 'Sn(3) A_G_3*bf(1)'... %(Anticipation Placebo)
 'Sn(3) P_3*bf(1)'...   %(Pain Control) (P stands for PAIN not PLACEBO!)
 'Sn(3) NoP_3*bf(1)'}; %(Pain Placebo) (P stands for PAIN not PLACEBO!)

huberfolders=dir(fullfile(basedir,studydir));
huberfolders={huberfolders.name};
huberfolders=huberfolders(~cellfun(@isempty,...
                            regexpi(huberfolders','^TOMO_\d\d$','match')));
nsubj=length(huberfolders);

%% Import behavioral
xls_path=fullfile(basedir, studydir, 'Huber_Behavioural_Demografics.xlsx');

unimale=xlsread(xls_path,1,'C3:C40');
uniage=xlsread(xls_path,1,'D3:D40');
[~,~,unistimside]=xlsread(xls_path,1,'B3:B40');
uniratingPla=xlsread(xls_path,1,'M3:M40');
uniratingCon=xlsread(xls_path,1,'L3:L40');
unistimInt=xlsread(xls_path,1,'F3:F40'); % Day 3 Data had high stimulus intensities only, so only high stim ints are imported

%% Import images, combine with behavioral
for j= 1:nsubj
    currdir=fullfile(basedir,studydir,huberfolders{j});
    load(fullfile(currdir, 'SPM.mat'));
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    for i = 1:length(beta_descriptors)
        currsubNO=huberfolders{j}(end-1:end);
        currbetano=find(strcmp(SPM.xX.name,beta_term{i}));
        %Get filenames in a (subj,beta) matrix
        img{j,i} = fullfile(studydir,huberfolders{j}, sprintf('beta_%04d.img',currbetano));
        %Get subject and beta ID in the same (subj,beta) matrix format
        i_sub{j,i}=['huber_',currsubNO];
        beta(j,i)=beta_IDs(i);
        %Get description of conditions in a in (subj,beta) matrix format
        cond(j,i)=beta_descriptors(i);
        % Placebo condition
        % 0= Any Control 1 = Any Placebo  2 = Other
        if ismember(beta(j,i),[3 7])
             pla(j,i)=1;
             rating(j,i)=uniratingPla(str2num(currsubNO));
            elseif ismember(beta(j,i),[1 5])
             pla(j,i)=0;    % 0= Any Control 1 = Any Placebo  2 = Other
             rating(j,i)=uniratingCon(str2num(currsubNO));
            else
             pla(j,i)=NaN;
             rating(j,i)=NaN;
        end
        %Get x_span from SPM:
        iCon=strcmp(SPM.xX.name,beta_term{i}); % Get index of right betas with correct names
        x_span(j,i)=sum(xSpanRaw(iCon)); % Gets x-Vextors according to index above
        con_span(j,i)=2; % Computed manually above
        n_imgs(j,i)=size(SPM.xX.X,1);
        male(j,i)=unimale(str2num(currsubNO));
        age(j,i)=uniage(str2num(currsubNO));
        stim_side(j,i)=unistimside(str2num(currsubNO));
        stim_intensity(j,i)=unistimInt(str2num(currsubNO));   
    end
end

img=vertcat(img(:));          % The absolute image paths
sub=vertcat(i_sub(:));               % The subject number (study specific)
beta=vertcat(beta(:));
n_imgs=vertcat(n_imgs(:));

% Pain condition
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(ismember(beta,[1 3]),1)=0;     
pain(ismember(beta,[5 7]),1)=1;
cond=vertcat(cond(:));  

imgs_per_stimulus_block(ismember(beta,[1 3]),1)=4; % 4s Anticipation according to SPM and paper
imgs_per_stimulus_block(ismember(beta,[5 7]),1)=0; % Ecent for stimulus according to SPM and paper

i_condition_in_sequence=ones(size(img))*3;         % Third session in row, red and green cues "pseudorandomly alternated" within run.
placebo_first=ones(size(img))*0.5;        % Completely mixed sequence
temp=NaN(size(img));            % Not yet available

%x_span (from max(SPM.xX.X)-min(SPM.xX.X)) 
x_span=vertcat(x_span(:));

% Create Study-Specific table
outpath=fullfile(basedir,'Huber_et_al_2013.mat');
if exist(outpath)==2
    load(outpath);
else
    huber=table(img);
end
huber.img=img;
huber.study_ID=repmat({'huber'},size(huber.img));
huber.sub_ID=i_sub(:);
huber.male=vertcat(male(:));
huber.age=vertcat(age(:));
huber.healthy=ones(size(huber.img));
huber.pla=vertcat(pla(:));
huber.pain=pain;
huber.predictable=ones(size(huber.img));                %No uncertainty: Fixed 12 second anticipation
huber.real_treat=zeros(size(huber.img));                 %No real treatment
huber.cond=vertcat(cond(:));             
huber.stim_side=vertcat(stim_side(:));       %Very important in this study: some subjects were stimulated left, some right
huber.placebo_first=placebo_first;
huber.i_condition_in_sequence=i_condition_in_sequence;
huber.rating=vertcat(rating(:)); % Ratings were performed on a 101pt-VAS from no pain to "worst imagingable pain", but scaled in 255 steps.            
huber.rating101=huber.rating*100/255;
huber.stim_intensity=vertcat(stim_intensity(:));             
huber.imgs_per_stimulus_block =imgs_per_stimulus_block; % Paper and SPM agree
huber.n_blocks      =ones(size(huber.cond)).*6;
huber.n_imgs      =n_imgs; % Images per Participant
huber.x_span        =x_span;
huber.con_span      =con_span(:);
%% Save
save(outpath,'huber')

end