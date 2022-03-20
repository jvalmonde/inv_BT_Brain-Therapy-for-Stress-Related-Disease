library('rlang')
library('dplyr')

plot_age <- function(data, var1, var2, geq, i){

  if(geq == 1){
    
    questions <- c("I was interested in the game's story", "I felt successful", "I felt bored",
                   "I found it impressive", "I forgot everything around me", "I felt frustrated",
                   "I found it tiresome", "I felt irritable", "I felt skillfull",
                   "I felt completely absorbed", "I felt content", "I felt challenged",
                   "I had to put a lot of effort into it", "I felt good")
    
  } else if (geq == 2){
    
    questions <- c("I felt revived", "I felt bad", "I found it hard to get back to reality",
                   "I felt guilty", "It felt like a victory", "I found it a waste of time",
                   "I felt energised", "I felt satisfied", "I felt disoriented",
                   "I felt exhausted", "I felt that I could have\ndone more useful things", 
                   "I felt powerful", "I felt weary", "I felt regret", "I felt ashamed", 
                   "I felt proud", "I had a sense that I had\nreturned from a journey")
    
  } else {
    
    stop("Only input values 1 and 2 for the geq argument.")
    
  }
  
  
  var1 <- enquo(var1)
  var2 <- rlang::sym(var2)
  
  df <- data %>%
    
    select(!!var1, Age) %>%
    group_by(!!var1, Age) %>%
    mutate(Count = n(), Percentage = round((Count / nrow(data) * 100), 2)) %>%
    unique()
  
  title <- paste0("Q", i, ". ", questions[i])
  
  ggplot(df, aes(!!var2, y = Percentage, fill = Age)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(x = "Responses", y = "Percentage", title = title) +
    scale_fill_manual(name = "Age Group", values = c(uhg1, uhg2, uhg3, uhg4, uhg5, uhg6)) +
    theme_joy_s
  
}

plot_gender <- function(data, var1, var2){
  
  var1 <- enquo(var1)
  var2 <- rlang::sym(var2)
  
  df <- data %>%
    select(!!var1, Gender) %>%
    group_by(!!var1, Gender) %>%
    mutate(Count = n(), Percentage = round((Count / nrow(data) * 100), 2)) %>%
    unique()
  
  ggplot(df, aes(!!var2, y = Percentage, fill = Gender)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(x = "Responses", y = "Percentage") +
    scale_fill_manual(name = "Gender", values = c(uhg1, uhg2)) +
    theme_joy_s
  
}

plot_tech_attitude <- function(data, var1, var2, geq, i){
  
  if(geq == 1){
    
    questions <- c("I was interested in the game's story", "I felt successful", "I felt bored",
                   "I found it impressive", "I forgot everything around me", "I felt frustrated",
                   "I found it tiresome", "I felt irritable", "I felt skillfull",
                   "I felt completely absorbed", "I felt content", "I felt challenged",
                   "I had to put a lot of effort into it", "I felt good")
    
  } else if (geq == 2){
    
    questions <- c("I felt revived", "I felt bad", "I found it hard to get back to reality",
                   "I felt guilty", "It felt like a victory", "I found it a waste of time",
                   "I felt energised", "I felt satisfied", "I felt disoriented",
                   "I felt exhausted", "I felt that I could have\ndone more useful things", 
                   "I felt powerful", "I felt weary", "I felt regret", "I felt ashamed", 
                   "I felt proud", "I had a sense that I had\nreturned from a journey")
    
  } else {
    
    stop("Only input values 1 and 2 for the geq argument.")
    
  }
  
  
  var1 <- enquo(var1)
  var2 <- rlang::sym(var2)
  
  df <- data %>%
    
    select(!!var1, TA_median) %>%
    group_by(!!var1, TA_median) %>%
    mutate(Count = n(), Percentage = round((Count / nrow(data) * 100), 2)) %>%
    unique()
  
  title <- paste0("Q", i, ". ", questions[i])
  
  ggplot(df, aes(!!var2, y = Percentage, fill = TA_median)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(x = "Responses", y = "Percentage", title = title) +
    scale_fill_manual(name = "Technology Attitude", values = c(uhg1, uhg2, uhg3)) +
    theme_joy_s
  
}

## MTUAS


plot_age_mtuas <- function(data, question_item1, question_item2, subscales_question){
  
  question_item1 <- enquo(question_item1)
  question_item2 <- rlang::sym(question_item2)
  
  df <- data %>%
    select(!!question_item1, Age) %>%
    group_by(!!question_item1, Age) %>%
    mutate(Count = n(), Percent = round((Count / nrow(data) * 100), 1)) %>%
    unique()
  
  if(subscales_question == "Usage"){
    
  ggplot(df, aes(!!question_item2, y = Percent, fill = Age)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(x = "", y = "Percent") +
    scale_fill_manual(name = "Age Group", values = c(uhg1, uhg2, uhg3, uhg4, uhg5, uhg6)) +
    theme_joy_s +
    coord_flip() 
    
  } else {
    
    ggplot(df, aes(!!question_item2, y = Percent, fill = Age)) +
      geom_bar(stat = "identity", position = "stack") +
      labs(x = "", y = "Percent") +
      scale_fill_manual(name = "Age Group", values = c(uhg1, uhg2, uhg3, uhg4, uhg5, uhg6)) +
      theme_joy_s 
    
  }
  
}

plot_gender_mtuas <- function(data, question_item1, question_item2, subscales_question, i, 
                              mtuas_question = NULL){
  
  question_item1 <- enquo(question_item1)
  question_item2 <- rlang::sym(question_item2)
  
  df <- data %>%
    select(!!question_item1, Gender) %>%
    group_by(!!question_item1, Gender) %>%
    mutate(Count = n(), Percent = round((Count / nrow(data) * 100), 1)) %>%
    unique()
  

  if(subscales_question == "Usage"){
    questions <- c("Send, receive and read e-mails (not including spam or junk mail)", 
                   "Check your personal e-mail", "Check your work or school e-mail", 
                   "Send or receive files via e-mail",
                    
                   'Send and receive text messages on a mobile phone', 
                   'Make and receive mobile phone calls', 'Check for text messages on a mobile phone',
                   'Check for voice calls on a mobile phone', 'Read e-mail on a mobile phone', 
                   'Get directions or use GPS on a mobile phone', 'Browse the web on a mobile phone', 
                   'Listen to music on a mobile phone', 'Take pictures using a mobile phone', 
                   'Check the news on a mobile phone', 'Record video on a mobile phone ', 
                   'Use apps (for any purpose) on a mobile phone', 'Search for information with a mobile phone', 
                   'Use your mobile phone during class or work time',
                   
                   'Watch TV shows, movies, etc. on a TV set', 'Watch video clips on a TV set', 
                   'Watch TV shows, movies, etc. on a computer', 'Watch video clips on a computer', 
                   'Download media files from other people on a computer', 'Share your own media files on a computer', 
                   'Search the Internet for news on any device', 'Search the Internet for information on any device', 
                   'Search the Internet for videos on any device', 
                   'Search the Internet for images or photos on any device', 
                   'Play games on a computer, video game console or smartphone BY YOURSELF', 
                   'Play games on a computer, video game console or smartphone WITH OTHER PEOPLE IN THE SAME ROOM',
                   'Play games on a computer, video game console or smartphone WITH OTHER PEOPLE ONLINE',
                   
                   'Check your Facebook page or other social networks', 
                   'Check your Facebook page from your smartphone', 'Check Facebook at work or school', 
                   'Post status updates', 'Post photos', 'Browse profiles and photos', 'Read postings', 
                   'Comment on postings, status updates, photos, etc', 'Click "Like" to a posting, photo, etc',
                   
                   'How many friends do you have on Facebook?', 'How many of your Facebook friends do you know in person?', 
                   'How many people have you met online that you have never met in person?', 
                   'How many people do you regularly interact with online that you have never met in person?')
                   
    plot_title <- paste0("Q", i, ". ", questions[i])
    
    ggplot(df, aes(!!question_item2, y = Percent, fill = Gender)) +
      geom_bar(stat = "identity", position = "stack") +
      labs(x = "", y = "Percent", title = plot_title) +
      scale_fill_manual(name = "Gender", values = c(uhg1, uhg2)) +
      theme_joy_s +
      theme(legend.title=element_blank()) + 
      coord_flip()
   
                   
  } else if (subscales_question == "Attitudes"){
    questions <- c('I feel it is important to be able to find any information whenever \nI want online', 
                   'I feel it is important to be able to access the Internet any time I want', 
                   'I think it is important to keep up with the latest trends in technology', 
                   'I get anxious when I don\'t have my cell phone.', 
                   'I get anxious when I don\'t have the Internet available to me', 
                   'I am dependent on my technology', 
                   'Technology will provide solutions to many of our problems', 
                   'With technology anything is possible', 
                   'I feel that I get more accomplished because of technology', 
                   'New technology makes people waste too much time', 
                   'New technology makes life more complicated', 
                   'New technology makes people more isolated', 
                   'I prefer to work on several projects in a day, rather than \ncompleting one project and then switching to another', 
                   'When doing a number of assignments, I like to switch back and \nforth between them rather than do one at a time', 
                   'I like to finish one task completely before focusing on anything else', 
                   'When I have a task to complete, I like to break it up by \nswitching to other tasks intermittently')
    
    text_size_ = 8
    plot_title <- paste0("Q", i, ". ", questions[i])
    ggplot(df, aes(!!question_item2, y = Percent, fill = Gender)) +
      geom_bar(stat = "identity", position = "stack") +
      labs(x = "", y = "Percent", title = plot_title) +
      scale_fill_manual(name = "Gender", values = c(uhg1, uhg2)) +
      theme_joy_s +
      theme(legend.title=element_blank()) 
    
  } else {
    stop("mtuas_question argument only accepts 1, 2, 3, 4, 7, 8, 9")
  }
    
}


plot_gender_mtuas_ <- function(data, question_item1, question_item2, mtuas_question, i){
  
  if(mtuas_question == 1){
    questions <- c("Send, receive and read e-mails \n(not including spam or junk mail)", 
                   "Check your personal e-mail", "Check your work or school e-mail", 
                   "Send or receive files via e-mail")
  } else if (mtuas_question == 2){
    questions <- c('Send and receive text messages on a mobile phone', 
                   'Make and receive mobile phone calls', 'Check for text messages on a mobile phone',
                   'Check for voice calls on a mobile phone', 'Read e-mail on a mobile phone', 
                   'Get directions or use GPS on a mobile phone', 'Browse the web on a mobile phone', 
                   'Listen to music on a mobile phone', 'Take pictures using a mobile phone', 
                   'Check the news on a mobile phone', 'Record video on a mobile phone ', 
                   'Use apps (for any purpose) on a mobile phone', 'Search for information with a mobile phone', 
                   'Use your mobile phone during class or work time')
  } else if (mtuas_question == 3){  
    questions <- c('Watch TV shows, movies, etc. on a TV set', 'Watch video clips on a TV set', 
                   'Watch TV shows, movies, etc. on a computer', 'Watch video clips on a computer', 
                   'Download media files from other people on a computer', 'Share your own media files on a computer', 
                   'Search the Internet for news on any device', 'Search the Internet for information on any device', 
                   'Search the Internet for videos on any device', 
                   'Search the Internet for images or photos on any device', 
                   'Play games on a computer, video game console or smartphone BY YOURSELF', 
                   'Play games on a computer, video game console or smartphone WITH OTHER PEOPLE IN THE SAME ROOM',
                   'Play games on a computer, video game console or smartphone WITH OTHER PEOPLE ONLINE')
  } else if (mtuas_question == 4){  
    questions <-c ('Do you have a Facebook account?')
  } else if (mtuas_question == 7){  
    questions <-c ('Check your Facebook page or other social networks', 
                   'Check your Facebook page from your smartphone', 'Check Facebook at work or school', 
                   'Post status updates', 'Post photos', 'Browse profiles and photos', 'Read postings', 
                   'Comment on postings, status updates, photos, etc', 'Click "Like" to a posting, photo, etc')
  } else if (mtuas_question == 8){
    questions <- c('How many friends do you have on Facebook?', 'How many of your Facebook friends do you know in person?', 
                   'How many people have you met online that you have never met in person?', 
                   'How many people do you regularly interact with online that you have never met in person?')
  } else if (mtuas_question == 9){
    questions <- c('I feel it is important to be able to find any information whenever \nI want online', 
                   'I feel it is important to be able to access the Internet any time I want', 
                   'I think it is important to keep up with the latest trends in technology', 
                   'I get anxious when I don\'t have my cell phone.', 
                   'I get anxious when I don\'t have the Internet available to me', 
                   'I am dependent on my technology', 
                   'Technology will provide solutions to many of our problems', 
                   'With technology anything is possible', 
                   'I feel that I get more accomplished because of technology', 
                   'New technology makes people waste too much time', 
                   'New technology makes life more complicated', 
                   'New technology makes people more isolated', 
                   'I prefer to work on several projects in a day, rather than completing one project \nand then switching to another', 
                   'When doing a number of assignments, I like to switch back and \nforth between them rather than do one at a time', 
                   'I like to finish one task completely before focusing on anything else', 
                   'When I have a task to complete, I like to break it up by switching to other tasks intermittently')
    
  } else {
    stop("mtuas_question argument only accepts 1, 2, 3, 4, 7, 8, 9")
  }
  
  
  question_item1 <- enquo(question_item1)
  question_item2 <- rlang::sym(question_item2)
  
  df <- data %>%
    select(!!question_item1, Gender) %>%
    group_by(!!question_item1, Gender) %>%
    mutate(Count = n(), Percent = round((Count / nrow(data) * 100), 1)) %>%
    unique()
  
  plot_title <- paste0("Q", i, ". ", questions[i])
  
  ggplot(df, aes(!!question_item2, y = Percent, fill = Gender)) +
    geom_bar(stat = "identity", position = "stack") +
    labs(x = "", y = "Percent", title = plot_title) +
    scale_fill_manual(name = "Gender", values = c(uhg1, uhg2)) +
    theme_joy_s +
    theme(legend.title=element_blank()) + 
    coord_flip() 
}
