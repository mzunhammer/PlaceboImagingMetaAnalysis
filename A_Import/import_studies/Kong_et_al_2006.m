function Kong_et_al_2006(datapath)

%% Set working environment

basedir = datapath;

%% Collects all behavioral data and absolute img-paths
% in a data frame, saves as .mat

studydir = 'Kong_et_al_2006';
subjpattern='^\w\w\d\d\d\d\d\dcon_\d\d\d\d.img';
kong_control_dir_hp_pre = dir(fullfile(basedir, studydir, 'control_hpVSbase_pre'));
img_pain_control_hp_pre = {kong_control_dir_hp_pre(~cellfun(@isempty,regexp({kong_control_dir_hp_pre.name},subjpattern))).name}';

kong_placebo_dir_hp_pre = dir(fullfile(basedir, studydir, 'placebo_hpVSbase_pre'));
img_pain_placebo_hp_pre = {kong_placebo_dir_hp_pre(~cellfun(@isempty,regexp({kong_placebo_dir_hp_pre.name},subjpattern))).name}';

kong_control_dir_lp_pre = dir(fullfile(basedir, studydir, 'control_lpVSbase_pre'));
img_pain_control_lp_pre = {kong_control_dir_lp_pre(~cellfun(@isempty,regexp({kong_control_dir_lp_pre.name},subjpattern))).name}';

kong_placebo_dir_lp_pre = dir(fullfile(basedir, studydir, 'placebo_lpVSbase_pre'));
img_pain_placebo_lp_pre = {kong_placebo_dir_lp_pre(~cellfun(@isempty,regexp({kong_placebo_dir_lp_pre.name},subjpattern))).name}';


kong_control_dir_hp_post = dir(fullfile(basedir, studydir, 'control_hpVSbase_post'));
img_pain_control_hp_post = {kong_control_dir_hp_post(~cellfun(@isempty,regexp({kong_control_dir_hp_post.name},subjpattern))).name}';

kong_placebo_dir_hp_post = dir(fullfile(basedir, studydir, 'placebo_hpVSbase_post'));
img_pain_placebo_hp_post = {kong_placebo_dir_hp_post(~cellfun(@isempty,regexp({kong_placebo_dir_hp_post.name},subjpattern))).name}';

kong_control_dir_lp_post = dir(fullfile(basedir, studydir, 'control_lpVSbase_post'));
img_pain_control_lp_post = {kong_control_dir_lp_post(~cellfun(@isempty,regexp({kong_control_dir_lp_post.name},subjpattern))).name}';

kong_placebo_dir_lp_post = dir(fullfile(basedir, studydir, 'placebo_lpVSbase_post'));
img_pain_placebo_lp_post = {kong_placebo_dir_lp_post(~cellfun(@isempty,regexp({kong_placebo_dir_lp_post.name},subjpattern))).name}';

%Suboptimal: Currently only con-images but no non-painful beta-images
%available
kong_painHiLo_dir = dir(fullfile(basedir, studydir, 'pre_highpain_vs_lowpain'));
img_painHiLo = {kong_painHiLo_dir(~cellfun(@isempty,regexp({kong_painHiLo_dir.name},'^\w\w\d\d\d\d\d\d.img'))).name}';

% Create image variable
img=[fullfile(studydir, 'control_hpVSbase_pre', img_pain_control_hp_pre);...
     fullfile(studydir, 'placebo_hpVSbase_pre', img_pain_placebo_hp_pre);...
     fullfile(studydir, 'control_lpVSbase_pre', img_pain_control_lp_pre);...
     fullfile(studydir, 'placebo_lpVSbase_pre', img_pain_placebo_lp_pre);...
     fullfile(studydir, 'control_hpVSbase_post', img_pain_control_hp_post);...
     fullfile(studydir, 'placebo_hpVSbase_post', img_pain_placebo_hp_post);...
     fullfile(studydir, 'control_lpVSbase_post', img_pain_control_lp_post);...
     fullfile(studydir, 'placebo_lpVSbase_post', img_pain_placebo_lp_post);...
     fullfile(studydir, 'pre_highpain_vs_lowpain', img_painHiLo)]; % The absolute image paths

 % Create array with subject ids
sub=regexp(img,'/(\w\w\d\d\d\d\d\d).*','tokens');
sub=[sub{:}];sub=strcat('kong06_',[sub{:}])';

% Assign "placebo condition" according to experimental condition
% 0= Any Control 1 = Any Placebo 2 = Other
pla= [zeros(size(img_pain_control_hp_pre));... % Importantly, the pre-treatment images all had no placebo treatment!!!
      zeros(size(img_pain_placebo_hp_pre));...
      zeros(size(img_pain_control_lp_pre));...
      zeros(size(img_pain_placebo_lp_pre));...
      zeros(size(img_pain_control_hp_post));...% For the post-treatment images there were placebo and control images
      ones(size(img_pain_placebo_hp_post));...
      zeros(size(img_pain_control_lp_post));...
      ones(size(img_pain_placebo_lp_post));...
      zeros(size(img_painHiLo))] ;             % These are the images for all high vs all low contrasts

n_blocks= [ones(size(img_pain_control_hp_pre))*6*4;... % As far as I understand the paper there were 6 high and 6 low pain stimuli at each "Random Sequence" site >>
          ones(size(img_pain_placebo_hp_pre))*6*4;...
          ones(size(img_pain_control_lp_pre))*6*4;...
          ones(size(img_pain_placebo_lp_pre))*6*4;...
          ones(size(img_pain_control_hp_post))*6*4;...
          ones(size(img_pain_placebo_hp_post))*6*4;...
          ones(size(img_pain_control_lp_post))*6*4;...
          ones(size(img_pain_placebo_lp_post))*6*4;...
          ones(size(img_painHiLo))*6*4*2] ;   % All pre- high vs low stimuli (high & low)
  
% Assign "pain condition" to beta image
% 0= NoPain 1=FullPain 2=EarlyPain 3=LatePain
pain= ones(size(img)) ;

% Assign condition labels
cond=[repmat({'pain_pre_control_high_pain'},size(img_pain_control_hp_pre));...
      repmat({'pain_pre_placebo_high_pain'},size(img_pain_placebo_hp_pre));...
      repmat({'pain_pre_control_low_pain'},size(img_pain_control_lp_pre));...
      repmat({'pain_pre_placebo_low_pain'},size(img_pain_placebo_lp_pre));...
      repmat({'pain_post_control_high_pain'},size(img_pain_control_hp_post));...
      repmat({'pain_post_placebo_high_pain'},size(img_pain_placebo_hp_post));...
      repmat({'pain_post_control_low_pain'},size(img_pain_control_lp_post));...
      repmat({'pain_post_placebo_low_pain'},size(img_pain_placebo_lp_post));...
      repmat({'preHighpainVSLowPain'},size(img_painHiLo))];

% Import behavioral
xls_path=fullfile(basedir, studydir, 'Behav-kong-JNeuSci2006.xlsx');

%Ratings
rating=[xlsread(xls_path,1,'H3:H12');...
        xlsread(xls_path,1,'L3:L12');...
        xlsread(xls_path,1,'G3:G12');...
        xlsread(xls_path,1,'K3:K12');...
        
        xlsread(xls_path,1,'F3:F12');...
        xlsread(xls_path,1,'J3:J12');...
        xlsread(xls_path,1,'E3:E12');...
        xlsread(xls_path,1,'I3:I12');...
        xlsread(xls_path,1,'M3:M12')];

% Create Study-Specific table
kong06=table(img);
kong06.img=img;
kong06.study_ID=repmat({'kong06'},size(kong06.img));
kong06.sub_ID=sub;
kong06.male=repmat(xlsread(xls_path,1,'B3:B12'),9,1);
kong06.age=repmat(xlsread(xls_path,1,'C3:C12'),9,1);
kong06.healthy=ones(size(kong06.img));
kong06.pla=pla;
kong06.pain=pain;
kong06.predictable=ones(size(kong06.img)); %cue-stimulus timing not jittered
kong06.real_treat=zeros(size(kong06.img));
kong06.cond=cond(:);
kong06.stim_side=repmat({'R'},size(kong06.img));
kong06.placebo_first=ones(size(img))*0.5; % The pre- sentation of these four random sequences alternated between the radial and ulnar sides of the medial surface of the forearm, it is unknown whether placebo and control were always tested in the same sequence or if sequences were randomised.
kong06.i_condition_in_sequence=ones(size(kong06.img))*2; %All areas were already stimulated before acupuncture. It is not mentioned whether Placebo and Control regions were tested in a particular or random sequence. 
kong06.rating=rating;
kong06.rating101=(rating)*100/20; % 20-pt Graceley sensory and affective box ratings were used. Could not find in the references provided which regions on this sensory scale are noxious and which non-noxious...
kong06.stim_intensity=NaN(size(img));       
kong06.imgs_per_stimulus_block =ones(size(img))*5; % stimulus length from paper 10s / 2 s TR... no SPM or other source available;
kong06.n_blocks      =n_blocks; % stimulus length from paper 10s / 2 s TR... no SPM or other source available;
kong06.n_imgs      =NaN(size(kong06.img)); % Images per Participant currently unknown
kong06.x_span        =NaN(size(img));       % currently unknown(?)   
kong06.con_span      =NaN(size(img));       % currently unknown(?) 

%% Save
%% Save in data_frame
load(fullfile(basedir,'data_frame.mat'));
df{find(strcmp(df.study_ID,'kong06')),'raw'}={kong06};
save(fullfile(basedir,'data_frame.mat'),'df');
end