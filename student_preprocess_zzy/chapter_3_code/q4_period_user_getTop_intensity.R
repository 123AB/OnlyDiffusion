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

col_pagerank <-c("user_id","pagerank")

i=4

testcase = criteria_vec[i]

#path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full.csv")

#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path= paste0("/home/zhiyue/TemporalAnalysis/action_with_gender_full.csv")
#path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\q6_output_reach_top_intensity.csv")

user_pagerank <- fread("D:\\R_test\\social\\z_master_thesis\\all_data\\ig\\pagerank\\Pagerank_sort_0.csv")%>%setnames(col_pagerank)

user_pagerank_rank <- user_pagerank%>%mutate(rank = rank(-pagerank, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))

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
users_rec_intensity <- data[, .(rec_intensity = .N),by = .(gender_target, target_id,week,first_week, top_week)]

## temporal analysis
########################################################
########################################################
##top percent intensity
rec_intensity_percentage <- c(0.001, 0.01, 0.05, 0.1)
#rec_intensity_percentage <- c(0.1)

groupBy_user_rec_intensity <- users_rec_intensity[  , .(sum_rec_intensity = sum(rec_intensity), gender_target = unique(gender_target)), by = target_id]

#groupBy_user_rec_intensity_rank <- groupBy_user_rec_intensity%>%mutate(rank = rank(-sum_rec_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))

#rec_intensity_total_row <- nrow(groupBy_user_rec_intensity_rank)

######################################################## Duration analysis top 0.01 percent rec_intensity
for(i in rec_intensity_percentage){
  
  #i = 0.1  
  #rec_intensity_total_percent <- round(rec_intensity_total_row * i)
  
  rec_intensity_percent_ByPopulation <- filter(user_pagerank_rank, percentage<=i)
  
  #rec_intensity_percent_ByPopulation <- groupBy_user_rec_intensity_rank%>% filter(rank %in% (1:rec_intensity_total_percent)) 
  
  user_rec_intensity_temp <-  groupBy_user_rec_intensity%>%  filter(target_id %in% (rec_intensity_percent_ByPopulation$user_id))
  
  #weekly_gender_people_group <- users_rec_intensity
  
  males_user_rec_intensity <- user_rec_intensity_temp[gender_target == "M",]
  females_user_rec_intensity <- user_rec_intensity_temp[gender_target == "F",]
  
  #weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_user_rec_intensity$target_id, 
  #                                                            "males_group_rec_intensity", 
  #                                                            ifelse(target_id %in% females_user_rec_intensity$target_id,  
  #                                                                   "females_group_rec_intensity",
  #                                                                   "others")), by = .(week)]
  
  weekly_gender_people_group <- users_rec_intensity %>% filter(target_id %in% males_user_rec_intensity$target_id)
  
  weekly_gender_people_group2 <- users_rec_intensity %>% filter(target_id %in% females_user_rec_intensity$target_id)
  
  
  weekly_gender_group_top <- weekly_gender_people_group
  
  weekly_gender_group_sec_top <- weekly_gender_people_group2
  
  #weekly_gender_people_group_males <- weekly_gender_group_top[target_id %in% males_user_rec_intensity$target_id, by = .(week)]
  
  #weekly_gender_people_group_females <- weekly_gender_group_sec_top[target_id %in% females_user_rec_intensity$target_id, by = .(week)]
  
  weekly_gender_people_group_males2 <-weekly_gender_group_top[gender_target == "M",]
  
  weekly_gender_people_group_males2 <- as.data.table(weekly_gender_people_group_males2[!duplicated(weekly_gender_people_group_males2$target_id), ])
  
  #weekly_gender_people_group_males2_row <- nrow(weekly_gender_people_group_males2)
  
  
  weekly_gender_people_group_females2 <- weekly_gender_group_sec_top[gender_target == "F",]
  
  weekly_gender_people_group_females2 <- as.data.table(weekly_gender_people_group_females2[!duplicated(weekly_gender_people_group_females2$target_id), ])
  
  #weekly_gender_people_group_females2_row <- nrow(weekly_gender_people_group_females2)
  
  
  get_average_male <- function(weekly = weekly_gender_people_group_males2){
    weekly_prob_top1 <- weekly[order(week), .(n = .N, reach_top_week = top_week - first_week),by = .(target_id)]%>%
      .[, .(reach_top_week) ,by = .(target_id)]%>%.[,type := "male_group",]
    
    weekly_prob_combined <- rbind(weekly_prob_top1)
    
    return(weekly_prob_combined)
  }
  
  get_average_female <- function(weekly = weekly_gender_people_group_females2){
    weekly_prob_top1 <- weekly[order(week), .(n = .N, reach_top_week = top_week- first_week),by = .(target_id)]%>%
      .[, .(reach_top_week) ,by = .(target_id)]%>%.[,type := "female_group",]
    
    weekly_prob_combined <- rbind(weekly_prob_top1)
    
    return(weekly_prob_combined)
  }
  
  male_week_data <- get_average_male(weekly_gender_people_group_males2)
  
  mean_male <- mean(male_week_data$reach_top_week)
  
  mean_male_print <- paste("mean_male_",i,"_percent: ",mean_male)
  
  mean_male_sd <- sd(male_week_data$reach_top_week)
  
  print(mean_male_print)
  
  print(mean_male_sd)
  
  print(nrow(weekly_gender_people_group_males2))
  
  female_week_data <- get_average_female(weekly_gender_people_group_females2)
  
  mean_female <- mean(female_week_data$reach_top_week)
  
  mean_female_print <- paste("mean_female_",i,"_percent: ",mean_female)
  
  mean_female_sd <- sd(female_week_data$reach_top_week)
  
  print(mean_female_print)
  
  print(mean_female_sd)
  
  print(nrow(weekly_gender_people_group_females2))
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
}

#########################################################################
########################################################
########################################################
