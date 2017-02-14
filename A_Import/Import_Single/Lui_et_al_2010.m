function Lui_et_al_2010

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';
studydir= 'Lui_et_al_2010';

%% Load images paths
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
 'Sn(2) A_R_3*bf(1)'...  %(Anticipation Control)
 'Sn(2) A_G_3*bf(1)'... %(Anticipation Placebo)
 'Sn(2) P_3*bf(1)'...   %(Pain Control) (P stands for PAIN not PLACEBO!)
 'Sn(2) NoP_3*bf(1)'}; %(Pain Placebo) (P stands for PAIN not PLACEBO!)

luifolders=dir(fullfile(basedir,studydir));
luifolders={luifolders.name};
luifolders=luifolders(~cellfun(@isempty,...
                            regexpi(luifolders','^TOMO_\d\d$','match')));
nsubj=length(luifolders);

%% Import behavioral
xls_path=fullfile(basedir, studydir, 'Lui_Behavioural_Demografics.xlsx');

unimale=xlsread(xls_path,1,'C3:C40');
uniage=xlsread(xls_path,1,'D3:D40');
[~,~,unistimside]=xlsread(xls_path,1,'B3:B40');
uniratingPla=xlsread(xls_path,1,'M3:M40');
uniratingCon=xlsread(xls_path,1,'L3:L40');
unistimInt=xlsread(xls_path,1,'F3:F40'); % Day 3 Data had high stimulus intensities only, so only high stim ints are imported

%% Import images, combine with behavioral
for j= 1:nsubj
    currdir=fullfile(basedir,studydir,luifolders{j});
    load(fullfile(currdir, 'SPM.mat'));
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    for i = 1:length(beta_descriptors)
        currsubNO=luifolders{j}(end-1:end);
        currbetano=find(strcmp(SPM.xX.name,beta_term{i}));
        %Get filenames in a (subj,beta) matrix
        img{j,i} = fullfile(studydir,luifolders{j}, sprintf('beta_%04d.img',currbetano));
        %Get subject and beta ID in the same (subj,beta) matrix format
        i_sub{j,i}=['lui_',currsubNO];
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
        %Get xSpan from SPM:
        iCon=strcmp(SPM.xX.name,beta_term{i}); % Get index of right betas with correct names
        xSpan(j,i)=sum(xSpanRaw(iCon)); % Gets x-Vextors according to index above
        conSpan(j,i)=1; % Simple beta images
        nImages(j,i)=size(SPM.xX.X,1);
        male(j,i)=unimale(str2num(currsubNO));
        age(j,i)=uniage(str2num(currsubNO));
        stimside(j,i)=unistimside(str2num(currsubNO));
        stimInt(j,i)=unistimInt(str2num(currsubNO));   
    end
end

img=vertcat(img(:));          % The absolute image paths
sub=vertcat(i_sub(:));               % The subject number (study specific)
beta=vertcat(beta(:));
nImages=vertcat(nImages(:));

% Pain condition
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(ismember(beta,[1 3]),1)=0;     
pain(ismember(beta,[5 7]),1)=1;

imgsPerBlock(ismember(beta,[1 3]),1)=4; % 4s Anticipation according to SPM and paper
imgsPerBlock(ismember(beta,[5 7]),1)=0; % Ecent for stimulus according to SPM and paper

cond=vertcat(cond(:));  

condSeq=ones(size(img))*3;         % Third session in row, red and green cues "pseudorandomly alternated" within run.
plaFirst=ones(size(img))*0.5;        % Completely mixed sequence
temp=NaN(size(img));            % Not yet available

%xSpan (from max(SPM.xX.X)-min(SPM.xX.X)) 
xSpan=vertcat(xSpan(:));

% Create Study-Specific table
outpath=fullfile(basedir,'Lui_et_al_2010.mat')
if exist(outpath)==2
    load(outpath);
else
    lui=table(img);
end
lui.img=img;
lui.imgType=repmat({'fMRI'},size(lui.img));
lui.studyType=repmat({'within'},size(lui.img));
lui.studyID=repmat({'lui'},size(lui.img));
lui.subID=i_sub(:);
lui.male=vertcat(male(:));
lui.age=vertcat(age(:));
lui.healthy=ones(size(lui.img));
lui.pla=vertcat(pla(:));
lui.pain=pain;
lui.predictable=ones(size(lui.img));                %No uncertainty: Fixed 12 second anticipation
lui.realTreat=zeros(size(lui.img));                 %No real treatment
lui.cond=vertcat(cond(:));             
lui.stimtype=repmat({'laser'},size(lui.img));
lui.stimloc=repmat({'L or R foot (v)'},size(lui.img));
lui.stimside=vertcat(stimside(:));       %Very important in this study: some subjects were stimulated left, some right
lui.plaForm=repmat({'TENS'},size(lui.img));
lui.plaInduct=repmat({'Suggestions + Conditioning'},size(lui.img));
lui.plaFirst=plaFirst;
lui.condSeq=condSeq;
lui.rating=vertcat(rating(:)); % % Ratings were performed on a 101pt-VAS from no pain to "worst imagingable pain", but scaled in 255 steps.  
lui.rating101=lui.rating*100/255;
lui.stimInt=vertcat(stimInt(:));             
lui.fieldStrength=ones(size(lui.img)).*3;
lui.tr           =ones(size(lui.img)).*3014;
lui.te           =ones(size(lui.img)).*35;
lui.voxelVolAcq  =ones(size(lui.img)).*(1.875*1.875*3.5);
lui.voxelVolMat  =ones(size(lui.img)).*(2*2*2);
lui.imgsPerBlock =imgsPerBlock; % Paper and SPM agree
lui.nBlocks      =ones(size(lui.cond)).*6;
lui.nImages      =nImages; % Images per Participant
lui.xSpan        =xSpan;
lui.conSpan      =conSpan(:);
lui.fsl          =zeros(size(lui.cond)); %analysis with fsl, rather than SPM

%% Save
save(outpath,'lui')

end