%% Meta-Analysis & Forest Plot
% Difference compared to "basic":


pubpath='../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/';
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('A3_Responder_Sample.mat')

% !!!!! These must be in the same order as listed under "studies" !!!!
studyIDtexts={
            'Atlas et al. 2012:';...
			'Bingel et al. 2006:';...
			'Bingel et al. 2011:';...
			'Choi et al. 2011:';...
			'Eippert et al. 2009:';...
			'Ellingsen et al. 2013:';...
            'Elsenbruch et al. 2012:';...
            'Freeman et al. 2015:';...
            'Geuter et al. 2013:';...
            'Kessner et al. 2014:*';...
            'Kong et al. 2006:';...
            'Kong et al. 2009:';...
            'Lui et al. 2010:';...
            'Ruetgen et al. 2015:'
            'Schenk et al. 2015:'
            'Theysohn et al. 2009:';...
            'Wager et al. 2004, Study 1:';...
            'Wager et al. 2004, Study 2:';...
            'Wrobel et al. 2014:'
            'Zeidan et al. 2015:';...
            };

%% Meta Analysis        
varselect={'rating','rating101','NPS','MHEraw','SIIPS','stimInt'};
ratingvars={'rating','rating101'};
imagingvars={'NPS','MHEraw','SIIPS','stimInt'};
% Loop for studies where both con and pla conditions are available
for j=1:length(varselect) % Loop through all outcome variables
    currvar=varselect{j};
    v=find(strcmp(df_resp.variables,currvar));
    for i=1:length(df_resp.studies) % Loop through all studies...
        rating_var_and_con_only=(any(strcmp(ratingvars,currvar)) && df_resp.consOnlyRating(i)==1);
        img_var_and_con_only=(any(strcmp(imagingvars,currvar)) && df_resp.consOnlyNPS(i)==1);
        if  ~rating_var_and_con_only && ~img_var_and_con_only % where both pla and con is available.
            if df_resp.BetweenSubject(i)==0 %Use withinMetastats for within-subject studies
               stats.(currvar)(i)=withinMetastats(df_resp.pladata{i}(:,v),df_resp.condata{i}(:,v));
            elseif df_resp.BetweenSubject(i)==1 %Use betweenMetastats for between-subject studies
               stats.(currvar)(i)=betweenMetastats(df_resp.pladata{i}(:,v),df_resp.condata{i}(:,v));
            end        
        end
    end
end

% For some studies (all within-subject) pla>con contrasts are available, only.
% For these studies within-subject correlations have to be imputed (mean of
% all other studies is used. There are some studies where contrasts only
% are available for images, others where this is the case for ratings.

% Loop for studies with contrast-only ratings
conOnly=find(df_resp.consOnlyRating==1);
for j=1:length(ratingvars)
    currvar=ratingvars{j};
    v=find(strcmp(df_resp.variables,currvar));
    impu_r=nanmean([stats.(currvar).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=conOnly'
        stats.(currvar)(i)=withinMetastats(df_resp.pladata{i}(:,v),impu_r);
    end
end

% Loop for studies with contrast-only imaging data
conOnly=find(df_resp.consOnlyNPS==1);
for j=1:length(imagingvars)
    currvar=imagingvars{j};
    v=find(strcmp(df_resp.variables,currvar));
    impu_r=nanmean([stats.(currvar).r]); % impute the mean within-subject study correlation observed in all other studies
    for i=conOnly'
        stats.(currvar)(i)=withinMetastats(df_resp.pladata{i}(:,v),impu_r);
    end
end        
        
%% One Forest plot per variable
varnames={'rating'
          'NPS'
          'MHEraw'
          'SIIPS'};
nicevarnames={'Pain ratings',...
              'NPS response',...
              'MHE response',...
              'SIIPS response'};
for i = 1:numel(varnames)
    summary.(varnames{i})=ForestPlotter(stats.(varnames{i}),...
                  'studyIDtexts',studyIDtexts,...
                  'outcomelabel',[nicevarnames{i},' (Hedges'' g)'],...
                  'type','random',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1);
    hgexport(gcf, fullfile(pubpath,['B4_Meta_Resp_',varnames{i},'.svg']), hgexport('factorystyle'), 'Format', 'svg');
    hgexport(gcf, fullfile(pubpath,['B4_Meta_Resp_',varnames{i},'.png']), hgexport('factorystyle'), 'Format', 'png'); 
    crop(fullfile(pubpath,['B4_Meta_Resp_',varnames{i},'.png']));
    close all;
end

%% Obtain Bayesian Factors
disp('BAYES FACTORS RATINGS')
effect=abs(summary.rating.g.random.summary);
SEeffect=summary.rating.g.random.SEsummary;
bayesfactor(effect,SEeffect,0,[0,0.5,2])

disp('BAYES FACTORS NPS')
effect=abs(summary.NPS.g.random.summary);
SEeffect=summary.NPS.g.random.SEsummary;

bayesfactor(effect,SEeffect,0,[0,0.5,2]) % Bayes factor for normal (two-tailed) null prior placing 95% probability for the mean effect being between -1 and 1
bayesfactor(effect,SEeffect,0,[0,0.5,1]) % "Enthusiast" Bayes factor for normal (one-tailed) null prior placing 95% probability for the mean effect being between -1 and 0
bayesfactor(effect,SEeffect,0,[abs(summary.rating.g.random.summary),...
                               summary.rating.g.random.SEsummary,2]) % Bayes factor for normal null prior identical with overall behavioral effect
