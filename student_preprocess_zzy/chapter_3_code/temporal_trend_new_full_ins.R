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

path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender.csv")
#path = paste0("E:\\social\\z_master_thesis\\dataset_whole\\dataset_", criteria_vec[i], "\\action_with_gender_full_sec_2.csv")


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
#users_indegree2 <- data[,.(indegree = source_id),by = .(gender_target,target_id,week)]

  
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
users_indegree_rank
  
  ### 
top10_users <- users_indegree_rank[rank<=10,.(target_id),][[1]] 
top11_100_users <- users_indegree_rank[rank<=100 & rank>10,.(target_id),][[1]]
top101_300_users <- users_indegree_rank[rank<=300 & rank>100,.(target_id),][[1]]
  
users_group1 <- users_indegree_rank[rank<=10,.(target_id),][[1]] 
users_group2 <- users_indegree_rank[rank<=100 & rank>10,.(target_id),][[1]]
users_group3 <- users_indegree_rank[rank<=300 & rank>100,.(target_id),][[1]]
  
users_group1 <- users_indegree_rank[rank<=50,.(target_id),][[1]] 
users_group2 <- users_indegree_rank[rank<=200 & rank>50,.(target_id),][[1]]
users_group3 <- users_indegree_rank[rank<=500 & rank>200,.(target_id),][[1]]
  ### all
weekly_group <- copy(data)
weekly_group_like <- copy(data[type=="like",,])

weekly_group_comment <- copy(data[type=="comment",,])
  
weekly_group[,user_group := ifelse(target_id %in% users_group1, 
                             "group1", 
                             ifelse(target_id %in% users_group2,  
                                    "group2",
                                    ifelse(target_id %in% users_group3,
                                           "group3",
                                           "others"))), by = .(week)]
weekly_group_like[,
                    user_group := ifelse(target_id %in% users_group1, 
                                         "group1", 
                                         ifelse(target_id %in% users_group2,
                                                "group2",ifelse(target_id %in% users_group3,
                                                            "group3","others"))), 
                    by = .(week)]
weekly_group_comment[,user_group := ifelse(target_id %in% top10_users, 
                       "group1", 
                       ifelse(target_id %in% top11_100_users,  
                              "group2",
                              ifelse(target_id %in% top101_300_users,
                                     "group3",
                                     "others"))), by = .(week)]
  
week_group_count <- weekly_group[order(week), .(n = .N),by = .(week, user_group)]
ggplot(week_group_count, aes(x = week, y=n, color = user_group))+
  geom_line()
  
get_temporal <- function(weekly = weekly_group){
  weekly_prob_top10 <- weekly[order(week), .(n = .N, prob = sum(user_group == "group1")/.N),by = .(week)]%>%
      .[, .(prob,
            UCI = prob + 1.96 * sqrt(prob*(1-prob)/n),
            LCI = prob - 1.96 * sqrt(prob*(1-prob)/n) 
      ) ,by = .(week)]%>%
      .[week>10,,]%>%
      .[,type := "group1",]
 weekly_prob_top11_100 <- weekly[order(week), .(n = .N, prob = sum(user_group == "group2")/.N),by = .(week)]%>%
      .[, .(prob,
            UCI = prob + 1.96 * sqrt(prob*(1-prob)/n),
            LCI = prob - 1.96 * sqrt(prob*(1-prob)/n)
      ) ,by = .(week)]%>%
      .[week>10,,]%>%
      .[,type := "group2",]
  weekly_prob_top101_300 <- weekly[order(week), .(n = .N, prob = sum(user_group == "group3")/.N),by = .(week)]%>%
      .[, .(prob,
            UCI = prob + 1.96 * sqrt(prob*(1-prob)/n),
            LCI = prob - 1.96 * sqrt(prob*(1-prob)/n)
      ) ,by = .(week)]%>%
      .[week>10,,]%>%
      .[,type := "group3",]
    
  weekly_prob_combined <- rbind(weekly_prob_top10,weekly_prob_top11_100, weekly_prob_top101_300)%>%mutate(type = factor(type, levels = c("group1", "group2", "group3")))

  return(weekly_prob_combined)
  }
  ##### 
temporal_all <- get_temporal(weekly = weekly_group)%>%mutate(criteria = "any")
temporal_like <- get_temporal(weekly = weekly_group_like)%>%mutate(criteria = "like")
temporal_comment <- get_temporal(weekly = weekly_group_comment)%>%mutate(criteria = "comment")
rbind(temporal_all, temporal_like, temporal_comment)%>%
    mutate(criteria = factor(criteria, levels = c("any", "like", "comment")))%>%
    ggplot(aes(x= week, y=prob, fill = type))+
    geom_line(lwd = 0.6, aes(color = type))+
    # geom_point()+
    geom_ribbon(aes(ymin = LCI, ymax = UCI), alpha = 0.8)+theme_bw()+
    facet_grid(criteria~., scales = "free")+ylab("probability")+ggtitle("Temporal evolution of interaction for the influential users")+
    theme(strip.text = element_text(size = 14), axis.title.y = element_text(size = 14),
          axis.text = element_text(size = 10), legend.title = element_blank())
ggsave("Temporal1.jpg")
ggsave("Temporal2.jpg")
user_record <- rbind(data[,.(id = source_id, week)] , data[,.(id = target_id, week)])%>%
    .[,.(starting_week = min(week)),by = id]
  
users_weekly <- rbind(data[,.(id = source_id, week)] , data[,.(id = target_id, week)])%>%
    .[order(week),.(user = unique(id)),by = week]
  
weekly_count <- users_weekly%>%left_join(user_record, by = c("user" = "id"))%>%
    mutate(week_elapse = week - starting_week)%>%
    group_by(week_elapse)%>%count()%>%
    mutate(percentage = n/63204)
  
  ### elapsed percentage lines
ggplot(weekly_count, aes(x = week_elapse, y= percentage))+
  geom_line(lwd = 0.8, color = "#FC887D")+theme_bw()+xlab("Week Joined")+ylab("Percentage")+
  ggtitle("Percentage of users remained")
  ###
engagement_time <-data
#Modified by zhiyue zhang change the outdegree to indegree
weekly_degree <- engagement_time[,.(indegree = n_distinct(source_id)),by = .(gender_target, target_id, week)]
#
#Modified by zhiyue zhang change the source_id to target id
weekly_degree_joined <- weekly_degree%>%arrange(week)%>%left_join(user_record, by = c("target_id" = "id"))
#Modified by zhiyue zhang change the source_id to target id

weekly_degree_joined <- weekly_degree_joined[,week_elapse := week - starting_week,]
  
weekly_degree_joined_at100 <- weekly_degree_joined[week==60,,]
weekly_degree_joined_at150 <-  weekly_degree_joined[week==120,,]
  
weekly_degree_joined_at200 <- weekly_degree_joined[week==180,,]
weekly_degree_joined_at250 <- weekly_degree_joined[week==240,,]
weekly_degree_joined_at300 <- weekly_degree_joined[week==300,,]

  
degree_asweek_at100 <- weekly_degree_joined_at100[order(week_elapse),.(indegree_mean = mean(indegree),
                                                             count = .N),by = .(week_elapse, gender_target)]
degree_asweek_at150 <- weekly_degree_joined_at150[order(week_elapse),.(indegree_mean = mean(indegree),
                                                             count = .N),by = .(week_elapse, gender_target)]
degree_asweek_at200 <- weekly_degree_joined_at200[order(week_elapse),.(indegree_mean = mean(indegree),
                                                             count = .N),by = .(week_elapse, gender_target)]
degree_asweek_at250 <- weekly_degree_joined_at250[order(week_elapse),.(indegree_mean = mean(indegree),
                                                             count = .N),by = .(week_elapse, gender_target)]
degree_asweek_at300 <- weekly_degree_joined_at300[order(week_elapse),.(indegree_mean = mean(indegree),
                                                             count = .N),by = .(week_elapse, gender_target)]
  
weekly_degree_joined_at100[,.(min_e = min(week_elapse)),by = target_id]

  
  # no gender
ggplot(degree_asweek_at100, aes(x =week_elapse, y = indegree_mean))+
  geom_line(lwd = 1)+theme_bw()+xlab("Week Joined")+ylab("Mean Indegree")+
    # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")
ggplot(degree_asweek_at200, aes(x =week_elapse, y = indegree_mean))+
  geom_line(lwd = 1)+theme_bw()+xlab("Week Joined")+ylab("Mean Indegree")+
    # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))
ggplot(degree_asweek_at300, aes(x =week_elapse, y = indegree_mean))+
  geom_line(lwd = 1)+theme_bw()+xlab("Week Joined")+ylab("Mean Indegree")+
    # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))
  
  # with gender
ggplot(degree_asweek_at100, aes(x =week_elapse, y = indegree_mean, color = gender_target))+
  geom_line(lwd = 1)+theme_bw()+xlab("Week Joined")+ylab("Mean Indegree")+
    # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 14")
ggsave("active_elapse14.jpg")
ggplot(degree_asweek_at150, aes(x =week_elapse, y = indegree_mean, color = gender_target))+
  geom_line(lwd = 1)+theme_bw()+xlab("Week Joined")+ylab("Mean Indegree")+
    # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 28")
ggsave("active_elapse28.jpg")
  
ggplot(degree_asweek_at200, aes(x =week_elapse, y = indegree_mean, color = gender_target))+
  geom_line(lwd = 1)+theme_bw()+xlab("Week Joined")+ylab("Mean Indegree")+
    # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 42")
ggsave("active_elapse42.jpg")
ggplot(degree_asweek_at250, aes(x =week_elapse, y = indegree_mean, color = gender_target))+
  geom_line(lwd = 1)+theme_bw()+xlab("Week Joined")+ylab("Mean Indegree")+
    # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 56")
ggsave("active_elapse56.jpg")
ggplot(degree_asweek_at300, aes(x =week_elapse, y = indegree_mean, color = gender_target))+
  geom_line(lwd = 1)+theme_bw()+xlab("Week Joined")+ylab("Mean Indegree")+
    # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 70")
ggsave("active_elapse70.jpg")
  
cor(degree_asweek_at100$indegree_mean, degree_asweek_at100$week_elapse)
cor(degree_asweek_at200$indegree_mean, degree_asweek_at200$week_elapse)
cor(degree_asweek_at300$indegree_mean, degree_asweek_at300$week_elapse)
  
ggsave("elapsed_indegree_mean1.jpg")
  
weekly_intensity <- engagement_time[, .(intensity = .N),by = .(gender_target,target_id, week)]
weekly_intensity_joined <- weekly_intensity%>%arrange(week)%>%left_join(user_record, by = c("target_id" = "id"))
weekly_intensity_joined <- weekly_intensity_joined[,week_elapse := week - starting_week,]
weekly_intensity_joined_rank <- weekly_intensity_joined%>%left_join(users_rec_intensity_rank, 
                                                                 by = c("target_id" = "target_id",
                                                                        "gender_target" = "gender_target"
                                                                        ))
  
weekly_intensity_joined_at100 <- weekly_intensity_joined[week==100,,]
weekly_intensity_joined_at200 <- weekly_intensity_joined[week==200,,]
weekly_intensity_joined_at300 <- weekly_intensity_joined[week==300,,]
  
intensity_asweek_at100 <- weekly_intensity_joined_at100[,.(intensity_mean = mean(intensity)),by = .(week_elapse, gender_target)]
intensity_asweek_at200 <- weekly_intensity_joined_at200[,.(intensity_mean = mean(intensity)),by = .(week_elapse, gender_target)]
intensity_asweek_at300 <- weekly_intensity_joined_at300[,.(intensity_mean = mean(intensity)),by = .(week_elapse, gender_target)]

  

ggplot(intensity_asweek_at100, aes(x =week_elapse, y = intensity_mean, color = gender_target))+
  geom_line(lwd = 0.8)+
    # geom_line(data = intensity_asweek_rank_rm20, color = "black")+
  theme_bw()+xlab("Week Joined")+ylab("Mean Rec Intensity")+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 14")
ggsave("active_elapse_intensity_14.jpg")
ggplot(intensity_asweek_at200, aes(x =week_elapse, y = intensity_mean, color = gender_target))+
  geom_line(lwd = 0.8)+
    # geom_line(data = intensity_asweek_rank_rm20, color = "black")+
  theme_bw()+xlab("Week Joined")+ylab("Mean Rec Intensity")+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 42")
ggsave("active_elapse_intensity_42.jpg")
ggplot(intensity_asweek_at300, aes(x =week_elapse, y = intensity_mean, color = gender_target))+
  geom_line(lwd = 0.8)+
    # geom_line(data = intensity_asweek_rank_rm20, color = "black")+
  theme_bw()+xlab("Week Joined")+ylab("Mean Rec Intensity")+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 70")
ggsave("active_elapse_intensity_70.jpg")
  
  
intensity_asweek_filter <- weekly_intensity_joined%>%left_join(users_outdegree_rank, 
                                                                 by = c("target_id" = "source_id"))%>%
  filter(percentage > 0.1)%>%.[,.(intensity_mean = mean(intensity)),by = .(week_elapse, gender_target)]

cor(intensity_asweek_at300$week_elapse, intensity_asweek_at300$intensity_mean, method = "spearman")
cor(degree_asweek_at300$week_elapse, degree_asweek_at300$indegree_mean, method = "spearman")
  
ggsave("elapsed_Rec_intensity1.jpg")


########################################################
########################################################
## Duration analysis top 10 intensity
males_rec_intensity <- users_rec_intensity[gender_target == "M",]
females_rec_intensity <- users_rec_intensity[gender_target == "F",]

males_rec_intensity_rank<-males_rec_intensity%>%mutate(rank = rank(-rec_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
females_rec_intensity_rank<-females_rec_intensity%>%mutate(rank = rank(-rec_intensity, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))

#top10_males_intensity <- males_rec_intensity_rank[rank<=10,.(target_id),][[1]]
get_top10_males_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM males_rec_intensity_rank")

real_top10_males_intensity <- distinct(get_top10_males_intensity, target_id, .keep_all = TRUE)

top10_males_intensity <- sqldf("SELECT * FROM real_top10_males_intensity limit 10 ")

#top10_males_intensity <- sqldf("SELECT TOP (10) PERCENT FROM real_top10_males_intensity")

#print(top10_males_intensity)

get_top10_females_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM females_rec_intensity_rank")

real_top10_females_intensity <- distinct(get_top10_females_intensity, target_id, .keep_all = TRUE)

top10_females_intensity <- sqldf("SELECT * FROM real_top10_females_intensity limit 10 ")


#top10_females_intensity <- females_rec_intensity_rank[rank<=10,.(target_id),][[1]]

#males_group1 <- males_rec_intensity_rank[rank<=10,.(target_id),][[1]] 
#females_group1 <- females_rec_intensity_rank[rank<=10,.(target_id),][[1]] 

males_group1_new <- sqldf("SELECT target_id FROM top10_males_intensity ")

males_group1 <- as.integer.integer64(unlist(males_group1_new[1]))

females_group1_new <- sqldf("SELECT target_id FROM top10_females_intensity ")

females_group1 <- as.integer.integer64(unlist(females_group1_new[1]))

males_group3 <- males_rec_intensity_rank[rank<=300 & rank>100,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_rec_intensity_rank)

weekly_male_people_group <- copy(top10_males_intensity)

weekly_female_people_group <- copy(top10_females_intensity)



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


#week_male_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]

#week_female_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]

print(weekly_gender_people_group_males)
get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top10 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "male_group1",]
#  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
#    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  

  weekly_prob_combined <- rbind(weekly_prob_top10)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "male_group1_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top10 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "female_group1_avr",]
  
  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}

duration_all_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_all_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_all_males_average <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_all_females_average <- get_duration_avr_male(weekly = weekly_gender_people_group_females)

ggplot()+geom_line(data = duration_all_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_10"),size=1)+
  geom_point(data = duration_all_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_10"),size=3)+
  geom_line(data = duration_all_females,aes(x = week,y = sum_intensity,colour ="female_group_intensity_10"),size=1) + 
  geom_point(data = duration_all_females,aes(x = week,y = sum_intensity,colour = "female_group_intensity_10"),size=3)+
  geom_line(data = duration_all_males_average,aes(x = week,y = average_intensity,colour = "male_group1_avr"),size=1)+
  geom_point(data = duration_all_males_average,aes(x = week,y = average_intensity,colour = "male_group1_avr"),size=3)+
  geom_line(data = duration_all_females_average,aes(x = week,y = average_intensity,colour = "female_group1_avr"),size=1)+
  geom_point(data = duration_all_females_average,aes(x = week,y = average_intensity,colour = "female_group1_avr"),size=3)+
  scale_colour_manual("",values = c("male_group_intensity_10" = "red","female_group_intensity_10" = "green",
                                    "male_group1_avr" = "blue","female_group1_avr" = "yellow"))+
  xlab("week")+ylab("sum_intensity")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top10_intensity.jpg")


#########################################################################
#########################################################################
#ANOVA 方差分析
#data_array_anova <- duration_all_males
#data_array_anova$sum_intensity2<- duration_all_females$sum_intensity
#data_array_anova$type2 <- duration_all_females$type

#get_data_array_anova <- rbind(duration_all_males,duration_all_females)
get_data_array_anova <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova <- summarySE(get_data_array_anova, measurevar="rec_intensity", groupvars=c("gender_target","week"))

ggplot(data_array_anova, aes(x=week, y=rec_intensity, colour=gender_target)) + 
  geom_errorbar(aes(ymin=rec_intensity-se, ymax=rec_intensity+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top10_intensity_anova.jpg")

#total_duration_all_males_average <- merge(duration_all_males,duration_all_males_average,by="week")
#output_total_duration_all_males_average<-filter(total_duration_all_males_average,sum_intensity>average_intensity)
#########################################################################


########################################################
########################################################
## Duration analysis top 10 to 100 intensity

#top100_males_intensity <- males_rec_intensity_rank[rank<=10,.(target_id),][[1]]
get_top100_males_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM males_rec_intensity_rank")

real_top100_males_intensity <- distinct(get_top100_males_intensity, target_id, .keep_all = TRUE)

top100_males_intensity <- sqldf("SELECT * FROM real_top100_males_intensity LIMIT 10,100")

get_top100_females_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM females_rec_intensity_rank")

real_top100_females_intensity <- distinct(get_top100_females_intensity, target_id, .keep_all = TRUE)

top100_females_intensity <- sqldf("SELECT * FROM real_top100_females_intensity LIMIT 10,100")

males_group2_new <- sqldf("SELECT target_id FROM top100_males_intensity ")

males_group2 <- as.integer.integer64(unlist(males_group2_new[1]))

females_group2_new <- sqldf("SELECT target_id FROM top100_females_intensity ")

females_group2 <- as.integer.integer64(unlist(females_group2_new[1]))

males_group3 <- males_rec_intensity_rank[rank<=300 & rank>100,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_rec_intensity_rank)

weekly_male_people_group <- copy(top100_males_intensity)

weekly_female_people_group <- copy(top100_females_intensity)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group2, 
                                                            "male_group2", 
                                                            ifelse(target_id %in% females_group2,  
                                                                   "female_group2",
                                                                   ifelse(target_id %in% males_group3,
                                                                          "male_group3",
                                                                          "others"))), by = .(week)]




weekly_gender_group_top100 <- weekly_gender_people_group

weekly_gender_group_sec_top100 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group_top100[target_id %in% males_group2, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group_sec_top100[target_id %in% females_group2, by = .(week)]


#week_male_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]

#week_female_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]


get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top100 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "male_group2",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top100)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top100 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "female_group2",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top100)
  
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top100_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top100_avr_tep[1,2]))
  
  weekly_prob_top100_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "male_group_intensity_100_avr",]
  
  weekly_prob_combined <- rbind(weekly_prob_top100_avr)
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top100_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top100_avr_tep[1,2]))
  
  weekly_prob_top100_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "female_group_intensity_100_avr",]
  
  weekly_prob_combined <- rbind(weekly_prob_top100_avr)
  return(weekly_prob_combined)
}

duration_top100_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top100_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_top100_males_avr <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_top100_females_avr <- get_duration_avr_female(weekly = weekly_gender_people_group_females)


ggplot()+geom_line(data = duration_top100_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_100"),size=1)+
  geom_point(data = duration_top100_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_100"),size=3)+
  geom_line(data = duration_top100_females,aes(x = week,y = sum_intensity,colour ="female_group_intensity_100"),size=1) + 
  geom_point(data = duration_top100_females,aes(x = week,y = sum_intensity,colour = "female_group_intensity_100"),size=3)+
  geom_line(data = duration_top100_males_avr,aes(x = week,y = average_intensity,colour = "male_group_intensity_100_avr"),size=0.5)+
  #geom_point(data = duration_top100_males_avr,aes(x = week,y = average_intensity,colour = "male_group_intensity_100_avr"),size=3)+
  geom_line(data = duration_top100_females_avr,aes(x = week,y = average_intensity,colour = "female_group_intensity_100_avr"),size=0.5)+
  #geom_point(data = duration_top100_females_avr,aes(x = week,y = average_intensity,colour = "female_group_intensity_100_avr"),size=3)+
  scale_colour_manual("",values = c("male_group_intensity_100" = "red","female_group_intensity_100" = "green",
                                    "male_group_intensity_100_avr" = "blue","female_group_intensity_100_avr" = "yellow"))+
  xlab("week")+ylab("sum_intensity")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top100_intensity.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
#data_array_anova <- duration_all_males
#data_array_anova$sum_intensity2<- duration_all_females$sum_intensity
#data_array_anova$type2 <- duration_all_females$type

#get_data_array_anova <- rbind(duration_all_males,duration_all_females)
get_data_array_anova_ins_100 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_ins_100 <- summarySE(get_data_array_anova_ins_100, measurevar="rec_intensity", groupvars=c("gender_target","week"))

ggplot(data_array_anova_ins_100, aes(x=week, y=rec_intensity, colour=gender_target)) + 
  geom_errorbar(aes(ymin=rec_intensity-se, ymax=rec_intensity+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top100_intensity_anova.jpg")

#########################################################################

########################################################
########################################################
## Duration analysis top 100 to 300 intensity

#top100_males_intensity <- males_rec_intensity_rank[rank<=10,.(target_id),][[1]]
get_top300_males_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM males_rec_intensity_rank")

real_top300_males_intensity <- distinct(get_top300_males_intensity, target_id, .keep_all = TRUE)

top300_males_intensity <- sqldf("SELECT * FROM real_top300_males_intensity LIMIT 100,300")

get_top300_females_intensity <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IntensityRank
FROM females_rec_intensity_rank")

real_top300_females_intensity <- distinct(get_top300_females_intensity, target_id, .keep_all = TRUE)

top300_females_intensity <- sqldf("SELECT * FROM real_top300_females_intensity LIMIT 100,300")

males_group3_new <- sqldf("SELECT target_id FROM top300_males_intensity ")

males_group3 <- as.integer.integer64(unlist(males_group3_new[1]))

females_group3_new <- sqldf("SELECT target_id FROM top300_females_intensity ")

females_group3 <- as.integer.integer64(unlist(females_group3_new[1]))

males_group_other <- males_rec_intensity_rank[rank<=500 & rank>300,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_rec_intensity_rank)

weekly_male_people_group <- copy(top300_males_intensity)

weekly_female_people_group <- copy(top300_females_intensity)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group3, 
                                                            "male_group3", 
                                                            ifelse(target_id %in% females_group3,  
                                                                   "female_group3",
                                                                   ifelse(target_id %in% males_group_other,
                                                                          "males_group_other",
                                                                          "others"))), by = .(week)]




weekly_gender_group_top300 <- weekly_gender_people_group

weekly_gender_group_sec_top300 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group_top300[target_id %in% males_group3, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group_sec_top300[target_id %in% females_group3, by = .(week)]


#week_male_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]

#week_female_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]


get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top300 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "males_group3",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top300)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top300 <- weekly[order(week), .(n = .N, sum_intensity = sum(rec_intensity)),by = .(week)]%>%
    .[, .(sum_intensity) ,by = .(week)]%>%.[,type := "females_group3",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top300)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top300_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top300_avr_tep[1,2]))
  
  weekly_prob_top300_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "female_300_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top300_avr)
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top300_avr_tep <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top300_avr_tep[1,2]))
  
  weekly_prob_top300_avr <- weekly[order(week), .(n = .N, average_intensity = ave_tep_data),by = .(week)]%>%
    .[, .(average_intensity),by = .(week)]%>%.[,type := "male_300_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top300_avr)
  return(weekly_prob_combined)
}


duration_top300_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top300_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_top300_males_avr <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_top300_females_avr <- get_duration_avr_female(weekly = weekly_gender_people_group_females)


ggplot()+geom_line(data = duration_top300_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_300"),size=1)+
  geom_point(data = duration_top300_males,aes(x = week,y = sum_intensity,colour = "male_group_intensity_300"),size=3)+
  geom_line(data = duration_top300_females,aes(x = week,y = sum_intensity,colour ="female_group_intensity_300"),size=1) + 
  geom_point(data = duration_top300_females,aes(x = week,y = sum_intensity,colour = "female_group_intensity_300"),size=3)+
  geom_line(data = duration_top300_males_avr,aes(x = week,y = average_intensity,colour = "male_300_avr"),size=1)+
  geom_point(data = duration_top300_males_avr,aes(x = week,y = average_intensity,colour = "male_300_avr"),size=3)+
  geom_line(data = duration_top300_females_avr,aes(x = week,y = average_intensity,colour = "female_300_avr"),size=1)+
  geom_point(data = duration_top300_females_avr,aes(x = week,y = average_intensity,colour = "female_300_avr"),size=3)+
  scale_colour_manual("",values = c("male_group_intensity_300" = "red","female_group_intensity_300" = "green",
                                    "male_300_avr" = "blue","female_300_avr" = "yellow"))+
  xlab("week")+ylab("sum_intensity")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top300_intensity.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
#data_array_anova <- duration_all_males
#data_array_anova$sum_intensity2<- duration_all_females$sum_intensity
#data_array_anova$type2 <- duration_all_females$type

#get_data_array_anova <- rbind(duration_all_males,duration_all_females)
get_data_array_anova_ins_300 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_ins_300 <- summarySE(get_data_array_anova_ins_300, measurevar="rec_intensity", groupvars=c("gender_target","week"))

ggplot(data_array_anova_ins_300, aes(x=week, y=rec_intensity, colour=gender_target)) + 
  geom_errorbar(aes(ymin=rec_intensity-se, ymax=rec_intensity+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top300_intensity_anova.jpg")

#########################################################################

########################################################
########################################################
## Duration analysis top 10 indegree
males_indegree <- users_indegree[gender_target == "M",]
females_indegree <- users_indegree[gender_target == "F",]

males_indegree_rank<-males_indegree%>%mutate(rank = rank(-indegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
females_indegree_rank<-females_indegree%>%mutate(rank = rank(-indegree, ties.method = "min"))%>%mutate(percentage = rank/nrow(.))
#top100_males_intensity <- males_rec_intensity_rank[rank<=10,.(target_id),][[1]]
get_top10_males_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM males_indegree_rank")

real_top10_males_indegree <- distinct(get_top10_males_indegree, target_id, .keep_all = TRUE)

top10_males_indegree <- sqldf("SELECT * FROM real_top10_males_indegree LIMIT 10")

get_top10_females_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM females_indegree_rank")

real_top10_females_indegree <- distinct(get_top10_females_indegree, target_id, .keep_all = TRUE)

top10_females_indegree <- sqldf("SELECT * FROM real_top10_females_indegree LIMIT 10")

males_group_indegree_get_10 <- sqldf("SELECT target_id FROM top10_males_indegree ")

males_group_indegree_10 <- as.integer.integer64(unlist(males_group_indegree_get_10[1]))

females_group_indegree_get_10 <- sqldf("SELECT target_id FROM top10_females_indegree ")

females_group_indegree_10 <- as.integer.integer64(unlist(females_group_indegree_get_10[1]))

males_group3 <- males_indegree_rank[rank<=300 & rank>100,.(target_id),][[1]]

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


#week_male_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]

#week_female_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]


get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top10 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "males_group_indegree_10",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top10 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "females_group_indegree_10",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top10)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))

  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "female_10_indegree_avr",]

  
  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top10_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top10_avr_tep[1,2]))
  
  weekly_prob_top10_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "male_10_indegree_avr",]

  

  weekly_prob_combined <- rbind(weekly_prob_top10_avr)
  return(weekly_prob_combined)
}

duration_top10_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top10_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_all_males_average <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_all_females_average <- get_duration_avr_female(weekly = weekly_gender_people_group_females)

##########################################################
##########################################################
#calculate male user influence
"
top_10_data_length <- nrow(males_group_indegree_get_10)
dNum <- -1
while(top_10_data_length + 1 > dNum){
  
  d_target_id <- males_group_indegree_get_10[dNum,1]
  male_influence_result <- filter(data,target_id == d_target_id)

  dNum <- dNum + 1;
}

top_10_females_data_length <- nrow(females_group_indegree_get_10)
dfemales_Num <- -1
while(top_10_females_data_length + 1 > dfemales_Num){
  
  d_target_id2 <- females_group_indegree_get_10[dfemales_Num,1]
  female_influence_result <- filter(male_influence_result,source_id == d_target_id2)
  print(female_influence_result)
  dfemales_Num <- dfemales_Num + 1;
}
"
############################################################
############################################################

##########################################################
##########################################################
#calculate female user influence
"
top_10_data_length_2 <- nrow(females_group_indegree_get_10)
dNum_2 <- -1
while(top_10_data_length_2 + 1 > dNum_2){
  
  d_target_id_2 <- females_group_indegree_get_10[dNum_2,1]
  female_influence_result2 <- filter(data,target_id == d_target_id_2)
  
  dNum_2 <- dNum_2 + 1;
}

top_10_males_data_length2 <- nrow(males_group_indegree_get_10)
dmales_Num2 <- -1
while(top_10_males_data_length2 + 1 > dmales_Num2){
  
  d_target_id2 <- males_group_indegree_get_10[dmales_Num2,1]
  female_influence_result <- filter(female_influence_result2,source_id == d_target_id2)
  print(female_influence_result)
  dmales_Num2 <- dmales_Num2 + 1;
}
"
############################################################
############################################################

ggplot()+geom_line(data = duration_top10_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_10"),size=1)+
  geom_point(data = duration_top10_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_10"),size=3)+
  geom_line(data = duration_top10_females,aes(x = week,y = sum_indegree,colour ="females_group_indegree_10"),size=1) + 
  geom_point(data = duration_top10_females,aes(x = week,y = sum_indegree,colour = "females_group_indegree_10"),size=3)+
  geom_line(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_10_indegree_avr"),size=1)+
  geom_point(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_10_indegree_avr"),size=3)+
  geom_line(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_10_indegree_avr"),size=1)+
  geom_point(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_10_indegree_avr"),size=3)+
  scale_colour_manual("",values = c("males_group_indegree_10" = "red","females_group_indegree_10" = "green",
                                    "male_10_indegree_avr" = "blue","female_10_indegree_avr" = "yellow"))+
  xlab("week")+ylab("sum_indegree")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top10_indegree.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
#data_array_anova <- duration_all_males
#data_array_anova$sum_intensity2<- duration_all_females$sum_intensity
#data_array_anova$type2 <- duration_all_females$type

#get_data_array_anova <- rbind(duration_all_males,duration_all_females)
get_data_array_anova_in_10 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_in_10 <- summarySE(get_data_array_anova_in_10, measurevar="indegree", groupvars=c("gender_target","week"))

ggplot(data_array_anova_in_10, aes(x=week, y=indegree, colour=gender_target)) + 
  geom_errorbar(aes(ymin=indegree-se, ymax=indegree+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top10_indegree_anova.jpg")

#########################################################################

########################################################
########################################################
## Duration analysis top 10 to 100 indegree

get_top100_males_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM males_indegree_rank")

real_top100_males_indegree <- distinct(get_top100_males_indegree, target_id, .keep_all = TRUE)

top100_males_indegree <- sqldf("SELECT * FROM real_top100_males_indegree LIMIT 10,100")

get_top100_females_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM females_indegree_rank")

real_top100_females_indegree <- distinct(get_top100_females_indegree, target_id, .keep_all = TRUE)

top100_females_indegree <- sqldf("SELECT * FROM real_top100_females_indegree LIMIT 10,100")

males_group_indegree_get_100 <- sqldf("SELECT target_id FROM top100_males_indegree ")

males_group_indegree_100 <- as.integer.integer64(unlist(males_group_indegree_get_100[1]))

females_group_indegree_get_100 <- sqldf("SELECT target_id FROM top100_females_indegree ")

females_group_indegree_100 <- as.integer.integer64(unlist(females_group_indegree_get_100[1]))

males_group3 <- males_indegree_rank[rank<=300 & rank>100,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_indegree_rank)

weekly_male_people_group <- copy(top100_males_indegree)

weekly_female_people_group <- copy(top100_females_indegree)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group_indegree_100, 
                                                            "males_group_indegree_100", 
                                                            ifelse(target_id %in% females_group_indegree_100,  
                                                                   "females_group_indegree_100",
                                                                   ifelse(target_id %in% males_group3,
                                                                          "male_group3",
                                                                          "others"))), by = .(week)]




weekly_gender_group_top100 <- weekly_gender_people_group

weekly_gender_group_sec_top100 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group_top100[target_id %in% males_group_indegree_100, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group_sec_top100[target_id %in% females_group_indegree_100, by = .(week)]


#week_male_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]

#week_female_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]


get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top100 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "males_group_indegree_100",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top100)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top100 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "females_group_indegree_100",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top100)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top100_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top100_avr_tep[1,2]))
  
  weekly_prob_top100_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "female_100_indegree_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top100_avr)
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top100_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top100_avr_tep[1,2]))
  
  weekly_prob_top100_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "male_100_indegree_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top100_avr)
  return(weekly_prob_combined)
}

##########################################################
#calculate female user influence
"
top_100_data_length <- nrow(females_group_indegree_get_100)
dNum_100 <- -1
while(top_100_data_length + 1 > dNum_100){
  
  d_target_id_100 <- females_group_indegree_get_300[dNum_100,1]
  female_influence_result_100 <- filter(data,target_id == d_target_id_100)
  
  dNum_100 <- dNum_100 + 1;
}

top_100_males_data_length <- nrow(males_group_indegree_get_100)
dNum_100_male <- -1

while(top_100_males_data_length + 1 > dNum_100_male){
  
  d_target_id100_male <- males_group_indegree_get_100[dNum_100_male,1]
  female_influence_result_100 <- filter(female_influence_result_100,source_id == d_target_id100_male)
  print(female_influence_result_100)
  dNum_100_male <- dNum_100_male + 1;
}
"
############################################################


duration_top100_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top100_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_all_males_average <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_all_females_average <- get_duration_avr_male(weekly = weekly_gender_people_group_females)

ggplot()+geom_line(data = duration_top100_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_100"),size=1)+
  geom_point(data = duration_top100_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_100"),size=3)+
  geom_line(data = duration_top100_females,aes(x = week,y = sum_indegree,colour ="females_group_indegree_100"),size=1) + 
  geom_point(data = duration_top100_females,aes(x = week,y = sum_indegree,colour = "females_group_indegree_100"),size=3)+
  geom_line(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_100_indegree_avr"),size=1)+
  geom_point(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_100_indegree_avr"),size=3)+
  geom_line(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_100_indegree_avr"),size=1)+
  geom_point(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_100_indegree_avr"),size=3)+
  scale_colour_manual("",values = c("males_group_indegree_100" = "red","females_group_indegree_100" = "green",
                                    "male_100_indegree_avr" = "blue","female_100_indegree_avr" = "yellow"))+
  xlab("week")+ylab("sum_indegree")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top100_indegree.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
#data_array_anova <- duration_all_males
#data_array_anova$sum_intensity2<- duration_all_females$sum_intensity
#data_array_anova$type2 <- duration_all_females$type

#get_data_array_anova <- rbind(duration_all_males,duration_all_females)
get_data_array_anova_in_100 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_in_100 <- summarySE(get_data_array_anova_in_100, measurevar="indegree", groupvars=c("gender_target","week"))

ggplot(data_array_anova_in_100, aes(x=week, y=indegree, colour=gender_target)) + 
  geom_errorbar(aes(ymin=indegree-se, ymax=indegree+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top100_indegree_anova.jpg")

#########################################################################

########################################################
########################################################
## Duration analysis top 100 to 300 indegree

get_top300_males_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM males_indegree_rank")

real_top300_males_indegree <- distinct(get_top300_males_indegree, target_id, .keep_all = TRUE)

top300_males_indegree <- sqldf("SELECT * FROM real_top300_males_indegree LIMIT 100,300")

get_top300_females_indegree <- sqldf("SELECT *, DENSE_RANK() OVER(ORDER BY rank) 
AS IndegreeRank
FROM females_indegree_rank")

real_top300_females_indegree <- distinct(get_top300_females_indegree, target_id, .keep_all = TRUE)

top300_females_indegree <- sqldf("SELECT * FROM real_top300_females_indegree LIMIT 100,300")

males_group_indegree_get_300 <- sqldf("SELECT target_id FROM top300_males_indegree ")

males_group_indegree_300 <- as.integer.integer64(unlist(males_group_indegree_get_300[1]))

females_group_indegree_get_300 <- sqldf("SELECT target_id FROM top300_females_indegree ")

females_group_indegree_300 <- as.integer.integer64(unlist(females_group_indegree_get_300[1]))

males_group3 <- males_indegree_rank[rank<=500 & rank>300,.(target_id),][[1]]

weekly_gender_people_group <- copy(users_indegree_rank)

weekly_male_people_group <- copy(top300_males_indegree)

weekly_female_people_group <- copy(top300_females_indegree)



weekly_gender_people_group[,gender_new_user_group := ifelse(target_id %in% males_group_indegree_300, 
                                                            "males_group_indegree_300", 
                                                            ifelse(target_id %in% females_group_indegree_300,  
                                                                   "females_group_indegree_300",
                                                                   ifelse(target_id %in% males_group3,
                                                                          "male_group3",
                                                                          "others"))), by = .(week)]




weekly_gender_group_top300 <- weekly_gender_people_group

weekly_gender_group_sec_top300 <- weekly_gender_people_group


weekly_gender_people_group_males <- weekly_gender_group_top300[target_id %in% males_group_indegree_300, by = .(week)]

weekly_gender_people_group_females <- weekly_gender_group_sec_top300[target_id %in% females_group_indegree_300, by = .(week)]


#week_male_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]

#week_female_group_count <- weekly_gender_group[order(week), .(n = .N),by = .(week, gender_new_user_group)]


get_duration <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top300 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "males_group_indegree_300",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top300)
  
  return(weekly_prob_combined)
}

get_duration_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top300 <- weekly[order(week), .(n = .N, sum_indegree = sum(indegree)),by = .(week)]%>%
    .[, .(sum_indegree) ,by = .(week)]%>%.[,type := "females_group_indegree_300",]
  #  weekly_females_top10 <- weekly[order(week), .(n = .N, average_intensity = sum(rec_intensity)),by = .(week)]%>%
  #    .[, .(average_intensity) ,by = .(week)]%>%.[,type := "female_group1",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top300)
  
  return(weekly_prob_combined)
}

get_duration_avr_female <- function(weekly = weekly_gender_people_group_females){
  weekly_prob_top300_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top300_avr_tep[1,2]))
  
  weekly_prob_top300_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "female_300_indegree_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top300_avr)
  return(weekly_prob_combined)
}

get_duration_avr_male <- function(weekly = weekly_gender_people_group_males){
  weekly_prob_top300_avr_tep <- weekly[order(week), .(n = .N, average_indegree = sum(indegree)/300)]
  ave_tep_data <- as.numeric(unlist(weekly_prob_top300_avr_tep[1,2]))
  
  weekly_prob_top300_avr <- weekly[order(week), .(n = .N, average_indegree = ave_tep_data),by = .(week)]%>%
    .[, .(average_indegree),by = .(week)]%>%.[,type := "male_300_indegree_avr",]
  
  
  weekly_prob_combined <- rbind(weekly_prob_top300_avr)
  return(weekly_prob_combined)
}

##########################################################
##########################################################
#calculate female user influence
"
top_300_data_length <- nrow(females_group_indegree_get_300)
dNum_3 <- -1
while(top_300_data_length + 1 > dNum_3){
  
  d_target_id_300 <- females_group_indegree_get_300[dNum_3,1]
  female_influence_result3 <- filter(data,target_id == d_target_id_300)
  
  dNum_3 <- dNum_3 + 1;
}

top_300_males_data_length <- nrow(males_group_indegree_get_300)
dmales_Num3 <- -1
print(female_influence_result3)
print(top_300_males_data_length)
while(190 + 1 > dmales_Num3){
  
  d_target_id300_male <- males_group_indegree_get_300[dmales_Num3,1]
  print(d_target_id300_male)
  female_influence_result_300 <- filter(female_influence_result3,source_id == d_target_id300_male)
  print(female_influence_result_300)
  dmales_Num3 <- dmales_Num3 + 1;
}
"
############################################################
############################################################

duration_top300_males <- get_duration(weekly = weekly_gender_people_group_males)
duration_top300_females <- get_duration_female(weekly = weekly_gender_people_group_females)
duration_all_males_average <- get_duration_avr_male(weekly = weekly_gender_people_group_males)
duration_all_females_average <- get_duration_avr_male(weekly = weekly_gender_people_group_females)

ggplot()+geom_line(data = duration_top300_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_300"),size=1)+
  geom_point(data = duration_top300_males,aes(x = week,y = sum_indegree,colour = "males_group_indegree_300"),size=3)+
  geom_line(data = duration_top300_females,aes(x = week,y = sum_indegree,colour ="females_group_indegree_300"),size=1) + 
  geom_point(data = duration_top300_females,aes(x = week,y = sum_indegree,colour = "females_group_indegree_300"),size=3)+
  geom_line(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_300_indegree_avr"),size=1)+
  geom_point(data = duration_all_males_average,aes(x = week,y = average_indegree,colour = "male_300_indegree_avr"),size=3)+
  geom_line(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_300_indegree_avr"),size=1)+
  geom_point(data = duration_all_females_average,aes(x = week,y = average_indegree,colour = "female_300_indegree_avr"),size=3)+
  scale_colour_manual("",values = c("males_group_indegree_300" = "red","females_group_indegree_300" = "green",
                                    "male_300_indegree_avr" = "blue","female_300_indegree_avr" = "yellow"))+  xlab("week")+ylab("sum_indegree")+
  theme(text=element_text(size=13, family="Comic Sans MS"))
ggsave("duration_top300_indegree.jpg")

#########################################################################
#########################################################################
#ANOVA 方差分析
#data_array_anova <- duration_all_males
#data_array_anova$sum_intensity2<- duration_all_females$sum_intensity
#data_array_anova$type2 <- duration_all_females$type

#get_data_array_anova <- rbind(duration_all_males,duration_all_females)
get_data_array_anova_in_300 <- rbind(weekly_gender_people_group_males,weekly_gender_people_group_females)
data_array_anova_in_300 <- summarySE(get_data_array_anova_in_300, measurevar="indegree", groupvars=c("gender_target","week"))

ggplot(data_array_anova_in_300, aes(x=week, y=indegree, colour=gender_target)) + 
  geom_errorbar(aes(ymin=indegree-se, ymax=indegree+se), width=.1) +
  geom_line() + 
  geom_point()

ggsave("duration_top300_indegree_anova.jpg")

#########################################################################

########################################################
########################################################
## user analysis

#users_analysis =  unique(data[,.(target_id)])
#print(users_analysis)


