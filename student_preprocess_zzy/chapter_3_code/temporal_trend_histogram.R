library(bit64)
library(data.table)
library(dplyr)
library(ggplot2)
library(magrittr)
library(reshape2)
library(lubridate)
library(scales)
library(zoo)

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

users_indegree <- data[,.(indegree = n_distinct(source_id)),by = .(gender_target,target_id)]
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
users_rec_intensity <- data[, .(rec_intensity = .N),by = .(gender_target, target_id)]

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
    .[week>100,,]%>%
    .[,type := "group1",]
  weekly_prob_top11_100 <- weekly[order(week), .(n = .N, prob = sum(user_group == "group2")/.N),by = .(week)]%>%
    .[, .(prob,
          UCI = prob + 1.96 * sqrt(prob*(1-prob)/n),
          LCI = prob - 1.96 * sqrt(prob*(1-prob)/n)
    ) ,by = .(week)]%>%
    .[week>100,,]%>%
    .[,type := "group2",]
  weekly_prob_top101_300 <- weekly[order(week), .(n = .N, prob = sum(user_group == "group3")/.N),by = .(week)]%>%
    .[, .(prob,
          UCI = prob + 1.96 * sqrt(prob*(1-prob)/n),
          LCI = prob - 1.96 * sqrt(prob*(1-prob)/n)
    ) ,by = .(week)]%>%
    .[week>100,,]%>%
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
weekly_degree <- engagement_time[,.(outdegree = n_distinct(target_id)),by = .(gender_source, source_id, week)]

weekly_degree_joined <- weekly_degree%>%arrange(week)%>%left_join(user_record, by = c("source_id" = "id"))
weekly_degree_joined <- weekly_degree_joined[,week_elapse := week - starting_week,]

weekly_degree_joined_at100 <- weekly_degree_joined[week==100,,]
weekly_degree_joined_at150 <-  weekly_degree_joined[week==150,,]

weekly_degree_joined_at200 <- weekly_degree_joined[week==200,,]
weekly_degree_joined_at250 <- weekly_degree_joined[week==250,,]
weekly_degree_joined_at300 <- weekly_degree_joined[week==288,,]


degree_asweek_at100 <- weekly_degree_joined_at100[order(week_elapse),.(outdegree_mean = mean(outdegree),
                                                                       count = .N),by = .(week_elapse, gender_source)]
degree_asweek_at150 <- weekly_degree_joined_at150[order(week_elapse),.(outdegree_mean = mean(outdegree),
                                                                       count = .N),by = .(week_elapse, gender_source)]
degree_asweek_at200 <- weekly_degree_joined_at200[order(week_elapse),.(outdegree_mean = mean(outdegree),
                                                                       count = .N),by = .(week_elapse, gender_source)]
degree_asweek_at250 <- weekly_degree_joined_at250[order(week_elapse),.(outdegree_mean = mean(outdegree),
                                                                       count = .N),by = .(week_elapse, gender_source)]
degree_asweek_at300 <- weekly_degree_joined_at300[order(week_elapse),.(outdegree_mean = mean(outdegree),
                                                                       count = .N),by = .(week_elapse, gender_source)]

weekly_degree_joined_at100[,.(min_e = min(week_elapse)),by = source_id]

# with gender
ggplot(degree_asweek_at100, aes(x =week_elapse, y = outdegree_mean, fill = gender_source))+
  geom_bar(stat='identity',position="dodge")+theme_bw()+xlab("Week Joined")+ylab("Mean Outdegree")+
  # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 100")
ggsave("active_elapse100.jpg")
ggplot(degree_asweek_at150, aes(x =week_elapse, y = outdegree_mean, fill = gender_source))+
  geom_bar(stat='identity',position="dodge")+theme_bw()+xlab("Week Joined")+ylab("Mean Outdegree")+
  # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 150")
ggsave("active_elapse150.jpg")

ggplot(degree_asweek_at200, aes(x =week_elapse, y = outdegree_mean, fill = gender_source))+
  geom_bar(stat='identity',position="dodge")+theme_bw()+xlab("Week Joined")+ylab("Mean Outdegree")+
  # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 200")
ggsave("active_elapse200.jpg")
ggplot(degree_asweek_at250, aes(x =week_elapse, y = outdegree_mean, fill = gender_source))+
  geom_bar(stat='identity',position="dodge")+theme_bw()+xlab("Week Joined")+ylab("Mean Outdegree")+
  # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 250")
ggsave("active_elapse250.jpg")
ggplot(degree_asweek_at300, aes(x =week_elapse, y = outdegree_mean, fill = gender_source))+
  geom_bar(stat='identity',position="dodge")+theme_bw()+xlab("Week Joined")+ylab("Mean Outdegree")+
  # geom_smooth(method = "lm", formula = y~x,se = F)+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 300")
ggsave("active_elapse300.jpg")

cor(degree_asweek_at100$outdegree_mean, degree_asweek_at100$week_elapse)
cor(degree_asweek_at200$outdegree_mean, degree_asweek_at200$week_elapse)
cor(degree_asweek_at300$outdegree_mean, degree_asweek_at300$week_elapse)

ggsave("elapsed_outdegree_mean1.jpg")

weekly_intensity <- engagement_time[, .(intensity = .N),by = .(gender_source,source_id, week)]
weekly_intensity_joined <- weekly_intensity%>%arrange(week)%>%left_join(user_record, by = c("source_id" = "id"))
weekly_intensity_joined <- weekly_intensity_joined[,week_elapse := week - starting_week,]
weekly_intensity_joined_rank <- weekly_intensity_joined%>%left_join(users_sent_intensity_rank, 
                                                                    by = c("source_id" = "source_id",
                                                                           "gender_source" = "gender_source"
                                                                    ))

weekly_intensity_joined_at100 <- weekly_intensity_joined[week==100,,]
weekly_intensity_joined_at200 <- weekly_intensity_joined[week==200,,]
weekly_intensity_joined_at300 <- weekly_intensity_joined[week==288,,]

intensity_asweek_at100 <- weekly_intensity_joined_at100[,.(intensity_mean = mean(intensity)),by = .(week_elapse, gender_source)]
intensity_asweek_at200 <- weekly_intensity_joined_at200[,.(intensity_mean = mean(intensity)),by = .(week_elapse, gender_source)]
intensity_asweek_at300 <- weekly_intensity_joined_at300[,.(intensity_mean = mean(intensity)),by = .(week_elapse, gender_source)]



ggplot(intensity_asweek_at100, aes(x =week_elapse, y = intensity_mean, fill = gender_source))+
  geom_bar(stat='identity', position="dodge")+
  # geom_line(data = intensity_asweek_rank_rm20, color = "black")+
  theme_bw()+xlab("Week Joined")+ylab("Mean Sent Intensity")+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 100")
ggsave("active_elapse_intensity_100.jpg")
ggplot(intensity_asweek_at200, aes(x =week_elapse, y = intensity_mean, fill = gender_source))+
  geom_bar(stat='identity', position="dodge")+ 
  theme_bw()+xlab("Week Joined")+ylab("Mean Sent Intensity")+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 200")
ggsave("active_elapse_intensity_200.jpg")
ggplot(intensity_asweek_at300, aes(x =week_elapse, y = intensity_mean, fill = gender_source))+
  geom_bar(stat='identity', position="dodge")+ 
  theme_bw()+xlab("Week Joined")+ylab("Mean Sent Intensity")+
  theme(axis.text = element_text(size = 12), axis.title  = element_text(size = 14), legend.title = element_text(size=12))+
  labs(color = "gender")+ggtitle("Observed at week 300")
ggsave("active_elapse_intensity_300.jpg")


intensity_asweek_filter <- weekly_intensity_joined%>%left_join(users_indegree_rank, 
                                                               by = c("source_id" = "target_id"))%>%
  filter(percentage > 0.1)%>%.[,.(intensity_mean = mean(intensity)),by = .(week_elapse, gender_source)]

cor(intensity_asweek_at300$week_elapse, intensity_asweek_at300$intensity_mean, method = "spearman")
cor(degree_asweek_at300$week_elapse, degree_asweek_at300$outdegree_mean, method = "spearman")

ggsave("elapsed_sent_intensity1.jpg")










