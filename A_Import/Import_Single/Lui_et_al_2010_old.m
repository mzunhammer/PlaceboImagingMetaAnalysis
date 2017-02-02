function Lui_et_al_2010

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';
studydir= 'Lui_et_al_2010';

%% Load images paths

%% Combine Betas to Cons representing the experimental conditions:
% Since placebo-pain and control-pain stimuli were modeled as
% stimulus+time-derivative, we'll have to combine betas:

% CAVE: FOR SOME PARTICIPANTS THERE WERE EXTRA PREDICTORS ON  SESSIONS 1 and 2
% (the  conditioning session unimportant for our analysis)... therefore the beta-numbers are
% not identical for all participants and have to be calculated based on the
% names of the design-matrix columns given in the SPM.xX.name
% The usual participant has 44 beta images.
% To get column names for a given SPM: [[SPM_lui.Sess(1).U.name],[SPM_lui.Sess(2).U.name]]'
% The columns of interest are:

% 'Sn(2) A_R_3*bf(1)' + 'Sn(2) A_R_3xpsicofisica^1*bf(1)' + 'Sn(2) A_R_3xpsicofisica^2*bf(1)' + 'Sn(2) A_R_3xordine^1*bf(1)' + 'Sn(2) A_R_3xordine^2*bf(1)' + 'Sn(2) A_R_3xpsicXord^1*bf(1)' (Anticipation Control)
% 'Sn(2) A_G_3*bf(1)' + 'Sn(2) A_G_3xpsicofisica^1*bf(1)' + 'Sn(2) A_G_3xpsicofisica^2*bf(1)' + 'Sn(2) A_G_3xordine^1*bf(1)' + 'Sn(2) A_G_3xordine^2*bf(1)' + 'Sn(2) A_G_3xpsicXord^1*bf(1)' (Anticipation Placebo)
% 'Sn(2) P_3*bf(1)'   + 'Sn(2) P_3xpsicofisica^1*bf(1)'   + 'Sn(2) P_3xpsicofisica^2*bf(1)'   + 'Sn(2) P_3xordine^1*bf(1)'   + 'Sn(2) P_3xordine^2*bf(1)'   + 'Sn(2) P_3xpsicXord^1*bf(1)'   (Pain Control)
% 'Sn(2) NoP_3*bf(1)' + 'Sn(2) NoP_3xpsicofisica^1*bf(1)' + 'Sn(2) NoP_3xpsicofisica^2*bf(1)' + 'Sn(2) NoP_3xordine^1*bf(1)' + 'Sn(2) NoP_3xordine^2*bf(1)' + 'Sn(2) NoP_3xpsicXord^1*bf(1)' (Pain Placebo)

luifolders=dir(fullfile(basedir,studydir));
luifolders={luifolders.name};
luifolders=luifolders(~cellfun(@isempty,...
                            regexpi(luifolders','^TOMO_\d\d$','match')));
nsubj=length(luifolders);
%% Con terms as listed in SPM.xX.name' used to index the correct betas-numbers for
% each participant
con_IDs = [1, 2, 3, 4];
con_descriptors= {...
    'conAnticControl'...
    'conAnticPlacebo'...
    'conPainControl'...
    'conPainPlacebo'};
ConLabels{1}= {... %AntiControlLabels
    'Sn(2) A_R_3*bf(1)'
    'Sn(2) A_R_3xpsicofisica^1*bf(1)'
    'Sn(2) A_R_3xpsicofisica^2*bf(1)'
    'Sn(2) A_R_3xordine^1*bf(1)'
    'Sn(2) A_R_3xordine^2*bf(1)'
    'Sn(2) A_R_3xpsicXord^1*bf(1)'}; 
ConLabels{2}= {... %AntiPlaceboLabels
    'Sn(2) A_G_3*bf(1)'
    'Sn(2) A_G_3xpsicofisica^1*bf(1)'
    'Sn(2) A_G_3xpsicofisica^2*bf(1)'
    'Sn(2) A_G_3xordine^1*bf(1)'
    'Sn(2) A_G_3xordine^2*bf(1)'
    'Sn(2) A_G_3xpsicXord^1*bf(1)'}; 
ConLabels{3}= {... %PainControlLabels (P stands for PAIN not PLACEBO!)
    'Sn(2) P_3*bf(1)'
    'Sn(2) P_3xpsicofisica^1*bf(1)'
    'Sn(2) P_3xpsicofisica^2*bf(1)'
    'Sn(2) P_3xordine^1*bf(1)'
    'Sn(2) P_3xordine^2*bf(1)'
    'Sn(2) P_3xpsicXord^1*bf(1)'}; 
ConLabels{4}= {... %PainPlaceboLabels (P stands for PAIN not PLACEBO!)
    'Sn(2) NoP_3*bf(1)'
    'Sn(2) NoP_3xpsicofisica^1*bf(1)'
    'Sn(2) NoP_3xpsicofisica^2*bf(1)'
    'Sn(2) NoP_3xordine^1*bf(1)'
    'Sn(2) NoP_3xordine^2*bf(1)'
    'Sn(2) NoP_3xpsicXord^1*bf(1)'}; 
%% Procedure to calculate "CON" images representing stimulus+derivatives (assuming default standardization and orthagonalization as implemented in SPM)
% for i=1:length(luifolders)
%     % Get current participant folder and load SPM
%     currdir=fullfile(basedir,studydir,luifolders{i});    
%     load(fullfile(currdir, 'SPM.mat'));
%     for j=1:length(ConLabels) % for each desired contrast
%         betaNos=find(ismember(SPM.xX.name,ConLabels{j}')); % get beta-numbers
%         betaImgs=strsplit(sprintf('beta_00%d.hdr,',betaNos'),',');
%         betaImgs=betaImgs(~cellfun(@isempty,betaImgs));
%         disp(['For participant ',luifolders{i},' ',num2str(length(betaImgs)),' beta images were summarized for ',con_descriptors{j},'.img'])
%         spm_imcalc(...
%             fullfile(currdir,betaImgs),...
%             fullfile(currdir,[con_descriptors{j},'.img']),...
%             'sum(X)',...
%             {1}); % <--- This is spm_imcalc's "read images as data-matrix (dtmx)" argument...
%     end
% end
% For some reason the placebo condition was only modeled with 5 regressors
% in Participant TOMO_18 (anticipation and placebo)

%% Import behavioral
xls_path=fullfile(basedir, studydir, 'Lui_Behavioural_Demografics.xlsx');

unimale=xlsread(xls_path,1,'C3:C40');
uniage=xlsread(xls_path,1,'D3:D40');
[~,~,unistimside]=xlsread(xls_path,1,'B3:B40');
uniratingPla=xlsread(xls_path,1,'M3:M40');
uniratingCon=xlsread(xls_path,1,'L3:L40');
unistimInt=xlsread(xls_path,1,'F3:F40'); % Day 3 Data had high stimulus intensities only, so only high stim ints are imported

%Read image names and ratings
for j= 1:nsubj
    currdir=fullfile(basedir,studydir,luifolders{j});
    load(fullfile(currdir, 'SPM.mat'));
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    for i = 1:length(con_descriptors)
        currsubNO=luifolders{j}(end-1:end);
        %Get filenames in a (subj,con) matrix
        img{j,i} = fullfile(studydir,luifolders{j}, [con_descriptors{i},'.img']);
        %Get subject and con ID in the same (subj,con) matrix format
        i_sub{j,i}=['lui_',currsubNO];
        con(j,i)=con_IDs(i);
        %Get description of conditions in a in (subj,con) matrix format
        cond(j,i)=con_descriptors(i); 
        
        % Placebo condition
        % 0= Any Control 1 = Any Placebo  2 = Other
        if ismember(con(j,i),[2 4])
             pla(j,i)=1;
             rating(j,i)=uniratingPla(str2num(currsubNO));
            elseif ismember(con(j,i),[1 3])
             pla(j,i)=0;    % 0= Any Control 1 = Any Placebo  2 = Other
             rating(j,i)=uniratingCon(str2num(currsubNO));
            else
             pla(j,i)=NaN;
             rating(j,i)=NaN;
        end
        %Get xSpan from SPM:
        iCon=ismember(SPM.xX.name,ConLabels{i}); % Get index of right betas with correct names
        xSpan(j,i)=sum(xSpanRaw(iCon)); % Gets x-Vextors according to index above
        conSpan(j,i)=2; % Computed manually above
        nImages(j,i)=size(SPM.xX.X,1);
        male(j,i)=unimale(str2num(currsubNO));
        age(j,i)=uniage(str2num(currsubNO));
        stimside(j,i)=unistimside(str2num(currsubNO));
        stimInt(j,i)=unistimInt(str2num(currsubNO));   
    end
end

img=vertcat(img(:));          % The absolute image paths
sub=vertcat(i_sub(:));               % The subject number (study specific)
con=vertcat(con(:));
nImages=vertcat(nImages(:));

% Pain condition
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain(ismember(con,[1 2]),1)=0;     
pain(ismember(con,[3 4]),1)=1;
cond=vertcat(cond(:));  

condSeq=ones(size(img))*3;         % Third session in row, red and green cues "pseudorandomly alternated" within run.
plaFirst=ones(size(img))*0.5;        % Completely mixed sequence
temp=NaN(size(img));            % Not yet available

%xSpan (from max(SPM.xX.X)-min(SPM.xX.X)) 
xSpan=vertcat(xSpan(:));

% Create Study-Specific table
lui=table(img);
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
lui.rating=vertcat(rating(:)); % Ratings were scaled in 255 steps.            
lui.stimInt=vertcat(stimInt(:));             
lui.fieldStrength=ones(size(lui.img)).*3;
lui.tr           =ones(size(lui.img)).*3014;
lui.te           =ones(size(lui.img)).*35;
lui.voxelVolAcq  =ones(size(lui.img)).*(1.875*1.875*3.5);
lui.voxelVolMat  =ones(size(lui.img)).*(2*2*2);
lui.meanBlockDur =ones(size(lui.cond)).*0; % Paper and SPM agree (somewhat, the paper states that pain was modeled as an 1 TR event, which is not possible)
lui.nImages      =nImages; % Images per Participant
lui.xSpan        =xSpan;
lui.conSpan      =conSpan(:);

%% Save
outpath=fullfile(basedir,'Lui_et_al_2010.mat')
save(outpath,'lui')

end