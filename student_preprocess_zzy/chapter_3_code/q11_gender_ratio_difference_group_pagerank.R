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

#col_pagerank <-c("user_id", "gender", "pagerank")
col_pagerank <-c("user_id","pagerank")

i=4

testcase = criteria_vec[i]

path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full.csv")

#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path= paste0("/home/zhiyue/TemporalAnalysis/action_with_gender_full.csv")
#path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")

user_pagerank <- fread("D:\\R_test\\social\\z_master_thesis\\all_data\\ig\\pagerank\\Pagerank_sort_0.csv")%>%setnames(col_pagerank)

#user_pagerank <- fread("D:\\R_test\\social\\z_master_thesis\\pagerank\\interact.csv")%>%setnames(col_pagerank)

user_pagerank_rank <- user_pagerank%>%mutate(rank = rank(-pagerank, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))


data <- fread(path, header = FALSE)%>%setnames(col)

data[,week := ceiling((timestamp-min(timestamp))/604800)]
data[,timestamp:=NULL]
data$gender_source <- ifelse(data$gender_source == "1", "M", "F")
data$gender_target <- ifelse(data$gender_target == "1", "M", "F")

users_rec_intensity <- data[, .(rec_intensity = .N),by = .(gender_target, target_id,week)]


##################################################
##################################################
# trying to find top user among the entirely dataset
groupBy_user_rec_intensity <- users_rec_intensity[  , .(sum_rec_intensity = sum(rec_intensity), gender_target = unique(gender_target)), by = target_id]

rec_intensity_percentage <- c(0.001, 0.01, 0.05, 0.1)
#rec_intensity_percentage <- c(0.1)

###################################################
###################################################
for(i in rec_intensity_percentage){
  
  #rec_intensity_percent_ByPopulation_test <- user_pagerank_rank
  #rec_intensity_percent_ByPopulation_test_m <- rec_intensity_percent_ByPopulation_test[gender == "1",]
  #rec_intensity_percent_ByPopulation_test_f <- rec_intensity_percent_ByPopulation_test[gender == "2",]
  #rec_intensity_percent_ByPopulation_test <- filter(rec_intensity_percent_ByPopulation_test_f, percentage<=i)
  #rec_intensity_percent_ByPopulation_test_m_r <- filter(rec_intensity_percent_ByPopulation_test_m, percentage<=i)
  rec_intensity_percent_ByPopulation_test <- filter(user_pagerank_rank, percentage<=i)
  rec_intensity_percent_ByPopulation_test_m <- data[gender_target == "M",] %>% filter(target_id %in% (rec_intensity_percent_ByPopulation_test$user_id))
  rec_intensity_percent_ByPopulation_test_f <- data[gender_target == "F",] %>% filter(target_id %in% (rec_intensity_percent_ByPopulation_test$user_id))
  
  #groupBy_user_rec_intensity_rank_m <- rec_intensity_percent_ByPopulation_test_m
  
  week_keeper <- c(1:303)
  
  l <- data.frame(week = numeric(),topMales = numeric(),topPopulation = numeric(),maleNum = numeric(),femaleNum = numeric(), totalNum= numeric())
  l_f <-data.frame(week = numeric(),topMales = numeric(),topPopulation = numeric(),maleNum = numeric(),femaleNum = numeric(), totalNum= numeric())
  col_l <- c("week", "topMales", "topPopulation","maleNum","femaleNum","totalNum")
  col_f <- c("week", "topFemales", "topPopulation","maleNum","femaleNum","totalNum")
  
  
    for(w in week_keeper){
    #w = 70  
    user_at_week <- data[week == w,]
    
    groupBy_user_at_week_rank <- user_at_week %>% filter(target_id %in% (rec_intensity_percent_ByPopulation_test$user_id))
    
    if(dim(groupBy_user_at_week_rank)[1] != 0){
      
      male_groupBy_user_at_week_rank <- groupBy_user_at_week_rank[gender_source == "M",]
      
      female_groupBy_user_at_week_rank <- groupBy_user_at_week_rank[gender_source == "F",]
      
      if(dim(male_groupBy_user_at_week_rank)[1] != 0){
        
        male_female_interaction <- male_groupBy_user_at_week_rank %>% filter(source_id %in% (rec_intensity_percent_ByPopulation_test_m$target_id))
        
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
          
          male_female_interaction_second <- female_groupBy_user_at_week_rank %>% filter(source_id %in% (rec_intensity_percent_ByPopulation_test_f$target_id))
          
          male_female_interaction_f <- nrow(male_female_interaction_second)/nrow(female_groupBy_user_at_week_rank) # 排名前列女性占据当周女性互动人口比例
          
          male_female_interaction_population_f <- nrow(male_female_interaction_second)/nrow(groupBy_user_at_week_rank) #排名前列女性占据当周全体互动人口比例
          
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
  #df_new <- data.frame(matrix(unlist(l), nrow = length(l), byrow = TRUE))
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
  
  ########################
  p <- paste("intensity_",i,"_interaction_percentage.jpg")
  
  ggplot()+geom_line(data = l,aes(x = week,y = topMales,colour = "topMales_in_Males_Per_Week"),size=1)+
    geom_line(data = l,aes(x = week,y = topPopulation,colour = "topMales_in_Population_per_week"),size=1)+
    geom_line(data = l_f,aes(x = week,y = topFemales,colour ="topFemales_in_Females_Per_Week"),size=1) + 
    geom_line(data = l_f,aes(x = week,y = topPopulation,colour = "topFemales_in_Population_per_week"),size=1)+
    scale_colour_manual("",values = c("topMales_in_Males_Per_Week" = "red",
                                      "topMales_in_Population_per_week" = "blue", "topFemales_in_Females_Per_Week" = "green", "topFemales_in_Population_per_week" = "purple"))+
    xlab("week")+ylab("percentage")+
    theme(text=element_text(size=13, family="Comic Sans MS"))
  ggsave(p)
  ########################
  df <- data.frame(sapply(l,c))
  #df <- setDT(df)
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
  pp <- paste("D:\\R_test\\social\\z_master_thesis\\action_with_gender_full_num_top_",i,"_interaction_percentage.csv")
  write.csv(df, pp, row.names = TRUE, col.names = TRUE, sep = ",")
  #ppp <- paste("D:\\R_test\\social\\z_master_thesis\\action_with_gender_full_num_top_",i,"_interaction_percentage_f.csv")
  #write.csv(l_f, file = ppp , row.names = F, col.names = TRUE)
  #write.table(l_f, file = ppp , row.names = F,  sep = ",")
  
}

