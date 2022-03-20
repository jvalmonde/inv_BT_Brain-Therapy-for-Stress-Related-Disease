table_to_df <- function(vr, table, chisq){
  
  if (vr == "go"){
    caption <- "Contingency Table for Oculus Go VR Users"
  } else if (vr == "rift"){
    caption <- "Contingency Table for Oculus Rift VR Users"
  } else {
    stop("Only go and rift values are acceptable for the vr argument.")
  }
  
  tbl_01 <- c(paste0("Chi-square test p-value: ", round(chisq$p.value, 2)), 
              "", "", "VR Game Experience", "")
  tbl_02 <- c("", "", "Negative", "Mixed", "Positive")
  tbl_03 <- c("", "Negative", table[1, 1], table[1, 2], table[1, 3])
  tbl_04 <- c("Technology Attitude", "Mixed", table[2, 1], table[2, 2], table[2, 3])
  tbl_05 <- c("", "Positive", table[3, 1], table[3, 2], table[3, 3])

  tbl_df <- as.data.frame(rbind(tbl_01, tbl_02, tbl_03, tbl_04, tbl_05))
  colnames(tbl_df) <- NULL
  rownames(tbl_df) <- NULL
  
  tbl_df %>%
    kable(align = c("c", "c", "c", "c", "c"), caption = caption) %>%
    row_spec(c(0, 1), bold = TRUE) %>%
    column_spec(c(1, 2), bold = TRUE) %>%
    kable_styling(full_width = F, latex_options = "hold_position") 
  
}