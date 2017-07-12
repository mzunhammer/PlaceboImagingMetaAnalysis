df=read.csv('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/E_NPS_Meta_Analysis_Placebo/df_lm.txt')

library(lme4)
library(lmerTest)
library(MuMIn)

lm_full <- lmer(rating ~ NPS + (1+NPS | studyID) , data = df)
lm_summary <-summary(lm_full)
beta_NPS<-lm_summary$coefficients[2,'Estimate']
SE_NPS<-lm_summary$coefficients[2,'Std. Error']
CI_NPS<-c(beta_NPS-SE_NPS*1.96,beta_NPS+SE_NPS*1.96)

anova(lm_full)
r.squaredGLMM(lm_full)