%% Placebo-response (ratings) vs placebo-response NPS

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/A_Analysis_GIV_Functions/')
% Uses boundedline toolbox to generate shaded confidence bounds for
% regression lines: https://de.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m
addpath(genpath('/Users/matthiaszunhammer/Documents/MATLAB/boundedline/'))
load('A1_Full_Sample.mat')

% !!!!! These must be in the same order as listed under "studies" !!!!

% studyIDtexts={
%             'Atlas et al. 2012: Hidden vs open remifentanil drip infusion (expectation period)| heat';...
% 			'Bingel et al. 2006: Control vs placebo cream | laser';...
% 			'Bingel et al. 2011: No vs positive expectations | heat';...
% 			'Choi et al. 2011: No vs low & high effective placebo drip infusion (Exp1 and 2) | electrical';...
% 			'Eippert et al. 2009: Control vs placebo cream (saline & naloxone group) | heat (early & late)';...
% 			'Ellingsen et al. 2013: Pre vs post placebo nasal spray | heat';...
%             'Elsenbruch et al. 2012: No vs certain placebo drip infusion | distension';...
%             'Freeman et al. 2015: Control vs placebo cream | heat';...
%             'Geuter et al. 2013: Control vs weak & strong placebo cream | heat (early & late)';...
%             'Huber et al. 2013: Red vs green cue signifying sham TENS off vs on | laser';...
%             'Kessner et al. 2014: Negative vs positive treatment expectation group | heat';...
%             'Kong et al. 2006: Control vs placebo acupuncture | heat (high & low)';...
%             'Kong et al. 2009: Control vs placebo sham acupuncture | heat';...
%             'Ruetgen et al. 2015: No treatment vs placebo pill group  | electrical'
%             'Schenk et al. 2015:  Control vs placebo (saline & lidocain) | heat'
%             'Theysohn et al. 2009: No vs certain placebo drip infusion | distension';...
%             'Wager et al. 2004, Study 1: Control vs placebo cream | heat*';...
%             'Wager et al. 2004, Study 2: Control vs placebo cream | electrical*';...
%             'Wrobel et al. 2014: Control vs placebo cream (saline & haldol group) | heat(early & late)'
%             'Zeidan et al. 2015: Control vs placebo cream (placebo group) | heat*';...
%             };

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
            'Huber et al. 2013';...
            'Kessner et al. 2014';...
            'Kong et al. 2006';...
            'Kong et al. 2009';...
            'Ruetgen et al. 2015'
            'Schenk et al. 2015'
            'Theysohn et al. 2009';...
            'Wager et al. 2004, Study 1';...
            'Wager et al. 2004, Study 2';...
            'Wrobel et al. 2014'
            'Zeidan et al. 2015';...
            };
%% First calculate meta-stats as usual for ratings
v=find(strcmp(df_full.variables,'rating'));
for i=1:length(df_full.studies) % Calculate for all studies except...
    if df_full.consOnlyRating(i)==0 %...data-sets where both pla and con is available
        if df_full.BetweenSubject(i)==0 %Within-subject studies
           stats.rating(i)=withinMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
        elseif df_full.BetweenSubject(i)==1 %Between-subject studies
           stats.rating(i)=betweenMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
        end        
    end
end
% Calculate for those studies where only pla>con contrasts are available
conOnly=find(df_full.consOnlyRating==1);
impu_r=nanmean([stats.rating.r]); % impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
stats.rating(i)=withinMetastats(df_full.pladata{i}(:,v),impu_r);
end

%% Second calculate meta-stats as usual for NPS
v=find(strcmp(df_full.variables,'NPSraw'));
for i=1:length(df_full.studies) % Calculate for all studies except...
    if df_full.consOnlyNPS(i)==0 %...data-sets where both pla and con is available
        if df_full.BetweenSubject(i)==0 %Within-subject studies
           stats.NPS(i)=withinMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
        elseif df_full.BetweenSubject(i)==1 %Between-subject studies
           stats.NPS(i)=betweenMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
        end        
    end
end
% Calculate for those studies where only pla>con contrasts are available
conOnly=find(df_full.consOnlyNPS==1);
impu_r=nanmean([stats.NPS.r]); % impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
stats.NPS(i)=withinMetastats(df_full.pladata{i}(:,v),impu_r);
end

%% Third calculate meta-stats as usual for MHE
v=find(strcmp(df_full.variables,'MHEraw'));
for i=1:length(df_full.studies) % Calculate for all studies except...
    if df_full.consOnlyNPS(i)==0 %...data-sets where both pla and con is available
        if df_full.BetweenSubject(i)==0 %Within-subject studies
           stats.MHE(i)=withinMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
        elseif df_full.BetweenSubject(i)==1 %Between-subject studies
           stats.MHE(i)=betweenMetastats(df_full.pladata{i}(:,v),df_full.condata{i}(:,v));
        end        
    end
end
% Calculate for those studies where only pla>con contrasts are available
conOnly=find(df_full.consOnlyNPS==1);
impu_r=nanmean([stats.MHE.r]); % impute the mean within-subject study correlation observed in all other studies
for i=conOnly'
stats.MHE(i)=withinMetastats(df_full.pladata{i}(:,v),impu_r);
end

%% Fixed effects analysis
WIstudies=[df_full.studies(df_full.BetweenSubject~=1)];
WIratings=[stats.rating(df_full.BetweenSubject~=1)];
WINPS=[stats.NPS(df_full.BetweenSubject~=1)];
WINMHE=[stats.MHE(df_full.BetweenSubject~=1)];


rating=vertcat(WIratings.std_delta);
NPS=vertcat(WINPS.std_delta);
MHE=vertcat(WINMHE.std_delta);

subjID=(1:length(rating))';
studyID=cell(0);
for i=1:length(WIstudies)
    n=length(WIratings(i).std_delta);
    studyID=vertcat(studyID, repmat(WIstudies(i),n,1));
end

df_lm=table(studyID,subjID,rating,NPS,MHE);
df_lm=df_lm(~(isnan(df_lm.rating)|isnan(df_lm.NPS)),:);
df_lm.studyID=categorical( df_lm.studyID);
df_lm.rating=double( df_lm.rating);
df_lm.NPS=double( df_lm.NPS);
df_lm.MHE=double( df_lm.MHE);

%% Linear model analysis
mdl0 = fitlm(df_lm,'rating ~ studyID');
mdl1 = fitlm(df_lm,'rating ~ studyID+NPS');

%% Mixed model analysis
mmdl0 = fitlme(df_lm,'rating ~ 1+(1+NPS|studyID)',...
              'CheckHessian',true)
mmdl1 = fitlme(df_lm,'rating ~ NPS+(1+NPS|studyID)',...
              'CheckHessian',true)
          
compare(mmdl0,mmdl1)
anova(mmdl1)
[~,~,lmefixed] =  fixedEffects(mmdl1);
[~,~,lmerandom] = randomEffects(mmdl1);

%% Plot standardized single-subject delta ratings vs NPS
% This is only possible for within-subject studies
% Plot single-study values
figure('units','normalized','position',[0 0 1.5 sqrt(1.5)]);
colormap jet
hold on
for i=1:length(df_full.studies) % Calculate for all studies except...
    if df_full.BetweenSubject(i)==0 %ONLY Within-subject studies
       
       c_rating=stats.rating(i).std_delta;
       c_NPS=stats.NPS(i).std_delta;
       plot(c_rating,c_NPS,'.',...
           'MarkerSize',5,...
           'DisplayName',studyIDtexts{i});
       xlabel('Standardized rating difference (placebo-control)')
       ylabel('Standardized NPS difference (placebo-control)')
       [R,P,RL,RU] =corrcoef(c_rating,c_NPS,'rows','complete');
       corrs(i)=R(2);
    end        
end

%lsline
legend show

% Add fixed effects predictions from lm with confidence interval
%[ypred,ypredCI]=predict(mdl1,x);

%plot(df_lm.NPS,ypred, '-black')
%X=[df_lm.NPS,fliplr(df_lm.NPS)];
%Y=[ypredCI(1,:)',fliplr(ypredCI(2,:)')];
%fill(X,Y,'bl','facealpha',0.2)
%fill([x,yci(1,:)],[x,yci(2,:)],'r')
%[l,p]=boundedline(x', y', yci', '-black','alpha');
%outlinebounds(l,p);


%Plot single study lines...
fixedB0=lmefixed.Estimate(1);
fixedB1=lmefixed.Estimate(2);
for i=1:length(df_full.studies) % Calculate for all studies except...
    if df_full.BetweenSubject(i)==0
       currstudy=df_full.studies(i);
       xl=[min(stats.rating(i).std_delta);max(stats.rating(i).std_delta)];
       x=linspace(xl(1),xl(2),100);
       %plot BLUPS from linear mixed model
%        currBLUPs=lmerandom.Estimate(strcmp(lmerandom.Level,currstudy));
%        curry=x.*(currBLUPs(2)+fixedB1)+(currBLUPs+fixedB0);
%        plot(x,curry,'LineWidth',1.5)
       %plot observed OLS
       currfit=fitlm(df_lm(df_lm.studyID==currstudy{:},:),'rating ~ NPS');
       curry=x.*(currfit.Coefficients.Estimate(2))+(currfit.Coefficients.Estimate(1));
       plot(x,curry,'LineWidth',1.5);
    end
end

% Plot overall fixed effects regression line
xl=[min(vertcat(stats.rating(:).std_delta))
       max(vertcat(stats.rating(:).std_delta))];
x=linspace(xl(1),xl(2),100);
overally=x.*(fixedB1)+(fixedB0);
plot(x,overally,'--black','LineWidth',2.5)


% Make graph prettier
xticks(-4:2:4)
yticks(-5:2:5)

hold off


hgexport(gcf, ['C_Ratings_vs_NPS.svg'], hgexport('factorystyle'), 'Format', 'svg'); 
