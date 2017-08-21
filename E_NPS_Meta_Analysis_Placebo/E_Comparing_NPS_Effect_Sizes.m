% Script to calculate NPS values for  Krishnan et al. (Heat Pain, 46.0 vs 47.0 vs 48.0?C) and
% Lopez-Sola et al. (Nailbed Pressure Pain, 4.5 kg/cm^2 vs 6.0 kg/cm^2 ).
%
% Standardized Effect of fixed physical stimulus intensity changes
% are calculated and compared with rating changes 
% to put results of the placebo meta-analysis into persepctive.

clear
% Add folder with Generic Inverse Variance Methods Functions first
addpath('../A_Analysis_GIV_Functions/')
%load('A1_Full_Sample.mat')


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
stats_6_vs_4pt5.nps=withinMetastats(DAT.npsresponse{1,3},DAT.npsresponse{1,4});

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
[   -0.082060860341652,... % Placebo effect in g, full sample, random effects summary
    stats_med_vs_lo.nps.g,...
    stats_hi_vs_med.nps.g,...
    stats_6_vs_4pt5.nps.g,...
    -0.985687939740397,... % Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    -1.12975157989753,...  % Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
];

X=(1:length(Y))+0.1;

E=...
[   0.037550776862540,... % SE of Placebo effect in g, full sample, random effects summary
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
[   -0.664132862751750,... % Placebo effect in g, full sample, random effects summary
    stats_med_vs_lo.rating.g,...
    stats_hi_vs_med.rating.g,...
    stats_6_vs_4pt5.rating.g,...
    -0.504462733313263,... % Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    -1.09287747555418,...  % Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
];
X=(1:length(Y))-0.1;

E_rating=...
[   0.068836787342458,... % SE of Placebo effect in g, full sample, random effects summary
    stats_med_vs_lo.rating.se_g,...
    stats_hi_vs_med.rating.se_g,...
    stats_6_vs_4pt5.rating.se_g,...
    0.118947320581685,... % SE of Remifentanil effect in g, Atlas et al. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
    0.230077844571065,... % SE of Remifentanil effect in g, Bingel et al 2011. See: Analysis/F_NPS_Meta_Analysis_Validation/E1_NPS_remifentanil
];

E_rating=E_rating*1.96;
errorbar(X,Y_rating,E_rating,'ro');
ylabel('Standardized effect size Hedge''s g with 95% CI ')