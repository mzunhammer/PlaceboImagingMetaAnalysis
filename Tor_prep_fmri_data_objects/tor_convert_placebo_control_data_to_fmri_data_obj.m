load('/Users/torwager/Dropbox/SHARED_DATASETS/P_Zunhammer_Bingel_Placebo_Boulder_Essen/Datasets/vectorized_images_conservative_masked_10_percent.mat')


%% Load mask image and put brainmask info into fmri_data attributes

%[dfv_masked.pain_placebo dfv_masked.pain_control]

img = fmri_data(which('brainmask.nii'));

% Replace mask values in fmri_data object: 
% (checked: brainmask3d is 1/0 with NaNs
whnan = isnan(dfv_masked.brainmask3d(:));
dfv_masked.brainmask3d(whnan) = 0;           % replace NaNs
img.volInfo.image_indx = logical(dfv_masked.brainmask3d(:));
 
% We need to assume that the .mat file with origin, voxel sizes, and
% flipping is the same as in brainmask.nii from SPM, because this info is
% not in Matthias's structure.  Matthias, OK??  
% 
%     -2     0     0    92
%      0     2     0  -128
%      0     0     2   -74
%      0     0     0     1
     
img.volInfo.wh_inmask = find(img.volInfo.image_indx);
img.volInfo.n_inmask = length(img.volInfo.wh_inmask);

[i, j, k] = ind2sub(img.volInfo(1).dim(1:3), img.volInfo(1).wh_inmask);
        img.volInfo(1).xyzlist = [i j k];
        
img.volInfo(1).cluster = spm_clusters(img.volInfo(1).xyzlist')';

img.dat = single(ones(size(img.volInfo.wh_inmask)));
img.removed_voxels = [];

img.mask.dat = img.dat;
img.mask.removed_voxels = [];
img.mask.volInfo = img.volInfo;

%% Build metadata indices of study and subject

% What is dfv_masked.placebo_and_control?

% Get study index with number of subjects
% Need to check multiple fields because there is no single list with all
% studies
getsizes = @(cellin) cellfun(@(x) size(x, 1), cellin, 'UniformOutput', false);

my_n_subj = [];

sz = getsizes(dfv_masked.placebo_and_control);
my_n_subj(:, 1) = cat(1, sz{:});

sz = getsizes(dfv_masked.placebo_minus_control);
my_n_subj(:, 2) = cat(1, sz{:});

sz = getsizes(dfv_masked.pain_placebo);
my_n_subj(:, 3) = cat(1, sz{:});

sz = getsizes(dfv_masked.pain_control);
my_n_subj(:, 4) = cat(1, sz{:});

n_with_placebo_control = my_n_subj(:, 3); % list with only studies with placebo and control data separately

my_n_subj = max(my_n_subj, [], 2); % all studies

get_ones = @(cellin) cellfun(@(x) ones(x, 1), cellin, 'UniformOutput', false); % get "ones" from sz output of getsizes

get_condf = @(cellin) indic2condf(blkdiag(cellin{:})); % turn "ones" into condition function of integers

% Get study index for studies with placebo and control data separately
sz = getsizes(dfv_masked.pain_placebo);
study_indx = get_condf(get_ones(sz));

% Get subject within study index
get_one_to_n = @(cellin) cellfun(@(x) (1:x)', cellin, 'UniformOutput', false); % get "ones" from sz output of getsizes
tmp = get_one_to_n(sz);

get_subj_vector = @(cellin) max(blkdiag(cellin{:}), [], 2); % turn "ones" into condition function of integers

subj_indx_within = get_subj_vector(get_one_to_n(sz));

subj_indx_within_across = 1000 * study_indx + subj_indx_within;

descrip = 'First 2 digits are study, last 3 are subject, e.g., 13007 is study 13, subj 7';


%% Now attach data from placebo studies
% build two objects from template mask, one for placebo and one for control

data_obj_pain_placebo = img;        % shell object

mydat = single(cat(1, dfv_masked.pain_placebo{:}))';

data_obj_pain_placebo.dat = mydat;

% attach meta-data
data_obj_pain_placebo.additional_info{1} = study_indx;
data_obj_pain_placebo.additional_info{2} = subj_indx_within;
data_obj_pain_placebo.additional_info{3} = subj_indx_within_across;

data_obj_pain_placebo.dat_descrip = ['Additional info: 1-study index 2-subj index within-study, 3-subj index within and across, ' descrip];

% *** attach subject outcome values here, to obj.Y ***


% Now the other object, control

data_obj_pain_control = img;        % shell object

mydat = single(cat(1, dfv_masked.pain_control{:}))';

data_obj_pain_control.dat = mydat;

% attach meta-data
data_obj_pain_control.additional_info{1} = study_indx;
data_obj_pain_control.additional_info{2} = subj_indx_within;
data_obj_pain_control.additional_info{3} = subj_indx_within_across;

data_obj_pain_control.dat_descrip = ['Additional info: 1-study index 2-subj index within-study, 3-subj index within and across, ' descrip];

% *** attach subject outcome values here, to obj.Y ***


%% Data are not on the same scale across studies
% Standardize by std or mad for each study
% Consider alternate scalings: rank, zscore...
% 
% Also, make a table of stats and how many values are zero/nan

% Helpful functions
get_study_indx = @(obj, i) obj.additional_info{1} == i;         % retrieve study index
get_study_data = @(obj, i) double(obj.dat(:, get_study_indx(obj, i)));  % retrieve data for a study. double to avoid any weird single-format glitches

makevector = @(x) x(:);

get_study_mean = @(obj, i) nanmean(makevector(get_study_data(obj, i)));
get_study_std = @(obj, i) nanstd(makevector(get_study_data(obj, i)));
get_study_zeros = @(obj, i) sum(makevector(get_study_data(obj, i)) == 0);
get_study_NaNs = @(obj, i) sum(isnan(makevector(get_study_data(obj, i))));

get_study_indices = @(obj) unique(obj.additional_info{1})';     % valid study indices only

myobj = data_obj_pain_placebo;

u = get_study_indices(myobj);
descrip_table = table;

for i = 1:length(u)
    tabledat(i, 1) = u(i);
    tabledat(i, 2) = get_study_mean(myobj, u(i));
    tabledat(i, 3) = get_study_std(myobj, u(i));
    tabledat(i, 4) = get_study_zeros(myobj, u(i));
    tabledat(i, 5) = get_study_NaNs(myobj, u(i));
    
end

mytable = array2table(tabledat, 'VariableNames', {'Study' 'Mean' 'STD' 'zerocount' 'NaNcount'});
disp(mytable)

%  Study      Mean         STD      zerocount     NaNcount 
%     _____    _________    _______    _________    __________
% 
%      1        -0.01031    0.46906    0                  7371
%      2         0.43487      1.202    0                  1917
%      4         -10.095     38.407    0                   820
%      5        0.027614    0.32936    0                  2438
%      6         -6.6241     29.473    0            1.5604e+05
%      7        0.071213    0.30745    0                 27188
%      8        0.086758    0.87561    0                   458
%      9       -0.004502    0.21582    0                 28246
%     10        0.068684    0.25484    0                  5530
%     12         0.10314    0.73595    0                 29104
%     13         0.98071     3.3998    0            1.0762e+05
%     15        0.057053    0.33736    0                 59244
%     16        -0.31645     0.5167    0            3.4761e+05
%     19        0.095814     0.3403    0                 10123

study_std = [];
study_std(:, 1) = tabledat(:, 3);

study_mean = [];
study_mean(:, 1) = tabledat(:, 2);



myobj = data_obj_pain_control;

u = get_study_indices(myobj);
descrip_table = table;

for i = 1:length(u)
    tabledat(i, 1) = u(i);
    tabledat(i, 2) = get_study_mean(myobj, u(i));
    tabledat(i, 3) = get_study_std(myobj, u(i));
    tabledat(i, 4) = get_study_zeros(myobj, u(i));
    tabledat(i, 5) = get_study_NaNs(myobj, u(i));
    
end

mytable = array2table(tabledat, 'VariableNames', {'Study' 'Mean' 'STD' 'zerocount' 'NaNcount'});
disp(mytable)

%     Study       Mean         STD      zerocount     NaNcount 
%     _____    __________    _______    _________    __________
% 
%      1        0.0092063    0.48329    0                  7872
%      2          0.49728     1.1331    0                  1973
%      4           -2.976     42.427    0                   814
%      5         0.037406    0.33414    0                  2223
%      6           -3.824     30.421    0            1.7172e+05
%      7         0.049289    0.32192    0                 27211
%      8          0.31722    0.85843    0                   442
%      9       -0.0049933    0.20972    0                 28407
%     10          0.07498    0.28925    0                 15531
%     12         0.028017    0.65495    0                 26948
%     13          0.67773     3.2529    0            1.0524e+05
%     15          0.15787    0.71122    0                 61115
%     16         -0.33327    0.56436    0            3.4141e+05
%     19         0.071986    0.31813    0                 19856
%     

study_std(:, 2) = tabledat(:, 3);
corrcoef(study_std)

% 0.9993 std values are correlated 0.9993 across studies

study_mean(:, 2) = tabledat(:, 2);
corrcoef(study_mean)

% 0.9364 study mean values are correlated 0.93 across studies

% scale by study, preserving individual diffs in whole-brain mean and scale
% but equating them at the study level. scale placebo and control values by
% the same value for each study, preserving any whole-brain diffs in mean
% and scale between placebo and control.

gmean = mean(study_mean, 2);

gstd = mean(study_std, 2);

%% Now implement rescaling

clear obj % u(i) is study number, i is index in u in list of studies with valid data
rescale_study_data = @(obj, u, i) (get_study_data(obj, u(i)) - gmean(i)) ./ gstd(i);

% tmp = rescale_study_data(data_obj_pain_control, 1);

myobj = data_obj_pain_placebo;

u = get_study_indices(myobj);
descrip_table = table;

for i = 1:length(u)
    
    tmp = rescale_study_data(myobj, u, i);
    
    wh = get_study_indx(myobj, u(i));
    
    myobj.dat(:, wh) = tmp;
    
end

descrip_table = table;

for i = 1:length(u)
    tabledat(i, 1) = u(i);
    tabledat(i, 2) = get_study_mean(myobj, u(i));
    tabledat(i, 3) = get_study_std(myobj, u(i));
    tabledat(i, 4) = get_study_zeros(myobj, u(i));
    tabledat(i, 5) = get_study_NaNs(myobj, u(i));
    
end

mytable = array2table(tabledat, 'VariableNames', {'Study' 'Mean' 'STD' 'zerocount' 'NaNcount'});
disp(mytable)

% check effect sizes
t = ttest(myobj);
t = threshold(t, .00001, 'unc');
montage(t)

data_obj_pain_placebo = myobj;

%% Now do the same for control

myobj = data_obj_pain_control;

u = get_study_indices(myobj);
descrip_table = table;

for i = 1:length(u)
    
    tmp = rescale_study_data(myobj, u, i);
    
    wh = get_study_indx(myobj, u(i));
    
    myobj.dat(:, wh) = tmp;
    
end

descrip_table = table;

for i = 1:length(u)
    tabledat(i, 1) = u(i);
    tabledat(i, 2) = get_study_mean(myobj, u(i));
    tabledat(i, 3) = get_study_std(myobj, u(i));
    tabledat(i, 4) = get_study_zeros(myobj, u(i));
    tabledat(i, 5) = get_study_NaNs(myobj, u(i));
    
end

mytable = array2table(tabledat, 'VariableNames', {'Study' 'Mean' 'STD' 'zerocount' 'NaNcount'});
disp(mytable)

% check effect sizes
t = ttest(myobj);
t = threshold(t, .00001, 'unc');
montage(t)

data_obj_pain_control = myobj;

%%

data_obj_pain_control = enforce_variable_types(data_obj_pain_control);
data_obj_pain_placebo = enforce_variable_types(data_obj_pain_placebo);

basedir = '/Users/torwager/Dropbox/SHARED_DATASETS/P_Zunhammer_Bingel_Placebo_Boulder_Essen';
datadir = fullfile(basedir, 'Datasets');

fname = fullfile(datadir, 'placebo_control_fmri_data_objects.mat');

save(fname, 'data_obj_pain_placebo', 'data_obj_pain_control');

%%



