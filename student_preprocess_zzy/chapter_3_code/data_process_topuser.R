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
library(extrafont)
library(dbplyr)

setwd("D:\\R_test\\social\\z_master_thesis")

#setwd("/home/zhiyue/TemporalAnalysis")
#user_pagerank <- fread("E:\\social\\z_master_thesis\\bothcriteria\\pagerank.csv")
#user_pagerank <- fread("/home/zhiyue/TemporalAnalysis/pagerank.csv")



criteria_vec = c("nofilter", "remove1interaction", "receivernosend",  "bothcriteria")
col <- c("gender_source", "gender_target", "source_id", "target_id", "type", "timestamp")
i=4

testcase = criteria_vec[i]

#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full.csv")
#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")
#path= paste0("/home/zhiyue/TemporalAnalysis/action_with_gender_full.csv")
path = paste0("D:\\R_test\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full.csv")
#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_bothcriteria\\action_with_gender.csv")

data <- fread(path, header = FALSE)%>%setnames(col)

data[,week := ceiling((timestamp-min(timestamp))/604800)]
data[,timestamp:=NULL]
data$gender_source <- ifelse(data$gender_source == "1", "M", "F")
data$gender_target <- ifelse(data$gender_target == "1", "M", "F")

data_100 <- data%>% filter(week %in% (250:300))

users_first_100 =  c(unique(data_100[,.(target_id)])[[1]], unique(data_100[,.(source_id)][[1]]))%>%unique()

data_temp <- data%>% filter(week %in% (100:300))

data <- data_temp%>% filter(target_id %in% (users_first_100))

#users_table <- rbind(data[,.(id = source_id, gender = gender_source)]%>%as.data.frame()%>%distinct(id,gender), 
#                     data[,.(id = target_id, gender = gender_target)]%>%as.data.frame()%>%distinct(id, gender))%>%distinct(id, gender)

users_indegree <- data[,.(indegree = n_distinct(source_id)),by = .(gender_target,target_id,week)]
users_indegree_like <- data[type=="like",.(indegree = n_distinct(source_id)),by = .(gender_target,target_id)]
users_indegree_comment <- data[type=="comment",.(indegree = n_distinct(source_id)),by = .(gender_target,target_id)]

########## Get the indegree group by user
groupBy_user_indegree <- setNames(aggregate(users_indegree$indegree, by=list(target_id=users_indegree$target_id), FUN=sum),
                                  c("target_id","sum_indegree"))

groupBy_user_indegree_rank <- groupBy_user_indegree%>%mutate(rank = rank(-sum_indegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))

indegree_total_row <- nrow(groupBy_user_indegree_rank)
sum_indegree_percent100_ByPopulation <- sum(groupBy_user_indegree_rank$sum_indegree)
average_indegree_percent100_ByPopulation <- sum_indegree_percent100_ByPopulation / indegree_total_row
user_indegree_100 <- as.data.table(users_indegree[!duplicated(users_indegree$target_id), ])
sum(user_indegree_100$gender_target=="F")
sum(user_indegree_100$gender_target=="M")


## Duration analysis top 0.01 percent indegree by total population
#indegree_total_percent001 <- round(indegree_total_row * 0.0001)
#indegree_percent001_ByPopulation <- groupBy_user_indegree_rank%>% filter(rank %in% (1:indegree_total_percent001)) 
#sum_indegree_percent001_ByPopulation <- sum(indegree_percent001_ByPopulation$sum_indegree)
#average_indegree_percent001_ByPopulation <- sum_indegree_percent001_ByPopulation / indegree_total_percent001
#print(average_indegree_percent001_ByPopulation)
#user_indegree_001 <-  users_indegree%>%  filter(target_id %in% (indegree_percent001_ByPopulation$target_id))
#user_indegree_001 <- as.data.table(user_indegree_001[!duplicated(user_indegree_001$target_id), ])
#sum(user_indegree_001$gender_target=="F")
#sum(user_indegree_001$gender_target=="M")


## Duration analysis top 0.1 percent indegree by total population
indegree_total_percent01 <- round(indegree_total_row * 0.001)
indegree_percent01_ByPopulation <- groupBy_user_indegree_rank%>% filter(rank %in% (1:indegree_total_percent01)) 
sum_indegree_percent01_ByPopulation <- sum(indegree_percent01_ByPopulation$sum_indegree)
average_indegree_percent01_ByPopulation <- sum_indegree_percent01_ByPopulation / indegree_total_percent01
print(average_indegree_percent01_ByPopulation)
user_indegree_01 <-  users_indegree%>%  filter(target_id %in% (indegree_percent01_ByPopulation$target_id))
user_indegree_01 <- as.data.table(user_indegree_01[!duplicated(user_indegree_01$target_id), ])
sum(user_indegree_01$gender_target=="F")
sum(user_indegree_01$gender_target=="M")

## Duration analysis top 0.1 percent indegree by total population
indegree_total_percent1 <- round(indegree_total_row * 0.01)
indegree_percent1_ByPopulation <- groupBy_user_indegree_rank%>% filter(rank %in% (1:indegree_total_percent1)) 
sum_indegree_percent1_ByPopulation <- sum(indegree_percent1_ByPopulation$sum_indegree)
average_indegree_percent1_ByPopulation <- sum_indegree_percent1_ByPopulation / indegree_total_percent1
user_indegree_1 <-  users_indegree%>%  filter(target_id %in% (indegree_percent1_ByPopulation$target_id))
user_indegree_1 <- as.data.table(user_indegree_1[!duplicated(user_indegree_1$target_id), ])
sum(user_indegree_1$gender_target=="F")
sum(user_indegree_1$gender_target=="M")


## Duration analysis top 0.1 percent indegree by total population

indegree_total_percent5 <- round(indegree_total_row * 0.05)
indegree_percent5_ByPopulation <- groupBy_user_indegree_rank%>% filter(rank %in% (1:indegree_total_percent5)) 
sum_indegree_percent5_ByPopulation <- sum(indegree_percent5_ByPopulation$sum_indegree)
average_indegree_percent5_ByPopulation <- sum_indegree_percent5_ByPopulation / indegree_total_percent5

user_indegree_5 <-  users_indegree%>%  filter(target_id %in% (indegree_percent5_ByPopulation$target_id))
user_indegree_5 <- as.data.table(user_indegree_5[!duplicated(user_indegree_5$target_id), ])
sum(user_indegree_5$gender_target=="F")
sum(user_indegree_5$gender_target=="M")

## Duration analysis top 0.1 percent indegree by total population
indegree_total_percent10 <- round(indegree_total_row * 0.1)
indegree_percent10_ByPopulation <- groupBy_user_indegree_rank%>% filter(rank %in% (1:indegree_total_percent10)) 
sum_indegree_percent10_ByPopulation <- sum(indegree_percent10_ByPopulation$sum_indegree)
average_indegree_percent10_ByPopulation <- sum_indegree_percent10_ByPopulation / indegree_total_percent10

user_indegree_10 <-  users_indegree%>%  filter(target_id %in% (indegree_percent10_ByPopulation$target_id))
user_indegree_10 <- as.data.table(user_indegree_10[!duplicated(user_indegree_10$target_id), ])
sum(user_indegree_10$gender_target=="F")
sum(user_indegree_10$gender_target=="M")

#males_indegree <- users_indegree[gender_target == "M",,]
#females_indegree <- users_indegree[gender_target == "F",,]
#users_outdegree <- data[,.(outdegree = n_distinct(target_id)),by = .(gender_source, source_id)]
#males_outdegree <- users_outdegree[gender_source == "M",,]
#females_outdegree <- users_outdegree[gender_source == "F",,]
#users_outdegree_rank <- users_outdegree%>%mutate(rank = rank(-outdegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
## intensity
#data <- data%>% filter(week %in% (100:300))


#write.csv(x = data,file = "bigdog.csv")




