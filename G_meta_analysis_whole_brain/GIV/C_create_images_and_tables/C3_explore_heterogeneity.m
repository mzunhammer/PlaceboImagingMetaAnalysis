function C3_explore_heterogeneity(datapath)
% Add analysis/permutation summary to statistical summary struct
p = mfilename('fullpath'); %CANlab's apply mask do not like relative paths so this cludge is needed
[p,~,~]=fileparts(p);
splitp=strsplit(p,'/');
whole_brain_path=fullfile(filesep,splitp{1:end-1});
results_path=fullfile(whole_brain_path,'vectorized_results');
figure_path='/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Protocol_and_Manuscript/whole_brain/figures/'

%% Explore heterogeneity
load(fullfile(results_path,'WB_summary_pain_full.mat'));
load(fullfile(results_path,'WB_summary_placebo_full.mat'));

%% SE vs effect sizes pain
x=summary_pain.g.random.summary;
y=summary_pain.g.random.SEsummary;
plot(x,y,'.')% Het vs effect sizes placebo
lsline
q = polyfit(x,y,4);
h=refcurve(q)
h.Color='red';
figure
hexbin(x,y,100)
[R,P,RLO,RUP]=corrcoef(x,y)
[R,P,RLO,RUP]=corrcoef(abs(x),y)
xlabel('g pain')
ylabel('SE g pain')
%FAZIT: SE is weakly, but significantly (r~0.17) related to the direction of effect of pain on brain activity
%Positive activity changes tending go along with larger tau values. This
%may be due to the fact that the range for positiv effect sizes is much
%larger than the range of negative effect sizes.


%% Het vs effect sizes pain
x=summary_pain.g.random.summary;
y=sqrt(summary_pain.g.heterogeneity.tausq);
plot(x,y,'.')% Het vs effect sizes placebo
lsline
q = polyfit(x,y,4);
h=refcurve(q)
h.Color='red';
figure
hexbin(x,y,100)
[R,P,RLO,RUP]=corrcoef(x,y)
[R,P,RLO,RUP]=corrcoef(abs(x),y)
xlabel('g pain')
ylabel('tau pain')
%FAZIT: tau is weakly, but significantly (r~0.17) related to the direction of effect of pain on brain activity
%Positive activity changes tending go along with larger tau values

%% SE vs effect sizes placebo g
x=summary_placebo.g.random.summary;
y=summary_placebo.g.random.SEsummary;

plot(x,y,'.')% Het vs effect sizes placebo
lsline
q = polyfit(x,y,4);
h=refcurve(q);
h.Color='red';
figure

%
%h1.FaceAlpha=0.2;
xwo0=x(y>0); %exclude null tau
ywo0=y(y>0); %exclude null tau
h1=hexbin(xwo0,ywo0,100)

[R,P,RLO,RUP]=corrcoef(x,y)

%[R,P,RLO,RUP]=corrcoef(x(y>=1),y(y>=1))
%[R,P,RLO,RUP]=corrcoef(abs(x(y>=1)),y(y>=1))
xlabel('g: pain_p_l_a_c_e_b_o - pain_c_o_n_t_r_o_l')
ylabel('SE g: pain_p_l_a_c_e_b_o - pain_c_o_n_t_r_o_l')

%FAZIT: SE is weakly, but significantly (r~0.21) related to the direction of placebo effects of on brain activity
% Positive activity changes tend to go along with larger SE.

%% Het vs effect sizes placebo g
x=summary_placebo.g.random.summary;
y=sqrt(summary_placebo.g.heterogeneity.tausq);

plot(x,y,'.')% Het vs effect sizes placebo
lsline
q = polyfit(x,y,4);
h=refcurve(q);
h.Color='red';
figure

%
%h1.FaceAlpha=0.2;
xwo0=x(y>0&y<0.3); %exclude null tau and high outlier
ywo0=y(y>0&y<0.3); %exclude null tau and high outlier
h1=hexbin(xwo0,ywo0,100,'colorbar')

[R,P,RLO,RUP]=corrcoef(x,y)
corrcoef(x,y)
%[R,P,RLO,RUP]=corrcoef(x(y>=1),y(y>=1))
%[R,P,RLO,RUP]=corrcoef(abs(x(y>=1)),y(y>=1))
xlabel('g: pain_p_l_a_c_e_b_o - pain_c_o_n_t_r_o_l')
ylabel('tau: pain_p_l_a_c_e_b_o - pain_c_o_n_t_r_o_l')

hgexport(h1, fullfile(figure_path,'Correlation_g_vs_tau_placebo.svg'), hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(h1, fullfile(figure_path,'Correlation_g_vs_tau_placebo.png'), hgexport('factorystyle'), 'Format', 'png'); 
%crop(sprintf('./figure_results/VOI_Full_pla_g_%d_%d_%d.svg',MNI_pla_g{i}));
crop(fullfile(figure_path,'Correlation_g_vs_tau_placebo.png'));

%FAZIT: tau is weakly, but significantly (r~0.22) related to the direction of placebo effects of on brain activity
% Positive activity changes tend to go along with larger tau values. Effect
% is somewhat stronger than for pain.

%% Het vs effect sizes placebo r
x=summary_placebo.r_external.random.summary*-1; % Correlation between brain activity and behavior was determine as the contrast pla-con. Therefore positive correlations represent brain regions where more brain activity is associated with more pain(!) under placebo conditions. Correlations are inverted so that positive correlations denote more brain activity AND more placebo effect (i.e. less pain under placebo conditions)
y=sqrt(summary_placebo.r_external.heterogeneity.tausq);

plot(x,y,'.')% Het vs effect sizes placebo
lsline
q = polyfit(x,y,4);
h=refcurve(q);
h.Color='red';
figure

%
%h1.FaceAlpha=0.2;
xwo0=x(y>0); %exclude null tau
ywo0=y(y>0); %exclude null tau
h1=hexbin(xwo0,ywo0,100,'colorbar')

[R,P,RLO,RUP]=corrcoef(x,y)

%[R,P,RLO,RUP]=corrcoef(x(y>=1),y(y>=1))
%[R,P,RLO,RUP]=corrcoef(abs(x(y>=1)),y(y>=1))
xlabel('r: behavioral placebo effect vs brain activity')
ylabel('tau: behavioral placebo effect vs brain activity')

hgexport(h1, fullfile(figure_path,'Correlation_r_vs_tau_placebo.svg'), hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(h1, fullfile(figure_path,'Correlation_r_vs_tau_placebo.png'), hgexport('factorystyle'), 'Format', 'png'); 
%crop(sprintf('./figure_results/VOI_Full_pla_g_%d_%d_%d.svg',MNI_pla_g{i}));
crop(fullfile(figure_path,'Correlation_r_vs_tau_placebo.png'));

%FAZIT:
% Tau and r show only very weak association (r=.06).