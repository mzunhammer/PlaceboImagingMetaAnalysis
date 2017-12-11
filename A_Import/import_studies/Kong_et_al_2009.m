function Kong_et_al_2009

%% Set working environment
clear
basedir = '../../../Datasets/';

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

% Assign condition labels
cond=[repmat({'pain_pre_control'},size(img_pain_control_pre));...
      repmat({'pain_pre_placebo'},size(img_pain_placebo_pre));...
      repmat({'pain_post_control'},size(img_pain_control_post));...
      repmat({'pain_post_placebo'},size(img_pain_placebo_post));...
      repmat({'allHighpainVSLowPain'},size(img_painHiLo))];

% Import behavioral
xls_path=fullfile(basedir, studydir, 'Behav-kong-neuroimage2009.xlsx');

% Create Study-Specific table
outpath=fullfile(basedir,'Kong_et_al_2009.mat')
if exist(outpath)==2
    load(outpath);
else
    kong09=table(img);
end
kong09.img=img;
kong09.study_ID=repmat({'kong09'},size(kong09.img));
kong09.sub_ID=sub;
kong09.male=repmat(xlsread(xls_path,1,'C3:C14'),5,1);
kong09.age=ones(size(kong09.img))*26.4; %currently not known using study mean from paper
kong09.healthy=ones(size(kong09.img));
kong09.pla=[zeros(size(img_pain_control_pre));... % Pre-Treatment is never Placebo
            zeros(size(img_pain_control_pre));...
            zeros(size(img_pain_control_post));... % Post-Treatment is Placebo or Control
            ones(size(img_pain_placebo_post));...
            zeros(size(img_painHiLo))] ;
kong09.pain=ones(size(img));
kong09.predictable=ones(size(kong09.img)); %cue-stimulus timing not jittered
kong09.real_treat=zeros(size(kong09.img));
kong09.cond=cond(:);
kong09.stim_side=repmat({'R'},size(kong09.img));
kong09.placebo_first=ones(size(kong09.img)).*0.5; %pre- sentation of these four random sequences alternated between the radial and ulnar sides of the medial surface of the forearm (i.e. the placebo and the control sides)
kong09.i_condition_in_sequence=ones(size(kong09.img))*2; %All areas were already stimulated before acupuncture. It is not mentioned whether Placebo and Control regions were tested in a particular or random sequence. 
kong09.rating=[xlsread(xls_path,1,'AA27:AA50');...
        xlsread(xls_path,1,'AA3:AA26');...
        NaN(size(img_painHiLo))]; %No ratings for hi/lo pain contrast available
kong09.rating101=(kong09.rating)*100/20; % 20-pt Graceley sensory and affective box ratings were used. Could not find in the references provided which regions on this sensory scale are noxious and which non-noxious...
kong09.stim_intensity=NaN(size(img));       
kong09.imgs_per_stimulus_block =ones(size(img))*6; % stimulus length from paper (12 s / 2s TR), no SPM or other source available.
kong09.n_blocks      =[ones(size(img_pain_control_pre))*2*6;... % According to behavioral data file tis should be 2*6 identical stimuli per participants and condition
                      ones(size(img_pain_control_pre))*2*6;...
                      ones(size(img_pain_control_post))*2*6;... % Post-Treatment is Placebo or Control
                      ones(size(img_pain_placebo_post))*2*6;...
                      ones(size(img_painHiLo))*4*2*2] ;  %No information for hi/lo pain contrast available from behavioral data-file. According to the paper this should be 4 high, 4 six low (on two sites).
kong09.n_imgs      =NaN(size(kong09.img)); % Images per Participant
kong09.x_span        =NaN(size(img)); % currently unknown(?)
kong09.con_span      =NaN(size(img)); % currently unknown(?)

%% Save
save(outpath,'kong09')

end