function Bingel_et_al_2006

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat

%% Set working environment
clear
cd '/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Import/Import_Single/'
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Bingel_et_al_2006/';
con_IDs = [1 4 2 5];
ncon=length(con_IDs);
con_descriptors= {...
    'con_cuePlacebo'...
    'con_cueNoPlacebo'...
    'con_painPlacebo'...
    'con_painNoPlacebo'...
    };
con_imgnames= {...
    'beta_0001'...
    'beta_0004'...
    'con_painPlacebo'...
    'con_painNoPlacebo'...
    };
con_coding={...
    logical([1 0 0 0 0 0 0 0]),...
    logical([0 0 0 1 0 0 0 0]),...
    logical([0 1 1 0 0 0 0 0]),...
    logical([0 0 0 0 1 1 0 0]),...
    }; %Contrasts had to be computed from betas post-hoc
bingelfolders=dir(fullfile(basedir,studydir));
bingelfolders={bingelfolders.name};
bingelfolders=bingelfolders(~cellfun(@isempty,...
                            regexpi(bingelfolders','^\w+$','match')));
nsubj=length(bingelfolders);

img={};
%for each participant

xls_path=fullfile(basedir, studydir,filesep, 'mean_ratings_oc.xlsx');

%Ratings
rating_pla_sess1=xlsread(xls_path,1,'B3:B21');
rating_con_sess1=xlsread(xls_path,1,'C3:C21');
rating_pla_sess2=xlsread(xls_path,1,'F3:F21');
rating_con_sess2=xlsread(xls_path,1,'G3:G21');

for j= 1:nsubj
    currfolder=fullfile(basedir,studydir,bingelfolders{j});
    % Get sub-folders of sub-sessions
    sidefolders=dir(currfolder);
    sidefolders={sidefolders.name};
    sidefolders=sidefolders(~cellfun(@isempty,...
                            regexpi(sidefolders','^ana\d\w','match')));
    sides=regexpi(sidefolders','^ana\d(\w)','tokens');
    sides=[sides{:}]; sides=[sides{:}];
    %for each session
    for k= 1:length(sidefolders)
        currfolder2=fullfile(currfolder,sidefolders{k});
        %get xSpan from SPM
        currSPMpath = fullfile(currfolder2,'SPM.mat');
        load(currSPMpath);
        xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
        xLength=size(SPM.xX.X,1);
        %for each contrast
        for i = 1:length(con_descriptors)
            %Get filenames in a (subj,con) matrix
            img{j,i,k}=fullfile(studydir,bingelfolders{j},sidefolders{k}, [con_imgnames{i},'.img']);
            %Get subject and con ID in the same (subj,con) matrix format
            i_sub(j,i,k)=bingelfolders(j);
            side(j,i,k)=sides(k);
            nImages(j,i,k)=xLength;
            xSpan(j,i,k)=sum(xSpanRaw(con_coding{i})); %Approximate predictor scaling 
            conSpan(j,i,k)=sum(abs(con_coding{i})); %sum(abs(SPMcon));
            %Get description of conditions in a in (subj,con) matrix format
            cond(j,i,k)={[con_descriptors{i},'_', sides{k}]}; 
            condSeq(j,i,k)=k; 
            % Assign "placebo condition" according to experimental condition
            % 0= Any Control 1 = Any Placebo  2 = Other
            pla(j,i,k)=cellfun(@isempty, regexpi(cond(j,i,k),'NoPlacebo'));
            
            if pla(j,i,k)==1 && condSeq(j,i,k)==1
                rating(j,i,k)=rating_pla_sess1(j);
            elseif pla(j,i,k)==0 && condSeq(j,i,k)==1
                rating(j,i,k)=rating_con_sess1(j);
            elseif pla(j,i,k)==1 && condSeq(j,i,k)==2
                rating(j,i,k)=rating_pla_sess2(j);
            elseif pla(j,i,k)==0 && condSeq(j,i,k)==2
                rating(j,i,k)=rating_con_sess2(j);
            else
                rating(j,i,k)=NaN;
            end
        end
    end
end

img=vertcat(img(:));
sub=vertcat(i_sub(:));
side=vertcat(side(:));
xSpan=vertcat(xSpan(:));
conSpan=vertcat(conSpan(:));
cond=vertcat(cond(:));
condSeq=vertcat(condSeq(:));
nImages=vertcat(nImages(:));
pla=vertcat(pla(:));
rating=vertcat(rating(:));

% Assign "pain condition" to con image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain=~cellfun(@isempty,regexpi(cond,'pain','match'));  
%% Collect all Variables in Table

% Create Study-Specific table
bingel06=table(img);
bingel06.imgType=repmat({'fMRI'},size(bingel06.img));
bingel06.studyType=repmat({'within'},size(bingel06.img));
bingel06.studyID=repmat({'bingel'},size(bingel06.img));
bingel06.subID=strcat('bingel06_',sub);
bingel06.male=ones(size(bingel06.img))*((19-4)/19); %MISSING: Mean sex according to paper
bingel06.age=ones(size(bingel06.img))*((19-4)/19);  %MISSING: Mean age according to paper
bingel06.healthy=ones(size(bingel06.img));
bingel06.pla=pla;
bingel06.pain=pain;
bingel06.predictable=ones(size(bingel06.img)); %Uncertainty: Train of 4 stimuli started 6±1s after cue, with 7±1s between stimuli"
bingel06.realTreat=zeros(size(bingel06.img));  %only placebo creams
bingel06.cond=cond;
bingel06.stimtype=repmat({'laser'},size(bingel06.img));
bingel06.stimloc=repmat({'L & R hand (d)'},size(bingel06.img));
bingel06.stimside=side;
bingel06.plaForm=repmat({'Topical Cream/Gel/Patch'},size(bingel06.img));
bingel06.plaInduct=repmat({'Suggestions + Conditioning'},size(bingel06.img));
bingel06.plaFirst=zeros(size(bingel06.img))+.5; %In this study placebo and control were measured in random sequence, thus placebo first/second does not apply
bingel06.condSeq=condSeq;
bingel06.rating=rating;  %Currently unknown            
bingel06.stimInt=ones(size(bingel06.img)).*0.6; %All had 0.6 Joule             
bingel06.fieldStrength=ones(size(bingel06.img)).*1.5;
bingel06.tr           =ones(size(bingel06.img)).*2600;
bingel06.te           =ones(size(bingel06.img)).*40;
bingel06.voxelVolAcq  =ones(size(bingel06.img)).*((210/64)*(210/64)*(3+1));
bingel06.voxelVolMat  =ones(size(bingel06.img)).*(3*3*3);
bingel06.meanBlockDur =zeros(size(bingel06.cond)); % All modeled as events
bingel06.nImages      =nImages; % Images per Participant AND SIDE!!! number of images/participant is 488*2=976
bingel06.xSpan        =xSpan;
bingel06.conSpan      =conSpan; %con images used
bingel06(cellfun(@isempty,bingel06.img),:)=[]; % Delete missing sessions
%% Save
outpath=fullfile(basedir,'Bingel_et_al_2006.mat')
save(outpath,'bingel06')

end