basedir = '/Users/tor/Dropbox (Personal)/SHARED_DATASETS/P_Zunhammer_Bingel_Placebo_Boulder_Essen';
datadir = fullfile(basedir, 'Datasets');
andir = fullfile(basedir, 'Analysis');
resultsdir = fullfile(andir, 'Tor_fixedfx_mega_analysis');

load(fullfile(datadir, 'data_frame.mat'))

g = genpath(datadir); 
addpath(g)


%% explore a bit

imgs = df.full(1).pla_minus_con.img % raw contrast images

imgs = df.full(1).pla_minus_con.norm_img % normalized contrast images

plot(obj)
t = ttest(obj);
t = threshold(t, .005, 'unc');

%% list all valid images

k = length(df.full);

clear imgs

wh_ok = false(1, k);

for i = 1:k
    if isempty(df.full(i).pla_minus_con) % between-subject study
        wh_ok(i) = false;
    else
        imgs{i} = df.full(i).pla_minus_con.norm_img;
        %imgs{i}  = check_valid_imagename(imgs{i});
        
        wh_ok(i) = true;
    end
end

wh_bad = cellfun(@isempty, imgs);
imgs(wh_bad) = [];

%% load all image sets into objects

clear DATA_OBJ

n = length(imgs);

for i = 1:n
    
DATA_OBJ{i} = fmri_data(imgs{i});

end

%% get behavioral placebo scores, for regression

% ***********

%% concatenate data 

DATA_CAT = cat(DATA_OBJ{:});

%% Build model for session intercepts and add
clear sz

for i = 1:size(DATA_OBJ, 2), sz(1, i) = size(DATA_OBJ{i}.dat, 2); end
DATA_CAT.images_per_session = sz;
DATA_CAT.removed_images = 0;


Im = intercept_model(DATA_CAT.images_per_session);
Im = scale(Im, 1); % mean-center; lose 1 df. individual regressors not interpretable/unique, but we don't care - just control for them

% could create orthogonal set of contrasts instead, this way: 
% hh = hadamard(20);
% hh = hh(2:18, 2:18);
cc = create_orthogonal_contrast_set(18)';
Im_con = Im * cc;

DATA_CAT.X = Im_con;  % intercept will be added automatically, last


%% Data preprocessing/scaling

%DATA_CAT = preprocess(DATA_CAT, 'remove_csf');
%DATA_CAT = preprocess(DATA_CAT, 'rescale_by_csf');
%DATA_CAT = preprocess(DATA_CAT, 'divide_by_csf_l2norm');

% must re-norm in some way: data scale is not the same across studies!
% by study or by individual, scaling by sd/zscore/l1norm/l2norm or ranking data

% didn't try this yet
%DATA_CAT = rescale(DATA_CAT, 'zscoreimages');     % scaling sensitive to mean and variance.

% tried this first
DATA_CAT = rescale(DATA_CAT, 'l2norm_images');     % scaling sensitive to mean and variance.

DATA_CAT = preprocess(DATA_CAT, 'windsorize'); % entire data matrix

% Optional: regress out CSF values
DATA_CAT2 = preprocess(DATA_CAT, 'remove_csf');

%% Save data for reload

% Reduce variable sizes
DATA_CAT = enforce_variable_types(DATA_CAT);
DATA_CAT2 = enforce_variable_types(DATA_CAT2);

savefilename = fullfile(resultsdir, 'DATA_CAT');
save(savefilename, 'DATA_CAT');


%% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------
% -----------------------------------------------------------------------

%% Reload and analyze

basedir = '/Users/tor/Dropbox (Personal)/SHARED_DATASETS/P_Zunhammer_Bingel_Placebo_Boulder_Essen';
datadir = fullfile(basedir, 'Datasets');
andir = fullfile(basedir, 'Analysis');
resultsdir = fullfile(andir, 'Tor_fixedfx_mega_analysis');

load(fullfile(datadir, 'data_frame.mat'))

g = genpath(datadir); 
addpath(g)

savefilename = fullfile(resultsdir, 'DATA_CAT');
load(savefilename, 'DATA_CAT');

%% Any additional preprocessing, etc.

% Optional: regress out CSF values
DATA_CAT2 = preprocess(DATA_CAT, 'remove_csf');


%% Regression: one-sample t-test across subjects, with study as fixed covariates

out = regress(DATA_CAT, .05, 'fdr');

t = get_wh_image(out.t, size(out.t.p, 2)); % get last image: intercept


%% Results at p < .001


t = threshold(t, .001, 'unc');

[o2, sig, pcl, ncl] = multi_threshold(t);  % default theshold: .001+10 vox, .01 .05 


%% re-threshold with fdr

t = threshold(t, .05, 'fdr');

%[o2, sig, pcl, ncl] = multi_threshold(t, 'o2', o2, 'thresh', [0.000025.001 .005]);  % fdr theshold, DATA_CAT

[o2, sig, pcl, ncl] = multi_threshold(t, 'o2', o2, 'thresh', [0.000101 .001 .005]);  % fdr theshold, DATA_CAT2

%% network-based analyses

% Need masks on path:
% cd('/Users/tor/Documents/Code_Repositories/Neuroimaging_Pattern_Masks')
% g = genpath(pwd); addpath(g); savepath

create_figure('placebo fx', 1, 4);
stats = image_similarity_plot(DATA_CAT, 'cosine_similarity', 'bucknerlab', 'nofigure');
title('Buckner lab: Cortex');
drawnow

subplot(1, 4, 2);
stats = image_similarity_plot(DATA_CAT, 'cosine_similarity', 'bucknerlab_wholebrain', 'nofigure');
title('Buckner lab: Cortex+BG+Cerebellum');
drawnow

%%
subplot(1, 4, 3);
stats = image_similarity_plot(DATA_CAT, 'cosine_similarity', 'bgloops', 'nofigure');
title('Pauli cortico-striatal loops: BG');
drawnow

% Look at the parcels on the brain
pauli = load_atlas('basal_ganglia');
figure; montage(atlas2region(pauli), 'unique');

%%
% subplot(1, 4, 4);
% stats = image_similarity_plot(DATA_CAT, 'cosine_similarity', 'bgloops_cortex', 'nofigure');
% title('Pauli cortico-striatal loops: Cortex');
% drawnow



%%

thal = load_atlas('thalamus');
parcel_means = apply_parcellation(DATA_CAT, thal);

% parcel_means = subjects x thalamic regions

% TO-DO FOR ALL PLOTS:
% covary out study-level effects (Can use Im variable above)
% regression against behavioral placebo scores, covary out for group
% analysis
% group analysis wedge plot...

figure; barplot_columns(parcel_means);

%%
subplot(1, 4, 4);
cla
hh = tor_wedge_plot(parcel_means, thal.labels, 'outer_circle_radius', double(max(abs(mean(parcel_means)))), 'bicolor', 'colors', {[1 1 0] [0 0 1]}, 'nofigure');

%% NPS + signatures
create_figure('placebo fx signatures', 1, 3);

stats = image_similarity_plot(DATA_CAT, 'cosine_similarity', 'painsig', 'nofigure');
title('CANlab pain signatures');
drawnow
