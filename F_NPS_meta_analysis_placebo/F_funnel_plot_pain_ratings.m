function F_funnel_plot_pain_ratings(datapath,pubpath)
%% Meta-Analysis & Forest Plot ? Full Sample (MAIN RESULTS)
% Path to add Forest Plots to:
% Add folder with Generic Inverse Variance Methods Functions
df_name='data_frame.mat';
load(fullfile(datapath,df_name),'df');

%% Funnel plot for ratings (by SE)
mean_g=mean([df.GIV_stats_rating.g]); 
scatter([df.GIV_stats_rating.g],[df.GIV_stats_rating.se_g],[df.GIV_stats_rating.n].*2)
set(gca,'Ydir','reverse')
hold on
% Get y-axis extremes to calculate CIs
ylims=get(gca,'Ylim');
funnel95_h0=0+ylims(2)*icdf('normal',[0.025,0.975],0,1);
funnel95_h1=mean_g+ylims(2)*icdf('normal',[0.025,0.975],0,1);
funnel99_h1=mean_g+ylims(2)*icdf('normal',[0.01,0.99],0,1);

h=patch([funnel95_h0(1),0,0],...%X
     [ylims(2),ylims(2),0],[0.9, 0.9, 0.9],...%Y
     'LineStyle','none');
uistack(h,'bottom');
 
line([funnel95_h1(1),mean_g],[ylims(2),0]);
line([funnel95_h1(2),mean_g],[ylims(2),0]);
line([funnel99_h1(1),mean_g],[ylims(2),0],'LineStyle','--');
line([funnel99_h1(2),mean_g],[ylims(2),0],'LineStyle','--');

line([mean_g,mean_g],...
      [0,ylims(2)],...
  'Color','red','LineStyle','--');

line([0,0],...
      [0,ylims(2)],...
  'Color',' black');

ylabel('Standard error (g)')
xlabel('Effect size (g)')
hold off
hgexport(gcf, fullfile(pubpath,['Funnel_plot_ratings','.svg']), hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, fullfile(pubpath,['Funnel_plot_ratings','.png']), hgexport('factorystyle'), 'Format', 'png'); 
crop(fullfile(pubpath,['Funnel_plot_ratings','.png']));

%close all;

% The analysis of funnel plot asymmetry is computed via regression of
% SND = b1*precision+b0 (Egger 1997, BMJ)
% Whereas:
% SND =standard normal deviate = effect_size / SE_effect
% precision= 1/SE_effect
% b0 = the intercept used as a measure of asymmetry.

SND=([df.GIV_stats_rating.g]./[df.GIV_stats_rating.se_g])';
precision=(1./[df.GIV_stats_rating.se_g])';
mdl_unweighted = fitlm(precision,SND);
disp(['Egger''s test: Funnel_Plot_Assymetry: p = '])
mdl_unweighted.Coefficients.pValue(1)
