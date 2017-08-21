%% Explore heterogeneity
load('B1_Full_Sample_Summary_Pain.mat')
load('B1_Full_Sample_Summary_Placebo.mat')

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
%FAZIT: I^2 is only weakly (r~0.05) related to the direction of effect of pain on brain activity
%and only weakly related to absolute pain-induced changes in brain activity.
%In both cases larger activity changes tending go along with larger I^2 values
%Voxels with small effect sizes tend to show a larger spread in I^2 values.


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
xwo0=x(y>0); %exclude null tau
ywo0=y(y>0); %exclude null tau
h1=hexbin(xwo0,ywo0,100)

[R,P,RLO,RUP]=corrcoef(x,y)

%[R,P,RLO,RUP]=corrcoef(x(y>=1),y(y>=1))
%[R,P,RLO,RUP]=corrcoef(abs(x(y>=1)),y(y>=1))
xlabel('g: pain_p_l_a_c_e_b_o - pain_c_o_n_t_r_o_l')
ylabel('tau: pain_p_l_a_c_e_b_o - pain_c_o_n_t_r_o_l')

hgexport(gcf, '/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Protocol_and_Manuscript/whole_brain/figures/Figure_S6_Correlation_g_tau.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Protocol_and_Manuscript/whole_brain/figures/Figure_S6_Correlation_g_tau.png', hgexport('factorystyle'), 'Format', 'png'); 
%crop(sprintf('./figure_results/VOI_Full_pla_g_%d_%d_%d.svg',MNI_pla_g{i}));
crop('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Protocol_and_Manuscript/whole_brain/figures/Figure_S6_Correlation_g_tau.png');

%FAZIT:
% Both gs and I^2s are far smaller than for pain
% There is a considerable fraction (~25%) of voxels showing a I^2 of 0.
% There seems to be a small (r=.2) positive association between g and I^sq,
% indicating more between-study heterogeneity in effects on voxels showing
% activation increases under placebo treatment.
% In contrast, absolute effect sizes and I^2 show only veery week
% association (r=.02)

%% Het vs effect sizes placebo r
x=summary_placebo.r_external.random.summary;
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
h1=hexbin(xwo0,ywo0,100)

[R,P,RLO,RUP]=corrcoef(x,y)

%[R,P,RLO,RUP]=corrcoef(x(y>=1),y(y>=1))
%[R,P,RLO,RUP]=corrcoef(abs(x(y>=1)),y(y>=1))
xlabel('r: correlation of cerebral effect and behavioral placebo analgesia')
ylabel('tau: correlation of cerebral effect and behavioral placebo analgesia')

hgexport(gcf, '/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Protocol_and_Manuscript/whole_brain/figures/Figure_S12_Correlation_r_tau.svg', hgexport('factorystyle'), 'Format', 'svg'); 
hgexport(gcf, '/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Protocol_and_Manuscript/whole_brain/figures/Figure_S12_Correlation_r_tau.png', hgexport('factorystyle'), 'Format', 'png'); 
%crop(sprintf('./figure_results/VOI_Full_pla_g_%d_%d_%d.svg',MNI_pla_g{i}));
crop('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Protocol_and_Manuscript/whole_brain/figures/Figure_S12_Correlation_r_tau.png');

%FAZIT:
% Both gs and I^2s are far smaller than for pain
% There is a considerable fraction (~25%) of voxels showing a I^2 of 0.
% There seems to be a small (r=.2) positive association between g and I^sq,
% indicating more between-study heterogeneity in effects on voxels showing
% activation increases under placebo treatment.
% In contrast, absolute effect sizes and I^2 show only veery week
% association (r=.02)