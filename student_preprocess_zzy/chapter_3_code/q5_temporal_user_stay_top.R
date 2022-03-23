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
col <- c("gender_target", "target_id", "week", "rec_intensity", "first_week", "top_week")
i=4

testcase = criteria_vec[i]

#path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full.csv")

#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path= paste0("/home/zhiyue/TemporalAnalysis/action_with_gender_full.csv")
#path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2_firstTop.csv")

data <- fread(path, header = FALSE)%>%setnames(col)

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
users_rec_intensity <- data[, .(rec_intensity = .N),by = .(gender_target, target_id,week,first_week, top_week)]

## temporal analysis
########################################################
########################################################
##top percent intensity
#rec_intensity_percentage <- c(0.001, 0.01, 0.05, 0.1)
#rec_intensity_percentage <- c(0.1)

groupBy_user_rec_intensity <- users_rec_intensity[  , .(sum_rec_intensity = sum(rec_intensity), gender_target = unique(gender_target)), by = target_id]

groupBy_user_rec_intensity_rank <- groupBy_user_rec_intensity%>%mutate(rank = rank(-sum_rec_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))

rec_intensity_total_row <- nrow(groupBy_user_rec_intensity_rank)

######################################################## Duration analysis top 0.01 percent rec_intensity
#for(i in rec_intensity_percentage){
  
i = 0.001  
rec_intensity_total_percent_test <- round(rec_intensity_total_row * i)
  
rec_intensity_percent_ByPopulation_test <- groupBy_user_rec_intensity_rank%>% filter(rank %in% (1:rec_intensity_total_percent_test)) 
  
user_rec_intensity_temp_test <-  groupBy_user_rec_intensity%>%  filter(target_id %in% (rec_intensity_percent_ByPopulation_test$target_id))
  

  
  
  
  #########################################################################
#}

#########################################################################
########################################################
########################################################


## temporal analysis
########################################################
########################################################
##top percent intensity
rec_intensity_percentage <- c(0.001, 0.01, 0.05, 0.1)

week_keeper <- c(1:288)


######################################################## Duration analysis top 0.01 percent rec_intensity
#for(k in rec_intensity_percentage){
  
  k = 0.001  
  #for(w in week_keeper){
  w = 100
  #user_at_week <- filter(users_rec_intensity$week == w)
  user_at_week <- users_rec_intensity[week == w,]
  #user_at_week <- users_rec_intensity
  
  groupBy_user_rec_intensity_rank <- groupBy_user_rec_intensity_rank %>% filter(target_id %in% (user_at_week$target_id))
        
  rec_intensity_total_row <- nrow(groupBy_user_rec_intensity_rank)
    
  rec_intensity_total_percent <- round(rec_intensity_total_row * k)
  
  #abc <- groupBy_user_rec_intensity_rank%>% filter((rank(rank)<rec_intensity_total_percent)) #added by test
  
  #print(abc)
  
  rec_intensity_percent_ByPopulation <- groupBy_user_rec_intensity_rank%>% filter((rank(rank)<rec_intensity_total_percent))
  
  #user_rec_intensity_temp <-  groupBy_user_rec_intensity%>%  filter(target_id %in% (rec_intensity_percent_ByPopulation$target_id))
  user_rec_intensity_temp <- rec_intensity_percent_ByPopulation
  
  user_rec_intensity_temp_2 <-  user_rec_intensity_temp_test%>%  filter(target_id %in% (rec_intensity_percent_ByPopulation$target_id))
  
  percentage_user <- nrow(user_rec_intensity_temp_2) / nrow(user_rec_intensity_temp)
  
  print(percentage_user)

  #########################################################################
  #########################################################################
  #}
#}