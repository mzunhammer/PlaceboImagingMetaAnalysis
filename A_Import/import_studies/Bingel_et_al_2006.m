function Bingel_et_al_2006

%% Collects all behavioral data and absolute img-paths for Elsenbruch 2012
% in a data frame, saves as .mat
% Since second session data for participant CK and FK were missing these
% were replaced by all-NaN "dummy" images

%% Set working environment

basedir = '../../../Datasets/';

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir= 'Bingel_et_al_2006/';
beta_IDs = [1 4 2 5];
nbeta=length(beta_IDs);
beta_descriptors= {...
    'cuePlacebo'...
    'cueNoPlacebo'...
    'painPlacebo'...
    'painNoPlacebo'...
    };
beta_imgnames= {...
    'beta_0001'...
    'beta_0004'...
    'beta_0002'...
    'beta_0005'...
    };
beta_coding={...
    logical([1 0 0 0 0 0 0 0]),...
    logical([0 0 0 1 0 0 0 0]),...
    logical([0 1 0 0 0 0 0 0]),...
    logical([0 0 0 0 1 0 0 0]),...
    }; %Contrasts had to be computed from betas post-hoc
sides={'L'...
       'R'};
bingelfolders=dir(fullfile(basedir,studydir));
bingelfolders={bingelfolders.name};
bingelfolders=bingelfolders(~cellfun(@isempty,...
                            regexp(bingelfolders','^\w{2,4}$','match')));
nsubj=length(bingelfolders);

img={};
%for each participant

xls_path=fullfile(basedir, studydir,filesep, 'mean_ratings_oc.xlsx');

%Ratings
rating_pla_sess1=xlsread(xls_path,1,'B3:B21');
rating_beta_sess1=xlsread(xls_path,1,'C3:C21');
rating_pla_sess2=xlsread(xls_path,1,'F3:F21');
rating_beta_sess2=xlsread(xls_path,1,'G3:G21');

%Quote from the original publication:
% Subjects were investigated in two scanning sessions. The placebo- cream was applied to the right hand in one session and to the left hand in the other scanning session, with the order randomized across subjects. The non-placebo hand was treated with an ?inactive? control cream
% Folder Structure is:
% SUBJECTID/ana{SESSION NUMBER}{PLACEBO L or R}

for j= 1:nsubj
    currfolder=fullfile(basedir,studydir,bingelfolders{j});
    % Get sub-folders of sub-sessions
    sidefolders=dir(currfolder);
    sidefolders={sidefolders.name};
    sidefolders=sidefolders(~cellfun(@isempty,...
                            regexpi(sidefolders','^ana\d\w','match')));
    pla_side=regexpi(sidefolders','^ana\d(\w)','tokens');
    pla_side=[pla_side{:}]; pla_side=[pla_side{:}];
    %for each session
    for k= 1:length(sidefolders)
        currfolder2=fullfile(currfolder,sidefolders{k});
        %get x_span from SPM
        currSPMpath = fullfile(currfolder2,'SPM.mat');
        load(currSPMpath);
        xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);
        xLength=size(SPM.xX.X,1);
        %for each contrast
        for i = 1:length(beta_descriptors)
            %Get filenames in a (subj,beta) matrix
            img{j,i,k}=fullfile(studydir,bingelfolders{j},sidefolders{k}, [beta_imgnames{i},'.img']);
            %Get subject and beta ID in the same (subj,beta) matrix format
            i_sub(j,i,k)=bingelfolders(j);
            n_imgs(j,i,k)=xLength;
            x_span(j,i,k)=sum(xSpanRaw(beta_coding{i})); %Approximate predictor scaling 
            con_span(j,i,k)=sum(abs(beta_coding{i})); %sum(abs(SPMcon));
            switch i
                case 1 %'cuePlacebo'
                    n_blocks(j,i,k)=length(SPM.Sess.U(1).ons);
                case 2 %'cueNoPlacebo'
                    n_blocks(j,i,k)=length(SPM.Sess.U(3).ons);
                case 3 %'painPlacebo'
                    n_blocks(j,i,k)=length(SPM.Sess.U(2).ons);
                case 4 %'painNoPlacebo'
                    n_blocks(j,i,k)=length(SPM.Sess.U(4).ons);
            end
            %Get description of conditions in a in (subj,con) matrix format
            cond_raw(j,i,k)={beta_descriptors{i}}; 
            i_condition_in_sequence(j,i,k)=k; 
            % Assign "placebo condition" according to experimental condition
            % 0= Any Control 1 = Any Placebo  2 = Other
            pla(j,i,k)=cellfun(@isempty, regexpi(cond_raw(j,i,k),'NoPlacebo'));
            
            % Get side depending on placebo condition
            if pla(j,i,k)==1 % If current session was placebo...
                side(j,i,k)=sides(strcmp(sides,pla_side(k))); % use pla_side as is.
            elseif pla(j,i,k)==0 % If current session was control...
                side(j,i,k)=sides(~strcmp(sides,pla_side(k))); %insert opposite side.
            end
            cond{j,i,k}=[cond_raw{j,i,k},'_', side{j,i,k}]; %combine cond_raw and side to cond

            % Get rating depending on session number and placebo
            % condition
            if pla(j,i,k)==1 && i_condition_in_sequence(j,i,k)==1 
                rating(j,i,k)=rating_pla_sess1(j); %select rating
            elseif pla(j,i,k)==0 && i_condition_in_sequence(j,i,k)==1
                rating(j,i,k)=rating_beta_sess1(j);
            elseif pla(j,i,k)==1 && i_condition_in_sequence(j,i,k)==2
                rating(j,i,k)=rating_pla_sess2(j);
            elseif pla(j,i,k)==0 && i_condition_in_sequence(j,i,k)==2
                rating(j,i,k)=rating_beta_sess2(j);
            else
                rating(j,i,k)=NaN;
            end
        end
    end
end


img=vertcat(img(:));
sub=vertcat(i_sub(:));
side=vertcat(side(:));
x_span=vertcat(x_span(:));
con_span=vertcat(con_span(:));
cond=vertcat(cond(:));
i_condition_in_sequence=vertcat(i_condition_in_sequence(:));
n_imgs=vertcat(n_imgs(:));
n_blocks=vertcat(n_blocks(:));
pla=vertcat(pla(:));
rating=vertcat(rating(:));


% Create a version of ratings on a 101pt-(%)Scale (0%, no pain, 100%, maximum pain)
% Scale was 0 to 4
% 0: no sensation
% 1: nonpainful warmth (the last non-painful (0%) rating)
% 2: pain threshold
% 3: moderate pain
% 4: maximum pain used in experiment
rating101=(rating-1)*100/3;
rating101(rating101<0)=0;

% Assign "pain condition" to con image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain=~cellfun(@isempty,regexpi(cond,'pain','match'));  
%% Collect all Variables in Table
bingel06=table(img);
bingel06.img=img;
bingel06.study_ID=repmat({'bingel'},size(bingel06.img));
bingel06.sub_ID=strcat('bingel06_',sub);
bingel06.male=ones(size(bingel06.img))*((19-4)/19); %MISSING: Mean sex according to paper
bingel06.age=ones(size(bingel06.img))*((19-4)/19);  %MISSING: Mean age according to paper
bingel06.healthy=ones(size(bingel06.img));
bingel06.pla=pla;
bingel06.pain=pain;
bingel06.predictable=ones(size(bingel06.img)); %Uncertainty: Train of 4 stimuli started 6?1s after cue, with 7?1s between stimuli"
bingel06.real_treat=zeros(size(bingel06.img));  %only placebo creams
bingel06.cond=cond;
bingel06.stim_side=side;
bingel06.placebo_first=zeros(size(bingel06.img))+.5; %In this study placebo and control were measured in random sequence, thus placebo first/second does not apply
bingel06.i_condition_in_sequence=i_condition_in_sequence;
bingel06.rating=rating;  %Currently unknown
bingel06.rating101=rating101;
bingel06.stim_intensity=ones(size(bingel06.img)).*0.6; %All had 0.6 Joule             
bingel06.imgs_per_stimulus_block =zeros(size(bingel06.cond)); % All modeled as events
bingel06.n_blocks      =n_blocks; % According to SPM
bingel06.n_imgs      =n_imgs; % Images per Participant AND SIDE!!! number of images/participant is 488*2=976
bingel06.x_span        =x_span;
bingel06.con_span      =con_span; %con images used
bingel06(cellfun(@isempty,bingel06.img),:)=[]; % Delete missing sessions
%% Save in data_frame
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_id,'bingel06')),'raw'}={bingel06};
save(fullfile(basedir,'data_frame.mat'),'df');
end
