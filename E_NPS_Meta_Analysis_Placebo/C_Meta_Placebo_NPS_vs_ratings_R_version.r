
#### Version based on individual placebo differences (placebo-control) ####

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

#### Version based on individual images####
rm(list = ls()) # clear workspace

df=read.csv('/Users/matthiaszunhammer/Dropbox/Boulder_Essen/Analysis/E_NPS_Meta_Analysis_Placebo/dfl.txt')

library(lme4)
library(lmerTest)
library(MuMIn)

lm_0 <- lmer(rating101 ~ 1 + (1 | studyID) + (1 | studyID:subID) , data = df)
r.squaredGLMM(lm_0)

lm_treat <- lmer(rating101 ~ 1 + treat + (1 | studyID) + (1 | studyID:subID) , data = df)
r.squaredGLMM(lm_treat)

lm_NPS <- lmer(rating101 ~ 1 + s_NPSraw + (1 | studyID) + (1 | studyID:subID) , data = df)
r.squaredGLMM(lm_NPS)

lm_SIIPS <- lmer(rating101 ~ 1 + s_SIIPS+ (1 | studyID) + (1 | studyID:subID) , data = df)
r.squaredGLMM(lm_SIIPS)

lm_treat_NPS <- lmer(rating101 ~ 1 + treat + s_NPSraw + (1 | studyID) + (1 | studyID:subID) , data = df)
r.squaredGLMM(lm_treat_NPS)

lm_treat_SIIPS <- lmer(rating101 ~ 1 + treat + s_SIIPS + (1 | studyID) + (1 | studyID:subID) , data = df)
r.squaredGLMM(lm_treat_SIIPS)

lm_full <- lmer(rating101 ~ 1 + treat + s_NPSraw+ s_SIIPS + (1 | studyID) + (1 | studyID:subID) , data = df)
r.squaredGLMM(lm_full)
