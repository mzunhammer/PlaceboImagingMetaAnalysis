function img_similarity(datapath,varargin)
addpath(genpath(fullfile(userpath,'CanlabCore')));
addpath(genpath(fullfile(userpath,'CanlabPatternMasks')));
addpath(genpath(fullfile(userpath,'cbrewer')));

%Set paths relative to function
p = mfilename('fullpath');
[resultspath,~,~]=fileparts(p);
splitp=strsplit(resultspath,'/');
anpath=fullfile(filesep,splitp{1:end-1});
fixedpath=fullfile(anpath,'/G_meta_analysis_whole_brain/GIV/nii_results/full/pla/g/subject_level');

randompath=fullfile(anpath,'/G_meta_analysis_whole_brain/GIV/nii_results/full/pla/g/study_level');

df_name= 'data_frame.mat';
load(fullfile(datapath,df_name),'df');

% Set names for bucknerlab
[~, names_buckner_wholebrain, ~] = load_image_set('bucknerlab_wholebrain');
[thal_maps, names_buckner_thal, ~] = load_bucknerlab_thalamus;

WI_sub_filter=strcmp(df.study_design,'within');

if strcmp(varargin,'dofixed')
    %% LOAD STUDIES FOR FIXED EFFECTS IMG_SIMILARITY ANALYSIS (WITHIN-SUBJECT STUDIES ONLY)
    % VERSION 1: using single-subject effect size images from GIV analysis to keep results fully
    % comparable
    fixed_imgs={};
    for i=1:size(df,1)
        if WI_sub_filter(i)
        fixed_imgs{i}=fullfile(fixedpath,strcat(df.subjects{i}.sub_ID,'.nii'));                                                                       
        end
    end
    fixed_imgs=vertcat(fixed_imgs{:});
    images_FIXED=fmri_data(fixed_imgs);
    images_FIXED.removed_images = 0;

    %VERSION 2: load raw (spatially re-sampled) images and CanLab prepro pipeline:
%     fixed_imgs={};
%     for i=1:size(df,1)
%         if WI_sub_filter(i)
%         curr_df=df.subjects{i};
%         curr_con=vertcat(curr_df.placebo_minus_control{:});
%         fixed_imgs{i}=fullfile(datapath,curr_con.norm_img); % using single-subject effect size images from GIV analysis to keep results fully                                                                   % comparable
%         end
%     end
%     fixed_imgs=vertcat(fixed_imgs{:});
%     images_FIXED=fmri_data(fixed_imgs);
%     images_FIXED.removed_images = 0;
%     images_FIXED = rescale(images_FIXED, 'l2norm_images'); 
%     images_FIXED = preprocess(images_FIXED, 'windsorize'); % entire data matrix
%     images_FIXED = preprocess(images_FIXED, 'remove_csf');



    %% REMOVE STUDY AVERAGES FIXED EFFECT

    images_FIXED.images_per_session = df.n(WI_sub_filter);

    Im = intercept_model(images_FIXED.images_per_session);
    Im = scale(Im, 1); % mean-center; lose 1 df. individual regressors not interpretable/unique, but we don't care - just control for them
    cc = create_orthogonal_contrast_set(18)';
    Im_con = Im * cc;

    images_FIXED.X = Im_con;  % intercept will be added automatically, last

    images_FIXED_study_stat=[];
    images_FIXED_study_stat=regress(images_FIXED, 'residual');

    images_FIXED_demeaned=images_FIXED;
    % Exchange data with intercept+residuals, by-study regressors are left out
    images_FIXED_demeaned.dat=images_FIXED_study_stat.resid.dat;
    intercept=zeros(size(images_FIXED_study_stat.b.removed_voxels));
    intercept(~images_FIXED_study_stat.b.removed_voxels)=images_FIXED_study_stat.b.dat(:,end);
    images_FIXED_demeaned.dat=images_FIXED_demeaned.dat+...
                              intercept; %last column of beta-values is intercept
    stats_fixed = image_similarity_plot(images_FIXED, 'cosine_similarity', 'bucknerlab_wholebrain','average');
    stats_fixed_demeaned = image_similarity_plot(images_FIXED_demeaned, 'cosine_similarity', 'bucknerlab_wholebrain','average');

    % check if de-meaning worked:
    % Get global study means
    figure
    plot([images_FIXED.X'*mean(images_FIXED.dat)';0]);
    hold on
    plot([images_FIXED_demeaned.X'*mean(images_FIXED_demeaned.dat)';0])
    hold off
    xticks(1:sum(WI_sub_filter))
    xticklabels(df.study_ID(WI_sub_filter))
    xtickangle(45);
    legend({'raw','by-study means removed'})
    ylabel('By-study grand mean (mean across voxels and subjects)')

    figure
    plot(mean(images_FIXED.dat));
    hold on
    plot(mean(images_FIXED_demeaned.dat))
    hold off
    legend({'raw','by-study means removed'})
    ylabel('By-subject grand mean (across voxels)')
    xlabel('Subject number')

    % further plot results before vs after demeaning
    figure
    plot(mean(stats_fixed.r,2),mean(stats_fixed_demeaned.r,2),'.','MarkerSize',15)
    axis([-0.02,0.02,-0.02,0.02])
    xlabel('Mean similarity estimates before study-demeaning')
    ylabel('Mean similarity estimates after study-demeaning')

    figure
    plot(std(stats_fixed.r,[],2),std(stats_fixed_demeaned.r,[],2),'.')
    axis([0,0.2,0,0.2])
    xlabel('SD of similarity estimates before study-demeaning')
    ylabel('SD of similarity estimates after study-demeaning')

    % Thalamus
    stats_fixed_demeaned_thal = image_similarity_plot(images_FIXED_demeaned,'mapset', thal_maps, 'networknames', names_buckner_thal, 'cosine_similarity','average');

end
%% LOAD STUDIES FOR RANDOM EFFECTS IMG_SIMILARITY ANALYSIS (ALL STUDIES)
%using single-study effect size images from GIV analysis to keep results fully
%comparable
effect_size_imgs_random=fullfile(randompath,strcat(df.study_ID,'.nii'));
effect_size_imgs_random=effect_size_imgs_random;
images_RANDOM=fmri_data(effect_size_imgs_random);
images_RANDOM.removed_images = 0;

% Cosine similarity analyses RANDOM
stats_random = image_similarity_plot(images_RANDOM, 'cosine_similarity', 'bucknerlab_wholebrain','nofigure','noplot'); %
cosine_simil=stats_random.r';
SE_cosine_simil=repmat(df.n,1,size(stats_random.r',2)); % approximation based on n of subjects

% GIV summarize across studies
for i=1:size(cosine_simil,2)
[simil(i).fixed,simil(i).random,simil(i).heterogeneity]=GIV_weight(r2fishersZ(cosine_simil(:,i)),...
                                                          n2fishersZse(SE_cosine_simil(:,i)));
[simil(i).fixed,simil(i).random,simil(i).heterogeneity]=GIV_weight_fishersZ2r(simil(i).fixed,simil(i).random,simil(i).heterogeneity);
end
% Polar Plot
simil_vert=vertcat(simil.random);
%polar_plot_matthias(vertcat(simil_vert.summary)',...
%                    vertcat(simil_vert.SEsummary)',...
%                    names_buckner_wholebrain);
matthias_wedge_plot(vertcat(simil_vert.summary),...
                    vertcat(simil_vert.SEsummary),...
                    names_buckner_wholebrain)
%                 
% THALAMUS
stats_random_thal = image_similarity_plot(images_RANDOM,'mapset', thal_maps, 'networknames', names_buckner_thal,'cosine_similarity','nofigure','noplot'); %
cosine_simil_thal=stats_random_thal.r';
SE_cosine_simil_thal=repmat(df.n,1,size(stats_random_thal.r',2)); % approximation based on n of subjects

% GIV summarize across studies
for i=1:size(cosine_simil_thal,2)
[simil_thal(i).fixed,simil_thal(i).random,simil_thal(i).heterogeneity]=GIV_weight(r2fishersZ(cosine_simil_thal(:,i)),...
                                                          n2fishersZse(SE_cosine_simil_thal(:,i)));
[simil_thal(i).fixed,simil_thal(i).random,simil_thal(i).heterogeneity]=...
    GIV_weight_fishersZ2r(simil_thal(i).fixed,simil_thal(i).random,simil_thal(i).heterogeneity);
end
% Polar Plot
simil_vert_thal=vertcat(simil_thal.random);
% polar_plot_matthias(vertcat(simil_vert_thal.summary)',...
%                     vertcat(simil_vert_thal.SEsummary)',...
%                     names_buckner_thal);
matthias_wedge_plot(vertcat(simil_vert_thal.summary),...
                    vertcat(simil_vert_thal.SEsummary),...
                    names_buckner_thal)


%% Forest plot wedges of interest
plotwedge='Frontoparietal';
i=find(strcmp(names_buckner_wholebrain,plotwedge));
forest_plot(stats_random.r(i,:)',...
            SE_cosine_simil(:,i),...
            df.n,...
            simil(i),...
            'study_ID_texts',df.study_ID,...
            'type','random',...
            'summary_stat','r',...
            'outcome_label',plotwedge);

% function [mask, networknames, imagenames] = load_thalamus
%
% % Load Thalamus parcellations
% % ------------------------------------------------------------------------
%
% networknames = {'Name 1' 'Name 2' 'Name 3' '};
%
% imagenames = { ...
%     'Img1.nii' ...
%     'Img2.nii' ...
%     'Img3.nii' ...
% };
%
% imagenames = check_image_names_get_full_path(imagenames);
%
% mask = fmri_data(imagenames, [], 'noverbose');  % loads images with spatial basis patterns
%
% end % function
function [image_obj, networknames, imagenames] = load_bucknerlab_thalamus

    % Load Bucker Lab 1,000FC masks – Thalamus, left and right hemispheres
    % pooled!
    % ------------------------------------------------------------------------

    names = load('Bucknerlab_7clusters_SPMAnat_Other_combined_regionnames.mat');
    img = which('rBucknerlab_7clusters_SPMAnat_Other_combined.img');

    image_obj = fmri_data(img, [], 'noverbose');  % loads image with integer coding of networks
    k = strncmp(names.rnames,'Thal',4);
    i_thal=find(k);
    %i_thal_left=i_thal(1:2:end);
    networknames = names.rnames(i_thal);

    newmaskdat = zeros(size(image_obj.dat, 1), length(i_thal));
    
    % Cortex, BG, CBLM
    for j =  1:length(i_thal)% breaks up into one map per image/network
        curr_i=i_thal(j);
        wh = image_obj.dat == curr_i; % left regions
        newmaskdat(:, j) = double(wh);
        
%         wh = image_obj.dat == curr_i + 1; % right regions
%         newmaskdat(:, j) = newmaskdat(:, j) + double(wh);
    end

    % ADD OTHER REGIONS
    % *****


    image_obj.dat = newmaskdat;

    imagenames = {img};
end
end
