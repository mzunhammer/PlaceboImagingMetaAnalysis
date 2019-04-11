function D_img_similarity_corr(datapath,varargin)
% For correlation maps of behavior vs placebo-related brain activity
% we cannot get single-subject estimates (correlations
% were calculated on study level). Similarity of activation patterns is
% calculated on study-level results images. Standard errors are
% approximated based on n.

addpath(genpath(fullfile(userpath,'CanlabCore')));
addpath(genpath(fullfile(userpath,'CanlabPatternMasks')));
addpath(genpath(fullfile(userpath,'cbrewer')));

if any(strcmp(varargin,'nolabels'))
    labelflag='nolabels';
else
    labelflag=[];
end   

if any(strcmp(varargin,'conservative'))
    fnamesuffix=['conservative',labelflag];
else
    fnamesuffix=['full',labelflag];
end

%Set paths relative to function
p = mfilename('fullpath');
[resultspath,~,~]=fileparts(p);
splitp=strsplit(p,['(?<!^)',filesep], 'DelimiterType','RegularExpression');
anpath=fullfile(splitp{1:end-2});
outpath=fullfile(splitp{1:end-2},'figure_results/');

% Load dataframe
df_name= 'data_frame.mat';
load(fullfile(datapath,df_name),'df');

% Correlate behavioral placebo response with bucknerlab (wholebrain), thalamus,
% brainstem, basal ganglia and insular atlase activation



% Load labels for bucknerlab masks, set order
[mask{1}, labels{1}, ~] = load_image_set('bucknerlab_wholebrain');
mask{2} = load_atlas('thalamus');
mask{3} = load_atlas('brainstem');
mask{4} = load_atlas('basal_ganglia');
mask{5} = load_insular_atlas();

labels{2} = mask{2}.labels;
labels{3} = mask{3}.labels;
labels{4} = mask{4}.labels;
labels{5} = mask{5}.additional_info{1}';

%Sequence of wedges
seq{1}=[1,2,3,4,5,6,7];
seq{2}=1:length(labels{2});
seq{3}=1:length(labels{3});
seq{4}=1:length(labels{4});
seq{5}=1:length(labels{5});

atlas_names={'bucknerlab_wholebrain','thalamus','brainstem','basal_ganglia','insula'};

for j=1:length(atlas_names)
    for i=1:length(df.GIV_stats_rating)
        curr_ROI_set=['GIV_stats_',atlas_names{j}];
        % correlate single-subject effect of behavior and voxel signal 
        df.(curr_ROI_set)(i).r_external=fastcorrcoef(df.(curr_ROI_set)(i).delta,...
                                                    df.GIV_stats_rating(i).delta,...
                                                    'exclude_nan'); % correlate single-subject effect of behavior and voxel signal 
        if ~isempty(df.(curr_ROI_set)(i).delta) % necessary as "sum" returns 0 for [] for some stupid reason
            df.(curr_ROI_set)(i).n_r_external=sum(~(isnan(df.(curr_ROI_set)(i).delta)|... % the n for the correlation is the n of subjects showing non-nan values at that particular voxels
                                             isnan(df.GIV_stats_rating(i).delta))); % AND non nan-ratings
        else
            df.(curr_ROI_set)(i).r_external=NaN(size(labels));
            df.(curr_ROI_set)(i).n_r_external=NaN(size(labels));
        end
    end
end

%% Wedge plots for CORRELATIONS
for i=1:length(atlas_names)
    currvar=atlas_names{i};
    curr_summary=GIV_summary(df.(['GIV_stats_',currvar])(strcmp(df.study_design,'within')),'r_external'); 
    % Wedge Plot
    values=curr_summary.r_external.random.summary*-1; % invert correlation as it is representing change in pain, not placebo effect
    SE_values=curr_summary.r_external.random.SEsummary;
    p_values=curr_summary.r_external.random.p';
    results_labels={};
    for j=1:length(labels{i})
        if p_values(j)<0.05
            results_labels{j}=strrep([labels{i}{j},'*'],'_',' ');
        else
            results_labels{j}=strrep([labels{i}{j}],'_',' ');
        end
    end
    if any(strcmp(varargin,'bar'))
        matthias_bar_plot_similarity(values(seq{i})',...
                            SE_values(seq{i})',...
                            results_labels(seq{i})',labelflag);
        xlabel('r ± SE')
        a=gca;
        a.YTickLabel={}; %turn y-labels off (unnecessary if arranged with pain in line)
        %a.YAxis.Visible = 'off'; %alternative: turn y-axis and labels off (unnecessary if arranged with pain in line)
        curr_path=fullfile(outpath,['bar_placebo_correlation_random_',labelflag,currvar]);
    else
        matthias_wedge_plot(values(seq{i})',...
                            SE_values(seq{i})',...
                            results_labels(seq{i})',...
                            'metric','similarity',labelflag);
        curr_path=fullfile(outpath,['wedge_placebo_correlation_random_',labelflag,currvar]);
    end
    curr_eps=[curr_path,'.eps'];
    curr_png=[curr_path,'.png'];
    hgexport(gcf, curr_eps, hgexport('factorystyle'), 'Format', 'eps'); 
    hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
    crop(curr_png);
    close all;
      %% print table
    disp("Placebo")
    currvar
    table(labels{i}',values',SE_values',p_values,'VariableNames',{'ROI','r','SE','p'})
end


%% Forest plots for PLACEBO
if any(strcmp(varargin,'forest_plots'))
for i=1:length(atlas_names)
    currvar=atlas_names{i};
    GIV_stats=df.(['GIV_stats_',currvar]);
    for j=1:length(GIV_stats(1).r_external)
      currstat=stat_reduce(GIV_stats,j);
      forest_plotter(currstat,...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',strrep([currvar,'_',labels{i}{j},' (Cosine similarity)'],'_',' '),...
                  'type','random',...
                  'summary_stat','r_external',...
                  'with_outlier',0,...
                  'box_scaling',1,...
                  'text_offset',0,...
                   'X_scale',1);
    curr_path=fullfile(outpath,['forest_placebo_corr_cossim_',currvar,'_',labels{i}{j},'_',fnamesuffix]);
    curr_eps=[curr_path,'.eps'];
    curr_png=[curr_path,'.png'];
    hgexport(gcf, curr_eps, hgexport('factorystyle'), 'Format', 'eps'); 
    hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
    crop(curr_png);
    close all;
    end
end




% %% Plot
%     for i=1:length(atlas_names)
%         curr_stats = image_similarity_plot(images_RANDOM.(atlas_names{i}),...
%                                            'mapset',mask,...
%                                            'networknames',curr_labels,...
%                                            'cosine_similarity',...
%                                            'nofigure',...
%                                            'noplot'); % CAVE: THESE RESULTS ARE NOT WEIGHTED FOR N YET!
%         sim=curr_stats.r';
%         SE_sim=n2fishersZse(repmat(df_r.n,1,size(sim,2))); % approximation of SE based on n of subjects
%         % GIV summarize across studies
%         simil=[];
%         for j=1:size(sim,2)
%         [simil(j).fixed,simil(j).random,simil(j).heterogeneity]=GIV_weight(r2fishersZ(sim(:,j)),...
%                                                                             SE_sim(:,j));
%         [simil(j).fixed,simil(j).random,simil(j).heterogeneity]=GIV_weight_fishersZ2r(simil(j).fixed,simil(j).random,simil(j).heterogeneity);
%         end
%         % Wedge Plot
%         simil_vert=vertcat(simil.random);
%         values=vertcat(simil_vert.summary);
%         SE_values=vertcat(simil_vert.SEsummary);
%         p_values=vertcat(simil_vert.p);
%         results_labels={};
%         for j=1:length(curr_labels)
%             if p_values(j)<0.05
%                 results_labels{j}=[curr_labels{j},'*'];
%             else
%                 results_labels{j}=[curr_labels{j}];
%             end
%             results_labels{j}=strrep(results_labels{j},'_',' ');
%         end
%         matthias_wedge_plot(values(seq),...
%                             SE_values(seq),...
%                             results_labels(seq),...
%                             'metric','cosim',labelflag)
%         curr_path=fullfile(outpath,['wedge_placebo_random_',targetvars{i},'_',atlas_names{k},'_',fnamesuffix]);
%         curr_svg=[curr_path,'.svg'];
%         curr_png=[curr_path,'.png'];
%         hgexport(gcf, curr_svg, hgexport('factorystyle'), 'Format', 'svg'); 
%         hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
%         crop(curr_png);
%         close all;
%     end
    
end