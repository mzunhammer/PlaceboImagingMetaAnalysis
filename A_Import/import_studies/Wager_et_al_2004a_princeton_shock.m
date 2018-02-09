function Wager_et_al_2004a_Princeton_shock(datapath)

%% Set working environment

basedir = datapath;

%% Load images paths
%and extract/assign experimental conditions from/to image names
studydir = 'Wager_et_al_2004a_Princeton_shock';
load(fullfile(basedir,studydir,'EXPTrilling.mat'));
% Get subject-directorys from EXPT.mat
subdir=EXPTrilling.subdir;

% Determine the betas for placebo/control from the contrasts saved in xCon    
    % Manual Extraction from xCon.mat:
    % None:                     Betas   1  6   11  16
    % Mild:                     Betas   2  7   12  17
    % Intense:                  Betas   3  8   13  18
    % Anticipation_Mild(?):     Betas   4  9   14  19 (Not explicitly used in any contrast, just guessing)
    % Anticipation_Intense:     Betas   5  10  15  20
    % Placebo/Control Runs alternated, must be extracted individually:
    % xCon(3) represents Intense>None Cont>Placebo
    % Therefore, if xCon(3).c(3)= 1  Betas 1:5 were control
    %            if xCon(3).c(3)=-1 Betas 1:5 were placebo
    % No betas available so far.
 
%         con_0002: 'intense-none';
%         con_0003: '(intense-none)control-placebo';
%         con_0004: 'antint';
%         con_0005: 'antint(control-placebo)';
%         con_0006: 'intense-mild';
con_name={'intense-none';'(intense-none)control-placebo';'antint';'antint(control-placebo)';'intense-mild'};
con_ID=[2;3;4;5;6];
    for j=1:length(subdir)
       currpath=fullfile(studydir,subdir{j});
       load(fullfile(basedir,currpath,'SPM_fMRIDesMtx.mat')); %For determining x_span, pre-load the SPM for that subject
       xSpanRaw=max(xX.X)-min(xX.X);
       for i=1:size(con_ID,1)
        n_imgs(j,i)=size(xX.X,1);
        %Get filenames in a (subj,con) matrix
        img{j,i} = fullfile(currpath,sprintf('con_00%0.2d.img', con_ID(i)));
        sub(j,i)=subdir(j); % The subject number (study specific)
        %Build Placebo vector
        if con_ID(i)==3 || con_ID(i)==5
            pla(j,i)=1; % 0= Any Control 1 = Any Placebo  2 = Other
        else    
            pla(j,i)=0; % 0= Any Control 1 = Any Placebo  2 = Other
        end
    %Build Pain vector
        switch con_ID(i)
            case 2
            pain(j,i)=1; % 0= NoPain 1=FullPain --> in this case contrast Strong vs No Pain
            x_span(j,i)=mean(xSpanRaw([1 6 11 16 3 8 13 18])); % Differential Contrast from betas 1 6 11 16 vs 3 8 13 18
            %no nImagesPerBlock since all vectors were modeled as events
            n_blocks(j,i)=length(Sess{1,1}.ons{1,1})+...
                        length(Sess{1,2}.ons{1,1})+...
                        length(Sess{1,3}.ons{1,1})+...
                        length(Sess{1,4}.ons{1,1})+...
                        length(Sess{1,1}.ons{1,3})+...
                        length(Sess{1,2}.ons{1,3})+...
                        length(Sess{1,3}.ons{1,3})+...
                        length(Sess{1,4}.ons{1,3});
            rating(j,i)=NaN;
            case 3
            pain(j,i)=0; % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain 4=StrongVsWeakPain 5=StrongVsNoPain
            x_span(j,i)=mean(xSpanRaw([1 6 11 16 3 8 13 18])); % Differential Contrast from betas 1 6 11 16 and 3 8 13 18
            rating(j,i)=EXPTrilling.behavior(j);
            n_blocks(j,i)=length(Sess{1,1}.ons{1,1})+...
                        length(Sess{1,2}.ons{1,1})+...
                        length(Sess{1,3}.ons{1,1})+...
                        length(Sess{1,4}.ons{1,1})+...
                        length(Sess{1,1}.ons{1,3})+...
                        length(Sess{1,2}.ons{1,3})+...
                        length(Sess{1,3}.ons{1,3})+...
                        length(Sess{1,4}.ons{1,3});
            case 4
            pain(j,i)=0; % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain 4=StrongVsWeakPain 5=StrongVsNoPain
            x_span(j,i)=mean(xSpanRaw([5 10 15 20])); % Additive Contrast from betas  5  10  15  20 (large fluctuations because of large jitter)
            rating(j,i)=NaN;
                        n_blocks(j,i)=length(Sess{1,1}.ons{1,5})+...
                        length(Sess{1,2}.ons{1,5})+...
                        length(Sess{1,3}.ons{1,5})+...
                        length(Sess{1,4}.ons{1,5});
            case 5
            pain(j,i)=0; % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain 4=StrongVsWeakPain 5=StrongVsNoPain
            x_span(j,i)=mean(xSpanRaw([5 10 15 20])); % Differential Contrast from betas 5  10  15  20
            rating(j,i)=EXPTrilling.behavior(j);
            n_blocks(j,i)=length(Sess{1,1}.ons{1,5})+...
                        length(Sess{1,2}.ons{1,5})+...
                        length(Sess{1,3}.ons{1,5})+...
                        length(Sess{1,4}.ons{1,5});
            case 6
            pain(j,i)=1; %  --> in this case contrast Strong vs Mild Pain !!!
            x_span(j,i)=mean(xSpanRaw([2 7 12 17 3 8 13 18]));% Differential Contrast from betas 2  7 12  17 and 3  8 13  18 
            rating(j,i)=NaN;
            n_blocks(j,i)=length(Sess{1,1}.ons{1,2})+...
                        length(Sess{1,2}.ons{1,2})+...
                        length(Sess{1,3}.ons{1,2})+...
                        length(Sess{1,4}.ons{1,2})+...
                        length(Sess{1,1}.ons{1,3})+...
                        length(Sess{1,2}.ons{1,3})+...
                        length(Sess{1,3}.ons{1,3})+...
                        length(Sess{1,4}.ons{1,3});
        end    
     %Build conditions vector
     cond(j,i)=con_name(i);
       end
    end

        img      = vertcat(img(:)); 
        sub      = vertcat(sub(:));
        pla      = vertcat(pla(:));
        pain     = vertcat(pain(:));
        x_span    = vertcat(x_span(:));
        n_imgs  = vertcat(n_imgs(:));
        n_blocks  = vertcat(n_blocks(:));
        cond     = vertcat(cond(:));
        rating   = vertcat(rating(:));

%blockLength
% p=(~cellfun(@isempty, (regexp(cond,'pain'))));

% This will be a difficult one:
% The SPMcfg-File contains an xX matrix where:
% "none" intervals scaled between 2.5123 (max) and -0.3985 min
% "mild" intervals scaled between 2.3972 (max) and -0.5135 min
% "intense" intervals scaled between 2.5123 (max) and -0.3985 min
% "anticipation mild" intervals scaled between 79.8974 (max) and  -19.5755 min
% "anticipation intense" intervals scaled between 96.0899 (max) and  -24.4716 min
blockLength=NaN(size(cond));

%con_span>>> Different for con
con_span(~cellfun(@isempty, (regexp(img,'0002.img'))),1) =4; % Differential Contrast from betas 1 6 11 16 vs 3 8 13 18 -> Contrast weigths add to 0, positive weights add to 4
con_span(~cellfun(@isempty, (regexp(img,'0003.img'))),1) =4; % Differential Contrast from betas 1 6 11 16 and 3 8 13 18 -> Contrast weigths add to 0, positive weights add to 4
con_span(~cellfun(@isempty, (regexp(img,'0004.img'))),1) =4; % Additive Contrast from betas  5  10  15  20 -> Contrasts weigths adding to 4
con_span(~cellfun(@isempty, (regexp(img,'0005.img'))),1) =2; % Differential Contrast from betas 5  10  15  20 -> Contrast weigths add to 0, positive weights add to 2
con_span(~cellfun(@isempty, (regexp(img,'0006.img'))),1) =4; % Differential Contrast from betas 2  7 12  17 and 3  8 13 18 -> Contrast weigths add to 0, positive weights add to 4

% Create Study-Specific table
wager_princeton=table(img);
wager_princeton.img=img;
wager_princeton.study_ID=repmat({'wager04a_princeton'},size(wager_princeton.img));
wager_princeton.sub_ID=strcat(wager_princeton.study_ID,'_',sub);
wager_princeton.male=NaN(size(wager_princeton.img));
wager_princeton.age=NaN(size(wager_princeton.img));
wager_princeton.healthy=ones(size(wager_princeton.img));
wager_princeton.pla=pla;
wager_princeton.pain=pain;
wager_princeton.predictable=zeros(size(wager_princeton.img)); %Uncertainty: mean 3,6,9,12 seconds anticipation
wager_princeton.real_treat=zeros(size(wager_princeton.img));
wager_princeton.cond=vertcat(cond(:));
wager_princeton.stim_side=repmat({'R'},size(wager_princeton.img));
wager_princeton.placebo_first=NaN(size(wager_princeton.img));% Parallel group design with pill>> placebo always first session
wager_princeton.i_condition_in_sequence=NaN(size(wager_princeton.img));% Parallel group design with pill>>  only first sessions
wager_princeton.rating=rating;
wager_princeton.rating101=rating*10; % an 11 pt-scale ranging from 0 (non painful) to 10 (unbearable) was used.
wager_princeton.stim_intensity=NaN(size(wager_princeton.img));       
wager_princeton.imgs_per_stimulus_block =zeros(size(cond)); % Everything modeled as events accroding to paper. However, each anticipation periods cosisted of many events
wager_princeton.n_blocks      =n_blocks; % Sum of events within each condition, according to SPM
wager_princeton.n_imgs      =zeros(size(cond)); % all events
wager_princeton.x_span        =x_span;
wager_princeton.con_span      =ones(size(wager_princeton.cond)).*1;

%% Save
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_ID,'wager04a_princeton')),'raw'}={wager_princeton};
save(fullfile(basedir,'data_frame.mat'),'df');
end