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


setwd("E:\\social\\z_master_thesis")
user_pagerank <- fread("E:\\social\\z_master_thesis\\bothcriteria\\pagerank.csv")


criteria_vec = c("nofilter", "remove1interaction", "receivernosend",  "bothcriteria")
col <- c("gender_source", "gender_target", "source_id", "target_id", "type", "timestamp")
i=4

testcase = criteria_vec[i]

#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender.csv")
path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")


data <- fread(path, header = FALSE)%>%setnames(col)

data[,week := ceiling((timestamp-min(timestamp))/604800)]
data[,timestamp:=NULL]
data$gender_source <- ifelse(data$gender_source == "1", "M", "F")
data$gender_target <- ifelse(data$gender_target == "1", "M", "F")

users =  c(unique(data[,.(target_id)])[[1]], unique(data[,.(source_id)][[1]]))%>%unique()
  
users_table <- rbind(data[,.(id = source_id, gender = gender_source)]%>%as.data.frame()%>%distinct(id,gender), 
                       data[,.(id = target_id, gender = gender_target)]%>%as.data.frame()%>%distinct(id, gender))%>%distinct(id, gender)

users_indegree <- data[,.(indegree = n_distinct(source_id)),by = .(gender_target,target_id,week)]
users_indegree_like <- data[type=="like",.(indegree = n_distinct(source_id)),by = .(gender_target,target_id)]
users_indegree_comment <- data[type=="comment",.(indegree = n_distinct(source_id)),by = .(gender_target,target_id)]
users_indegree_rank <- users_indegree%>%mutate(rank = rank(-indegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))

  
males_indegree <- users_indegree[gender_target == "M",,]
females_indegree <- users_indegree[gender_target == "F",,]
users_outdegree <- data[,.(outdegree = n_distinct(target_id)),by = .(gender_source, source_id)]
males_outdegree <- users_outdegree[gender_source == "M",,]
females_outdegree <- users_outdegree[gender_source == "F",,]
users_outdegree_rank <- users_outdegree%>%mutate(rank = rank(-outdegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
  ## intensity
  ### all users
users_sent_intensity <- data[, .(sent_intensity = .N),by = .(gender_source, source_id)]
users_rec_intensity <- data[, .(rec_intensity = .N),by = .(gender_target, target_id,week)]
  
users_sent_intensity_rank <- users_sent_intensity%>%mutate(rank = rank(-sent_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
users_rec_intensity_rank <- users_rec_intensity%>%mutate(rank = rank(-rec_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))

males_sent_intensity <- users_sent_intensity[gender_source == "M",]
females_sent_intensity <- users_sent_intensity[gender_source == "F",]
males_rec_intensity <- users_rec_intensity[gender_target == "M",]
females_rec_intensity <- users_rec_intensity[gender_target == "F",]

user_pagerank <- user_pagerank%>%left_join(users_table, by = "id")
user_pagerank_rank <- user_pagerank%>%mutate(rank = rank(-pagerank, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
  
users_table_rank <-   users_table %>% left_join(users_indegree_rank, by = c("gender" = "gender_target","id"="target_id"))
  
  ## temporal analysis
users_indegree_rank <- users_indegree%>%arrange(desc(indegree))%>%mutate(rank = rank(-indegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))

  

########################################################
########################################################
## Duration analysis top 1 percent intensity
temp_users_rec_intensity <- users_rec_intensity
get_top1_population <- temp_users_rec_intensity%>%mutate(rank = rank(-rec_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
get_top1_population_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM get_top1_population")
real_top1_population_intensity <- distinct(get_top1_population_intensity, target_id, .keep_all = TRUE)
intensity1_total_row <- nrow(real_top1_population_intensity)
intensity_total_percent1 <- round(intensity1_total_row * 0.01)


sql_intensity1_total_percent <- paste("SELECT * FROM real_top1_population_intensity limit",intensity_total_percent1,collapse = "+")

top1_population_intensity <- sqldf(sql_intensity1_total_percent)
setDT(top1_population_intensity)
males_in_top1_intensity <- top1_population_intensity[gender_target == "M",]
males_in_top1_intensity_row <- nrow(males_in_top1_intensity)
##########################################################

males_rec_intensity <- users_rec_intensity[gender_target == "M",]
females_rec_intensity <- users_rec_intensity[gender_target == "F",]

males_rec_intensity_rank<-males_rec_intensity%>%mutate(rank = rank(-rec_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
females_rec_intensity_rank<-females_rec_intensity%>%mutate(rank = rank(-rec_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))


get_top1_males_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM males_rec_intensity_rank")

real_top1_males_intensity <- distinct(get_top1_males_intensity, target_id, .keep_all = TRUE)

intensity1_m_row <- nrow(real_top1_males_intensity)
intensity_m_percent1 <- round(intensity1_m_row * 0.01)


sql_intensity1_m_percent <- paste("SELECT * FROM real_top1_males_intensity limit",intensity_m_percent1,collapse = "+")

top1_males_intensity <- sqldf(sql_intensity1_m_percent)

get_top1_females_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM females_rec_intensity_rank")

real_top1_females_intensity <- distinct(get_top1_females_intensity, target_id, .keep_all = TRUE)

intensity1_fm_row <- nrow(real_top1_females_intensity)
intensity_fm_percent1 <- round(intensity1_fm_row * 0.01)

sql_intensity1_fm_percent <- paste("SELECT * FROM real_top1_males_intensity limit",intensity_fm_percent1,collapse = "+")

top1_females_intensity <- sqldf(sql_intensity1_fm_percent)



males_group1_new <- sqldf("SELECT target_id FROM top1_males_intensity ")

males_group1 <- as.integer.integer64(unlist(males_group1_new[1]))

females_group1_new <- sqldf("SELECT target_id FROM top1_females_intensity ")

females_group1 <- as.integer.integer64(unlist(females_group1_new[1]))

males_group3 <- males_rec_intensity_rank[rank<=300 & rank>100,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_rec_intensity_rank)

weekly_male_people_group <- copy(top1_males_intensity)

weekly_female_people_group <- copy(top1_females_intensity)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group1, 
                                                 "male_group1", 
                                                 ifelse(target_id %in% females_group1,  
                                                        "female_group1",
                                                        ifelse(target_id %in% males_group3,
                                                               "male_group3",
                                                               "others"))), by = .(week)]




weekly_gender_group1 <- weekly_gender_people_group

weekly_gender_group2 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group1[target_id %in% males_group1, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group2[target_id %in% females_group1, by = .(week)]

get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top1 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "male_group1",]
  

  weekly_prob_combined <- rbind(weekly_prob_top1)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top1_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top1_avr_tep[1,2]))
  
  weekly_prob_top1_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "male_group1_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top1_avr)
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top1 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  weekly_prob_combined <- rbind(weekly_prob_top1)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top1_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top1_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "female_group1_avr",]
  
  weekly_prob_combined <- rbind(weekly_prob_top1_avr)
  return(weekly_prob_combined)
}

duration_all_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_all_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_all_males_average <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_all_females_average <- get_duration_avr_male(weekly = weekly_gender_people_group_females)

ggplot()+geom_line(data = duration_all_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_1"),size=1)+
  geom_point(data = duration_all_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_1"),size=3)+
  geom_line(data = duration_all_females,aes(x = week,y = sum_intensity,colour ="female_group_intensity_1"),size=1) + 
  geom_point(data = duration_all_females,aes(x = week,y = sum_intensity,colour = "female_group_intensity_1"),size=3)+
  geom_line(data = duration_all_males_average,aes(x = week,y = average_intensity,colour = "male_group1_avr"),size=1)+
  geom_point(data = duration_all_males_average,aes(x = week,y = average_intensity,colour = "male_group1_avr"),size=3)+
  geom_line(data = duration_all_females_average,aes(x = week,y = average_intensity,colour = "female_group1_avr"),size=1)+
  geom_point(data = duration_all_females_average,aes(x = week,y = average_intensity,colour = "female_group1_avr"),size=3)+
  scale_colour_manual("",values = c("male_group_intensity_1" = "red","female_group_intensity_1" = "green",
                                    "male_group1_avr" = "blue","female_group1_avr" = "yellow"))+
  xlab("week")+ylab("sum_intensity")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top1_intensity.jpg")



#########################################################################
#########################################################################
#ANOVA 方差分析
get_data_array_anova <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova <- summarySE(get_data_array_anova, measurevar="rec_intensity", groupvars=c("gender_target","week"))

ggplot(data_array_anova, aes(x=week, y=rec_intensity, colour=gender_target)) + 
  geom_errorbar(aes(ymin=rec_intensity-se, ymax=rec_intensity+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top1_intensity_anova.jpg")

#########################################################################


########################################################
########################################################
## Duration analysis top 5 percent intensity

#top100_males_intensity <- males_rec_intensity_rank[rank<=10,.(target_id),][[1]]
get_top5_males_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM males_rec_intensity_rank")

real_top5_males_intensity <- distinct(get_top5_males_intensity, target_id, .keep_all = TRUE)

intensity5_m_row <- nrow(real_top5_males_intensity)
intensity_m_percent5 <- round(intensity5_m_row * 0.05)

sql_intensity5_m_percent <- paste("SELECT * FROM real_top5_males_intensity limit",intensity_m_percent5,collapse = "+")

top5_males_intensity <- sqldf(sql_intensity5_m_percent)

get_top5_females_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM females_rec_intensity_rank")

real_top5_females_intensity <- distinct(get_top5_females_intensity, target_id, .keep_all = TRUE)

intensity5_fm_row <- nrow(real_top5_females_intensity)
intensity_fm_percent5 <- round(intensity5_fm_row * 0.05)

sql_intensity5_fm_percent <- paste("SELECT * FROM real_top5_females_intensity limit",intensity_fm_percent5,collapse = "+")

top5_females_intensity <- sqldf(sql_intensity5_fm_percent)

males_group2_new <- sqldf("SELECT target_id FROM top5_males_intensity ")

males_group2 <- as.integer.integer64(unlist(males_group2_new[1]))

females_group2_new <- sqldf("SELECT target_id FROM top5_females_intensity ")

females_group2 <- as.integer.integer64(unlist(females_group2_new[1]))

males_group3 <- males_rec_intensity_rank[rank<=300 & rank>100,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_rec_intensity_rank)

weekly_male_people_group <- copy(top5_males_intensity)

weekly_female_people_group <- copy(top5_females_intensity)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group2, 
                                                            "male_group2", 
                                                            ifelse(target_id %in% females_group2,  
                                                                   "female_group2",
                                                                   ifelse(target_id %in% males_group3,
                                                                          "male_group3",
                                                                          "others"))), by = .(week)]




weekly_gender_group_top5 <- weekly_gender_people_group

weekly_gender_group_sec_top5 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group_top5[target_id %in% males_group2, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group_sec_top5[target_id %in% females_group2, by = .(week)]


get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top5 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "male_group2",]
  
  weekly_prob_combined <- rbind(weekly_prob_top5)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top5 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "female_group2",]
  
  weekly_prob_combined <- rbind(weekly_prob_top5)
  
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top5_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top5_avr_tep[1,2]))
  
  weekly_prob_top5_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "male_group_intensity_5_avr",]
  
  weekly_prob_combined <- rbind(weekly_prob_top5_avr)
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top5_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top5_avr_tep[1,2]))
  
  weekly_prob_top5_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "female_group_intensity_5_avr",]
  
  weekly_prob_combined <- rbind(weekly_prob_top5_avr)
  return(weekly_prob_combined)
}

duration_top5_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top5_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_top5_males_avr <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_top5_females_avr <- get_duration_avr_female(weekly = weekly_gender_people_group_females)


ggplot()+geom_line(data = duration_top5_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_5"),size=1)+
  geom_point(data = duration_top5_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_5"),size=3)+
  geom_line(data = duration_top5_females,aes(x = week,y = sum_intensity,colour ="female_group_intensity_5"),size=1) + 
  geom_point(data = duration_top5_females,aes(x = week,y = sum_intensity,colour = "female_group_intensity_5"),size=3)+
  geom_line(data = duration_top5_males_avr,aes(x = week,y = average_intensity,colour = "male_group_intensity_5_avr"),size=0.5)+
  #geom_point(data = duration_top100_males_avr,aes(x = week,y = average_intensity,colour = "male_group_intensity_100_avr"),size=3)+
  geom_line(data = duration_top5_females_avr,aes(x = week,y = average_intensity,colour = "female_group_intensity_5_avr"),size=0.5)+
  #geom_point(data = duration_top100_females_avr,aes(x = week,y = average_intensity,colour = "female_group_intensity_100_avr"),size=3)+
  scale_colour_manual("",values = c("male_group_intensity_5" = "red","female_group_intensity_5" = "green",
                                    "male_group_intensity_5_avr" = "blue","female_group_intensity_5_avr" = "yellow"))+
  xlab("week")+ylab("sum_intensity")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top5_intensity.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
get_data_array_anova_ins_5 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_ins_5 <- summarySE(get_data_array_anova_ins_5, measurevar="rec_intensity", groupvars=c("gender_target","week"))

ggplot(data_array_anova_ins_5, aes(x=week, y=rec_intensity, colour=gender_target)) + 
  geom_errorbar(aes(ymin=rec_intensity-se, ymax=rec_intensity+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top5_intensity_anova.jpg")

#########################################################################

########################################################
########################################################
## Duration analysis top 10 intensity

get_top10_males_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM males_rec_intensity_rank")

real_top10_males_intensity <- distinct(get_top10_males_intensity, target_id, .keep_all = TRUE)

intensity10_m_row <- nrow(real_top10_males_intensity)
intensity_m_percent10 <- round(intensity10_m_row * 0.10)

sql_intensity10_m_percent <- paste("SELECT * FROM real_top10_males_intensity limit",intensity_m_percent10,collapse = "+")

top10_males_intensity <- sqldf(sql_intensity10_m_percent)
get_top10_females_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM females_rec_intensity_rank")

real_top10_females_intensity <- distinct(get_top10_females_intensity, target_id, .keep_all = TRUE)

intensity10_fm_row <- nrow(real_top10_females_intensity)
intensity_fm_percent10 <- round(intensity10_fm_row * 0.10)

sql_intensity10_fm_percent <- paste("SELECT * FROM real_top10_females_intensity limit",intensity_fm_percent10,collapse = "+")

top10_females_intensity <- sqldf(sql_intensity10_fm_percent)
males_group3_new <- sqldf("SELECT target_id FROM top10_males_intensity ")

males_group3 <- as.integer.integer64(unlist(males_group3_new[1]))

females_group3_new <- sqldf("SELECT target_id FROM top10_females_intensity ")

females_group3 <- as.integer.integer64(unlist(females_group3_new[1]))

males_group_other <- males_rec_intensity_rank[rank<=500 & rank>300,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_rec_intensity_rank)

weekly_male_people_group <- copy(top10_males_intensity)

weekly_female_people_group <- copy(top10_females_intensity)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group3, 
                                                            "male_group3", 
                                                            ifelse(target_id %in% females_group3,  
                                                                   "female_group3",
                                                                   ifelse(target_id %in% males_group_other,
                                                                          "males_group_other",
                                                                          "others"))), by = .(week)]




weekly_gender_group_top10 <- weekly_gender_people_group

weekly_gender_group_sec_top10 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group_top10[target_id %in% males_group3, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group_sec_top10[target_id %in% females_group3, by = .(week)]

get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top10 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "males_group3",]
  
  weekly_prob_combined <- rbind(weekly_prob_top10)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top10 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "females_group3",]
  
  weekly_prob_combined <- rbind(weekly_prob_top10)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "female_10_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}

get_duration_avr_female_per_person <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, per_fm_average_intensity = sum(rec_intensity)/288/intensity_fm_percent10)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, per_fm_average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(per_fm_average_intensity),by = .(week)]%>%.[,type := "female_10_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "male_10_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}

get_duration_avr_male_per_person <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, per_m_average_intensity = sum(rec_intensity)/288/intensity_m_percent10)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, per_m_average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(per_m_average_intensity),by = .(week)]%>%.[,type := "male_10_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}



duration_top10_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top10_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_top10_males_avr <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_top10_females_avr <- get_duration_avr_female(weekly = weekly_gender_people_group_females)
duration_top10_males_avr_per_m <- get_duration_avr_male_per_person(weekly = weekly_gender_people_group_males)
duration_top10_females_avrper_fm <- get_duration_avr_female_per_person(weekly = weekly_gender_people_group_females)


ggplot()+geom_line(data = duration_top10_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_10"),size=1)+
  geom_point(data = duration_top10_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_10"),size=3)+
  geom_line(data = duration_top10_females,aes(x = week,y = sum_intensity,colour ="female_group_intensity_10"),size=1) + 
  geom_point(data = duration_top10_females,aes(x = week,y = sum_intensity,colour = "female_group_intensity_10"),size=3)+
  geom_line(data = duration_top10_males_avr,aes(x = week,y = average_intensity,colour = "male_10_avr"),size=1)+
  geom_point(data = duration_top10_males_avr,aes(x = week,y = average_intensity,colour = "male_10_avr"),size=3)+
  geom_line(data = duration_top10_females_avr,aes(x = week,y = average_intensity,colour = "female_10_avr"),size=1)+
  geom_point(data = duration_top10_females_avr,aes(x = week,y = average_intensity,colour = "female_10_avr"),size=3)+
  geom_line(data = duration_top10_males_avr_per_m,aes(x = week,y = per_m_average_intensity,colour = "male_10_avr_per_m"),size=1)+
  geom_line(data = duration_top10_females_avrper_fm,aes(x = week,y = per_fm_average_intensity,colour = "female_10_avr_per_m"),size=1)+
  
  scale_colour_manual("",values = c("male_group_intensity_10" = "red","female_group_intensity_10" = "green",
                                    "male_10_avr" = "blue","female_10_avr" = "yellow","female_10_avr_per_m" = "black",
                                    "female_10_avr_per_m" = "orange"))+
  xlab("week")+ylab("sum_intensity")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top10_intensity.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
get_data_array_anova_ins_10 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_ins_10 <- summarySE(get_data_array_anova_ins_10, measurevar="rec_intensity", groupvars=c("gender_target","week"))

ggplot(data_array_anova_ins_10, aes(x=week, y=rec_intensity, colour=gender_target)) + 
  geom_errorbar(aes(ymin=rec_intensity-se, ymax=rec_intensity+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top10_intensity_anova.jpg")

#########################################################################

########################################################
########################################################
## Duration analysis top 1 indegree
males_indegree <- users_indegree[gender_target == "M",]
females_indegree <- users_indegree[gender_target == "F",]

males_indegree_rank<-males_indegree%>%mutate(rank = rank(-indegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
females_indegree_rank<-females_indegree%>%mutate(rank = rank(-indegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
get_top1_males_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM males_indegree_rank")

real_top1_males_indegree <- distinct(get_top1_males_indegree, target_id, .keep_all = TRUE)

indegree1_m_row <- nrow(real_top1_males_indegree)
indegree_m_percent1 <- round(indegree1_m_row * 0.01)

sql_indegree1_m_percent <- paste("SELECT * FROM real_top1_males_indegree limit",indegree_m_percent1,collapse = "+")

top1_males_indegree <- sqldf(sql_indegree1_m_percent)

get_top1_females_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM females_indegree_rank")

real_top1_females_indegree <- distinct(get_top1_females_indegree, target_id, .keep_all = TRUE)

indegree1_fm_row <- nrow(real_top1_females_indegree)
indegree_fm_percent1 <- round(indegree1_fm_row * 0.01)

sql_indegree1_fm_percent <- paste("SELECT * FROM real_top1_females_indegree limit",indegree_fm_percent1,collapse = "+")

top1_females_indegree <- sqldf(sql_indegree1_fm_percent)
males_group_indegree_get_1 <- sqldf("SELECT target_id FROM top1_males_indegree ")

males_group_indegree_1 <- as.integer.integer64(unlist(males_group_indegree_get_1[1]))

females_group_indegree_get_1 <- sqldf("SELECT target_id FROM top1_females_indegree ")

females_group_indegree_1 <- as.integer.integer64(unlist(females_group_indegree_get_1[1]))

males_group3 <- males_indegree_rank[rank<=300 & rank>100,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_indegree_rank)

weekly_male_people_group <- copy(top1_males_indegree)

weekly_female_people_group <- copy(top1_females_indegree)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group_indegree_1, 
                                                            "males_group_indegree_1", 
                                                            ifelse(target_id %in% females_group_indegree_1,  
                                                                   "females_group_indegree_1",
                                                                   ifelse(target_id %in% males_group3,
                                                                          "male_group3",
                                                                          "others"))), by = .(week)]




weekly_gender_group_top1 <- weekly_gender_people_group

weekly_gender_group_sec_top1 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group_top1[target_id %in% males_group_indegree_1, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group_sec_top1[target_id %in% females_group_indegree_1, by = .(week)]

get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top1 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "males_group_indegree_1",]

  weekly_prob_combined <- rbind(weekly_prob_top1)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top1 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "females_group_indegree_1",]
 
  weekly_prob_combined <- rbind(weekly_prob_top1)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top1_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top1_avr_tep[1,2]))

  weekly_prob_top1_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "female_1_indegree_avr",]

  
  weekly_prob_combined <- rbind(weekly_prob_top1_avr)
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top1_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top1_avr_tep[1,2]))
  
  weekly_prob_top1_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "male_1_indegree_avr",]

  

  weekly_prob_combined <- rbind(weekly_prob_top1_avr)
  return(weekly_prob_combined)
}

duration_top1_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top1_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_all_males_average <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_all_females_average <- get_duration_avr_female(weekly = weekly_gender_people_group_females)

##########################################################

############################################################

ggplot()+geom_line(data = duration_top1_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_1"),size=1)+
  geom_point(data = duration_top1_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_1"),size=3)+
  geom_line(data = duration_top1_females,aes(x = week,y = sum_indegree,colour ="females_group_indegree_1"),size=1) + 
  geom_point(data = duration_top1_females,aes(x = week,y = sum_indegree,colour = "females_group_indegree_1"),size=3)+
  geom_line(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_1_indegree_avr"),size=1)+
  geom_point(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_1_indegree_avr"),size=3)+
  geom_line(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_1_indegree_avr"),size=1)+
  geom_point(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_1_indegree_avr"),size=3)+
  scale_colour_manual("",values = c("males_group_indegree_1" = "red","females_group_indegree_1" = "green",
                                    "male_1_indegree_avr" = "blue","female_1_indegree_avr" = "yellow"))+
  xlab("week")+ylab("sum_indegree")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top1_indegree.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
get_data_array_anova_in_1 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_in_1 <- summarySE(get_data_array_anova_in_1, measurevar="indegree", groupvars=c("gender_target","week"))

ggplot(data_array_anova_in_1, aes(x=week, y=indegree, colour=gender_target)) + 
  geom_errorbar(aes(ymin=indegree-se, ymax=indegree+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top1_indegree_anova.jpg")

#########################################################################

########################################################
########################################################
## Duration analysis top 5 indegree

get_top5_males_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM males_indegree_rank")

real_top5_males_indegree <- distinct(get_top5_males_indegree, target_id, .keep_all = TRUE)

indegree5_m_row <- nrow(real_top5_males_indegree)
indegree_m_percent5 <- round(indegree5_m_row * 0.05)

sql_indegree5_m_percent <- paste("SELECT * FROM real_top5_males_indegree limit",indegree_m_percent5,collapse = "+")

top5_males_indegree <- sqldf(sql_indegree5_m_percent)

get_top5_females_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM females_indegree_rank")

real_top5_females_indegree <- distinct(get_top5_females_indegree, target_id, .keep_all = TRUE)

indegree5_fm_row <- nrow(real_top5_females_indegree)
indegree_fm_percent5 <- round(indegree5_fm_row * 0.05)

sql_indegree5_fm_percent <- paste("SELECT * FROM real_top5_females_indegree limit",indegree_fm_percent5,collapse = "+")

top5_females_indegree <- sqldf(sql_indegree5_fm_percent)

males_group_indegree_get_5 <- sqldf("SELECT target_id FROM top5_males_indegree ")

males_group_indegree_5 <- as.integer.integer64(unlist(males_group_indegree_get_5[1]))

females_group_indegree_get_5 <- sqldf("SELECT target_id FROM top5_females_indegree ")

females_group_indegree_5 <- as.integer.integer64(unlist(females_group_indegree_get_5[1]))

males_group3 <- males_indegree_rank[rank<=300 & rank>100,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_indegree_rank)

weekly_male_people_group <- copy(top5_males_indegree)

weekly_female_people_group <- copy(top5_females_indegree)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group_indegree_5, 
                                                            "males_group_indegree_5", 
                                                            ifelse(target_id %in% females_group_indegree_5,  
                                                                   "females_group_indegree_5",
                                                                   ifelse(target_id %in% males_group3,
                                                                          "male_group3",
                                                                          "others"))), by = .(week)]




weekly_gender_group_top5 <- weekly_gender_people_group

weekly_gender_group_sec_top5 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group_top5[target_id %in% males_group_indegree_5, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group_sec_top5[target_id %in% females_group_indegree_5, by = .(week)]

get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top5 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "males_group_indegree_5",]
  
  weekly_prob_combined <- rbind(weekly_prob_top5)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top5 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "females_group_indegree_5",]
  
  weekly_prob_combined <- rbind(weekly_prob_top5)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top5_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top100_avr_tep[1,2]))
  
  weekly_prob_top5_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "female_5_indegree_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top5_avr)
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top5_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top5_avr_tep[1,2]))
  
  weekly_prob_top5_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "male_5_indegree_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top5_avr)
  return(weekly_prob_combined)
}

##########################################################



duration_top5_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top5_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_all_males_average <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_all_females_average <- get_duration_avr_male(weekly = weekly_gender_people_group_females)

ggplot()+geom_line(data = duration_top5_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_5"),size=1)+
  geom_point(data = duration_top5_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_5"),size=3)+
  geom_line(data = duration_top5_females,aes(x = week,y = sum_indegree,colour ="females_group_indegree_5"),size=1) + 
  geom_point(data = duration_top5_females,aes(x = week,y = sum_indegree,colour = "females_group_indegree_5"),size=3)+
  geom_line(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_5_indegree_avr"),size=1)+
  geom_point(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_5_indegree_avr"),size=3)+
  geom_line(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_5_indegree_avr"),size=1)+
  geom_point(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_5_indegree_avr"),size=3)+
  scale_colour_manual("",values = c("males_group_indegree_5" = "red","females_group_indegree_5" = "green",
                                    "male_5_indegree_avr" = "blue","female_5_indegree_avr" = "yellow"))+
  xlab("week")+ylab("sum_indegree")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top5_indegree.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
get_data_array_anova_in_5 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_in_5 <- summarySE(get_data_array_anova_in_5, measurevar="indegree", groupvars=c("gender_target","week"))

ggplot(data_array_anova_in_5, aes(x=week, y=indegree, colour=gender_target)) + 
  geom_errorbar(aes(ymin=indegree-se, ymax=indegree+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top5_indegree_anova.jpg")

#########################################################################

########################################################
########################################################
## Duration analysis top 10 indegree

get_top10_males_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM males_indegree_rank")

real_top10_males_indegree <- distinct(get_top10_males_indegree, target_id, .keep_all = TRUE)

indegree10_m_row <- nrow(real_top10_males_indegree)
indegree_m_percent10 <- round(indegree10_m_row * 0.10)

sql_indegree10_m_percent <- paste("SELECT * FROM real_top10_males_indegree limit",indegree_m_percent10,collapse = "+")

top10_males_indegree <- sqldf(sql_indegree10_m_percent)


get_top10_females_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM females_indegree_rank")

real_top10_females_indegree <- distinct(get_top10_females_indegree, target_id, .keep_all = TRUE)

indegree10_fm_row <- nrow(real_top10_females_indegree)
indegree_fm_percent10 <- round(indegree10_fm_row * 0.10)

sql_indegree10_fm_percent <- paste("SELECT * FROM real_top10_females_indegree limit",indegree_fm_percent10,collapse = "+")

top10_females_indegree <- sqldf(sql_indegree10_fm_percent)

males_group_indegree_get_10 <- sqldf("SELECT target_id FROM top10_males_indegree ")

males_group_indegree_10 <- as.integer.integer64(unlist(males_group_indegree_get_10[1]))

females_group_indegree_get_10 <- sqldf("SELECT target_id FROM top10_females_indegree ")

females_group_indegree_10 <- as.integer.integer64(unlist(females_group_indegree_get_10[1]))

males_group3 <- males_indegree_rank[rank<=500 & rank>300,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_indegree_rank)

weekly_male_people_group <- copy(top10_males_indegree)

weekly_female_people_group <- copy(top10_females_indegree)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group_indegree_10, 
                                                            "males_group_indegree_10", 
                                                            ifelse(target_id %in% females_group_indegree_10,  
                                                                   "females_group_indegree_10",
                                                                   ifelse(target_id %in% males_group3,
                                                                          "male_group3",
                                                                          "others"))), by = .(week)]




weekly_gender_group_top10 <- weekly_gender_people_group

weekly_gender_group_sec_top10 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group_top10[target_id %in% males_group_indegree_10, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group_sec_top10[target_id %in% females_group_indegree_10, by = .(week)]



get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top10 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "males_group_indegree_10",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top10 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "females_group_indegree_10",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "female_10_indegree_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/288)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "male_10_indegree_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}

##########################################################

############################################################

duration_top10_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top10_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_all_males_average <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_all_females_average <- get_duration_avr_male(weekly = weekly_gender_people_group_females)

ggplot()+geom_line(data = duration_top10_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_10"),size=1)+
  geom_point(data = duration_top10_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_10"),size=3)+
  geom_line(data = duration_top10_females,aes(x = week,y = sum_indegree,colour ="females_group_indegree_10"),size=1) + 
  geom_point(data = duration_top10_females,aes(x = week,y = sum_indegree,colour = "females_group_indegree_10"),size=3)+
  geom_line(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_10_indegree_avr"),size=1)+
  geom_point(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_10_indegree_avr"),size=3)+
  geom_line(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_10_indegree_avr"),size=1)+
  geom_point(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_10_indegree_avr"),size=3)+
  scale_colour_manual("",values = c("males_group_indegree_10" = "red","females_group_indegree_10" = "green",
                                    "male_10_indegree_avr" = "blue","female_10_indegree_avr" = "yellow"))+  xlab("week")+ylab("sum_indegree")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top10_indegree.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
get_data_array_anova_in_10 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_in_10 <- summarySE(get_data_array_anova_in_10, measurevar="indegree", groupvars=c("gender_target","week"))

ggplot(data_array_anova_in_10, aes(x=week, y=indegree, colour=gender_target)) + 
  geom_errorbar(aes(ymin=indegree-se, ymax=indegree+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top10_indegree_anova.jpg")

#########################################################################



