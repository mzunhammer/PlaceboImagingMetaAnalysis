function Kong_et_al_2009

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Collects all behavioral data and absolute img-paths
% in a data frame, saves as .mat

studydir = 'Kong_et_al_2009';
subjpattern='^\w\w\d\d\d\d\d\d.img';
kong_control_dir_pre = dir(fullfile(basedir, studydir, 'control_pre_pain'));
img_pain_control_pre = {kong_control_dir_pre(~cellfun(@isempty,regexp({kong_control_dir_pre.name},subjpattern))).name}';
kong_placebo_dir_pre = dir(fullfile(basedir, studydir, 'placebo_pre_pain'));
img_pain_placebo_pre = {kong_placebo_dir_pre(~cellfun(@isempty,regexp({kong_placebo_dir_pre.name},subjpattern))).name}';

kong_control_dir_post = dir(fullfile(basedir, studydir, 'control_post_pain'));
img_pain_control_post = {kong_control_dir_post(~cellfun(@isempty,regexp({kong_control_dir_post.name},subjpattern))).name}';
kong_placebo_dir_post = dir(fullfile(basedir, studydir, 'placebo_post_pain'));
img_pain_placebo_post = {kong_placebo_dir_post(~cellfun(@isempty,regexp({kong_placebo_dir_post.name},subjpattern))).name}';

%Suboptimal: Currently only con-images but no non-painful beta-images
%available
kong_painHiLo_dir = dir(fullfile(basedir, studydir, 'allHighpainVSLowPain'));
img_painHiLo = {kong_painHiLo_dir(~cellfun(@isempty,regexp({kong_painHiLo_dir.name},subjpattern))).name}';

% Create image variable
img=[fullfile(studydir, 'control_pre_pain', img_pain_control_pre);...
     fullfile(studydir, 'placebo_pre_pain', img_pain_placebo_pre);...
     fullfile(studydir, 'control_post_pain', img_pain_control_post);...
     fullfile(studydir, 'placebo_post_pain', img_pain_placebo_post);...
     fullfile(studydir, 'allHighpainVSLowPain', img_painHiLo)]; % The absolute image paths

 % Create array with subject ids
sub=regexp(img,'(\w\w\d\d\d\d\d\d).img','tokens');
sub=[sub{:}];sub=strcat('kong09_',[sub{:}])';

% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo 2 = Other
pla= [zeros(size(img_pain_control_post));... % Pre-Treatment is never Placebo
      zeros(size(img_pain_control_post));...
      zeros(size(img_pain_control_post));... % Post-Treatment is Placebo or Control
      ones(size(img_pain_placebo_post));...
      zeros(size(img_painHiLo))] ;
  
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain= ones(size(img)) ;

% Assign condition labels
cond=[repmat({'pain_pre_control'},size(img_pain_control_pre));...
      repmat({'pain_pre_placebo'},size(img_pain_placebo_pre));...
      repmat({'pain_post_control'},size(img_pain_control_post));...
      repmat({'pain_post_placebo'},size(img_pain_placebo_post));...
      repmat({'allHighpainVSLowPain'},size(img_painHiLo))];

% Import behavioral
xls_path=fullfile(basedir, studydir, 'Behav-kong-neuroimage2009.xlsx');

%Ratings
rating=[xlsread(xls_path,1,'AA27:AA50');...
        xlsread(xls_path,1,'AA3:AA26');...
        NaN(size(img_painHiLo))]; %No ratings for hi/lo pain contrast available

%Stimulus intensities (currently not available)
stimInt=NaN(size(img));

male=repmat(xlsread(xls_path,1,'C3:C14'),5,1);
plaFirst=NaN(size(img));     % currently unknown(?)
blockLength=ones(size(img))*7; % stimulus length from paper, no SPM or other source available.
xSpan =ones(size(img));       % currently unknown(?)   
conSpan =ones(size(img)); % currently unknown(?)

% Create Study-Specific table
kong09=table(img);
kong09.imgType=repmat({'fMRI'},size(kong09.img));
kong09.studyType=repmat({'within'},size(kong09.img));
kong09.studyID=repmat({'kong09'},size(kong09.img));
kong09.subID=sub;
kong09.male=male;
kong09.age=ones(size(kong09.img))*26.4; %currently not known using study mean from paper
kong09.healthy=ones(size(kong09.img));
kong09.pla=pla;
kong09.pain=pain;
kong09.predictable=ones(size(kong09.img)); %cue-stimulus timing not jittered
kong09.realTreat=zeros(size(kong09.img));
kong09.cond=cond(:);
kong09.stimtype=repmat({'heat'},size(kong09.img));
kong09.stimloc=repmat({'R forearm (v)'},size(kong09.img));
kong09.stimside=repmat({'R'},size(kong09.img));
kong09.plaForm=repmat({'Acupuncture'},size(kong09.img));
kong09.plaInduct=repmat({'Suggestions + Conditioning'},size(kong09.img));
kong09.plaFirst=plaFirst; %pre- sentation of these four random sequences alternated between the radial and ulnar sides of the medial surface of the forearm (i.e. the placebo and the control sides)
kong09.condSeq=ones(size(kong09.img))*2; %All areas were already stimulated before acupuncture. It is not mentioned whether Placebo and Control regions were tested in a particular or random sequence. 
kong09.rating=rating;
kong09.rating101=(rating)*100/20; % 20-pt Graceley sensory and affective box ratings were used. Could not find in the references provided which regions on this sensory scale are noxious and which non-noxious...
kong09.stimInt=stimInt;       
kong09.fieldStrength=ones(size(kong09.img)).*3;
kong09.tr           =ones(size(kong09.img)).*2000;
kong09.te           =ones(size(kong09.img)).*40;
kong09.voxelVolAcq  =ones(size(kong09.img)).*(3.13*3.13*(4+1));
kong09.voxelVolMat  =ones(size(kong09.img)).*(2*2*2);
kong09.meanBlockDur =blockLength;
kong09.nImages      =NaN(size(kong09.img)); % Images per Participant
kong09.xSpan        =xSpan;
kong09.conSpan      =conSpan;
kong09.fsl          =zeros(size(kong09.cond)); %analysis with fsl, rather than SPM

%% Save
outpath=fullfile(basedir,'Kong_et_al_2009.mat')
save(outpath,'kong09')

end