% Script to calculate NPS values for  Krishnan et al. (Heat Pain, 46.0 vs 47.0 vs 48.0?C) and
% Lopez-Sola et al. (Nailbed Pressure Pain, 4.5 kg/cm^2 vs 6.0 kg/cm^2 ).
%
% Standardized Effect of fixed physical stimulus intensity changes
% are calculated and compared with rating changes 
% to put results of the placebo meta-analysis into persepctive.

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
load('Full_Sample_Study_Level_Results_Placebo.mat')
placebo_rating_summary=GIVsummary(stats.rating);
placebo_NPS_summary=GIVsummary(stats.NPS);
placebo_SIIPS_summary=GIVsummary(stats.SIIPS);

%% Krishnan et al. 2017: Heat
load('../../Datasets_for_NPS_effect_size_comparison/2016_Krishnan_VPS_eLife/data/heat_LMH.mat')

high_name=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(heathigh_vs_rest.Y_names));
med_name=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(heatmed_vs_rest.Y_names));
low_name=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(heatlow_vs_rest.Y_names));

krish_high=array2table(heathigh_vs_rest.Y,'VariableNames',high_name);
krish_med=array2table(heatmed_vs_rest.Y,'VariableNames',med_name);
krish_low=array2table(heatlow_vs_rest.Y,'VariableNames',low_name);

stats_hi_vs_med.nps=withinMetastats(krish_med.NPS,krish_high.NPS);
stats_hi_vs_med.rating=withinMetastats(krish_med.Rating,krish_high.Rating);

stats_med_vs_lo.nps=withinMetastats(krish_low.NPS,krish_med.NPS);
stats_med_vs_lo.rating=withinMetastats(krish_low.Rating,krish_med.Rating);

sprintf(['Effect Size (Hedge''s g) of Temperature difference 48 vs 47?C on NPS: ',...
        '%0.2g +- %0.2g'],stats_hi_vs_med.nps.g,stats_hi_vs_med.nps.se_g)
sprintf(['Effect Size (Hedge''s g) of Temperature difference 47 vs 46?C on NPS: ',...
        '%0.2g +- %0.2g'],stats_med_vs_lo.nps.g,stats_med_vs_lo.nps.se_g)

sprintf(['Effect Size (Hedge''s g) of Temperature difference 48 vs 47?C on Rating: ',...
        '%0.2g +- %0.2g'],stats_hi_vs_med.rating.g,stats_hi_vs_med.rating.se_g)
sprintf(['Effect Size (Hedge''s g) of Temperature difference 47 vs 46?C on Rating: ',...
        '%0.2g +- %0.2g'],stats_med_vs_lo.rating.g,stats_med_vs_lo.rating.se_g)

corrcoef(stats_med_vs_lo.rating.std_delta,stats_med_vs_lo.nps.std_delta)
corrcoef(stats_hi_vs_med.rating.std_delta,stats_hi_vs_med.nps.std_delta)

%% Lopez-Sola et al. 2017: Pressure

load('../../Datasets_for_NPS_effect_size_comparison/2016_Marina_FMstudy_PRESSUREPAIN/results/image_names_and_setup.mat');


NPS4pt5=DAT.SIG_conditions.raw.dotproduct.NPS.Controls_4pt5_kgPress;
NPS6=DAT.SIG_conditions.raw.dotproduct.NPS.Controls_6_kgPress;
SIIPS4pt5=DAT.SIG_conditions.raw.dotproduct.SIIPS.Controls_4pt5_kgPress;
SIIPS6=DAT.SIG_conditions.raw.dotproduct.SIIPS.Controls_6_kgPress;


stats_6_vs_4pt5.nps=withinMetastats(NPS4pt5,NPS6);

rating6=xlsread('../../Datasets_for_NPS_effect_size_comparison/2016_Marina_FMstudy_PRESSUREPAIN/data/ControlsFM_PainRatings.xlsx','B2:B30');
rating4pt5=xlsread('../../Datasets_for_NPS_effect_size_comparison/2016_Marina_FMstudy_PRESSUREPAIN/data/ControlsFM_PainRatings.xlsx','D2:D30');
stats_6_vs_4pt5.rating=withinMetastats(rating4pt5,rating6);



sprintf(['Effect Size (Hedge''s g) of nailbed pressure difference 6 vs 4.5 km/cm^2 on NPS: ',...
        '%0.2g +- %0.2g'],stats_6_vs_4pt5.nps.g,stats_6_vs_4pt5.nps.se_g)
sprintf(['Effect Size (Hedge''s g) of nailbed pressure difference 6 vs 4.5 km/cm^2 on Ratings: ',...
        '%0.2g +- %0.2g'],stats_6_vs_4pt5.rating.g,stats_6_vs_4pt5.rating.se_g)

corrcoef(stats_6_vs_4pt5.rating.std_delta,stats_6_vs_4pt5.nps.std_delta)

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
 x=[%[stats_hilo.rating.g]'
     stats_med_vs_lo.rating.g
    stats_hi_vs_med.rating.g
    stats_6_vs_4pt5.rating.g];
 y=[%[stats_hilo.NPS.g]'
     stats_med_vs_lo.nps.g
    stats_hi_vs_med.nps.g
    stats_6_vs_4pt5.rating.g];

 xneg=([%[stats_hilo.rating.se_g]'
     stats_med_vs_lo.rating.se_g
    stats_hi_vs_med.rating.se_g
    stats_6_vs_4pt5.rating.se_g].*1.96);
 xpos=xneg;
 yneg=([%[stats_hilo.NPS.se_g]'
     stats_med_vs_lo.nps.se_g
    stats_hi_vs_med.nps.se_g
    stats_6_vs_4pt5.nps.se_g].*1.96);
 ypos=yneg;
 errorbar(x,y,yneg,ypos,xneg,xpos,'ro')
 plot(x,y,'r.')
 
 
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

% Then plot effects of changes in remifentanil treatment on NPS/ratings in
% green
 x=[ -0.504462733313263,... % Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    -1.09287747555418]  % Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil]);
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


