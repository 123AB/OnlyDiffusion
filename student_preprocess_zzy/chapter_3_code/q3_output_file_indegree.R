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

users_indegree <- data[,.(indegree = n_distinct(source_id)),by = .(gender_target,target_id,week)]

data_filter <- users_indegree[, list(week=min(week)), by = target_id]

data_filter2 <- users_indegree[, .SD[which.max(indegree)], by = target_id]

data_filter3 <- as.data.table(users_indegree)

peak <- data_filter3[, length(which(indegree == max(indegree))),by = .(target_id)]

names(data_filter)[names(data_filter) == "week"] <- "first_week"

names(data_filter2)[names(data_filter2) == "week"] <- "top_week"

names(peak)[names(peak) == "V1"] <- "num_top_week" 

activity_week <-  data_filter3[, length(which(indegree == indegree)),by = .(target_id)]

names(activity_week)[names(activity_week) == "V1"] <- "active_week"

data_filter2$gender_target <- NULL

data_filter2$indegree <- NULL


#data_filter<- data %>% mutate(first_week = aggregate(week~target_id, data, function(x)min(x)))

combine_data <- inner_join(users_indegree, data_filter, by = "target_id")

combine_data <- inner_join(combine_data, data_filter2, by = "target_id")

combine_data <- inner_join(combine_data, peak, by = "target_id")

combine_data <- inner_join(combine_data, activity_week, by = "target_id")

end_week <- 303

new_combine_data <- combine_data[, .(duration = end_week - first_week),by = .(target_id)]

new_combine_data <- as.data.table(new_combine_data[!duplicated(new_combine_data$target_id), ])

combine_data <- inner_join(combine_data, new_combine_data, by = "target_id")

new_combine_data2 <- combine_data[, .(duration_percentage = active_week/duration),by = .(target_id)]

new_combine_data2 <- as.data.table(new_combine_data2[!duplicated(new_combine_data2$target_id), ])

combine_data <- inner_join(combine_data, new_combine_data2, by = "target_id")
#########################################################################
########################################################
########################################################

write.csv(combine_data, "D:\\R_test\\social\\z_master_thesis\\q5_output_active_indegree.csv", row.names = FALSE)
