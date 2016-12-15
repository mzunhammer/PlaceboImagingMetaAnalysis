% Generating a signal
y=[100 101 100 101 101]';       
% Two variants of modelling the signal
X1= [0 1 0 1 0]';                          %Standard Dummy Coding
X2= [-0.1 1.1 -0.1 1.1 -0.1]'; %Strange SPM-Style Coding
X3= [0 0 1 1 0]';

himax=6
lomax=3
himin=himax*0.2
lomin=lomax*0.2

X4= [-lomin lomax -himin himax himax]'; %Strange SPM-Style Coding

xs=abs(himax+himin);
xss=abs(lomax+lomin);
xsges=(xs+xss);

xges=sum(abs(X4))
xmean=xges/length(X4);

maxdiff=himax*length(X4)-sum(X4)
mindiff=himin*length(X4)-sum(X4)

whole_area=maxdiff+mindiff



% Generating beta values and an intercept
b1=regress(y,[ones(size(X1)) X1]);
b2=regress(y,[ones(size(X2)) X2]);

b4=regress(y,[ones(size(X4)) X4]);

% Three variants of re-translating betas to signal with X

signal1a=b1(2).*max(X1);
signal1b=b1(2).*(max(X1)+min(X1));
signal1c=b1(2).*(max(X1)-min(X1));

signalchange2a=b2(2).*max(X2);
signalchange2b=b2(2).*(max(X2)+min(X2));
signalchange2c=b2(2).*(max(X2)-min(X2));

signal2a=b2(2).*max(X2)+b2(1);
signal2b=b2(2).*(max(X2)+min(X2))+b2(1);
signal2c=b2(2).*(max(X2)-min(X2))+b2(1);

signalchange4a=b4(2).*max(X4);
signalchange4b=b4(2).*(max(X4)+min(X4));
xs=max(X4)-min(X4);
signalchange4c=b4(2).*(xs/xss-((xs-xss)/(xs+xss)))*xss    %.*(0.91666666)
signalchange4c=b4(2).*(xs-((xs-xss)/(xs+xss)*xss))     %.*(0.91666666)
signalchange4c=b4(2).*xs    %.*(0.91666666)

signalchange4d=b4(2).*(mean(X4)*2);

signal4a=b4(2).*max(X4)+b4(1);
signal4b=b4(2).*(max(X4)+min(X4))+b4(1);
signal4c=b4(2).*(max(X4)-min(X4))+b4(1);
