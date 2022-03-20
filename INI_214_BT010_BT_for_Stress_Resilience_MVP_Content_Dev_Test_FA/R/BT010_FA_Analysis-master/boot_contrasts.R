get_diff_in_diff = function(ecg_dat, glm_dat_lme4, n_sim = 100)
{
  i = 1
  sim_dat = simulate(glm_dat_lme4, seed = i)
  diff_dat = 
    ecg_dat %>%
    bind_cols(sim_y = sim_dat[,1]) %>%
    select(sim_y, type, difficulty, perceptibility) %>%
    group_by(type, difficulty, perceptibility) %>% 
    summarise(mean_y = mean(sim_y)) %>% 
    mutate(diff_percp = paste0(difficulty, perceptibility)) %>% 
    ungroup %>% select(-difficulty, -perceptibility) %>% 
    spread(key = diff_percp, value = mean_y) %>%
    mutate(
      HH_HL = HH - HL, 
      HH_LH = HH - LH, 
      HH_LL = HH - LL, 
      HL_LH = HL - LH, 
      HL_LL = HL - LL, 
      LH_LL = LH - LL
      ) %>% 
    select(-HH, -HL, -LH, -LL) %>% 
    gather("diff_params", "value", -type) %>%
    spread(key = type, value = value) %>%
    mutate(diff = `2D` - `3D`, n_sim = i) %>%
    select(diff_params, diff, n_sim)
  
  for(i in 2:n_sim)
  {
    sim_dat = simulate(glm_dat_lme4, seed = i)
    diff_dat = 
      ecg_dat %>%
      bind_cols(sim_y = sim_dat[,1]) %>%
      select(sim_y, type, difficulty, perceptibility) %>%
      group_by(type, difficulty, perceptibility) %>% 
      summarise(mean_y = mean(sim_y)) %>% 
      mutate(diff_percp = paste0(difficulty, perceptibility)) %>% 
      ungroup %>% 
      select(-difficulty, -perceptibility) %>% 
      spread(key = diff_percp, value = mean_y) %>%
      mutate(
        HH_HL = HH - HL, 
        HH_LH = HH - LH, 
        HH_LL = HH - LL, 
        HL_LH = HL - LH, 
        HL_LL = HL - LL, 
        LH_LL = LH - LL
        ) %>% 
      select(-HH, -HL, -LH, -LL) %>% 
      gather("diff_params", "value", -type) %>%
      spread(key = type, value = value) %>%
      mutate(diff = `2D` - `3D`, n_sim = i) %>%
      select(diff_params, diff, n_sim) %>%
      bind_rows(diff_dat)
  }
  
  diff_dat %>%
    group_by(diff_params) %>%
    summarise(
      mean = mean(diff), 
      sd = sd(diff), 
      lower = quantile(diff, probs = c(0.025)), 
      upper = quantile(diff, probs = c(0.975))
    ) %>%
    mutate(
      diff_params = str_replace(diff_params, "_", "-")
    ) -> diff_dat
  
  return(diff_dat)
}

make_interaction_plot = function(ecg_dat, resp)
{
  
  ecg_dat %>% 
    select(difficulty, perceptibility, type, one_of(resp)) %>%
    rename(resp = one_of(resp)) %>%
    ggplot(
      aes(
        x = difficulty, y = resp, shape = perceptibility, color = perceptibility
      )
    ) + 
    geom_point(
      position = position_jitterdodge(jitter.width = .25, dodge.width = 0.5), 
      alpha = 0.5
    ) + 
    stat_summary(
      fun.y = "mean", 
      geom = "line", 
      aes(group = perceptibility), 
      position = position_dodge(width = 0.5)
    ) + 
    stat_summary(
      fun.data = "mean_cl_boot", 
      geom = "errorbar", 
      aes(group = perceptibility),
      position = position_dodge(width = 0.5), 
      width = 0.25
    ) + 
    facet_grid(~ type) + 
    ylab(resp) -> diff_percp
  
  ecg_dat %>% 
    select(difficulty, perceptibility, type, one_of(resp)) %>%
    rename(resp = one_of(resp)) %>%
    ggplot(
      aes(
        x = perceptibility, y = resp, shape = difficulty, color = difficulty
      )
    ) + 
    geom_point(
      position = position_jitterdodge(jitter.width = .25, dodge.width = 0.5), 
      alpha = 0.5
    ) + 
    stat_summary(
      fun.y = "mean", 
      geom = "line", 
      aes(group = difficulty), 
      position = position_dodge(width = 0.5)
    ) + 
    stat_summary(
      fun.data = "mean_cl_boot", 
      geom = "errorbar", 
      aes(group = difficulty),
      position = position_dodge(width = 0.5), 
      width = 0.25
    ) + 
    facet_grid(~ type) + 
    ylab(resp) -> percp_diff
  
  list(diff_percp, percp_diff) %>% return()
  
}

  
# for(i in 1:nrow(param_settings))
# {
#   param_names[i] = param_settings[i, ] %>% 
#     unlist() %>% 
#     as.character %>%
#     paste0(collapse = "-")
#   # simulate data for setting 1
#   ecg_dat %>%
#     filter(
#       pid == "0001", difficulty == param_settings[i,1], 
#       perceptibility == param_settings[i,2], type == '2D'
#     ) -> temp_dat1
#   ecg_dat %>%
#     filter(
#       difficulty == param_settings[i,1], 
#       perceptibility == param_settings[i,2], type == '3D'
#     ) -> temp_dat2
#   
#   sim_dat[, i] = 
#     simulate(glm_dat, newdata = temp_dat[1,], nsim = 100, seed = 1) %>%
#     as.numeric()
# }
# 
# pairwise_cis = 
#   matrix(nrow = nrow(param_settings), ncol = nrow(param_settings)) %>%
#   as.data.frame()
# 
# for(i in 1:nrow(param_settings)) 
# {
#   for(j in i:nrow(param_settings))
#   {
#     t_test = t.test(sim_dat[, i], sim_dat[, j])
#     pairwise_cis[i, j] = 
#       t_test$conf.int %>%
#       round(2) %>%
#       paste(collapse = ", ") %>%
#       paste0("(", ., ")")
#     pairwise_cis[j, i] = (t_test$estimate[1] - t_test$estimate[2]) %>% round(3)
#     if(i == j)
#       pairwise_cis[i, j] = "-"
#   }
# }
# 
# colnames(pairwise_cis) = rownames(pairwise_cis) = param_names
# 
# stop()
# 
# i = 1
# sim_dat = simulate(glm_dat, seed = i, nsim = 100)
# ecg_dat %>%
#   select(type, difficulty, perceptibility) %>%
#   bind_cols(sim_dat) %>% print(10)
#   group_by(type, difficulty, perceptibility) %>%
#   summarise(group_means = mean(sim_y)) 
# 
# for(i in 2:5)
# {
#   sim_dat = simulate(glm_dat, seed = i)
#   ecg_dat %>%
#     select(type, difficulty, perceptibility) %>%
#     bind_cols(sim_y = sim_dat[,1]) %>% 
#     group_by(type, difficulty, perceptibility) %>%
#     summarise(group_means = mean(sim_y)) %>%
#     mutate(sim_num = i) %>%
#     bind_rows(means_dat) -> means_dat
# }
