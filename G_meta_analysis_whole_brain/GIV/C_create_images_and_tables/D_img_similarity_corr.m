function D_img_similarity_corr(datapath)
% For correlation maps of behavior vs placebo-related brain activity
% we cannot get single-subject estimates (correlations
% were calculated on study level). Similarity of activation patterns is
% calculated on study-level results images. Standard errors are
% approximated based on n.

addpath(genpath(fullfile(userpath,'CanlabCore')));
addpath(genpath(fullfile(userpath,'CanlabPatternMasks')));
addpath(genpath(fullfile(userpath,'cbrewer')));

%Set paths relative to function
p = mfilename('fullpath');
[resultspath,~,~]=fileparts(p);
splitp=strsplit(resultspath,'/');
anpath=fullfile(filesep,splitp{1:end-1});
outpath=fullfile(filesep,splitp{1:end-1},'figure_results/');

% Load dataframe
df_name= 'data_frame.mat';
load(fullfile(datapath,df_name),'df');

% Load study-summary images from GIV analysis
targetvars={'r'};
random_img_dir_r=fullfile(anpath,'/nii_results/full/pla/rrating/study_level');
r_imgs_random=fullfile(random_img_dir_r,strcat(df.study_ID,'.nii'));
images_RANDOM.r=fmri_data(r_imgs_random); %Create CANlab data obj
images_RANDOM.r.removed_images = 0;

% Prepare/load bucknerlab (wholebrain), thalamus, brainstem, basal ganglia atlases


atlas_names={'bucknerlab_wholebrain','thalamus','brainstem','basal_ganglia'};
for k=1:length(atlas_names)
    %[~, names_buckner_wholebrain, ~] = load_image_set('bucknerlab_wholebrain');
    %seq_buckner=[7,6,5,3,4,2,1];
    if strcmp(atlas_names{k},'bucknerlab_wholebrain')
       [mask, curr_labels, ~] = load_image_set('bucknerlab_wholebrain'); 
       seq=[7,2,6,5,4,3,1]; %sequence of wedges
    else
        curr_atlas = load_atlas(atlas_names{k});
        mask=fmri_data;
        mask.dat=curr_atlas.probability_maps;
        mask.removed_voxels=curr_atlas.removed_voxels;
        mask.volInfo=curr_atlas.volInfo; % Well, that was a pain to get right
        curr_labels= curr_atlas.labels;
        seq=1:length(curr_labels);
    end
    for i=1:length(targetvars)
        curr_stats = image_similarity_plot(images_RANDOM.(targetvars{i}),...
                                           'mapset',mask,...
                                           'networknames',curr_labels,...
                                           'cosine_similarity',...
                                           'nofigure',...
                                           'noplot'); % CAVE: THESE RESULTS ARE NOT WEIGHTED FOR N YET!
        sim=curr_stats.r';
        SE_sim=n2fishersZse(repmat(df.n,1,size(sim,2))); % approximation of SE based on n of subjects
        % GIV summarize across studies
        simil=[];
        for j=1:size(sim,2)
        [simil(j).fixed,simil(j).random,simil(j).heterogeneity]=GIV_weight(r2fishersZ(sim(:,j)),...
                                                                            SE_sim(:,j));
        [simil(j).fixed,simil(j).random,simil(j).heterogeneity]=GIV_weight_fishersZ2r(simil(j).fixed,simil(j).random,simil(j).heterogeneity);
        end
        % Wedge Plot
        simil_vert=vertcat(simil.random);
        values=vertcat(simil_vert.summary);
        SE_values=vertcat(simil_vert.SEsummary);
        p_values=vertcat(simil_vert.p);
        results_labels={};
        for j=1:length(curr_labels)
            if p_values(j)<0.05
                results_labels{j}=[curr_labels{j},'*'];
            else
                results_labels{j}=[curr_labels{j}];
            end
            results_labels{j}=strrep(results_labels{j},'_',' ');
        end
        matthias_wedge_plot(values(seq),...
                            SE_values(seq),...
                            results_labels(seq),...
                            'metric','cosim')
        curr_path=fullfile(outpath,['wedge_placebo_random_',targetvars{i},'_',atlas_names{k}]);
        curr_svg=[curr_path,'.svg'];
        curr_png=[curr_path,'.png'];
        hgexport(gcf, curr_svg, hgexport('factorystyle'), 'Format', 'svg'); 
        hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
        crop(curr_png);
        close all;
        end
end