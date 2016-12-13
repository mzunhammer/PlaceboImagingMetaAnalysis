function Freeman_et_al_2015

%% Set working environment
clear
basedir = '/Users/matthiaszunhammer/Dropbox/boulder_essen/Datasets/';

%% Collects all behavioral data and absolute img-paths
% in a data frame, saves as .mat

studydir = 'Freeman_et_al_2015';
freeman_control_dir = dir(fullfile(basedir, studydir, 'post-pain-Control'));
img_pain_control = {freeman_control_dir(~cellfun(@isempty,regexp({freeman_control_dir.name},'.img'))).name}';

freeman_placebo_dir = dir(fullfile(basedir, studydir, 'post-pain-placebo'));
img_pain_placebo = {freeman_placebo_dir(~cellfun(@isempty,regexp({freeman_placebo_dir.name},'.img'))).name}';

%Suboptimal: Currently only con-images but no non-painful beta-images
%available
freeman_painHiLo_dir = dir(fullfile(basedir, studydir, 'post-HighpainVsLowpain'));
img_painHiLo = {freeman_painHiLo_dir(~cellfun(@isempty,regexp({freeman_painHiLo_dir.name},'.img'))).name}';

freeman_allPrePainvsbldir = dir(fullfile(basedir, studydir, 'all_pre-painVSbaseline'));
img_painAllPrevsBL = {freeman_allPrePainvsbldir(~cellfun(@isempty,regexp({freeman_allPrePainvsbldir.name},'.img'))).name}';

% Create image variable
img=[fullfile(studydir, 'post-pain-Control', img_pain_control);...
     fullfile(studydir, 'post-pain-placebo', img_pain_placebo);...
     fullfile(studydir, 'post-HighpainVsLowpain', img_painHiLo);...
     fullfile(studydir, 'all_pre-painVSbaseline', img_painAllPrevsBL)]; % The image paths relative to the data-folder

 % Create array with subject ids
sub=regexp(img,'.*/(LIDCAP\d\d\d).*','tokens');
sub=[sub{:}];sub=strcat('freeman_',[sub{:}])';

% Assign condition labels
cond=[repmat({'pain_post_control_high_pain'},size(img_pain_control));...
      repmat({'pain_post_placebo_high_pain'},size(img_pain_placebo));...
      repmat({'post-HighpainVsLowpain'},size(img_painHiLo));...
      repmat({'all_pre-painVSbaseline'},size(img_painAllPrevsBL))];

% Path to import behavioral
xls_path=fullfile(basedir, studydir, 'Behav-kong-neuroimage2015-withGender.xlsx');

% Create Study-Specific table
freeman=table(img);
freeman.imgType=repmat({'fMRI'},size(freeman.img));
freeman.studyType=repmat({'within'},size(freeman.img));
freeman.studyID=repmat({'freeman'},size(freeman.img));
freeman.subID=sub;
freeman.male=repmat(xlsread(xls_path,'BetaSummary','D2:D25'),4,1);
freeman.age=repmat(xlsread(xls_path,'BetaSummary','C2:C25'),4,1);
freeman.healthy=ones(size(freeman.img));
% Assign "placebo condition" according to experimental condition
freeman.pla=[zeros(size(img_pain_control));...
      ones(size(img_pain_placebo));...
      zeros(size(img_painHiLo));...
      zeros(size(img_painAllPrevsBL))];% 0= Any Control 1 = Any Placebo 2 = Other
% Assign "pain condition" to beta image
freeman.pain=ones(size(img));% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
freeman.predictable=ones(size(freeman.img)); %cue-stimulus timing not jittered
freeman.realTreat=zeros(size(freeman.img));
freeman.cond=cond(:);
freeman.stimtype=repmat({'heat'},size(freeman.img));
freeman.stimloc=repmat({'R forearm (v)'},size(freeman.img));
freeman.stimside=repmat({'R'},size(freeman.img));
freeman.plaForm=repmat({'Topical Cream/Gel/Patch'},size(freeman.img));
freeman.plaInduct=repmat({'Suggestions + Conditioning'},size(freeman.img));
freeman.plaFirst=[ones(size(img_pain_control));...
                  ones(size(img_pain_placebo));...
                  nan(size(img_painHiLo));...
                  nan(size(img_painAllPrevsBL))];    % The pre- sentation of these four random sequences alternated between the radial and ulnar sides of the medial surface of the forearm
freeman.condSeq=[ones(size(img_pain_control))*5;...%Placebo and control regions were tested in a 3x3 field (placebo,control,nocebo) with the following order: 
                 ones(size(img_pain_placebo))*4;...%"To balance the design, we started the administra- tion of sequences of heat pain stimuli at the most lateral column and moved medially across all subjects." 
                 nan(size(img_painHiLo));...       %Thus, mean sequence position of placebo conditions was 4 and control conditions was 5!!!
                 nan(size(img_painAllPrevsBL))]; 
freeman.rating=[xlsread(xls_path,'BetaSummary','H2:H25');...
        xlsread(xls_path,'BetaSummary','F2:F25');...
        NaN(size(img_painHiLo));...
        NaN(size(img_painAllPrevsBL))];
freeman.stimInt=NaN(size(img));    % Currently unknown   
freeman.fieldStrength=ones(size(freeman.img)).*3;
freeman.tr           =ones(size(freeman.img)).*2000;
freeman.te           =ones(size(freeman.img)).*40;
freeman.voxelVolAcq  =ones(size(freeman.img)).*(3.13*3.13*(4+1));
freeman.voxelVolMat  =ones(size(freeman.img)).*(2*2*2);
freeman.meanBlockDur =ones(size(img))*7; % stimulus length from paper, no SPM or other source available.;
freeman.nImages      =NaN(size(img)); % Images per Participant
freeman.xSpan        =ones(size(img));       % currently unknown(?)
freeman.conSpan      =[ones(size(img_pain_control));...
                       ones(size(img_pain_placebo));...
                       ones(size(img_painHiLo))*2;...
                       ones(size(img_painAllPrevsBL))*2];


%% Save
outpath=fullfile(basedir,'Freeman_et_al_2015.mat')
save(outpath,'freeman')

end