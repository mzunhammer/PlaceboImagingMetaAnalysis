%% Placebo-response (ratings) vs placebo-response NPS
clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
load('G_dflong.mat')

dflong=dflong(~isnan(dflong.rating101),:);
dflong=dflong(~dflong.ex_lo_p_ratings,:);

%% Pre-processing

% Calculate by-study z-Scores for NPS, stimInt and rating to
% to even out scaling differences  (mean-centered, standardized by SD)
vars2zscore={'NPSraw','MHEraw',...%'PPR_pain_raw','PPR_anti_raw','brainPPR_anti_raw',...
             'rating','stimInt'};
studies=unique(dflong.studyID);
for i=1:length(studies)
    icurrstudy=strcmp(dflong.studyID,studies{i});
    z=nanzscore(dflong{icurrstudy,vars2zscore});
    z(isinf(z))=0;
    z=double(z);
    dflong(icurrstudy,strcat('z_',vars2zscore))=array2table(z);    
end

% Calculate by-study standardized effect sizes for NPS, stimInt and rating to
% to even out scaling differences  (standardized by SD)
vars2stand={'NPSraw','MHEraw',...%'PPR_pain_raw','PPR_anti_raw','brainPPR_anti_raw',...
             'rating','stimInt'};
studies=unique(dflong.studyID);
for i=1:length(studies)
    icurrstudy=strcmp(dflong.studyID,studies{i});
    d=dflong{icurrstudy,vars2stand}./nanstd(dflong{icurrstudy,vars2stand});
    d(isinf(d))=0;
    d=double(d);
    dflong(icurrstudy,strcat('d_',vars2stand))=array2table(d);    
end

% Create a dummy-coded variable for all studies using placebo conditioning
dflong.suggestions=~cellfun(@isempty,regexp(dflong.plaInduct,'Suggestions'));
dflong.conditioning=~cellfun(@isempty,regexp(dflong.plaInduct,'Conditioning'));

% Create a dummy-coded variable for placebo type (only placebo-types used in more than 1 study are included)
rareplas=strcmp(dflong.plaForm,'Nasal spray')|strcmp(dflong.plaForm,'TENS')|strcmp(dflong.plaForm,'Pill');
dflong.plaForm_red=dflong.plaForm;
dflong.plaForm_red(rareplas)={'other'};

% Reduce imaging session numbers to 1 vs >1 
dflong.condSeq12=dflong.condSeq-1;
dflong.condSeq12(dflong.condSeq12>0)=1;

% Reduce stimside to left, right ,both/neither
dflong.stimsideLR=dflong.stimside;
dflong.stimsideLR(~(strcmp(dflong.stimside,'L')|strcmp(dflong.stimside,'R')))={'both_or_midline'};

% Reduce loc to upper-extremty (arm, hand) vs rest
dflong.stimlocUpperEx=~cellfun(@isempty,regexp(dflong.stimloc,'arm'));

% Center, standardize (across whole sample) to obtain standardized results
% and to avoid non-convergence
dflong.age=nanzscore(dflong.age);

%% 1) Mixed model analysis of NPS raw values. Reasons for scaling differences

% Random intercepts for subjects nested within studies

mx_NPSraw_0 = fitlme(dflong,'NPSraw ~ 1+(1|studyID)+(1|studyID:subID)',...
              'CheckHessian',true)
mx_NPSraw_fs = fitlme(dflong,'NPSraw ~ fieldStrength+(1|studyID)+(1|studyID:subID)',...
              'CheckHessian',true)
mx_NPSraw_te = fitlme(dflong,'NPSraw ~ te+(1|studyID)+(1|studyID:subID)',...
              'CheckHessian',true)
mx_NPSraw_tr = fitlme(dflong,'NPSraw ~ tr+(1|studyID)+(1|studyID:subID)',...
              'CheckHessian',true)
mx_NPSraw_vxA = fitlme(dflong,'NPSraw ~ voxelVolAcq+(1|studyID)+(1|studyID:subID)',...
              'CheckHessian',true)
mx_NPSraw_xSpan0 = fitlme(dflong,'NPSraw ~ 1+(xSpan-1|studyID)+(1|studyID:subID)',...
              'CheckHessian',true)
mx_NPSraw_xSpan = fitlme(dflong,'NPSraw ~ xSpan+(xSpan-1|studyID)+(1|studyID:subID)',...
              'CheckHessian',true)
mx_NPSraw_xSpan_r_slope = fitlme(dflong,'NPSraw ~ nImages+(1|studyID)+(1|studyID:subID)',...
              'CheckHessian',true)                 
compare(mx_NPSraw_xSpan0,mx_NPSraw_xSpan,'CheckNesting',true)
%% Mixed model analysis of ratings
% ACHTUNG! Ratings/NPS values values were z-Transformed on a by-study level to
% account for (drastic) scaling differences between studies. Therefore the
% mean of those variables is 0 for all studies >> Random intercepts of
% studies cannot be estimated (since these are 0)
mmdlr0 = fitlme(dflong,'z_rating ~ z_stimInt+pla+age+(1|subID)+(pla-1|studyID)',...
              'CheckHessian',true);
mmdlr1 = fitlme(dflong,'z_rating ~ stimtype+(1|subID)+(pla-1|studyID)',...
              'CheckHessian',true)
mmdlr2 = fitlme(dflong,'z_rating ~ plaForm_red+plaFirst*pla*conditioning+(1|subID)',...
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


%%

dfbyID=grpstats(dflong,'studyID',{'nanmean','nanvar'},'DataVars',{'NPSraw_ci','nImages','nBlocks','imgsPerBlock'});