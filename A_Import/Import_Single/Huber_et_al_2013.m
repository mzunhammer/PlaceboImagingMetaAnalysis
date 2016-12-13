function Huber_et_al_2013

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';
studydir= 'Huber_et_al_2013';

%% Load images paths

%% Combine Betas to Cons representing the experimental conditions:
% Since placebo-pain and control-pain stimuli were modeled as
% stimulus+time-derivative, we'll have to combine betas:

% CAVE: FOR SOME PARTICIPANTS THERE WERE EXTRA PREDICTORS ON  SESSIONS 1 and 2
% (the unimportant ones)... therefore the beta-numbers are
% not identical for all participants and have to be calculated based on the
% names of the design-matrix columns given in the SPM.xX.name
% The usual participant has 53 beta images.
% The columns of interest are:
% "Sn(3) A_R_3*bf(1)" + "Sn(3) A_R_3xordine^1*bf(1)" (Anticipation Control)
% "Sn(3) A_G_3*bf(1)" + "Sn(3) A_G_3xordine^1*bf(1)" (Anticipation Placebo)
% "Sn(3) P_3*bf(1)"   + "Sn(3) P_3xordine^1*bf(1)"   (Pain Control)
% "Sn(3) NoP_3*bf(1)" + "Sn(3) NoP_3xordine^1*bf(1)" (Pain Placebo)

beta_IDs = [1,2,3,4,5,6,7,8];
beta_descriptors= {...
   'antic_control_red'...
   'antic_control_red_1st_deriv'...
   'antic_placebo_green'...
   'antic_placebo_green_1st_deriv'...
   'pain_control'...
   'pain_control_1st_deriv'...
   'pain_placebo'...
   'pain_placebo_1st_deriv'};

huberfolders=dir(fullfile(basedir,studydir));
huberfolders={huberfolders.name};
huberfolders=huberfolders(~cellfun(@isempty,...
                            regexpi(huberfolders','^TOMO_\d\d$','match')));
nsubj=length(huberfolders);

% Con terms as listed in SPM.xX.name used to search the correct betas-numbers for
% each participant
con_term1= {...
 'Sn(3) A_R_3*bf(1)'...  %(Anticipation Control)
 'Sn(3) A_G_3*bf(1)'... %(Anticipation Placebo)
 'Sn(3) P_3*bf(1)'...   %(Pain Control)
 'Sn(3) NoP_3*bf(1)'}; %(Pain Placebo)
con_term2= {...
 'Sn(3) A_R_3xordine^1*bf(1)'...  %(Anticipation Control) 1st derivative
 'Sn(3) A_G_3xordine^1*bf(1)'... %(Anticipation Placebo) 1st derivative
 'Sn(3) P_3xordine^1*bf(1)'...   %(Pain Control) 1st derivative
 'Sn(3) NoP_3xordine^1*bf(1)'}; %(Pain Placebo) 1st derivative


%% Procedure to calculate "CON" images representing stimulus+time derivatives
% for i=1:length(huberfolders)
% % Combine First time derivatives and stimulus times
%     currdir=fullfile(basedir,studydir,huberfolders{i});
%     load(fullfile(currdir, 'SPM.mat'));
%     SPM.xX.name;
%     
%     AR_betano=num2str(find(strcmp(SPM.xX.name,con_term1{1})));
%     AR1_betano=num2str(find(strcmp(SPM.xX.name,con_term2{1})));
%     spm_imcalc(...% Combine anticipation control
%         {fullfile(currdir,['beta_00',AR_betano,'.hdr']),...
%             fullfile(currdir,['beta_00',AR1_betano,'.hdr'])},...
%         fullfile(currdir,'conAnticControl.img'),...
%         '(i1+i2)');
%     
%     AG_betano=num2str(find(strcmp(SPM.xX.name,con_term1{2})));
%     AG1_betano=num2str(find(strcmp(SPM.xX.name,con_term2{2})));
%     spm_imcalc(...% Combine anticipation placebo
%         {fullfile(currdir,['beta_00',AG_betano,'.hdr']),...
%             fullfile(currdir,['beta_00',AG1_betano,'.hdr'])},...
%         fullfile(currdir,'conAnticPlacebo.img'),...
%         '(i1+i2)');
% % Combine Pain Betas "Sn(3) P_3*bf(1)"   + "Sn(3) P_3xordine^1*bf(1)"
%     PC_betano=num2str(find(strcmp(SPM.xX.name,con_term1{3})));
%     PC1_betano=num2str(find(strcmp(SPM.xX.name,con_term2{3})));
%     spm_imcalc(...% Combine anticipation control
%         {fullfile(currdir,['beta_00',PC_betano,'.hdr']),...
%             fullfile(currdir,['beta_00',PC1_betano,'.hdr'])},...
%         fullfile(currdir,'conPainControl.img'),...
%         '(i1+i2)');
%     PP_betano=num2str(find(strcmp(SPM.xX.name,con_term1{4})));
%     PP1_betano=num2str(find(strcmp(SPM.xX.name,con_term2{4})));
%     spm_imcalc(...% Combine anticipation placebo
%         {fullfile(currdir,['beta_00',PP_betano,'.hdr']),...
%             fullfile(currdir,['beta_00',PP1_betano,'.hdr'])},...
%         fullfile(currdir,'conPainPlacebo.img'),...
%         '(i1+i2)');
% end

con_IDs = [1, 2, 3, 4];
con_descriptors= {...
    'conAnticControl'...
    'conAnticPlacebo'...
    'conPainControl'...
    'conPainPlacebo'};

% Import behavioral
xls_path=fullfile(basedir, studydir, 'Huber_Behavioural_Demografics.xlsx');

unimale=xlsread(xls_path,1,'C3:C40');
uniage=xlsread(xls_path,1,'D3:D40');
[~,~,unistimside]=xlsread(xls_path,1,'B3:B40');
uniratingPla=xlsread(xls_path,1,'M3:M40');
uniratingCon=xlsread(xls_path,1,'L3:L40');
unistimInt=xlsread(xls_path,1,'F3:F40'); % Day 3 Data had high stimulus intensities only, so only high stim ints are imported

%Ratings
for j= 1:nsubj
    currdir=fullfile(basedir,studydir,huberfolders{j});
    load(fullfile(currdir, 'SPM.mat'));
    xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
    for i = 1:length(con_descriptors)
        currsubNO=huberfolders{j}(end-1:end);
        %Get filenames in a (subj,con) matrix
        img{j,i} = fullfile(studydir,huberfolders{j}, [con_descriptors{i},'.img']);
        %Get subject and con ID in the same (subj,con) matrix format
        i_sub{j,i}=['huber_',currsubNO];
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
        iCon=strcmp(SPM.xX.name,con_term1{i})|strcmp(SPM.xX.name,con_term2{i}); % Get index of right betas with correct names
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
huber=table(img);
huber.imgType=repmat({'fMRI'},size(huber.img));
huber.studyType=repmat({'within'},size(huber.img));
huber.studyID=repmat({'huber'},size(huber.img));
huber.subID=i_sub(:);
huber.male=vertcat(male(:));
huber.age=vertcat(age(:));
huber.healthy=ones(size(huber.img));
huber.pla=vertcat(pla(:));
huber.pain=pain;
huber.predictable=ones(size(huber.img));                %No uncertainty: Fixed 12 second anticipation
huber.realTreat=zeros(size(huber.img));                 %No real treatment
huber.cond=vertcat(cond(:));             
huber.stimtype=repmat({'laser'},size(huber.img));
huber.stimloc=repmat({'L or R foot (v)'},size(huber.img));
huber.stimside=vertcat(stimside(:));       %Very important in this study: some subjects were stimulated left, some right
huber.plaForm=repmat({'TENS'},size(huber.img));
huber.plaInduct=repmat({'Suggestions + Conditioning'},size(huber.img));
huber.plaFirst=plaFirst;
huber.condSeq=condSeq;
huber.rating=vertcat(rating(:)); % Ratings were scaled in 255 steps.            
huber.stimInt=vertcat(stimInt(:));             
huber.fieldStrength=ones(size(huber.img)).*3;
huber.tr           =ones(size(huber.img)).*3014;
huber.te           =ones(size(huber.img)).*35;
huber.voxelVolAcq  =ones(size(huber.img)).*(1.875*1.875*3.5);
huber.voxelVolMat  =ones(size(huber.img)).*(2*2*2);
huber.meanBlockDur =ones(size(huber.cond)).*0; % Paper and SPM agree
huber.nImages      =nImages; % Images per Participant
huber.xSpan        =xSpan;
huber.conSpan      =conSpan(:);

%% Save
outpath=fullfile(basedir,'Huber_et_al_2013.mat')
save(outpath,'huber')

end