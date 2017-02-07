%% Placebo-response (ratings) vs placebo-response NPS

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
load('dflong.mat')


dflong=dflong(~isnan(dflong.rating),:);
dflong=dflong(~dflong.ex_lo_p_ratings,:);
dflong.suggestions=~cellfun(@isempty,regexp(dflong.plaInduct,'Suggestions'));
dflong.conditioning=~cellfun(@isempty,regexp(dflong.plaInduct,'Conditioning'));
%% Mixed model analysis of ratings
% ACHTUNG! Ratings/NPS values values were z-Transformed on a by-study level to
% account for (drastic) scaling differences between studies. Therefore the
% mean of those variables is 0 for all studies >> Random intercepts of
% studies cannot be estimated (since these are 0)
mmdlr0 = fitlme(dflong,'z_rating ~ z_stimInt+pla+age+(1|subID)+(pla-1|studyID)',...
              'CheckHessian',true);
mmdlr1 = fitlme(dflong,'z_rating ~ stimtype+(1|subID)+(pla-1|studyID)',...
              'CheckHessian',true)
mmdlr2 = fitlme(dflong,'z_rating ~ z_stimInt+plaFirst*pla*conditioning+(1|subID)',...
              'CheckHessian',true)          
compare(mmdlr1,mmdlr2)
anova(mmdlr2)
[~,~,lmefixed] =  fixedEffects(mmdlr2);
[~,~,lmerandom] = randomEffects(mmdlr2);


plot(dflong.z_rating,fitted(mmdlr2),'.')
plot(fitted(mmdlr2),residuals(mmdlr2),'.')
corrcoef(fitted(mmdlr2),residuals(mmdlr2),'rows','complete')

%% Mixed model analysis of NPSscores
mmdl0 = fitlme(dflong,'z_rating ~ z_stimInt+pla+age+(1|subID)+(pla-1|studyID)',...
              'CheckHessian',true);
mmdl2 = fitlme(dflong,'z_MHEraw ~ z_stimInt+z_rating*pla+(1|subID)',...
              'CheckHessian',true);
          
compare(mmdl0,mmdl2)
anova(mmdl2)
[~,~,lmefixed] =  fixedEffects(mmdl2);
[~,~,lmerandom] = randomEffects(mmdl2);


plot(dflong.z_rating,fitted(mmdl2),'.')
plot(fitted(mmdl2),residuals(mmdl2),'.')
%% Plot standardized single-subject delta ratings vs NPS
% This is only possible for within-subject studies
% Plot single-study values
figure('units','normalized','position',[0 0 1.5 sqrt(1.5)]);
colormapping=brighten(cbrewer('qual','Accent',20),-0.1);
hold on
studies=unique(dflong.studyID);
studyIDtexts={
            'Atlas et al. 2012';...
			'Bingel et al. 2006';...
			'Bingel et al. 2011';...
			'Choi et al. 2011';...
			'Eippert et al. 2009';...
			'Ellingsen et al. 2013';...
            'Elsenbruch et al. 2012';...
            'Freeman et al. 2015';...
            'Geuter et al. 2013';...
            'Kessner et al. 2014';...
            'Kong et al. 2006';...
            'Kong et al. 2009';...
            'Lui et al. 2010';...
            'Ruetgen et al. 2015'
            'Schenk et al. 2015'
            'Theysohn et al. 2009';...
            'Wager et al. 2004, Study 2';...
            'Wrobel et al. 2014'
            };

for i=1:length(studies) % Calculate for all studies except...
       icurrstudy=strcmp(dflong.studyID,studies(i));
       c_rating=dflong.z_rating(icurrstudy);
       c_NPS=dflong.z_NPSraw(icurrstudy);
       %Plot single data-points
       plot(c_NPS,c_rating,'.',...
           'MarkerSize',5,...
           'DisplayName',studyIDtexts{i},...
           'MarkerEdgeColor',colormapping(i,:),...
           'MarkerFaceColor',colormapping(i,:));
       %Plot simple regression lines
       xl=[min(c_NPS);max(c_NPS)]; % Limit regression line to range(min,max)
       x=linspace(xl(1),xl(2),100); % Limit regression line to range(min,max)
       
       currfit=fitlm(dflong(icurrstudy,:),'z_rating ~ z_NPSraw');
       curry=x.*(currfit.Coefficients.Estimate(2))+(currfit.Coefficients.Estimate(1));
       % for model checking: plot BLUPS from linear mixed model (regression lines predicted by fixed+random effects)
%        currBLUPs=lmerandom.Estimate(strcmp(lmerandom.Level,currstudy));
%        curry=x.*(currBLUPs(2)+fixedB1)+(currBLUPs(1)+fixedB0);
       plot(x,curry,'LineWidth',1.5,...
           'DisplayName','',...
           'Color',colormapping(i,:),...
           'MarkerEdgeColor',colormapping(i,:),...
           'MarkerFaceColor',colormapping(i,:));
       %[R,P,RL,RU] =corrcoef(c_NPS,c_rating,'rows','complete');
       %corrs(i)=R(2);
end
xlabel('Standardized NPS')
ylabel('Standardized rating')
legend show


%% Plot standardized single-subject stimint ratings vs NPS
figure('units','normalized','position',[0 0 1.5 sqrt(1.5)]);
colormapping=brighten(cbrewer('qual','Accent',20),-0.1);
hold on
for i=1:length(studies) % Calculate for all studies except...
       icurrstudy=strcmp(dflong.studyID,studies(i));
       c_stimInt=dflong.z_stimInt(icurrstudy);
       c_NPS=dflong.z_NPSraw(icurrstudy);
       %Plot single data-points
       plot(c_NPS,c_stimInt,'.',...
           'MarkerSize',5,...
           'DisplayName',studyIDtexts{i},...
           'MarkerEdgeColor',colormapping(i,:),...
           'MarkerFaceColor',colormapping(i,:));
       %Plot simple regression lines
       xl=[min(c_NPS);max(c_NPS)]; % Limit regression line to range(min,max)
       x=linspace(xl(1),xl(2),100); % Limit regression line to range(min,max)
       
       if ~all(isnan(dflong(icurrstudy,:).z_NPSraw))&&~all(isnan(dflong(icurrstudy,:).z_stimInt))
       currfit=fitlm(dflong(icurrstudy,:),'z_stimInt ~ z_NPSraw');
       curry=x.*(currfit.Coefficients.Estimate(2))+(currfit.Coefficients.Estimate(1));

       % for model checking: plot BLUPS from linear mixed model (regression lines predicted by fixed+random effects)
%        currBLUPs=lmerandom.Estimate(strcmp(lmerandom.Level,currstudy));
%        curry=x.*(currBLUPs(2)+fix~edB1)+(currBLUPs(1)+fixedB0);
       plot(x,curry,'LineWidth',1.5,...
           'DisplayName','',...
           'Color',colormapping(i,:),...
           'MarkerEdgeColor',colormapping(i,:),...
           'MarkerFaceColor',colormapping(i,:));
       %[R,P,RL,RU] =corrcoef(c_NPS,c_stimInt,'rows','complete');
       %corrs(i)=R(2);
       end
end
xlabel('Standardized NPS')
ylabel('Standardized Stimulus Intensity')
legend show

%% Plot standardized single-subject delta ratings vs stimInt
figure('units','normalized','position',[0 0 1.5 sqrt(1.5)]);
colormapping=brighten(cbrewer('qual','Accent',20),-0.1);
hold on
for i=1:length(studies) % Calculate for all studies except...
       icurrstudy=strcmp(dflong.studyID,studies(i));
       c_stimInt=dflong.z_stimInt(icurrstudy);
       c_rating=dflong.z_rating(icurrstudy);
       %Plot single data-points
       plot(c_rating,c_stimInt,'.',...
           'MarkerSize',5,...
           'DisplayName',studyIDtexts{i},...
           'MarkerEdgeColor',colormapping(i,:),...
           'MarkerFaceColor',colormapping(i,:));
       %Plot simple regression lines
       xl=[min(c_rating);max(c_rating)]; % Limit regression line to range(min,max)
       x=linspace(xl(1),xl(2),100); % Limit regression line to range(min,max)
       
       if ~all(isnan(dflong(icurrstudy,:).z_NPSraw))&&~all(isnan(dflong(icurrstudy,:).z_stimInt))
       currfit=fitlm(dflong(icurrstudy,:),'z_stimInt ~ z_rating');
       curry=x.*(currfit.Coefficients.Estimate(2))+(currfit.Coefficients.Estimate(1));

       % for model checking: plot BLUPS from linear mixed model (regression lines predicted by fixed+random effects)
%        currBLUPs=lmerandom.Estimate(strcmp(lmerandom.Level,currstudy));
%        curry=x.*(currBLUPs(2)+fix~edB1)+(currBLUPs(1)+fixedB0);
       plot(x,curry,'LineWidth',1.5,...
           'DisplayName','',...
           'Color',colormapping(i,:),...
           'MarkerEdgeColor',colormapping(i,:),...
           'MarkerFaceColor',colormapping(i,:));
       %[R,P,RL,RU] =corrcoef(c_rating,c_stimInt,'rows','complete');
       %corrs(i)=R(2);
       end
end
xlabel('Standardized Rating')
ylabel('Standardized Stimulus Intensity')
legend show