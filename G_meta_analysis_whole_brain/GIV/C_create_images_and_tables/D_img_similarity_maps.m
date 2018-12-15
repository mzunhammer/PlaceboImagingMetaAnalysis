function D_img_similarity_maps(datapath,varargin)
% Summarizes single-subject cosine similarity estimates using the GIV.
% Cosine similarity estimates were obtained with 
% analysis/D_apply_NPS/A_apply_various.m
% optional inputs:
% 'forest_plots': Will additionally provide a forest_plot with each wedge
% 'conservative': Will use the conservative instead of the full sample.
% 'nolabels': Will yield wedge-plots without lables.

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

disp(['Results saved in:', outpath])
% Load dataframe
df_name= 'data_frame.mat';
load(fullfile(datapath,df_name),'df');

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

% Sequence of wedges
seq{1}=[1,2,3,4,5,6,7]; %alternative [7,2,6,5,4,3,1]
seq{2}=1:length(labels{2});
seq{3}=1:length(labels{3});
seq{4}=1:length(labels{4});
seq{5}=1:length(labels{5});


%% Meta-Analysis of binary maps for pain
variable_select={'bucknerlab_wholebrain','thalamus','brainstem','basal_ganglia','insula'}; %,
for j=1:length(variable_select) % Loop through all outcome variables
    currvar=variable_select{j};
    for i=1:size(df,1) % Loop through all studies...
        df_pain=df.subjects{i}.placebo_and_control;
        df_pain=vertcat(df_pain{:});
        df.(['GIV_stats_pain_',currvar])(i)=summarize_within(df_pain.(currvar),0,...
                                                             'winsor',3); %winsorize by 3 SD
    end
end

%% Wedge plots for PAIN
for i=1:length(variable_select)
    currvar=variable_select{i};
    curr_summary=GIV_summary(df.(['GIV_stats_pain_',currvar])); 
    % Wedge Plot
    values=curr_summary.mu.random.summary;
    SE_values=curr_summary.mu.random.SEsummary;
    p_values=curr_summary.mu.random.p';
    results_labels={};
    for j=1:length(labels{i})
        if p_values(j)<0.05 
            results_labels{j}=strrep([labels{i}{j},'*'],'_',' ');
        else
            results_labels{j}=strrep([labels{i}{j}],'_',' ');
        end
    end
    matthias_wedge_plot(values(seq{i})',...
                        SE_values(seq{i})',...
                        results_labels(seq{i})',...
                        'metric','similarity',labelflag);
    curr_path=fullfile(outpath,['wedge_pain_random_cossim_',labelflag,currvar]);
    curr_eps=[curr_path,'.eps'];
    curr_png=[curr_path,'.png'];
    hgexport(gcf, curr_eps, hgexport('factorystyle'), 'Format', 'eps'); 
    hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
    crop(curr_png);
    close all;
    %% print table
    disp("Pain")
    currvar
    table(labels{i}',values',SE_values',p_values,'VariableNames',{'ROI','Similarity','SE','p'})
end

%% Forest plots for PAIN
if any(strcmp(varargin,'forest_plots'))
for i=1:length(variable_select)
    currvar=variable_select{i};
    GIV_stats=df.(['GIV_stats_pain_',currvar]);
    for j=1:length(GIV_stats(1).mu)
      currstat=stat_reduce(GIV_stats,j);
      forest_plotter(currstat,...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',strrep([currvar,'_',labels{i}{j},' (Cosine similarity)'],'_',' '),...
                  'type','random',...
                  'summary_stat','mu',...
                  'with_outlier',0,...
                  'WI_subdata',{currstat.delta},...
                  'box_scaling',1,...
                  'text_offset',0);
    curr_path=fullfile(outpath,['forest_pain_random_cossim_',currvar,'_',labels{i}{j}]);
    curr_eps=[curr_path,'.eps'];
    curr_png=[curr_path,'.png'];
    hgexport(gcf, curr_eps, hgexport('factorystyle'), 'Format', 'eps'); 
    hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
    crop(curr_png);
    close all;
    end
end
end

%% Meta-Analysis of binary maps for placebo
% Loop for studies where both con and pla conditions are available
for j=1:length(variable_select) % Loop through all outcome variables
    currvar=variable_select{j};
    for i=1:size(df,1) % Loop through all studies...
        if strcmp(varargin,'conservative')
            ex_study=df.excluded_conservative_sample(i);
            ex_subj=df.subjects{i}.excluded;
        else
            ex_study=0;
            ex_subj=zeros((size(df.subjects{i}.excluded)));
        end
        if ~ex_study
            df_placebo=df.subjects{i}.pain_placebo(~ex_subj,:);
            df_placebo=vertcat(df_placebo{:});
            df_control=df.subjects{i}.pain_control(~ex_subj,:);
            df_control=vertcat(df_control{:});
            if  ~(df.contrast_imgs_only(i)==1) % where both pla and con is available.
                if strcmp(df.study_design{i},'within') %Use withinMetastats for within-subject studies
                   df.(['GIV_stats_',currvar])(i)=summarize_within(df_placebo.(currvar),df_control.(currvar),...
                                                                        'winsor',3); %winsorize by 3 SD
                elseif strcmp(df.study_design{i},'between') %Use betweenMetastats for between-subject studies
                   df.(['GIV_stats_',currvar])(i)=summarize_between([df_placebo.(currvar)],[df_control.(currvar)],...
                                                                        'winsor',3); %winsorize by 3 SD
                end
            end
        end
    end
end

% For some (within-subject) studies  pla>con contrasts are available, only.
% % For these studies within-subject correlations have to be imputed (mean of
% % within-subject correlation of all other studies is used).
% Loop for studies with contrast-only imaging data
for j=1:length(variable_select)
    currvar=variable_select{j};
    impu_r=nanmean([df.(['GIV_stats_',currvar]).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=find(df.contrast_imgs_only==1)'
        if strcmp(varargin,'conservative')
            ex_study=df.excluded_conservative_sample(i);
            ex_subj=df.subjects{i}.excluded;
        else
            ex_study=1;
            ex_subj=zeros((size(df.subjects{i}.excluded)));
        end
        df_placebo=df.subjects{i}.placebo_minus_control(~ex_subj,:);
        df_placebo=vertcat(df_placebo{:});
        df.(['GIV_stats_',currvar])(i)=summarize_within(df_placebo.(currvar),impu_r,...
                                                        'winsor',3);
    end
end

%% Wedge plots for PLACEBO
for i=1:length(variable_select)
    currvar=variable_select{i};
    curr_summary=GIV_summary(df.(['GIV_stats_',currvar])); 
    % Wedge Plot
    values=curr_summary.mu.random.summary;
    SE_values=curr_summary.mu.random.SEsummary;
    p_values=curr_summary.mu.random.p';
    results_labels={};
    for j=1:length(labels{i})
        if p_values(j)<0.05
            results_labels{j}=strrep([labels{i}{j},'*'],'_',' ');
        else
            results_labels{j}=strrep([labels{i}{j}],'_',' ');
        end
    end
    matthias_wedge_plot(values(seq{i})',...
                        SE_values(seq{i})',...
                        results_labels(seq{i})',...
                        'metric','similarity',labelflag);
    curr_path=fullfile(outpath,['wedge_placebo_random_cossim_',currvar,'_',fnamesuffix]);
    curr_eps=[curr_path,'.eps'];
    curr_png=[curr_path,'.png'];
    hgexport(gcf, curr_eps, hgexport('factorystyle'), 'Format', 'eps'); 
    hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
    crop(curr_png);
    close all;
     %% print table
    disp("Placebo")
    currvar
    table(labels{i}',values',SE_values',p_values,'VariableNames',{'ROI','Similarity','SE','p'})
end


%% Forest plots for PLACEBO
if any(strcmp(varargin,'forest_plots'))
for i=1:length(variable_select)
    currvar=variable_select{i};
    GIV_stats=df.(['GIV_stats_',currvar]);
    for j=1:length(GIV_stats(1).mu)
      currstat=stat_reduce(GIV_stats,j);
      forest_plotter(currstat,...
                  'study_ID_texts',df.study_citations,...
                  'outcome_labels',strrep([currvar,'_',labels{i}{j},' (Cosine similarity)'],'_',' '),...
                  'type','random',...
                  'summary_stat','mu',...
                  'with_outlier',0,...
                  'WI_subdata',{currstat.delta},...
                  'box_scaling',1,...
                  'text_offset',0);
    curr_path=fullfile(outpath,['forest_placebo_random_cossim_',currvar,'_',labels{i}{j},'_',fnamesuffix]);
    curr_eps=[curr_path,'.eps'];
    curr_png=[curr_path,'.png'];
    hgexport(gcf, curr_eps, hgexport('factorystyle'), 'Format', 'eps'); 
    hgexport(gcf, curr_png, hgexport('factorystyle'), 'Format', 'png'); 
    crop(curr_png);
    close all;
    end
end
end
save(fullfile(datapath,'data_frame.mat'), 'df');

end
