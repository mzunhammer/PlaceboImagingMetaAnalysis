function img_similarity(datapath)
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
%% LOAD STUDIES FOR FIXED EFFECTS IMG_SIMILARITY ANALYSIS (WITHIN-SUBJECT STUDIES ONLY)

% 
% fixed_imgs={}
% for i=1:size(df,1)
%     if ~strcmp(df.study_design{i},'between')
%     fixed_imgs{i}=fullfile(fixedpath,strcat(df.subjects{i}.sub_ID,'.nii'));
%     end
% end
% fixed_imgs=vertcat(fixed_imgs{:});
% % using single-subject effect size images from GIV analysis to keep results fully
% % comparable
% images_FIXED=fmri_data(fixed_imgs);
% images_FIXED.removed_images = 0;

%% LOAD STUDIES FOR RANDOM EFFECTS IMG_SIMILARITY ANALYSIS (ALL STUDIES)
% using single-study effect size images from GIV analysis to keep results fully
% comparable
effect_size_imgs_random=fullfile(randompath,strcat(df.study_ID,'.nii'));
images_RANDOM=fmri_data(effect_size_imgs_random);
images_RANDOM.removed_images = 0;

%% Network-based analyses RANDOM
stats_random = image_similarity_plot(images_RANDOM, 'cosine_similarity', 'bucknerlab_wholebrain','nofigure');
cosine_simil=stats_random.r';
SE_cosine_simil=repmat(df.n,1,size(stats_random.r',2)); % approximation based on n of subjects

%% GIV summarize across studies
for i=1:size(cosine_simil,2)
[simil(i).fixed,simil(i).random,simil(i).heterogeneity]=GIV_weight(r2fishersZ(cosine_simil(:,i)),...
                                                          n2fishersZse(SE_cosine_simil(:,i)));
end
%% Polar Plot
[~, networknames, ~] = load_image_set('bucknerlab_wholebrain');
polar_plot_matthias(sim_summary.random.summary,...
                    sim_summary.random.summary,...
                    networknames);
%% Forest plot wedges of interest
plotwedge='Somatomotor';
i=find(strcmp(networknames,plotwedge));
forest_plot(stats_random.r(i,:)',...
            SE_cosine_simil(:,i),...
            df.n,...
            simil(i),...
            'study_ID_texts',df.study_ID,...
            'type','random',...
            'summary_stat','r');

%%
function polar_plot_matthias(m,se,networknames)
        toplot=[m+se; m; m-se]';
        %plot_colors=cbrewer('qual','Paired',3);
        color_mean=[.25,.25,.25];
        color_SE=[.75,.75,.75];
        create_figure('tor_polar');
        [hh, hhfill] = matthias_polar_plot({toplot}, {color_SE,color_mean,color_SE}, {networknames}, 'nonneg');
        set(hh{1}(1:3:end), 'LineWidth', 1); %'LineStyle', ':', 'LineWidth', 2);
        set(hh{1}(3:3:end), 'LineWidth', 1); %'LineStyle', ':', 'LineWidth', 2);
        
        set(hh{1}(2:3:end), 'LineWidth', 4);
        set(hhfill{1}([3:3:end]), 'FaceAlpha', 1, 'FaceColor', 'w');
        set(hhfill{1}([2:3:end]), 'FaceAlpha', 0);
        set(hhfill{1}([1:3:end]), 'FaceAlpha', .3);
        
        handle_inds=1:3:length(hh{1});
        stats.line_handles = hh{1}(handle_inds:handle_inds+2);
        stats.fill_handles = hhfill{1}(handle_inds:handle_inds+2);
        
        % doaverage
        hhtext = findobj(gcf, 'Type', 'text'); set(hhtext, 'FontSize', 20);
end

end
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

