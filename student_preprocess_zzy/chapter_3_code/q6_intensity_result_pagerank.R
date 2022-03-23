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
library(ggpubr)
library(gplots)
library(Rmisc)
library(Hmisc)


setwd("D:\\R_test\\social\\z_master_thesis")

#setwd("E:\\social\\z_master_thesis")
#user_pagerank <- fread("E:\\social\\z_master_thesis\\bothcriteria\\pagerank.csv")
#user_pagerank <- fread("/home/zhiyue/TemporalAnalysis/pagerank.csv")


criteria_vec = c("nofilter", "remove1interaction", "receivernosend",  "bothcriteria")
#col <- c("gender_source", "gender_target", "source_id", "target_id", "type", "timestamp")
col <- c("target_id", "count_top", "sum_rec_intensity", "gender_target", "rank", "percentage")
i=4

testcase = criteria_vec[i]

#path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full.csv")

#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path= paste0("/home/zhiyue/TemporalAnalysis/action_with_gender_full.csv")
#path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_num_top_0.1_percentage.csv")

data <- fread(path, header = FALSE,skip = 1)%>%setnames(col)

#data[,week := ceiling((timestamp-min(timestamp))/604800)]
#data[,timestamp:=NULL]
#data$gender_source <- ifelse(data$gender_source == "1", "M", "F")
#data$gender_target <- ifelse(data$gender_target == "1", "M", "F")

#get user between week 100 to week 300
#data_100 <- data%>% filter(week %in% (200:300))


#filter the user who do not first appearing after week 100

#data_before100 <- data%>% filter(week %in% (1:200))

#users_before_100 =  c(unique(data_before100[,.(target_id)])[[1]], unique(data_before100[,.(source_id)][[1]]))%>%unique()

#data_100 <- data_100 %>% filter(target_id %nin% (users_before_100))

#users_first_100 =  c(unique(data_100[,.(target_id)])[[1]], unique(data_100[,.(source_id)][[1]]))%>%unique()


#

#data_temp <- data%>% filter(week %in% (200:300))

#data <- data_temp%>% filter(target_id %in% (users_first_100))

#users_indegree <- data[,.(indegree = n_distinct(source_id)),by = .(gender_target,target_id,week)]


## intensity
### all users
users_rec_intensity <- data

## temporal analysis
########################################################

  
  males_user_rec_intensity <- users_rec_intensity[gender_target == "M",]
  females_user_rec_intensity <- users_rec_intensity[gender_target == "F",]
  
  #weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_user_rec_intensity$target_id, 
  #                                                            "males_group_rec_intensity", 
  #                                                            ifelse(target_id %in% females_user_rec_intensity$target_id,  
  #                                                                   "females_group_rec_intensity",
  #                                                                   "others")), by = .(week)]
  

  
  get_average_male <- function(weekly = males_user_rec_intensity){
    mean_value <- mean(weekly$count_top)
    
    return(mean_value)
  }
  
  get_average_female <- function(weekly = females_user_rec_intensity){
    mean_value <- mean(weekly$count_top)
    
    return(mean_value)
  }
  
  male_week_data <- get_average_male(males_user_rec_intensity)
  
  mean_male_print <- paste("mean_male_",i,"_percent: ",male_week_data)
  
  print(mean_male_print)
  
  female_week_data <- get_average_female(females_user_rec_intensity)
  
  mean_female_print <- paste("mean_female_",i,"_percent: ",female_week_data)
  
  print(mean_female_print)
  #########################################################################
  #########################################################################
  #ANOVA ·½²î·ÖÎö
  
  #p <- paste("duration_top",i,"_group_reach_top_week.jpg")
  
  #  get_data_array_anova_rec_intensity <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
  #  data_array_anova_rec_intensity <- summarySE(get_data_array_anova_rec_intensity, measurevar="reach_top_week", groupvars=c("gender_target","week"))
  
  #extrafont::loadfonts()
  #ggplot()+geom_line(data = male_average,aes(x = week,y = reach_top_week,colour = "male_group"),size=1)+
  #  geom_point(data = male_average,aes(x = week,y = reach_top_week,colour = "male_group"),size=3)+
  #  geom_line(data = female_average,aes(x = week,y = reach_top_week,colour ="female_group"),size=1) + 
  #  geom_point(data = female_average,aes(x = week,y = reach_top_week,colour = "female_group"),size=3)+
  #  scale_colour_manual("",values = c("male_group" = "red","female_group" = "green"))+
  #  xlab("week")+ylab("number_users_reach_top_week_percentage")+
  #  theme(text=element_text(size=13, family="Comic Sans MS"))
  #ggsave(p)
  
  
  
  #########################################################################
#}

#########################################################################
########################################################
########################################################
