# Title     : TODO
# Objective : TODO
# Created by: 14496
# Created on: 2021-02-05

# Title     : TODO
# Objective : TODO
# Created by: 14496
# Created on: 2021-01-14

library(bit64)
library(data.table)
library(dplyr)
library(ggplot2)
library(magrittr)
library(reshape2)
library(lubridate)
library(scales)
library(zoo)
library(sqldf)
#library(ggpubr)
library(gplots)
library(Rmisc)
library(Hmisc)


setwd("D:\\R_test\\social\\z_master_thesis")

#setwd("E:\\social\\z_master_thesis")
#user_pagerank <- fread("E:\\social\\z_master_thesis\\bothcriteria\\pagerank.csv")
#user_pagerank <- fread("/home/zhiyue/TemporalAnalysis/pagerank.csv")


criteria_vec = c("nofilter", "remove1interaction", "receivernosend",  "bothcriteria")
col <- c("gender_source", "gender_target", "source_id", "target_id", "type", "timestamp")
i=4

testcase = criteria_vec[i]

path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full.csv")

#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path= paste0("/home/zhiyue/TemporalAnalysis/action_with_gender_full.csv")
#path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")


data <- fread(path, header = FALSE)%>%setnames(col)

data[,week := ceiling((timestamp-min(timestamp))/604800)]
data[,timestamp:=NULL]
data$gender_source <- ifelse(data$gender_source == "1", "M", "F")
data$gender_target <- ifelse(data$gender_target == "1", "M", "F")

users_indegree <- data[,.(indegree = n_distinct(source_id)),by = .(gender_target,target_id,week)]


##################################################
##################################################
# trying to find top user among the entirely dataset

groupBy_user_rec_intensity <- users_indegree[  , .(sum_indegree = sum(indegree), gender_target = unique(gender_target)), by = target_id]

rec_intensity_percentage <- c(0.001, 0.01, 0.05, 0.1,1)

###################################################
###################################################
for(i in rec_intensity_percentage){
  
  groupBy_user_rec_intensity_rank_original <- groupBy_user_rec_intensity%>%mutate(rank = rank(-sum_indegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
  
  groupBy_user_rec_intensity_rank <- groupBy_user_rec_intensity_rank_original[gender_target == "F",]
  
  m_groupBy_user_rec_intensity_rank <- groupBy_user_rec_intensity_rank_original[gender_target == "M",]
  
  
  rec_intensity_total_row <- nrow(groupBy_user_rec_intensity_rank)
  
  
  rec_intensity_total_percent_test <- round(rec_intensity_total_row * i)
  
  rec_intensity_percent_ByPopulation_test <- groupBy_user_rec_intensity_rank%>% filter(rank %in% (1:rec_intensity_total_percent_test)) 
  
  
  rec_intensity_total_row_m <- nrow(m_groupBy_user_rec_intensity_rank)
  
  
  rec_intensity_total_percent_test_m <- round(rec_intensity_total_row_m * i)
  
  rec_intensity_percent_ByPopulation_test_m <- m_groupBy_user_rec_intensity_rank%>% filter(rank %in% (1:rec_intensity_total_percent_test_m)) 
  
  groupBy_user_rec_intensity_rank_m <- rec_intensity_percent_ByPopulation_test_m
  
  
  #################################################
  #################################################
  
  rec_intensity_total_percent_test_f <- round(rec_intensity_total_row * 0.1)
  
  rec_intensity_percent_ByPopulation_test_f <- groupBy_user_rec_intensity_rank%>% filter(rank %in% (1:rec_intensity_total_percent_test_f)) 
  
  groupBy_user_rec_intensity_rank_f <- rec_intensity_percent_ByPopulation_test_f
  
  
  ## temporal analysis
  ########################################################
  ########################################################
  ##top percent intensity
  #rec_intensity_percentage2 <- c(0.001, 0.01, 0.05, 0.1)
  #rank_result <- groupBy_user_rec_intensity_rank
  #X <- rec_intensity_percent_ByPopulation_test
  #week_keeper <- c(1:288)
  week_keeper <- c(1:303)
  
  #l <- data.frame()
  l <- data.frame(week = numeric(),topMales = numeric(),topPopulation = numeric(),maleNum = numeric(),femaleNum = numeric(), totalNum= numeric())
  l_f <-data.frame(week = numeric(),topMales = numeric(),topPopulation = numeric(),maleNum = numeric(),femaleNum = numeric(), totalNum= numeric())
  col_l <- c("week", "topMales", "topPopulation","maleNum","femaleNum","totalNum")
  col_f <- c("week", "topFemales", "topPopulation","maleNum","femaleNum","totalNum")
  
  
  
  #l <- data.frame(week = numeric())
  #lname <- c("week","topMales","topPopulation") #top_male_percentage_in_males, top_male_percentage_in_population
  #colnames(l) <- lname
  ######################################################## Duration analysis top 0.01 percent rec_intensity
  #for(k in rec_intensity_percentage2){
  #k = 0.05
  for(w in week_keeper){
    #w = 70  
    user_at_week <- data[week == w,]
    
    groupBy_user_at_week_rank <- user_at_week %>% filter(target_id %in% (rec_intensity_percent_ByPopulation_test_m$target_id))
    
    if(dim(groupBy_user_at_week_rank)[1] != 0){
      
      
      male_groupBy_user_at_week_rank <- groupBy_user_at_week_rank[gender_source == "M",]
      
      female_groupBy_user_at_week_rank <- groupBy_user_at_week_rank[gender_source == "F",]
      
      if(dim(male_groupBy_user_at_week_rank)[1] != 0){
        
        male_female_interaction <- male_groupBy_user_at_week_rank %>% filter(source_id %in% (groupBy_user_rec_intensity_rank_m$target_id))
        
        male_female_interaction_m <- nrow(male_female_interaction)/nrow(male_groupBy_user_at_week_rank) # 排名前列男性占据当周男性互动人口比例
        
        male_female_interaction_population <- nrow(male_female_interaction)/nrow(groupBy_user_at_week_rank) #排名前列男性占据当周全体互动人口比例
        
        
        male_female_mean_female <- nrow(male_female_interaction)
        
        male_female_mean_male <- nrow(male_groupBy_user_at_week_rank)
        
        male_female_mean_group_user <- nrow(groupBy_user_at_week_rank)
        
        #groupBy_user_rec_intensity_rank_week <- groupBy_user_rec_intensity_rank %>% filter(target_id %in% (user_at_week$target_id))
        
        #rec_intensity_total_row2 <- nrow(groupBy_user_rec_intensity_rank_week)
        
        model_data <- c(w,male_female_interaction_m,male_female_interaction_population,male_female_mean_female,male_female_mean_male,male_female_mean_group_user)
        #model_data <- c(w)
        #l[nrow(l)+1,] <- rbind(l,model_data)
        l <- rbind(l,model_data)
        
        if(dim(female_groupBy_user_at_week_rank)[1] != 0){  
          
          male_female_interaction_second <- female_groupBy_user_at_week_rank %>% filter(source_id %in% (groupBy_user_rec_intensity_rank_f$target_id))
          
          male_female_interaction_f <- nrow(male_female_interaction_second)/nrow(female_groupBy_user_at_week_rank) # 排名前列男性占据当周男性互动人口比例
          
          male_female_interaction_population_f <- nrow(male_female_interaction_second)/nrow(groupBy_user_at_week_rank) #排名前列男性占据当周全体互动人口比例
          
          male_female_mean_female <- nrow(male_female_interaction_second)
          
          male_female_mean_male <- nrow(female_groupBy_user_at_week_rank)
          
          male_female_mean_group_user <- nrow(female_groupBy_user_at_week_rank)
          
          model_data_f <- c(w,male_female_interaction_f,male_female_interaction_population_f,male_female_mean_female,male_female_mean_male,male_female_mean_group_user)
          

          
          l_f <- rbind(l_f, model_data_f)
          
        }
        
        
        
      }
      
    }
    
  }
  l <- l %>%setnames(col_l)
  l_f <- l_f %>% setnames(col_f)
  #  p <- paste("D:\\R_test\\social\\z_master_thesis\\action_with_gender_full_num_top_",i,"_interaction_percentage.csv")
  #  write.csv(l, p , row.names = FALSE)
    if(i  == 0.001){
      l1 <- l
    } else if (i == 0.01){
      l2 <- l
    } else if (i == 0.05){
      l3 <- l
    } else if (i == 0.1){
      l4 <- l
    }
  
  if(i  == 0.001){
    l5 <- l_f
  } else if (i == 0.01){
    l6 <- l_f
  } else if (i == 0.05){
    l7 <- l_f
  } else if (i == 0.1){
    l8 <- l_f
  }
  
  p <- paste("indegree_",i,"_interaction_percentage.jpg")
  
  ggplot()+geom_line(data = l,aes(x = week,y = topMales,colour = "topMales_in_Males_Per_Week"),size=1)+
    geom_line(data = l,aes(x = week,y = topPopulation,colour = "topMales_in_Population_per_week"),size=1)+
    geom_line(data = l_f,aes(x = week,y = topFemales,colour ="topFemales_in_Females_Per_Week"),size=1) + 
    geom_line(data = l_f,aes(x = week,y = topPopulation,colour = "topFemales_in_Population_per_week"),size=1)+
    scale_colour_manual("",values = c("topMales_in_Males_Per_Week" = "red",
                                      "topMales_in_Population_per_week" = "blue", "topFemales_in_Females_Per_Week" = "green", "topFemales_in_Population_per_week" = "purple"))+
    xlab("week")+ylab("percentage")+
    theme(text=element_text(size=13, family="Comic Sans MS"))
  ggsave(p)
  
  print(mean(l$topMales))
  print(mean(l$topPopulation))
  print(mean(l$maleNum))
  print(mean(l$femaleNum))
  print(mean(l$totalNum))
  print("male finish!")
  
  print(mean(l_f$topFemales))
  print(mean(l_f$topPopulation))
  print(mean(l_f$maleNum))
  print(mean(l_f$femaleNum))
  print(mean(l_f$totalNum))
  #pp <- paste("D:\\R_test\\social\\z_master_thesis\\action_with_gender_full_num_top_",i,"_interaction_percentage.csv")
  #write.csv(l, pp , row.names = FALSE, col.names = TRUE, sep=",")
  ppp <- paste("D:\\R_test\\social\\z_master_thesis\\action_with_gender_full_num_top_",i,"_interaction_percentage_indegree_f.csv")
  #write.csv(l_f, file = ppp , row.names = F, col.names = TRUE)
  write.table(l_f, file = ppp , row.names = F,  sep = ",")
  
}

#####################################################
#####################################################
#options(digits = 3)

#users_rec_intensity_test <- data[, .(gender_ratio = round((sum(gender_source == "M")/sum(source_id == source_id)),3)),by = .(target_id,week)]

#users_rec_intensity_test <- users_rec_intensity_test %>% mutate(across(is.numeric, ~ round(., 5)))

#data_filter <- users_rec_intensity[, list(week=min(week)), by = target_id]

#data_filter2 <- users_rec_intensity[, .SD[which.max(rec_intensity)], by = target_id]

