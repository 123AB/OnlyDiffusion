# input line : gender1 gender2 id1 id2 timestamp
# output line : gender1 gender2 id1 id2 #hop #week

import networkx as nx
import pandas as pd
import csv
import os
import math
import time

gender_dict = {}
# 'nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria'
#testcase = 'receivernosend'
testcase = 'bothcriteria'
# file = '../../../dataset_2015/dataset_{}/task1/1_stat_user2/1_stat_user2_0.csv'
file = './dataset_whole/dataset_nofilter/graph_edges_total_45mil_new.csv'
# 0: like, 1: comment, 2: interact

# if only care 2015/1/1 ~ 2015/12/31
only1year = False

# recording whether this line is a like or a comment
like_list = []
comment_list = []
line_num = 0

min_timestamp = float('inf')
max_timestamp = 0

with open(file.format(testcase), 'r') as read_file:
        headers = read_file.readline()
        for line in read_file:
            token = line.strip().split(',')
            src_g = token[0]
            dst_g = token[1]
            src = token[2]
            dst = token[3]
            act = token[4]
            if act == 'like':
            	like_list.append(line_num)
            elif act == 'comment':
            	comment_list.append(line_num)
            timestamp = int(token[5])
            if timestamp != 0:
	            if timestamp < min_timestamp:
	            	min_timestamp = timestamp
	            if timestamp > max_timestamp:
	            	max_timestamp = timestamp
	            if src not in gender_dict: gender_dict[src] = src_g
	            if dst not in gender_dict: gender_dict[dst] = dst_g
            line_num += 1



total_week = int((max_timestamp - min_timestamp) * 1.0 / (60 * 60 * 24 * 7))
# print(total_week)
# time_list[t] = list of edge at time t 
like_time_list = [[] for _ in range(total_week+1)]
comment_time_list = [[] for _ in range(total_week+1)]
interact_time_list = [[] for _ in range(total_week+1)]
# time_list[t] = list of new forming edge at time t 
like_time_dif_list = [[] for _ in range(total_week+1)]
comment_time_dif_list = [[] for _ in range(total_week+1)]
interact_time_dif_list = [[] for _ in range(total_week+1)]


with open(file.format(testcase), 'r') as read_file:
        headers = read_file.readline()
        for line in read_file:
            token = line.strip().split(',')
            src_g =   [0]
            dst_g = token[1]
            src = token[2]
            dst = token[3]
            act = token[4]
            timestamp = int(token[5])
            week_num = int((timestamp - min_timestamp) * 1.0 / (60 * 60 * 24 * 7))
            # print(week_num)
            if act == 'like':
                like_time_list[week_num].append((src,dst))
                interact_time_list[week_num].append((src,dst))
            else:
                comment_time_list[week_num].append((src,dst))
                interact_time_list[week_num].append((src,dst))

for i in range(total_week+1):
    if i != 0:
        like_time_list[i] = list(set(like_time_list[i-1]).union(set(like_time_list[i])))
        comment_time_list[i] = list(set(comment_time_list[i-1]).union(set(comment_time_list[i])))
        interact_time_list[i] = list(set(interact_time_list[i-1]).union(set(interact_time_list[i])))
    else:
        like_time_list[i] = list(set(like_time_list[i]))
        like_time_list[i].sort(key=lambda tup: tup[0])
        comment_time_list[i] = list(set(comment_time_list[i]))
        comment_time_list[i].sort(key=lambda tup: tup[0])
        interact_time_list[i] = list(set(interact_time_list[i]))
        interact_time_list[i].sort(key=lambda tup: tup[0])

# finding new forming edges 
for i in range(total_week+1):
    if i == 0:
        like_time_dif_list[i] = like_time_list[i]
        comment_time_dif_list[i] = comment_time_list[i]
        interact_time_dif_list[i] = interact_time_list[i]
    else:
        like_time_dif_list[i] = list(set(like_time_list[i]) - set(like_time_list[i-1]))
        comment_time_dif_list[i] = list(set(comment_time_list[i]) - set(comment_time_list[i-1]))
        interact_time_dif_list[i] = list(set(interact_time_list[i]) - set(interact_time_list[i-1]))


# like network
G = nx.DiGraph()
line2write = []
OUTPUT_DIR = '{}/{}_hop.csv'
look_at = total_week+1
# shortest path length
# hop = 0
for byType in range(3):
    if byType == 0:
        act = 'like'
        now_list = like_time_dif_list
    elif byType == 1:
        act = 'comment'
        now_list = comment_time_dif_list
    else:
        act = 'interact'
        now_list = interact_time_dif_list

    if only1year:
        look_at = 52+1
    for i in range(look_at):
        if i == 0:
            if byType == 0:
                G.add_edges_from(now_list[0])
            elif byType == 1:
                G.add_edges_from(now_list[0])
            else:
                G.add_edges_from(now_list[0])
            line2write.append((src,dst,src_g,dst_g,1,0))
        else:
            for link in now_list[i]:
                if link[0] not in G or link[1] not in G:
                    hop = 'inf'
                else:
                    try :
                        hop = nx.shortest_path_length(G, source=link[0], target=link[1])
                    except nx.NetworkXNoPath:
                    	hop = 'inf'
                    # print(nx.shortest_path(G, source=link[0], target=link[1]))
                    src = link[0]
                    dst = link[1]
                    src_g = gender_dict[src]
                    dst_g = gender_dict[dst]
                    line2write.append((src,dst,src_g,dst_g,hop,i))
            G.add_edges_from(now_list[i])

    with open(OUTPUT_DIR.format(testcase, act), 'w') as writefile:
                writer = csv.writer(writefile)
                for line in line2write:
                    writer.writerow(line)
    G.clear()
    line2write = []




