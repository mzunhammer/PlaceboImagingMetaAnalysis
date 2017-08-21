%% Placebo-response (ratings) vs placebo-response NPS

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
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
            'Kessner et al. 2014';...
            'Kong et al. 2006';...
            'Kong et al. 2009';...
            'Lui et al. 2010';...
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

summary=GIVsummary(stats.rating,'g');

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
var0=var(df_lm.rating)
mmdl0 = fitlme(df_lm,'rating ~ 1',...
              'CheckHessian',true);
mmdl_randintercept = fitlme(df_lm,'rating ~ 1+(1|studyID)',...
              'CheckHessian',true);
mmdl_randslope = fitlme(df_lm,'rating ~ 1+(1+NPS|studyID)',...
              'CheckHessian',true);
mmdl_full = fitlme(df_lm,'rating ~ NPS+(1+NPS|studyID)',...
              'CheckHessian',true)
          
compare(mmdl_randslope,mmdl_full)
anova(mmdl_full)
[~,~,lmefixed] =  fixedEffects(mmdl_full);
[~,~,lmerandom] = randomEffects(mmdl_full);
fixedB0=lmefixed.Estimate(1);
fixedB1=lmefixed.Estimate(2);

% The R^2 estimates from MATLABs fitlme do not match what is described by 
% Nakagawa & Schielzeth 2013 and Johnson 2014

% >> Export table and use marginal and conditional R^2 obtained with lmer4 and MuMIn in R
writetable(df_lm);

% >> Rmarginal obtained by MuMIn was 0.03960617
% Converting to g according to Borenstein
% % Estimating effect size of association 
 R2marginal=0.03960617; 
 r_marginal=sqrt(R2marginal);
 d_marginal=2*r_marginal./sqrt(1-R2marginal);
 J=1-(3./(4.* 458-1));
 g_marginal=d_marginal.*J;
 disp(['Marginal (fixed effects only) R^2: ',num2str(R2marginal),' , corresponding g = ', num2str(g_marginal)])


%% Plot standardized single-subject delta ratings vs NPS
% This is only possible for within-subject studies
% Plot single-study values
figure('units','normalized','position',[0 0 1.5 sqrt(1.5)]);
colormapping=brighten(cbrewer('qual','Accent',20),-0.1);
hold on
for i=1:length(df_full.studies) % Calculate for all studies except...
    if df_full.BetweenSubject(i)==0 %ONLY Within-subject studies
       %Get current studyname & standardized ratings, NPS values
       currstudy=df_full.studies(i);
       c_rating=stats.rating(i).std_delta;
       c_NPS=stats.NPS(i).std_delta;
       %Plot single data-points
       plot(c_NPS,c_rating,'.',...
           'MarkerSize',5,...
           'DisplayName',studyIDtexts{i},...
           'MarkerEdgeColor',colormapping(i,:),...
           'MarkerFaceColor',colormapping(i,:));
       %Plot simple regression lines
       xl=[min(c_NPS);max(c_NPS)]; % Limit regression line to range(min,max)
       x=linspace(xl(1),xl(2),100); % Limit regression line to range(min,max)
       
       currfit=fitlm(df_lm(df_lm.studyID==currstudy{:},:),'rating ~ NPS');
       curry=x.*(currfit.Coefficients.Estimate(2))+(currfit.Coefficients.Estimate(1));
       % for model checking: plot BLUPS from linear mixed model (regression lines predicted by fixed+random effects)
%        currBLUPs=lmerandom.Estimate(strcmp(lmerandom.Level,currstudy));
%        curry=x.*(currBLUPs(2)+fixedB1)+(currBLUPs(1)+fixedB0);
       plot(x,curry,'LineWidth',1.5,...
           'DisplayName','',...
           'Color',colormapping(i,:),...
           'MarkerEdgeColor',colormapping(i,:),...
           'MarkerFaceColor',colormapping(i,:));
       [R,P,RL,RU] =corrcoef(c_NPS,c_rating,'rows','complete');
       corrs(i)=R(2);
    end        
end
xlabel('Standardized NPS difference (placebo-control)')
ylabel('Standardized rating difference (placebo-control)')
legend show

R_overall=corrcoef(df_lm.rating,df_lm.NPS)
disp(['Overall correlation: ', num2str(R_overall(2))])
disp(['Mean correlation: ', num2str(mean(corrs(i)))])

% Plot overall fixed effects regression line
xl=[min(vertcat(stats.NPS(:).std_delta))
       max(vertcat(stats.NPS(:).std_delta))];
x=linspace(xl(1),xl(2),100);
overally=x.*(fixedB1)+(fixedB0);
plot(x,overally,'--black','LineWidth',2.5)

line([-4,4],repmat(mean(df_lm.rating),2,1))
line(repmat(mean(df_lm.NPS),2,1),[-4,4])

% Make graph prettier
xticks(-4:2:4)
yticks(-4:2:4)
 
hold off


%hgexport(gcf, ['C_Ratings_vs_NPS.svg'], hgexport('factorystyle'), 'Format', 'svg'); 
pubpath='../../Protocol_and_Manuscript/NPS_placebo/NEJM/Figures/';
hgexport(gcf, fullfile(pubpath,'C_Ratings_vs_NPS.svg'), hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, fullfile(pubpath,'C_Ratings_vs_NPS.png'), hgexport('factorystyle'), 'Format', 'png');

crop(fullfile(pubpath,'C_Ratings_vs_NPS.png'));



%% Additionally: Regression analysis based on NPS and Rating data (not difference scores)

studyID=[];
subID=[];
treat=[];
data=[];
zdata=[];
std_data=[];
for i=1:length(df_full.studies)
    if ~(df_full.consOnlyNPS(i)||df_full.consOnlyRating(i)) %Studies for which only contrasts are available are of no use here
        n_con=size(df_full.condata{1,i},1);
        n_pla=size(df_full.pladata{1,i},1);
        n=n_con+n_pla;
        studyID=vertcat(studyID, repmat(df_full.studies(i),n,1));
        if df_full.BetweenSubject(i)
           subID= vertcat(subID,[1:n]');
        else
           subID= vertcat(subID,[(1:n_con)';(1:n_pla)']);
        end
        treat=vertcat(treat,[zeros(n_con,1);ones(n_pla,1)]);
        data=vertcat(data,[df_full.condata{1,i};df_full.pladata{1,i}]);
        zdata=vertcat(zdata,[nanzscore(df_full.condata{1,i});nanzscore(df_full.pladata{1,i})]);
        std_data=vertcat(std_data,[df_full.condata{1,i}./nanstd(df_full.condata{1,i});
                                   df_full.pladata{1,i}./nanstd(df_full.pladata{1,i})]);
    end
end

dfl=table(studyID);
dfl=[dfl,table(subID)];
dfl=[dfl,table(treat)];
dfl=[dfl,array2table(data,'VariableNames',df_full.variables)];
dfl=[dfl,array2table(zdata,'VariableNames',strcat('z_',df_full.variables))];
dfl=[dfl,array2table(std_data,'VariableNames',strcat('s_',df_full.variables))];
dfl.subID=strrep(strcat(dfl.studyID,num2str(dfl.subID)),' ','_');

plot(dfl.z_rating(dfl.treat==0),dfl.z_NPSraw(dfl.treat==0),'.k')
lsline
hold on
plot(dfl.z_rating(dfl.treat==1),dfl.z_NPSraw(dfl.treat==1),'.b')
lsline
hold off

%% Plot with lm lines
studies=unique(dfl.studyID);
figure
hold on
for i=1:numel(studies) % Calculate for all studies except...  
    %Get current studyname & standardized ratings, NPS values
       for currtreat=[0,1]
       currstudy=studies(i);
       rating101=dfl.rating101(strcmp(dfl.studyID,currstudy)&dfl.treat==currtreat);
       NPS=dfl.s_NPSraw(strcmp(dfl.studyID,currstudy)&dfl.treat==currtreat);
       %Plot single data-points
       c=[0,0,1*currtreat];
        plot(rating101,NPS,'.',...
               'MarkerSize',5,...
               'DisplayName',studyIDtexts{i},...
               'MarkerEdgeColor',c,...
               'MarkerFaceColor',c);   
       %Plot simple regression lines
       xl=[min(rating101);max(rating101)]; % Limit regression line to range(min,max)
       x=linspace(xl(1),xl(2),100); % Limit regression line to range(min,max)
       
       currfit=fitlm(rating101,NPS);
       curry=x.*(currfit.Coefficients.Estimate(2))+(currfit.Coefficients.Estimate(1));
       % for model checking: plot BLUPS from linear mixed model (regression lines predicted by fixed+random effects)
%        currBLUPs=lmerandom.Estimate(strcmp(lmerandom.Level,currstudy));
%        curry=x.*(currBLUPs(2)+fixedB1)+(currBLUPs(1)+fixedB0);
       plot(x,curry,'LineWidth',1.5,...
           'DisplayName','',...
           'Color',c,...
           'MarkerEdgeColor',c,...
           'MarkerFaceColor',c);
    end        
end
hold off
%%
mmdl0 = fitlme(dfl,'s_rating ~ 1',...
              'CheckHessian',true);
mmdl_randintercept = fitlme(dfl,'s_rating ~ 1+(1|studyID:subID)',...
              'CheckHessian',true);
mmdl_randslope = fitlme(dfl,'z_rating ~ 1+(1+z_NPSraw|studyID:subID)',...
              'CheckHessian',true);

mmdl_NPS_like_meta = fitlme(dfl,'s_NPSraw ~ 1+treat+(1+treat|studyID)+(1|subID)',...
              'CheckHessian',true); % The mixed model estimates an even smaller effect of placebo treatment (-.045) ... but note that it excludes contrast-only studies.    
 
          
mmdl_full = fitlme(dfl,'rating101 ~ 1+s_NPSraw+treat+s_NPSraw:treat+(1+s_NPSraw|studyID:subID)',...
              'CheckHessian',true);
mmdl_full1 = fitlme(dfl,'rating101 ~ 1+s_NPSraw+treat+s_NPSraw:treat+(1+s_NPSraw|studyID)+(1|subID)',...
              'CheckHessian',true);

mmdl_full2 = fitlme(dfl,'rating101 ~ 1+s_NPSraw+treat+s_NPSraw:treat+(1+s_NPSraw|studyID)+(1+s_NPSraw|studyID:subID)',...
              'CheckHessian',true);
compare(mmdl_full,mmdl_full1)
compare(mmdl_full,mmdl_full2)
compare(mmdl_full1,mmdl_full2)