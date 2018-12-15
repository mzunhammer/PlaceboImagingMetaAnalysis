basedir = '/Users/torwager/Dropbox (Cognitive and Affective Neuroscience Laboratory)/SHARED_DATASETS/P_Zunhammer_Bingel_Placebo_Boulder_Essen/Analysis/G_meta_analysis_whole_brain/GIV/nii_results';

%% Pain effects

imgpath = fullfile(basedir, 'full/pain/g/random');

% Cluster extent: FWER TFCE 
gfwe = statistic_image(fullfile(imgpath, 'Full_pain_g_pperm_FWE05.nii'));

create_figure('montage2'); axis off
o2 = montage(gfwe);
o2 = title_montage(o2, 5, 'Full_pain_g_pperm_FWE05');
drawnow, snapnow

% Voxel-wise FDR, to localize and interpret peaks (not so good for pain,
% too much activation!)

gfdr = statistic_image(fullfile(imgpath, 'Full_pain_g_pperm_FDR.nii'));

o2 = removeblobs(o2);
o2 = montage(gfdr, o2);
o2 = title_montage(o2, 5, 'Full_pain_g_pperm_FDR');
drawnow, snapnow

% Individual regions

r = region(gfdr);
[rpos, rneg] = table(r);
montage([rpos, rneg], 'regioncenters', 'colormap');

%% Pain effects:  Wedge plots 
% Networks: Buckner cortex, BG and cerebellum
% Note: does not use GIV weighting, but still useful archive + for figure
% elements

dat = get_indiv_study_images(imgpath);

[hh, output_values_by_region, labels, atlas_obj, colorband_colors] = wedge_plot_by_atlas(dat, 'atlases', {'buckner', 'striatum', 'cerebellum'}, 'montage');

[hh, output_values_by_region, labels, atlas_obj, colorband_colors] = wedge_plot_by_atlas(dat, 'atlases', {'thalamus'}, 'montage');

%% Add other isosurfaces we need to show regions
% Prep thal figure
p = addbrain('cutaway');
wh = findobj('Tag', 'thalamus'); delete(wh);
wh = findobj('Tag', 'hypothalamus'); delete(wh);
wh = findobj('Tag', 'put'); delete(wh);
wh = findobj('Tag', 'GPe'); delete(wh);
wh = findobj('Tag', 'GPi'); delete(wh);
wh = findobj('Tag', 'nacc'); delete(wh);
wh = findobj('Tag', 'VeP'); delete(wh);
wh = findobj('Tag', 'caudate'); set(wh, 'FaceAlpha', 0);

atlas_obj = load_atlas('thalamus');
colors = scn_standard_colors(num_regions(atlas_obj)); % these match defaults in wedge plot
isosurface(atlas_obj, 'colors', colors, 'nosymmetric');
%p = addbrain('hires left');
%set(p, 'FaceAlpha', .2); view(135, 10);
lightRestoreSingle
lightFollowView
% for reference: saveas(gcf, 'Thalamus_isosurface.png');

clf
p = addbrain('cutaway');
atlas_obj = load_atlas('buckner');
colors = scn_standard_colors(num_regions(atlas_obj)); % these match defaults in wedge plot
% p = surface(atlas_obj, 'colors', colors, 'nosymmetric', 'surface_handles', p);

% or: 
p = isosurface(atlas_obj, 'colors', colors, 'nosymmetric');
set(p, 'FaceAlpha', .7); view(135, 10);
lightRestoreSingle
lightFollowView
% for reference: saveas(gcf, 'Buckner_cortex_isosurface.png');

%% Placebo effects

imgpath = fullfile(basedir, 'full/pla/g/random');

% Cluster extent: FWER TFCE 
gfwe = statistic_image(fullfile(imgpath, 'Full_pla_g_pperm_tfce_FWE05.nii'));

create_figure('montage2'); axis off
o2 = montage(gfwe);
o2 = title_montage(o2, 5, 'Full_pla_g_pperm_tfce_FWE05');
drawnow, snapnow

% Voxel-wise FDR, to localize and interpret peaks

gfdr = statistic_image(fullfile(imgpath, 'Full_pla_g_pperm_FDR.nii'));

o2 = removeblobs(o2);
o2 = montage(gfdr, o2);
o2 = title_montage(o2, 5, 'Full_pla_g_pperm_FDR');
drawnow, snapnow

% Individual regions

r = region(gfdr);
[rpos, rneg] = table(r);
montage([rpos, rneg], 'regioncenters', 'colormap');

%% Placebo effects: Distribution of unthresholded effect sizes
% fixed and random 

gunt = statistic_image(fullfile(imgpath, 'Full_pla_g_unthresh.nii'));
descriptives(gunt);
       
imgpath = fullfile(basedir, 'full/pla/g/fixed');
gunt = statistic_image(fullfile(imgpath, 'Full_pla_g_unthresh.nii'));
descriptives(gunt);

%% Placebo effects:  Wedge plots 
% Networks: Buckner cortex, BG and cerebellum
% Note: does not use GIV weighting, but still useful archive + for figure
% elements

dat = get_indiv_study_images(imgpath);

[hh, output_values_by_region, labels, atlas_obj, colorband_colors] = wedge_plot_by_atlas(dat, 'atlases', {'buckner', 'striatum', 'cerebellum'}, 'montage');

wedge_plot_by_atlas(dat, 'atlases', {'thalamus'});
saveas(gcf, 'Thalamus_colorband.png');

wedge_plot_by_atlas(dat, 'atlases', {'buckner'});
saveas(gcf, 'Buckner_colorband.png');

%% Placebo effects: Heterogeneity

hetpath = fullfile(basedir, 'full/pla/g/heterogeneity');

tau = statistic_image(fullfile(hetpath, 'Full_pla_g_tausq.nii'));
p = statistic_image(fullfile(hetpath, 'Full_pla_g_p_map.nii'));
tau.p = p.dat;  clear p

tau = threshold(tau, .001, 'unc');
figure; o2 = montage(tau);
o2 = title_montage(o2, 5, 'Heterogeneity (p < .001)');

o2 = multi_threshold(tau, 'thresh', [.001 .01 .05], 'k', [5 1 1]);
o2 = title_montage(o2, 2, 'Heterogeneity (p < .001 k=5, .01, .05 pruned)');


%% Placebo correlations with analgesia

imgpath = fullfile(basedir, 'full/pla/rrating/random');

% Cluster extent: FWER TFCE 
gfwe = statistic_image(fullfile(imgpath, 'Full_pla_rrating_pperm_tfce_FWE05.nii'));

create_figure('montage2'); axis off
o2 = montage(gfwe);
o2 = title_montage(o2, 5, 'Full_pla_rrating_pperm_tfce_FWE05');
drawnow, snapnow

% Voxel-wise FDR, to localize and interpret peaks

gfdr = statistic_image(fullfile(imgpath, 'Full_pla_rrating_pperm_FDR.nii'));

o2 = removeblobs(o2);
o2 = montage(gfdr, o2);
o2 = title_montage(o2, 5, 'Full_pla_rrating_pperm_FDR');
drawnow, snapnow

% Individual regions

r = region(gfdr);
[rpos, rneg] = table(r);
montage([rpos, rneg], 'regioncenters', 'colormap');

%% Placebo correlations with analgesia: Distribution of unthresholded effect sizes

% fixed and random 

gunt = statistic_image(fullfile(imgpath, 'Full_pla_rrating_unthresh.nii'));
descriptives(gunt);
       
imgpath = fullfile(basedir, 'full/pla/rrating/fixed');
gunt = statistic_image(fullfile(imgpath, 'Full_pla_rrating_unthresh.nii'));
descriptives(gunt);

%% Placebo correlations with analgesia: Heterogeneity

hetpath = fullfile(basedir, 'full/pla/rrating/heterogeneity');

tau = statistic_image(fullfile(hetpath, 'Full_pla_rrating_tausq.nii'));
p = statistic_image(fullfile(hetpath, 'Full_pla_rrating_p_map.nii'));
tau.p = p.dat;  clear p

tau = threshold(tau, .001, 'unc');
figure; o2 = montage(tau);
o2 = title_montage(o2, 5, 'Heterogeneity (p < .001)');

o2 = multi_threshold(tau, 'thresh', [.001 .01 .05], 'k', [5 1 1]);
o2 = title_montage(o2, 2, 'Heterogeneity (p < .001 k=5, .01, .05 pruned)');


%% Pain - Compare different thresholds
%

imgpath = fullfile(basedir, 'full/pain/g/random');

imgnames = {'Full_pain_g_p001.nii' 'Full_pain_g_p_FDR.nii' 'Full_pain_g_pperm_FDR.nii' 'Full_pain_g_pperm_FWE05.nii'};
k = length(imgnames);
gobj = cell(1, k);

o2 = canlab_results_fmridisplay([], 'multirow', k);

for i = 1:k
    
    disp(imgnames{i});
    gobj{i} = statistic_image(fullfile(imgpath, imgnames{i}));
    
    o2 = addblobs(o2, region(gobj{i}), 'wh_montages', 2*i-1:2*i);
    
    o2 = title_montage(o2, 2*i, imgnames{i});
    
    disp(imgnames{i});
    table(region(gobj{i}));
    
    drawnow, snapnow
end

%% Placebo - Compare different thresholds
%
% most sensitive:
% Full_pla_g_pperm_tfce_FWE05.nii
% Full_pla_g_pperm_FDR.nii

imgpath = fullfile(basedir, 'full/pla/g/random');

imgnames = {'Full_pla_g_p001.nii' 'Full_pla_g_p_FDR.nii' 'Full_pla_g_pperm_FDR.nii' 'Full_pla_g_pperm_FWE05.nii' 'Full_pla_g_pperm_tfce_FDR.nii' 'Full_pla_g_pperm_tfce_FWE05.nii'};
k = length(imgnames);
gobj = cell(1, k);

o2 = canlab_results_fmridisplay([], 'multirow', k);

for i = 1:k
    
    disp(imgnames{i});
    gobj{i} = statistic_image(fullfile(imgpath, imgnames{i}));
    
    o2 = addblobs(o2, region(gobj{i}), 'wh_montages', 2*i-1:2*i);
    
    o2 = title_montage(o2, 2*i, imgnames{i});
    
    disp(imgnames{i});
    table(region(gobj{i}));
    
    drawnow, snapnow
end

% Extra: montage showcenters - for final threshold
r = region(gobj{i});
montage(r, 'regioncenters', 'colormap');
table(r);

%% Look at individual study images
% Explore centering/scaling

imgpath = fullfile(basedir, 'full/pla/g/study_level');

dat = get_indiv_study_images(imgpath);

histogram(dat, 'byimage');


%dat = remove_empty(dat);

dat = replace_empty(dat);

s = sum(sign(dat.dat) > 0, 2);              % signs - how many images have positive?
p = 2 * min([binocdf(s, size(dat.dat, 2), .5) binocdf(s, size(dat.dat, 2), .5, 'upper')], [], 2);
simg = statistic_image('dat', s - size(dat.dat, 2) ./ 2, 'volInfo', dat.volInfo, 'p', p);

simg = threshold(simg, .01, 'unc');
create_figure('signs'); montage(simg);

P = ones(size(dat.dat, 1), 1);
D = dat.dat';                   % data
for i = 1:length(P)
    P(i) = signtest(D(:, i));
end

simg2 = simg;
simg2.p = P(~dat.removed_voxels);

corr(simg2.p, simg.p)
figure; plot(simg.p, simg2.p, 'k.');

% 
% [P,H,STATS] = signtest(dat.dat(1000, :)');
% [P,H,STATS] = signrank(dat.dat');



%% Sub-functions


function dat = get_indiv_study_images(imgpath)

imgs = filenames(fullfile(imgpath, '*nii'), 'absolute');
wh = cellfun(@isempty, strfind(imgs, '_pos.nii'));
imgs(wh) = [];
posimgs = imgs;

imgs = filenames(fullfile(imgpath, '*nii'), 'absolute');
wh = cellfun(@isempty, strfind(imgs, '_neg.nii'));
imgs(wh) = [];
negimgs = imgs;

imgs = filenames(fullfile(imgpath, '*nii'), 'absolute');
wh = ~(cellfun(@isempty, strfind(imgs, '_pos.nii'))) | ~(cellfun(@isempty, strfind(imgs, '_neg.nii')));
imgs(wh) = [];
imgs = imgs;

dat = fmri_data(imgs);

end

