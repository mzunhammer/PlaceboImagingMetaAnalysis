function I_medication_effects(datapath,pubpath)
%% Meta-Analysis & Forest Plot ? Full Sample (MAIN RESULTS)
df_name='data_frame.mat';
load(fullfile(datapath,df_name),'df');

study_ID_texts={
            'Atlas et al. 2012: Remifentanil vs saline infusion';...
			'Bingel et al. 2011: Remifentanil vs saline infusion';...
			'Eippert et al. 2009: Naloxone vs saline infusion';...
            'Schenk et al. 2015:  Lidocaine vs control cream'
            'Wrobel et al. 2014: Haloperidol vs saline pill'
            };
%% Meta-Analysis
% note that standardized effect sizes are based on 
% the between-subject SD of summarized signal (summarized
% across images) at each voxel, not single-image SD (as within-subject
% images were not collected)

variable_select={'rating','rating101','NPS'}; %'MHEraw','SIIPS',
ratingvars={'rating','rating101'};
imagingvars={'NPS'};

% Loop for df.study_ID where both con and pla conditions are available
for j=1:length(variable_select) % Loop through all outcome variables
    currvar=variable_select{j};
    
    i=find(strcmp(df.study_ID,'atlas'));
    df_med=df.subjects{i}.med_pain;
    df_med=vertcat(df_med{:});
    df_nomed=df.subjects{i}.nomed_pain;
    df_nomed=vertcat(df_nomed{:});
    df.(['GIV_stats_med_',currvar])(i)=summarize_within(df_med.(currvar),df_nomed.(currvar));
    
    i=find(strcmp(df.study_ID,'bingel11'));
    df_med=df.subjects{i}.med_pain;
    df_med=vertcat(df_med{:});
    df_nomed=df.subjects{i}.nomed_pain;
    df_nomed=vertcat(df_nomed{:});
    df.(['GIV_stats_med_',currvar])(i)=summarize_within(df_med.(currvar),df_nomed.(currvar));
    
    i=find(strcmp(df.study_ID,'eippert'));
    df_med=df.subjects{i}.med_pain;
    df_med=vertcat(df_med{:});
    df_nomed=df.subjects{i}.nomed_pain;
    df_nomed=vertcat(df_nomed{:});
    df.(['GIV_stats_med_',currvar])(i)=summarize_between(df_med.(currvar),df_nomed.(currvar));

    i=find(strcmp(df.study_ID,'schenk'));
    df_med=df.subjects{i}.med_pain;
    df_med=vertcat(df_med{:});
    df_nomed=df.subjects{i}.nomed_pain;
    df_nomed=vertcat(df_nomed{:});
    df.(['GIV_stats_med_',currvar])(i)=summarize_within(df_med.(currvar),df_nomed.(currvar));
 
    i=find(strcmp(df.study_ID,'wrobel'));
    df_med=df.subjects{i}.med_pain;
    df_med=vertcat(df_med{:});
    df_nomed=df.subjects{i}.nomed_pain;
    df_nomed=vertcat(df_nomed{:});
    df.(['GIV_stats_med_',currvar])(i)=summarize_between(df_med.(currvar),df_nomed.(currvar));
end

%% One Forest plot per variable
varnames={'rating'
          'NPS'};
nicevarnames={'Pain ratings',...
              'NPS response'};
summary=[];

for i = 1:numel(varnames)
    meta_stats=[df.(['GIV_stats_med_',varnames{i}])];
    meta_stats=meta_stats([1,3,5,15,19]);
    summary.(varnames{i})=forest_plotter(meta_stats,...
                  'study_ID_texts',study_ID_texts,...
                  'outcome_labels',[nicevarnames{i},' (Hedges'' g)'],...
                  'type','random',...
                  'summary_stat','g',...
                  'with_outlier',0,... %'WI_subdata',{GIV_stats.std_delta},...
                  'WI_subdata',{meta_stats.std_delta},...
                  'box_scaling',1,...
                  'text_offset',0);%X_scale',2
    hgexport(gcf, fullfile(pubpath,['B1_Meta_Meds_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
    hgexport(gcf, fullfile(pubpath,['B1_Meta_Meds_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_Meds_',varnames{i},'.png']));
end
close all;
%% Additional forest plot for pain ratings standardized to 101pt VAS
varnames={'rating101'};
nicevarnames={'Pain ratings'};
for i = 1:numel(varnames)
    meta_stats=[df.(['GIV_stats_med_',varnames{i}])];
    meta_stats=meta_stats([1,3,5,15,19]);
    summary.(varnames{i})=forest_plotter(meta_stats,...
                  'study_ID_texts',study_ID_texts,...
                  'outcome_labels',[nicevarnames{i},' (VAS_1_0_1)'],...
                  'type','random',...
                  'summary_stat','mu',...
                  'with_outlier',0,...%'WI_subdata',{GIV_stats.std_delta},...
                  'WI_subdata',{meta_stats.delta},...
                  'box_scaling',1,...
                  'text_offset',0);
    hgexport(gcf, fullfile(pubpath,['B1_Meta_Meds_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg'); 
    hgexport(gcf, fullfile(pubpath,['B1_Meta_Meds_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B1_Meta_Meds_',varnames{i},'.png']));
end

close all
save(fullfile(datapath,'data_frame.mat'), 'df');
end