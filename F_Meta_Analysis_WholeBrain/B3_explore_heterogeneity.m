%% Explore heterogeneity
load('B1_Full_Sample_Summary_Pain.mat')
load('B1_Full_Sample_Summary_Placebo.mat')

%% Het vs effect sizes pain
x=summary_pain.g.random.summary;
y=summary_pain.g.heterogeneity.Isq;
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
ylabel('I^2 pain')
%FAZIT: I^2 is only weakly (r~0.05) related to the direction of effect of pain on brain activity
%and only weakly related to absolute pain-induced changes in brain activity.
%In both cases larger activity changes tending go along with larger I^2 values
%Voxels with small effect sizes tend to show a larger spread in I^2 values.


%% Het vs effect sizes pain
x=summary_placebo.g.random.summary;
y=summary_placebo.g.heterogeneity.Isq;

plot(x,y,'.')% Het vs effect sizes placebo
lsline
q = polyfit(x,y,4);
h=refcurve(q);
h.Color='red';
figure

%
%h1.FaceAlpha=0.2;
xwo0=x(y>=1); %exclude null Isq
ywo0=y(y>=1); %exclude null Isq
h1=hexbin(xwo0,ywo0,100)

hold on
x0=x(y<1); %exclude null Isq
y0=y(y<1); %exclude null Isq
h0=hexbin(x0,y0,[100,100])
h0.CData(2:end,:)=NaN;
hold off

[R,P,RLO,RUP]=corrcoef(x,y)
[R,P,RLO,RUP]=corrcoef(abs(x),y)

%[R,P,RLO,RUP]=corrcoef(x(y>=1),y(y>=1))
%[R,P,RLO,RUP]=corrcoef(abs(x(y>=1)),y(y>=1))
xlabel('g: pain_p_l_a_c_e_b_o - pain_c_o_n_t_r_o_l')
ylabel('I^2: pain_p_l_a_c_e_b_o - pain_c_o_n_t_r_o_l')
%FAZIT:
% Both gs and I^2s are far smaller than for pain
% There is a considerable fraction (~25%) of voxels showing a I^2 of 0.
% There seems to be a small (r=.2) positive association between g and I^sq,
% indicating more between-study heterogeneity in effects on voxels showing
% activation increases under placebo treatment.
% In contrast, absolute effect sizes and I^2 show only veery week
% association (r=.02)
%% Het in pain vs effect sizes placebo
x=summary_placebo.g.random.summary;
y=summary_pain.g.heterogeneity.Isq;

plot(x,y,'.')% Het vs effect sizes placebo
lsline
q = polyfit(x,y,4);
h=refcurve(q);
h.Color='red';
figure
hexbin(x,y,100)
[R,P,RLO,RUP]=corrcoef(x,y)
[R,P,RLO,RUP]=corrcoef(abs(x),y)
xlabel('g placebo')
ylabel('I^2 pain')
%FAZIT:
% Interestingly, there seems to be a negative correlation (r=-.15)
% between placebo effects on activity and the relative amount of between-study variance 
% (I^2) in pain-related activity. Regions showing positive placebo effects
% show LOWER I^2 under pain. Again, the correlation between I^2 pain and 
% absolute placebo responses is fairly weak (r=0.07)  

%% Effect size pain vs effect sizes placebo
x=summary_pain.g.random.summary;
y=summary_placebo.g.random.summary;

plot(x,y,'.')% Het vs effect sizes placebo
lsline
q = polyfit(x,y,4);
h=refcurve(q);
h.Color='red';
figure
hexbin(x,y,100)
xlabel('g pain')
ylabel('g placebo')
figure
hexbin(x,abs(y),100)
xlabel('g pain')
ylabel('abs g placebo')
figure
hexbin(abs(x),y,100)
xlabel('abs g pain')
ylabel('g placebo')
figure
hexbin(abs(x),abs(y),100)
xlabel('abs g pain')
ylabel('abs g placebo')

[R_xy,P,RLO,RUP]=corrcoef(x,y)
[R_x_absy,P,RLO,RUP]=corrcoef(x,abs(y))
[R_absx_y,P,RLO,RUP]=corrcoef(abs(x),y)
[R_absxy,P,RLO,RUP]=corrcoef(abs(x),abs(y))

%FAZIT:
%
% pain,placebo: r= .03: No real correspondence between pain-related
% activity and placebo-related changes in pain activity
% pain,abs(placebo): r= .15: Tendency for regions showing positive responses to pain,
% tend to show larger absolute placebo effects (in both reductions and increases)
% abs(pain), placebo: r= .07: Regions showing large positive and negative
% responses to pain, no real relationship with placebo.
% abs(pain),abs(placebo): r= .05 Regions showing large changes under pain
% show no real pattern with changes under placebo

%% 
x=summary_placebo.g.random.summary;
y=summary_placebo.r_external.random.summary;

plot(x,y,'.')% Het vs effect sizes placebo
lsline
q = polyfit(x,y,4);
h=refcurve(q);
h.Color='red';
figure
hexbin(x,y,100)
[R,P,RLO,RUP]=corrcoef(x,y)
[R,P,RLO,RUP]=corrcoef(abs(x),y)
xlabel('SE pain')
ylabel('SE placebo')