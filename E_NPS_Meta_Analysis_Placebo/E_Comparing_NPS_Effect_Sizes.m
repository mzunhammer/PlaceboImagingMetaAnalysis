%% Comparison of placebo effects with temperature and remifentanil
% to calculate NPS values for  Krishnan et al. (Heat Pain, 46.0 vs 47.0 vs 48.0?C) and
% Lopez-Sola et al. (Nailbed Pressure Pain, 4.5 kg/cm^2 vs 6.0 kg/cm^2 ).
%
% Standardized Effect of fixed physical stimulus intensity changes
% are calculated and compared with rating changes 
% to put results of the placebo meta-analysis into persepctive.

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('Full_Sample_Study_Level_Results_Placebo.mat')
load('../F_NPS_Meta_Analysis_Validation/Hi_vs_lo_pain_all_study_level_results.mat')
load('../F_NPS_Meta_Analysis_Validation/Remifentanil_Results.mat')

placebo_rating_summary=GIVsummary(stats.rating);
placebo_NPS_summary=GIVsummary(stats.NPS);
placebo_SIIPS_summary=GIVsummary(stats.SIIPS);

%% Zunhammer et al. 2014: Heat
results_zunhammer=load('../../Datasets_for_NPS_effect_size_comparison/Oxytocin_Zunhammer_2014_NPS_SIIPS.mat');
results_zunhammer=results_zunhammer.results;
results_zunhammer.temp=categorical(results_zunhammer.temp);
subIDs=regexp(results_zunhammer.imgs,'.+(\d\d\d\d\d\d).+','tokens');
subIDs=[subIDs{:}]
results_zunhammer.subID=[subIDs{:}]';

% Analyze using Session 1 only:
results_zunhammer_sess1=results_zunhammer(results_zunhammer.session==1,:);

ts=categories(results_zunhammer_sess1.temp);
t_names=matlab.lang.makeValidName(strcat('t',ts))
for i=1:length(ts)
    t{i}=results_zunhammer_sess1(results_zunhammer_sess1.temp==ts{i},{'rating','NPS'});
end
vars={'rating','NPS'}
for i=1:length(vars)
    for j=1:(length(t)-1)
        stats_zunhammer.(vars{i})(j)=withinMetastats(t{j}.(vars{i}),t{j+1}.(vars{i})); 
        t_diff_names{j}=[t_names{j},'-',t_names{j+1}];
    end
end

figure
plot([stats_zunhammer.rating.g],'.')
title('Sess1')
hold on
plot([stats_zunhammer.NPS.g],'.')
hold off
xticklabels(t_diff_names)

%Analyze using both sessions pooled:

results_zunhammer_both=grpstats(results_zunhammer(:,2:end),{'subID','temp'},@mean);
results_zunhammer_both.Properties.VariableNames{'mean_NPS'}='NPS';
results_zunhammer_both.Properties.VariableNames{'mean_rating'}='rating';
ts=categories(results_zunhammer_both.temp);
t_names=matlab.lang.makeValidName(strcat('t',ts))
for i=1:length(ts)
    t{i}=results_zunhammer_both(results_zunhammer_both.temp==ts{i},{'rating','NPS'});
end
vars={'rating','NPS'}
for i=1:length(vars)
    for j=1:(length(t)-1)
        stats_zunhammer.(vars{i})(j)=withinMetastats(t{j}.(vars{i}),t{j+1}.(vars{i})); 
        t_diff_names{j}=[t_names{j},'-',t_names{j+1}];
    end
end

figure
plot([stats_zunhammer.rating.g],'.')
title('Both_Sessions')
hold on
plot([stats_zunhammer.NPS.g],'.')
hold off
xticklabels(t_diff_names)

%%
Y=...
[   placebo_NPS_summary.g.random.summary,... % Placebo effect in g, full sample, random effects summary
    stats_med_vs_lo.nps.g,...
    stats_hi_vs_med.nps.g,...
    stats_6_vs_4pt5.nps.g,...
    -0.985687939740397,... % Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    -1.12975157989753,...  % Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
];

X=(1:length(Y))+0.1;

E=...
[   placebo_NPS_summary.g.random.SEsummary,... % SE of Placebo effect in g, full sample, random effects summary
    stats_med_vs_lo.nps.se_g,...
    stats_hi_vs_med.nps.se_g,...
    stats_6_vs_4pt5.nps.se_g,...
    0.333877843471232,... % SE of Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    0.201771502162592,... % SE of Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
];

E=E*1.96;
errorbar(X,Y,E,'o');

labs=[{{'Placebo treatment', 'full sample', 'random effects analysis'}},...
     {{'Thermode heat reduction', '48 to 47?C', 'Krishnan et al. 2016'}},...
     {{'Thermode heat reduction', '47 to 46?C', 'Krishnan et al. 2016'}},...
     {{'Nailbed pressure reduction', '6.0 to 4.5 kg/cm^2', 'Lopez-Sola et al. 2016'}},...
     {{'Remifentanil treatment', '0.76?ng/ml', 'Atlas et al. 2012'}},...
     {{'Remifentanil treatment', '0.80?ng/ml','Bingel et al. 2011'}}];
set(gca,'xticklabel',[])

for i=1:length(labs)
    text(i,round(min(Y-E),1)-0.22,labs{i},'HorizontalAlignment','center')
end

axis([0 length(labs)+1 round(min(Y-E),1)-0.1 round(max(Y+E),1)+0.1])


hold on

Y_rating=...
[   placebo_rating_summary.g.random.summary,... % Placebo effect in g, full sample, random effects summary
    stats_med_vs_lo.rating.g,...
    stats_hi_vs_med.rating.g,...
    stats_6_vs_4pt5.rating.g,...
    -0.504462733313263,... % Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    -1.09287747555418,...  % Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
];
X=(1:length(Y))-0.1;

E_rating=...
[   placebo_rating_summary.g.random.SEsummary,... % SE of Placebo effect in g, full sample, random effects summary
    stats_med_vs_lo.rating.se_g,...
    stats_hi_vs_med.rating.se_g,...
    stats_6_vs_4pt5.rating.se_g,...
    0.118947320581685,... % SE of Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    0.230077844571065,... % SE of Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
];

E_rating=E_rating*1.96;
errorbar(X,Y_rating,E_rating,'ro');
ylabel('Standardized effect size Hedge''s g with 95% CI ')



figure(1)
errorbar(X,Y_rating,E_rating,'ro');

%% Plot Standardized NPS vs Standardized Rating response (Same figure, 2 axes)

 figure(2)
% First plot effects of changes in stimulus intensity on NPS/ratings in red
stats_hilo=load('../F_NPS_Meta_Analysis_Validation/Hi_vs_lo_pain_all_study_level_results.mat');
stats_hilo=stats_hilo.stats;

 hold on
 x=[[stats_hilo.rating.g]'*-1
     stats_med_vs_lo.rating.g
    stats_hi_vs_med.rating.g
    stats_6_vs_4pt5.rating.g];
 y=[[stats_hilo.NPS.g]'*-1
     stats_med_vs_lo.nps.g
    stats_hi_vs_med.nps.g
    stats_6_vs_4pt5.rating.g];

 xneg=([[stats_hilo.rating.se_g]'
     stats_med_vs_lo.rating.se_g
    stats_hi_vs_med.rating.se_g
    stats_6_vs_4pt5.rating.se_g].*1.96);
 xpos=xneg;
 yneg=([[stats_hilo.NPS.se_g]'
     stats_med_vs_lo.nps.se_g
    stats_hi_vs_med.nps.se_g
    stats_6_vs_4pt5.nps.se_g].*1.96);
 ypos=yneg;
 errorbar(x,y,yneg,ypos,xneg,xpos,'ro')
 plot(x,y,'r.')
 lsline
 
%  x_single=[[vertcat(stats_hilo.rating.std_delta)]*-1
%      vertcat(stats_med_vs_lo.rating.std_delta)
%     vertcat(stats_hi_vs_med.rating.std_delta)
%     vertcat(stats_6_vs_4pt5.rating.std_delta)];
%  y_single=[[vertcat(stats_hilo.NPS.std_delta)]*-1
%      vertcat(stats_med_vs_lo.nps.std_delta)
%     vertcat(stats_hi_vs_med.nps.std_delta)
%     vertcat(stats_6_vs_4pt5.rating.std_delta)];
%  plot(x_single,y_single,'r.')
 
 
%Then plot effects of placebos
statsRating_pla=[stats.rating];
statsNPS_pla=[stats.NPS];
x=[statsRating_pla.g];
y=[statsNPS_pla.g];
yneg=([statsNPS_pla.se_g].*1.96);
ypos=([statsNPS_pla.se_g].*1.96);
xneg=([statsRating_pla.se_g].*1.96);
xpos=([statsRating_pla.se_g].*1.96);
errorbar(x,y,yneg,ypos,xneg,xpos,'bo')
plot(x,y,'b.')
lsline

%  x_single=[vertcat(statsRating_pla.std_delta)];
%  y_single=[vertcat(statsNPS_pla.std_delta)];
%  plot(x_single,y_single,'b.')


% Then plot effects of changes in remifentanil treatment on NPS/ratings in
% green
 x=[ -0.504462733313263,... % Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    -1.09287747555418];  % Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil]);
 y=[ -0.985687939740397,...,... %  Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
        -1.12975157989753]; % Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil]);
 
 xneg=([0.118947320581685,... % SE of Remifentanil effect on Rating in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    0.230077844571065].*1.96);
 xpos=xneg;
 yneg=([0.333877843471232,... % SE of Remifentanil effect on NPS in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    0.201771502162592].*1.96);
 ypos=yneg;
 
 errorbar(x,y,yneg,ypos,xneg,xpos,'go')
 plot(x,y,'g.') 

 
% Then plot effects of changes in temperature for Zunhammer et al.
 x=[stats_zunhammer.rating.g]
 y=[stats_zunhammer.NPS.g]
 
 xneg=([stats_zunhammer.rating.se_g].*1.96);
 xpos=xneg;
 yneg=([stats_zunhammer.NPS.se_g].*1.96);
 ypos=yneg;
 
 errorbar(x,y,yneg,ypos,xneg,xpos,'ko')
 plot(x,y,'k.')  
 lsline
 
hold off
ylabel('Effect on NPS response (Hedges''g)')
xlabel('Effect on pain ratings (Hedges''g)')


%% Plot RATING vs NPS

% Krishnan NPS
mu_NPS=mean([krish_high.NPS;krish_med.NPS;krish_low.NPS]);
mu_Rating=mean([krish_high.Rating; krish_med.Rating; krish_low.Rating]);
mu_SIIPS=mean([krish_high.SIIPS1; krish_med.SIIPS1; krish_low.SIIPS1]);
sd_NPS=std([krish_high.NPS;krish_med.NPS;krish_low.NPS]);
sd_Rating=std([krish_high.Rating; krish_med.Rating; krish_low.Rating]);
sd_SIIPS=std([krish_high.SIIPS1; krish_med.SIIPS1; krish_low.SIIPS1]);

figure(3)
plot((krish_high.Rating-mu_Rating)/sd_Rating,...
      (krish_high.NPS-mu_NPS)/sd_NPS,...
      'r.');
xlabel('Standardized Rating Response')
ylabel('Standardized NPS Response')

hold on
plot((krish_med.Rating-mu_Rating)/sd_Rating,...
     (krish_med.NPS-mu_NPS)/sd_NPS,...
    'b.')
plot((krish_low.Rating-mu_Rating)/sd_Rating,...
    (krish_low.NPS-mu_NPS)/sd_NPS,...
    'g.')

legend('48?C Heat','47?C Heat','46?C Heat')
lsline
hold off
axis([-4 4 -4 4])

% Krishnan SIIPS
figure(4)
plot((krish_high.Rating-mu_Rating)/sd_Rating,...
     (krish_high.SIIPS1-mu_SIIPS)/sd_SIIPS,...
     'r.')
xlabel('Standardized Rating Response')
ylabel('Standardized SIIPS Response')

hold on
plot((krish_med.Rating-mu_Rating)/sd_Rating,...
     (krish_med.SIIPS1-mu_SIIPS)/sd_SIIPS,...
     'b.')
plot((krish_low.Rating-mu_Rating)/sd_Rating,...
     (krish_low.SIIPS1-mu_SIIPS)/sd_SIIPS,...
     'g.')

legend('48?C Heat','47?C Heat','46?C Heat')
lsline
hold off
axis([-4 4 -4 4])


%%  Lopez-Sol? NPS

mu_NPS=mean([NPS4pt5;NPS6]);
mu_Rating=mean([rating4pt5;rating6]);
mu_SIIPS=mean([SIIPS4pt5;SIIPS6]);
sd_NPS=std([NPS4pt5;NPS6]);
sd_Rating=std([rating4pt5;rating6]);
sd_SIIPS=std([SIIPS4pt5;SIIPS6]);


figure(5)
plot((rating6-mu_Rating)/sd_Rating,...
     (NPS6-mu_NPS)/sd_NPS,...
     'r.')
xlabel('Standardized Rating Response')
ylabel('Standardized NPS Response')

hold on
plot((rating4pt5-mu_Rating)/sd_Rating,...
    (NPS4pt5-mu_NPS)/sd_NPS,...
    'b.')

legend('6 kg/cm^2 nailbed pressure','4.5 kg/cm^2 nailbed pressure')
lsline
hold off
axis([-4 4 -4 4])

figure(6)
plot((rating6-mu_Rating)/sd_Rating,...
    (SIIPS6-mu_SIIPS)/sd_SIIPS,...
    'r.')
xlabel('Standardized Rating Response')
ylabel('Standardized SIIPS Response')

hold on
plot((rating4pt5-mu_Rating)/sd_Rating,...
    (SIIPS4pt5-mu_SIIPS)/sd_SIIPS,'b.')

legend('6 kg/cm^2 nailbed pressure','4.5 kg/cm^2 nailbed pressure')
lsline
hold off
axis([-4 4 -4 4])


