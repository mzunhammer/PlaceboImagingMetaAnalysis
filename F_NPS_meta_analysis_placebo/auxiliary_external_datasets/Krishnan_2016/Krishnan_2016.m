%% Krishnan et al. 2016: Heat
load('../../../../Datasets_for_NPS_effect_size_comparison/2016_Krishnan_VPS_eLife/data/heat_LMH.mat')

temp_steps={ 
           sprintf('46.0 vs 47.0%cC',char(176))
           sprintf('47.0 vs 48.0%cC',char(176))
           };

temp_step_summary={sprintf('Average of 1%cC heat decreases',char(176))
                    };   
%% Import data from data struct supplied by Krishnan et al. 
high_name=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(heathigh_vs_rest.Y_names));
med_name=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(heatmed_vs_rest.Y_names));
low_name=matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(heatlow_vs_rest.Y_names));

krish_high=array2table(heathigh_vs_rest.Y,'VariableNames',high_name);
krish_med=array2table(heatmed_vs_rest.Y,'VariableNames',med_name);
krish_low=array2table(heatlow_vs_rest.Y,'VariableNames',low_name);

%% Calculate MetaStats
krish_stats.nps(1)=withinMetastats(krish_low.NPS,krish_med.NPS);
krish_stats.nps(2)=withinMetastats(krish_med.NPS,krish_high.NPS);

krish_stats.rating(1)=withinMetastats(krish_low.Rating,krish_med.Rating);
krish_stats.rating(2)=withinMetastats(krish_med.Rating,krish_high.Rating);

save('Krishnan_2016_Temperature_Effects.mat','krish_stats');
%% Forest plots for ratings and NPS
% Do not calculate GIV summary... all conditions are from
% the same study, therefore this is not the appropriate!
ForestPlotter([krish_stats.rating],...
                  'studyIDtexts',temp_steps,...
                  'outcomelabel','Rating difference (Hedges'' g)',...
                  'type','fixed',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0,...
                  'NOsummary',1,...
                  'Xscale',2);
hgexport(gcf, 'Krishnan_2016_Rating.svg', hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, 'Krishnan_2016_Rating.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('Krishnan_2016_Rating.png');

ForestPlotter([krish_stats.nps],...
                  'studyIDtexts',temp_steps,...
                  'outcomelabel','NPS difference (Hedges'' g)',...
                  'type','fixed',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',1,...
                  'textoffset',0,...
                  'NOsummary',1,...
                  'Xscale',2);
hgexport(gcf, 'Krishnan_2016_NPS.svg', hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, 'Krishnan_2016_NPS.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('Krishnan_2016_NPS.png');

%% Print Results as text
ciLo=krish_stats.nps(2).g+1.96*krish_stats.nps(2).se_g;
ciHi=krish_stats.nps(2).g-1.96*krish_stats.nps(2).se_g;
sprintf(['Effect Size (Hedge''s g) of Temperature difference 48 vs 47?C on NPS: ',...
        '%0.2g 95%% CI [%0.2g, %0.2g]'],krish_stats.nps(2).g,ciLo,ciHi)
ciLo=krish_stats.nps(1).g+1.96*krish_stats.nps(1).se_g;
ciHi=krish_stats.nps(1).g-1.96*krish_stats.nps(1).se_g;
sprintf(['Effect Size (Hedge''s g) of Temperature difference 47 vs 46?C on NPS: ',...
        '%0.2g 95%% CI [%0.2g, %0.2g]'],krish_stats.nps(1).g,ciLo,ciHi)
ciLo=krish_stats.rating(2).g+1.96*krish_stats.rating(2).se_g;
ciHi=krish_stats.rating(2).g-1.96*krish_stats.rating(2).se_g;
sprintf(['Effect Size (Hedge''s g) of Temperature difference 48 vs 47?C on Rating: ',...
        '%0.2g 95%% CI [%0.2g, %0.2g]'],krish_stats.rating(2).g,ciLo,ciHi)
ciLo=krish_stats.rating(1).g+1.96*krish_stats.rating(1).se_g;
ciHi=krish_stats.rating(1).g-1.96*krish_stats.rating(1).se_g;
sprintf(['Effect Size (Hedge''s g) of Temperature difference 47 vs 46?C on Rating: ',...
        '%0.2g 95%% CI [%0.2g, %0.2g]'],krish_stats.rating(1).g,ciLo,ciHi)

corrcoef(krish_stats.rating(1).std_delta,krish_stats.nps(1).std_delta)
corrcoef(krish_stats.rating(2).std_delta,krish_stats.nps(2).std_delta)


%% Calculate within-study summary
% Summarize continuous effect size statistic g WITHIN studies
% according to Borenstein, Chapter 24, formulas 24.4 and
% 24.5.

% Rating
krish_sum_stats.rating=WI_study_summary(krish_stats.rating);
krish_sum_stats.nps=WI_study_summary(krish_stats.nps);

ForestPlotter(krish_sum_stats.rating,...
                  'studyIDtexts',temp_step_summary,...
                  'outcomelabel','Rating difference (Hedges'' g)',...
                  'type','fixed',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',0.3,...
                  'textoffset',0,...
                  'NOsummary',1,...
                  'Xscale',2);
hgexport(gcf, 'Krishnan_2016_Rating_summary.svg', hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, 'Krishnan_2016_Rating_summary.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('Krishnan_2016_Rating.png');


% NPS

ForestPlotter(krish_sum_stats.nps,...
                  'studyIDtexts',temp_step_summary,...
                  'outcomelabel','NPS difference (Hedges'' g)',...
                  'type','fixed',...
                  'summarystat','g',...
                  'withoutlier',0,...
                  'WIsubdata',0,...
                  'boxscaling',0.3,...
                  'textoffset',0,...
                  'NOsummary',1,...
                  'Xscale',2);
hgexport(gcf, 'Krishnan_2016_NPS_summary.svg', hgexport('factorystyle'), 'Format', 'svg');
hgexport(gcf, 'Krishnan_2016_NPS_summary.png', hgexport('factorystyle'), 'Format', 'png'); 
crop('Krishnan_2016_NPS_summary.png');