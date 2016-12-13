rm(list = ls())

#### Load packages ####
library(lme4)
library(lmerTest) # will enhance the lme4 summary by df's and p-values
library(pbkrtest) # required by lmerTest for Kenward-Roger's
library(ggplot2)
library(GGally)
library(plyr)
library(lsmeans)
library(gridExtra)
library(Rmisc)
library(psychometric)
library(boot)
library(corrplot)
library(ICC)

### Define a function handle for computing the mean without NaNs for
# R's bootstrapping (requires functions with two arguments: data(x) and cases (d))
resamples=1000
  
bmean <- function(x, d) {
  return(mean(x[d],na.rm=TRUE))
}

# Create seperate bootstrapping functions for ggplot
booty_lo <- function(y,d) {
  if(length(unique(y)) > 1) {
    b <- boot(data= y[d], statistic= bmean, R= resamples)
    bci <- boot.ci(b,conf = 0.95,type="bca")
    ci<-bci$bca[4]
    }
  else 
  {ci<- bmean(y)
  }
  return(ci)
}

booty_hi <- function(y,d) {
  if(length(unique(y)) > 1) {
    b <- boot(data= y[d], statistic= bmean, R= resamples)
    bci <- boot.ci(b,conf = 0.95,type="bca")
    ci<-bci$bca[5]
    }
  else 
  {ci<- bmean(y)
  }
  return(ci)
}

####LOAD AND DEFINE DATA#####
# Load data into dataframe
setwd("/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/")
df <- read.table("df.dat",header=TRUE,sep="\t")

# Replace NaN with NA
is.na(df) <- is.na(df)

df$real_pain<-factor(df$pain==1|df$pain==3, labels = c("noPain", "Pain"))
df$real_pla<-factor(df$pla==1, labels = c("noPlacebo","Placebo"))

df <- within(df, {
                male        <- factor(male, levels = 0:1, labels = c("female", "male"))
                healthy     <- factor(healthy, levels = 0:1, labels = c("patient","healthy"))
                pla         <- factor(pla, levels = 0:2, labels = c("control", "placebo","other"))
                pain        <- factor(pain, levels = 0:3, labels = c("noPain", "Pain","earlyPain","latePain"))  # Cave: for the wager princeton-data watch the cond labels: there was intense-mild and intense-baseline!!!
                predictable <- factor(predictable, levels = 0:1, labels = c("unpredictable", "predictable"))  # Cave: currently not useful, because almost all studies included a cue and jittered anticipation phases. It's difficult do decide at what cutoff a stimulus was predictable or not. Maybe better to use anticipation duration or some scalar measure of uncertainty.
                realTreat   <- factor(realTreat, levels = 0:1, labels = c("without Verum", "with Verum"))
                plaFirst    <- factor(plaFirst, levels = 0:1, labels = c("plaSecond", "plaFirst"))
                })

# z-Transform continuous data by-study
#df$zrating =unlist(tapply(df$rating,df$studyID, function(x) scale(x, center = TRUE, scale = TRUE)))
#df$zstimInt=unlist(tapply(df$stimInt,df$studyID, function(x) scale(x, center = TRUE, scale = TRUE)))
#df$zNPSraw =unlist(tapply(df$NPSraw,df$studyID, function(x) scale(x, center = TRUE, scale = TRUE)))
#df$zNPScorrected=unlist(tapply(df$NPScorrected,df$studyID, function(x) scale(x, center = TRUE, scale = TRUE)))
  
#######  EXCLUDE OUTLIERS ######
#df=df[!(df$subID=="bingel_14"&df$pla=="control"),] #Excluded: Onset mistakenly entered twice at baseline

#Excluded for excessive deviation (>30 points)

#ex=abs(df$dev_from_target_rating)>=30
#df$expect[ex]=NA
#df$rating[ex]=NA

#### Plot NPScorr vs Covariates ####
# Define the plot appearance for a particular type of plot
plotAll <- function(df,plX) {
dodge <- position_dodge(width=0.5)
jdodge <-position_jitterdodge(jitter.width=0.5,dodge.width=0.5)
pl<- ggplot(df, aes(x=eval(parse(text=plX),df),y=zNPScorrected,color=studyID))+
  geom_point(position=jdodge)+
  geom_smooth(method='lm',formula=y~x)+
  geom_smooth(aes(x=eval(parse(text=plX),df),y=zNPScorrected,color="OVERALL"),method='lm',formula=y~x)+
  #geom_line(aes(group=positive:tbl),stat='summary', fun.y=bmean,position=dodge)+
  #scale_colour_manual("Group:",values = c(rgb(.35,.70,.90), rgb(.0,.45,.70), rgb(.80,.40,.70), rgb(.45,.15,.50)))+
  #scale_fill_manual("Group:",values = c(rgb(.35,.70,.90), rgb(.0,.45,.70), rgb(.80,.40,.70), rgb(.45,.15,.50)))+
  #ylim(-30, 100)+
  labs(x = plX)+
  labs(y = "NPS (within-study z-Score, painful condition)")+
  theme(aspect.ratio = 1/sqrt(2))+ #fix plot size
  theme(axis.text=element_text(size=12), #fix axis font size
        axis.title=element_text(size=14,face="bold"))+ #fix axis title font size
  theme(strip.text.x = element_text(size = 12,face="bold"))+
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major.y = element_line(colour = "#111111",size=0.2), #element_line(colour = "#555555"), #fix grid display
        panel.grid.minor.y = element_blank(), #fix grid display
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        strip.background = element_rect(fill = 'transparent'),
        panel.background = element_blank())
  #ggtitle(as.character(dfwirk$combistudyIDs[1])) # Add inital of studyIDs first name as graph title
pl
#ggtitle(as.character(dfwirk$combistudyIDs[1])) # Add inital of studyIDs first name as graph title
list(pl)
}

#### Plot  ####
plX=cbind("zrating","zstimInt","male","age","pla","pain","plaFirst","condSeq","fieldStrength","tr","te","voxelVolume","meanBlockDur","xSpan")

for(i in 1:length(plX)){
  print(plotAll(df[df$pain!="noPain",],plX[i]))
  }


#### Plot NPScorr for pain vs nopain ####
# Define the plot appearance for a particular type of plot
SpaghettiplotAll <- function(df,plX) {
  dodge <- position_dodge(width=0.5)
  jdodge <-position_jitterdodge(jitter.width=0.5,dodge.width=0.5)
  pl<- ggplot(df, aes(x=pain,y=zNPScorrected,group=subID,color=subID))+
    geom_point()+
    geom_line()+
    #geom_smooth(aes(x=pain,y=zNPScorrected,group="OVERALL",color="OVERALL"),method='lm',formula=y~x)+
    #geom_line(aes(group=positive:tbl),stat='summary', fun.y=bmean,position=dodge)+
    #scale_colour_manual("Group:",values = c(rgb(.35,.70,.90), rgb(.0,.45,.70), rgb(.80,.40,.70), rgb(.45,.15,.50)))+
    #scale_fill_manual("Group:",values = c(rgb(.35,.70,.90), rgb(.0,.45,.70), rgb(.80,.40,.70), rgb(.45,.15,.50)))+
    #ylim(-30, 100)+
    guides(colour=FALSE)+
    labs(y = "NPS (within-study z-Score, painful condition)")+
    theme(aspect.ratio = 1/sqrt(2))+ #fix plot size
    theme(axis.text=element_text(size=12), #fix axis font size
          axis.title=element_text(size=14,face="bold"))+ #fix axis title font size
    theme(strip.text.x = element_text(size = 12,face="bold"))+
    theme(axis.line = element_line(colour = "black"),
          panel.grid.major.y = element_line(colour = "#111111",size=0.2), #element_line(colour = "#555555"), #fix grid display
          panel.grid.minor.y = element_blank(), #fix grid display
          panel.grid.major.x = element_blank(),
          panel.grid.minor = element_blank(),
          strip.background = element_rect(fill = 'transparent'),
          panel.background = element_blank())+
  ggtitle(as.character(df$studyID[1])) # Add inital of studyIDs first name as graph title
  pl
  #ggtitle(as.character(dfwirk$combistudyIDs[1])) # Add inital of studyIDs first name as graph title
  list(pl)
}

#### Plot  ####
by(df[df$pla=="control",],df$studyID[df$pla=="control"],SpaghettiplotAll)


##### Linear  Model Analysis of NPScorrected values #######
# Select subframe of data for lmer analysis
mdf=df[df$real_pain=="Pain"&df$studyID!="ruetgen"&df$studyID!="kessner",]

##### Linear MIXED Model Analysis of NPScorrected values considering study differences in association #####
mm1<-lmer(zNPScorrected~1 # I() is necessary if a term shall be entered as polynomial
                     +(1|studyID/subID), # Random intercepts and placebo effects for subjects nested in studies:(1+real_pla|studyID/subID)
                     data=mdf,
                     na.action =na.exclude,
                     REML=1,
                     control=lmerControl(optCtrl=list(maxfun=180000)))
AIC(mm1)
summary(mm1)
anova(mm1,mm1=1) #


# Formulas for model analytics
EBLUPS=ranef(mm1) # GET EBLUPS for Random Effects
plot(EBLUPS)
mdf$resids=residuals(mm1,na.action =na.exclude) # GET Residuals
mdf$zresids=scale(mdf$resids,center=TRUE,scale=TRUE) # Scale Residuals
mdf$predicts=predict(mm1,na.action =na.exclude) # GET Predicted values
mdf$zpredicts=scale(mdf$predicts,center=TRUE,scale=TRUE) # Scale Residuals

# Plot actual vs predicted
ggplot(mdf, aes(x=zNPScorrected,
                y=predicts,
                color=studyID))+
                xlim(c(min(c(mdf$zNPScorrected,mdf$predicts),na.rm=1),max(c(mdf$zNPScorrected,mdf$predicts),na.rm=1)))+# Make y and x axis limits identical
                ylim(c(min(c(mdf$zNPScorrected,mdf$predicts),na.rm=1),max(c(mdf$zNPScorrected,mdf$predicts),na.rm=1)))+# Make y and x axis limits identical
                geom_point()+
                geom_smooth(method='lm',formula=y~x)+
                geom_smooth(aes(x=zNPScorrected,y=predicts,color="OVERALL"),method='lm',formula=y~x)+
                coord_fixed()

# Plot predicted vs residuals
ggplot(mdf, aes(x=predicts,
                y=zresids,
                color=studyID))+
  xlim(c(min(c(mdf$zresids,mdf$predicts),na.rm=1),max(c(mdf$zresids,mdf$predicts),na.rm=1)))+# Make y and x axis limits identical
  ylim(c(min(c(mdf$zresids,mdf$predicts),na.rm=1),max(c(mdf$zresids,mdf$predicts),na.rm=1)))+# Make y and x axis limits identical
  geom_point()+
  #geom_smooth(method='lm',formula=y~x)+
  geom_smooth(aes(x=zNPScorrected,y=predicts,color="OVERALL"),method='lm',formula=y~x)+
  coord_fixed()

histogram(mdf$zresids) # Histogram of residuals
