function B1_select_for_meta_conservative_sample(datapath)
%% Define cases for the meta-analysis of the conservative sample

% Difference compared to "ALL":
% Atlas: None 
% Bingel06: None
% Bingel11: Excluded study because placebo condition was not randomized in
% respect to testing sequence.
% Choi: None
% Eippert: None
% Ellingsen: None
% Elsenbruch: None
% Freeman: None
% Geuter: None
% Kessner: None
% Kong06: Excluded study as not all participants from original analysis were available.
% Kong09: None
% Ruetgen: Excluded study because of responder selection
% Schenk: None
% Theysohn: None
% Wager06a: None
% Wager06b: Excluded study because of responder selection
% Wrobel: None
% Zeidan: Excluded as not all participants from original analysis were
%         available + only ASL study

% Add folder with Generic Inverse Variance Methods Functions first
load(fullfile(datapath,'data_frame.mat'),'df')
df.conservative=df.full;
studies_excluded={'bingel11','kong06','ruetgen','wager04b_michigan','zeidan'};
i=find(ismember(df.study_ID,studies_excluded));

% Fill with empty fields
for j=i
df.conservative(j)=struct('con',cell(1,1),...
              'pla',cell(1,1),...
              'pla_minus_con',cell(1,1),...
              'mean_pla_con',cell(1,1));
end

save(fullfile(datapath,'data_frame.mat'),'df');

end
