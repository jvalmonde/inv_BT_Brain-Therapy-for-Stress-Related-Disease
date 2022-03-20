rm(list = ls())

library(tidyverse)
library(lme4)
library(lmerTest)
library(emmeans)

setwd("~/BT010_FA_Analysis/")
data = read_csv("./data/feature_data.csv")
source("boot_contrasts.R")

responses = c(
    "ecg_heart_rate_mean", "log_ecg_hrv_std_mean", "skin_temperature_mean", 
    "eda_mean_mean", "log_eda_no_of_peaks_mean", "eda_lf_mean", "log_eda_hf_mean", 
    "eda_lf_hf_ratio_mean"
)
    
ecg_dat = data %>% 
    rename(
        pid = Participant, 
        type = Type
    ) %>%
    select(
        pid, type, Difficulty, Perceptibility, context_order, one_of(responses)
    ) %>% 
    mutate(
        time = as.factor(context_order), 
        pid = as.factor(pid), 
        type = as.factor(type), 
        difficulty = as.factor(ifelse(Difficulty == 0, 'L', 'H')), 
        perceptibility = as.factor(ifelse(Perceptibility == 0, 'L', 'H'))
    ) %>%
    select(-context_order, - Difficulty, -Perceptibility) %>%
    mutate(
        ecg_heart_rate_mean = ifelse(
            ecg_heart_rate_mean < 50, NA, ecg_heart_rate_mean
        ), 
        log_ecg_hrv_std_mean = log(ecg_hrv_std_mean),
        ecg_hrv_std_mean = ifelse(
            ecg_hrv_std_mean > 250, NA, ecg_hrv_std_mean
        ), 
        skin_temperature_mean = ifelse(
            skin_temperature_mean < 25, NA, skin_temperature_mean
        ), 
        log_eda_hf_mean = log(eda_hf_mean)
    )

for(i in 1:length(responses))
{
    resp = responses[i]
    formula_string = paste0(
        resp, " ~ (1|pid) + time + type*difficulty*perceptibility"
    )
    glm_dat_lme4 = lme4::lmer(as.formula(formula_string), data = ecg_dat)
    glm_dat_lmerTest = lmerTest::lmer(as.formula(formula_string), data = ecg_dat)
    print("###################################################################")
    print(resp)
    anova(glm_dat_lmerTest, type = "III") %>% print()
    emmeans(glm_dat_lme4, specs = pairwise ~ difficulty:perceptibility:type)
    get_diff_in_diff(ecg_dat, glm_dat_lme4, n_sim = 100) %>% print()
    print("###################################################################")
}

