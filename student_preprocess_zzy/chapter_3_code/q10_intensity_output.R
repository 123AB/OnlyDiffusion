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

#data_filter <- data %>% select(target_id,week) %>% unique()
users_rec_intensity <- data[, .(rec_intensity = .N),by = .(gender_target, target_id,week)]

#options(digits = 3)

users_rec_intensity_test <- data[, .(gender_ratio = round((sum(gender_source == "M")/sum(source_id == source_id)),3)),by = .(target_id,week)]

get_average_gender_ratio <- function(weekly = data){
  weekly_prob_top1 <- weekly[order(week), .(gender_ratio = (sum(gender_source == "M")/sum(source_id == source_id))),by = .(target_id,week)]%>%
    .[, .(gender_ratio) ,by = .(target_id,week)]
  
  weekly_prob_combined <- rbind(weekly_prob_top1)
  
  return(weekly_prob_combined)
}

gender_ratio <- get_average_gender_ratio(data)


##top percent intensity
rec_intensity_percentage <- c(0.001, 0.01, 0.05, 0.1)
#rec_intensity_percentage <- c(0.1)

groupBy_user_rec_intensity <- users_rec_intensity[  , .(sum_rec_intensity = sum(rec_intensity), gender_target = unique(gender_target)), by = target_id]

groupBy_user_rec_intensity_rank <- groupBy_user_rec_intensity%>%mutate(rank = rank(-sum_rec_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))

rec_intensity_total_row <- nrow(groupBy_user_rec_intensity_rank)

for(i in rec_intensity_percentage){
 
  rec_intensity_total_percent <- round(rec_intensity_total_row * i)
  
  rec_intensity_percent_ByPopulation <- groupBy_user_rec_intensity_rank%>% filter(rank %in% (1:rec_intensity_total_percent)) 
  
  rec_intensity_percent_ByPopulation <- rec_intensity_percent_ByPopulation[gender_target == "F",]
  
  user_rec_intensity_temp <-  gender_ratio%>%  filter(target_id %in% (rec_intensity_percent_ByPopulation$target_id))
  
  week_keeper <- c(1:303)
  
  l <- data.frame(week = numeric(),topMales = numeric(),topPopulation = numeric())
  col_l <- c("week", "gender_ratio")

  for(w in week_keeper){
  
    user_at_week <- user_rec_intensity_temp[week == w,]
    
    user_at_week_mean <- mean(user_at_week$gender_ratio)
    
    model_data <- c(w,user_at_week_mean)

    l <- rbind(l,model_data)
    
    
  }
  
  l <- l %>%setnames(col_l)
  
  if(i  == 0.001){
    l1 <- l
  } else if (i == 0.01){
    l2 <- l
  } else if (i == 0.05){
    l3 <- l
  } else if (i == 0.1){
    l4 <- l
  }
   
}

p <- paste("intensity",i,"_interaction_percentage_ratio.jpg")

ggplot()+geom_line(data = l1,aes(x = week,y = gender_ratio,colour = "top 0.1% female"),size=1)+
  geom_line(data = l2,aes(x = week,y = gender_ratio,colour = "top 1% female"),size=1)+
  geom_line(data = l3,aes(x = week,y = gender_ratio,colour ="top 5% female"),size=1) + 
  geom_line(data = l4,aes(x = week,y = gender_ratio,colour = "top 10% female"),size=1)+
  scale_colour_manual("",values = c("top 0.1% female" = "red",
                                    "top 1% female" = "blue", "top 5% female" = "green", "top 10% female" = "purple"))+
  xlab("week")+ylab("percentage")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave(p)
#users_rec_intensity_test <- users_rec_intensity_test %>% mutate(across(is.numeric, ~ round(., 5)))

#data_filter <- users_rec_intensity[, list(week=min(week)), by = target_id]

#data_filter2 <- users_rec_intensity[, .SD[which.max(rec_intensity)], by = target_id]

#data_filter3 <- as.data.table(users_rec_intensity)

#peak <- data_filter3[, length(which(rec_intensity >= (max(rec_intensity) - max(rec_intensity)*0.10))),by = .(target_id)]


#names(data_filter)[names(data_filter) == "week"] <- "first_week"

#names(data_filter2)[names(data_filter2) == "week"] <- "top_week"

#names(peak)[names(peak) == "V1"] <- "num_top_week" 

#data_filter2$gender_target <- NULL

#data_filter2$rec_intensity <- NULL

#combine_data <- inner_join(users_rec_intensity, data_filter, by = "target_id")

#combine_data <- inner_join(combine_data, data_filter2, by = "target_id")

#combine_data <- inner_join(combine_data, peak, by = "target_id")
#########################################################################
########################################################
########################################################

#write.csv(combine_data, "D:\\R_test\\social\\z_master_thesis\\q7_output_stay_top_intensity.csv", row.names = FALSE)
