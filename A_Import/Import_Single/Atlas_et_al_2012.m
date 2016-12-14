function Atlas_et_al_2012

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Import Atlas_et_al_2012: Study 2

studydir = 'Atlas_et_al_2012/';
load(fullfile(basedir,studydir,'EXPT_estHRF.mat'));
% Get subject-directorys from EXPT.mat
subdir=dir(fullfile(basedir,studydir));
subdir={subdir.name}';
subdir=subdir(~cellfun(@isempty, regexp(subdir,'remi')));
beta_ID=1:25;
conditions={...
'StimHiPain_Open_Stimulation'
'StimHiPain_Open_RemiConz'
'StimHiPain_Open_ExpectationPeriod'
'StimLoPain_Open_Stimulation'
'StimLoPain_Open_RemiConz'
'StimLoPain_Open_ExpectationPeriod'
'StimHiPain_Hidden_Stimulation'
'StimHiPain_Hidden_RemiConz'
'StimHiPain_Hidden_ExpectationPeriod'
'StimLoPain_Hidden_Stimulation'
'StimLoPain_Hidden_RemiConz'
'StimLoPain_Hidden_ExpectationPeriod'
'RatingPeriod'
'AnticHiPain_Open'
'AnticHiPain_Open_RemiConz'
'AnticHiPain_Open_ExpectationPeriod'
'AnticLoPain_Open'
'AnticLoPain_Open_RemiConz'
'AnticLoPain_Open_ExpectationPeriod'
'AnticHiPain_Hidden'
'AnticHiPain_Hidden_RemiConz'
'AnticHiPain_Hidden_ExpectationPeriod'
'AnticLoPain_Hidden'
'AnticLoPain_Hidden_RemiConz'
'AnticLoPain_Hidden_ExpectationPeriod'};

img=cell(length(subdir),length(beta_ID));
sub=cell(length(subdir),length(beta_ID));
xSpan=NaN(length(subdir),length(beta_ID));
nImages=NaN(length(subdir),length(beta_ID));
cond=cell(length(subdir),length(beta_ID));
temp=NaN(length(subdir),length(beta_ID));
meanBlockDur=NaN(length(subdir),length(beta_ID));
openFirst=NaN(length(subdir),length(beta_ID));

% Extract parametric-covaritates to compute correct ratings after loop
covHO=cell(size(subdir));
covWO=cell(size(subdir));
covHH=cell(size(subdir));
covWH=cell(size(subdir));

for j=1:length(subdir)
     currpath=fullfile(studydir,subdir{j});
     load(fullfile(basedir,currpath,'SPM.mat')); %For determining xSpan, pre-load the SPM for that subject
     xSpanRaw=max(SPM.xX.X)-min(SPM.xX.X);   
     % Needed to compute ratings according to images later
     covHO{j}=[ones(18,1), horzcat(SPM.Sess.U(1).P.P)];
     covWO{j}=[ones(18,1), horzcat(SPM.Sess.U(2).P.P)];
     covHH{j}=[ones(18,1), horzcat(SPM.Sess.U(3).P.P)];
     covWH{j}=[ones(18,1), horzcat(SPM.Sess.U(4).P.P)];
    for i=1:size(beta_ID,2)
        %Get filenames in a (subj,con) matrix
        img{j,i} = fullfile(studydir,subdir{j},sprintf('swbeta_00%0.2d.img', beta_ID(i)));
        cond(j,i) = conditions(i);
        sub{j,i}=subdir(j); % The subject number (study specific)
        xSpan(j,i)=xSpanRaw(beta_ID(i)); % Gets xSpan for betas one at a time
        nImages(j,i)=size(SPM.xX.X,1);
        temp(j,i)= EXPT.cov_uncentered(j,3);
        
        if ~cellfun(@isempty, regexp(cond(j,i),'Stim')) %Determine mean block duration on by-participant level. There seems to be some variation of duration of anticipation peroids within subjects!
            meanBlockDur(j,i)=mean(mean([SPM.Sess.U(1:4).dur])*2); %
        elseif ~cellfun(@isempty, regexp(cond(j,i),'RatingPeriod'))
            meanBlockDur(j,i)=mean(mean([SPM.Sess.U(5).dur])*2); %
        elseif ~cellfun(@isempty, regexp(cond(j,i),'Antic'))
            meanBlockDur(j,i)=mean(mean([SPM.Sess.U(6:9).dur])*2); %
        else
            meanBlockDur(j,i)=NaN;
        end
        
        %"Open" corresponds to "placebo" in this study.
        openFirst(j,i)=sum(SPM.Sess.U(1).ons)<sum(SPM.Sess.U(3).ons); % SPM.Sess.U(1).ons are always the HiPain open onsets, SPM.Sess.U(3).ons are always the corresponding hidden onsets... 
    end
end
 
% Ratings are found in the file 'for_param_model.mat'
% As described in the paper, there were no ratings for participants 2050 and 2363
% In order to make the ratings fully comparable with the images, we'll have to
% apply the co-variates in SPM.Sess.U.P to the 18 ratings/ subject
% (one/block/rating type). This results in three orthogonal types of rating:
% Ratings-due-to-stimulation, rating-change-due-to-remifentain, rating-change-due-to-expectation-period

ratingfile=load('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Datasets/Atlas_et_al_2012/ratings/for_param_model.mat')
[~,sortratings]=ismember(ratingfile.wh_subjs',subdir);
ratings_HO=NaN(length(covHH{1}),length(subdir));
ratings_WO=NaN(length(covHH{1}),length(subdir));
ratings_HH=NaN(length(covHH{1}),length(subdir));
ratings_WH=NaN(length(covHH{1}),length(subdir));

subsright(1,sortratings)=ratingfile.wh_subjs; % just to check if subject-order of folders and ratings is same   
ratings_HO(:,sortratings)=ratingfile.HO;
ratings_WO(:,sortratings)=ratingfile.WO;
ratings_HH(:,sortratings)=ratingfile.HH;
ratings_WH(:,sortratings)=ratingfile.WH;

% For each participant calculate linear regression of covariates with
% ratings (after orthogonalizing predictors just like spm)
for i = 1:length(subdir)
   yHO=ratings_HO(:,i);
   XHO=spm_orth(covHO{i});
   bHO(i,:)=regress(yHO,XHO);

   yWO=ratings_WO(:,i);
   XWO=spm_orth(covWO{i});
   bWO(i,:)=regress(yWO,XWO);
   
   yHH=ratings_HH(:,i);
   XHH=spm_orth(covHH{i});
   bHH(i,:)=regress(yHH,XHH);
  
   yWH=ratings_WH(:,i);
   XWH=spm_orth(covWH{i});
   bWH(i,:)=regress(yWH,XWH);
end

rating=[bHO,bWO,bHH,bWH,...% For Stimulation Images
NaN(size(subdir)),...% For Rating Period Images
bHO,bWO,bHH,bWH]; % Repeat for Anticipation Period Images
rating(rating==0)=NaN; %Unfortunately the regress function spits out zeros when getting an all-nan vector

% Unfold all variables
        img      = vertcat(img(:));
        nImages  = vertcat(nImages(:));
        sub      = vertcat(sub(:));
        xSpan    = vertcat(xSpan(:));
        cond     = vertcat(cond(:));
        temp     = vertcat(temp(:));
        meanBlockDur = vertcat(meanBlockDur(:));
        openFirst= vertcat(openFirst(:));
        rating = vertcat(rating(:));
        
        pla=zeros(size(cond));  
        pla(~cellfun(@isempty, regexp(cond,'Open')))=1; % 0= Any Control 1 = Any Placebo 2 = Other (in this case placebo = treatment expectation)

        pain=zeros(size(cond));  
        pain(~cellfun(@isempty, regexp(cond,'Stim')))=1; % 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
        
        condSeq=NaN(length(subdir)*length(beta_ID),1);
        condSeq(~cellfun(@isempty, regexp(cond,'Open'))&openFirst==1)=1;
        condSeq(~cellfun(@isempty, regexp(cond,'Open'))&openFirst==0)=2;
        condSeq(~cellfun(@isempty, regexp(cond,'Hidden'))&openFirst==1)=2;
        condSeq(~cellfun(@isempty, regexp(cond,'Hidden'))&openFirst==0)=1;


% Create Study-Specific table
atlas=table(img);
atlas.imgType=repmat({'fMRI'},size(atlas.img));
atlas.studyType=repmat({'within'},size(atlas.img));
atlas.studyID=repmat({'atlas'},size(atlas.img));
atlas.subID=strcat(atlas.studyID,'_',[sub{:}]')
atlas.male=ones(size(atlas.img)).*10/21; %male proportion in sample 
atlas.age=ones(size(atlas.img)).*24.7; %male proportion in sample
atlas.healthy=ones(size(atlas.img));
atlas.pla=pla;
atlas.pain=pain;
atlas.predictable=zeros(size(atlas.img)); %Uncertainty: On each trial, participants saw a cue (3 s) that provided information about upcoming heat intensity (?Hot? or ?Warm?). This was followed by a 7?13 s jittered anticipation period (M?10.16 s,SD?2.64), and 10 s of noxious stimulation (1.5 s ramp up,7sat peak, 1.5 s return to baseline)
atlas.realTreat=ones(size(atlas.img));
atlas.cond=vertcat(cond(:));
atlas.stimtype=repmat({'heat'},size(atlas.img));
atlas.stimloc=repmat({'L forearm (v)'},size(atlas.img));
atlas.stimside=repmat({'L'},size(atlas.img));
atlas.plaForm=repmat({'Intravenous drip'},size(atlas.img));
atlas.plaInduct=repmat({'Suggestions'},size(atlas.img));
atlas.plaFirst=openFirst;
atlas.condSeq=condSeq;
atlas.rating=rating;
atlas.stimInt=temp;       

atlas.fieldStrength=ones(size(atlas.img)).*1.5;
atlas.tr           =ones(size(atlas.img)).*2000;
atlas.te           =ones(size(atlas.img)).*34;
atlas.voxelVolAcq  =ones(size(atlas.img)).*(3.5*3.5*4.0);
atlas.voxelVolMat  =ones(size(atlas.img)).*(2*2*2);
atlas.meanBlockDur =meanBlockDur; % According to paper
atlas.nImages      =nImages; % Images per Participant
atlas.xSpan        =xSpan;
atlas.conSpan      =ones(size(atlas.cond));

%% Save
outpath=fullfile(basedir,'Atlas_et_al_2012.mat')
save(outpath,'atlas')

end