# input line : gender1 gender2 id1 id2 timestamp
# output line : gender1 gender2 id1 id2 #hop #week

import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict




file_node = '../dt_node_ins_filter.csv'

# file_edge = 'DT_edge.csv'
file_edge = 'dt_edge_ins_filter.csv'
# file_edge = "test.csv"
file_edgew = "ins_full_dataset/output_file.csv"
header_list = ["edge_type", " actor_id", "week", "post_id"]
header_list_node = ["index", " user_id", "gender"]
post_type = ["comment", "like"]

# read the pickle back
start = time.time()
df = pd.read_pickle("hindex_ins_data/df_hindex.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")

#print(df)
#print(df[df['user_id']==int(1418179390)]['user_id'].item())
# type: comment / like
# hindex_list = [{},{},{}]
#output_list = [{}, {}, {}]
com = set()
lik = set()
ta = set()

degree_list = {}
filename = "../timeweek/{}.csv"
list = range(1, 999)

for blocknum in list:
    print("this blocknum is:", blocknum)
    if (os.path.exists(filename.format(blocknum)) == True):
        edge_list = {}
        edge_list2 = {}
        with open(filename.format(blocknum), 'r') as read_file:
            for line in read_file:
                token = line.strip().split(",")
                edge_type = token[1]
                # usr2 = actor
                # usr1 = person
                usr1 = token[4]
                usr2 = token[2]
                #token = line.strip().split(",")
                #usr1 = token[0]
                #usr2 = token[1]
                # print(usr1, usr2)
                if edge_type in post_type:
                    if "comment" in edge_type:
                        usr1_temp = usr1
                        usr1_temp = int(usr1_temp)
                        usr2_temp = usr2
                        usr2_temp = int(usr2_temp)
                        if usr1_temp in df.values:
                                if usr2_temp in df.values:
                                    # store in edge list
                                    if usr1 not in edge_list:
                                        edge_list[usr1] = [usr2]
                                    else:
                                        if usr2 not in edge_list[usr1]:
                                            edge_list[usr1].append(usr2)
                                    if usr2 not in edge_list:
                                        edge_list[usr2] = [usr1]
                                    else:
                                        if usr1 not in edge_list[usr2]:
                                            edge_list[usr2].append(usr1)

                if edge_type in post_type:
                    if "like" in edge_type:
                        usr1_temp = usr1
                        usr1_temp = int(usr1_temp)
                        usr2_temp = usr2
                        usr2_temp = int(usr2_temp)
                        if usr1_temp in df.values:
                            if usr2_temp in df.values:
                                # store in edge list
                                if usr1 not in edge_list2:
                                    edge_list2[usr1] = [usr2]
                                else:
                                    if usr2 not in edge_list2[usr1]:
                                        edge_list2[usr1].append(usr2)
                                if usr2 not in edge_list2:
                                    edge_list2[usr2] = [usr1]
                                else:
                                    if usr1 not in edge_list2[usr2]:
                                        edge_list2[usr2].append(usr1)

        edge_list_sorted = OrderedDict(sorted(edge_list.items(), key=lambda t: int(t[0])))
        sorted_degree_list = sorted(edge_list_sorted.items(), key=lambda d: len(d[1]), reverse=True)

        edge_list_sorted2 = OrderedDict(sorted(edge_list2.items(), key=lambda t: int(t[0])))
        sorted_degree_list2 = sorted(edge_list_sorted2.items(), key=lambda d: len(d[1]), reverse=True)

        OUTPUT_DIR = 'output_data/fb_degree_comment_{}.csv'.format(blocknum)
        OUTPUT_DIR_1 = 'output_data/fb_edge_list_comment_{}.csv'.format(blocknum)

        #OUTPUT_DIR_like = 'output_data/fb_degree_like_{}.csv'.format(blocknum)
        #OUTPUT_DIR_1_like = 'output_data/fb_edge_list_like_{}.csv'.format(blocknum)


        line2write = []

        for usr, edge in edge_list_sorted.items():
            line = []
            line.append(usr)
            for edges in edge:
                line.append(edges)
            line_ = tuple(line)
            line2write.append(line_)

        with open(OUTPUT_DIR_1,'w',newline='\n') as writefile:
            writer = csv.writer(writefile,delimiter=" ")
            for line in line2write:
                writer.writerow(line)

        line2write = []


        for pair in sorted_degree_list:
            usr = pair[0]
            degree = pair[1]
            # line2write.append((usr, gender_dict[usr], len(degree)))
            if (int(usr) == 2147483647):
                print("The problem user is:",usr)
                pass
            else:
                if df[df['user_id'] == int(usr)].empty:
                    print("this user is:", usr)
                else:
                    #print("the user is:",df[df['user_id']==int(usr)])
                    #print("the gender is:",df[df['user_id']==int(usr)]['gender'].item())
                    #print("the user gender:",df[df['user_id']==int(usr)]['gender'].item())
                    #print("the degree of len is:",len(degree))
                    line2write.append((usr, df[df['user_id']==int(usr)]['gender'].item(), len(degree)))

        with open(OUTPUT_DIR, 'w', newline='\n') as writefile:
            writer = csv.writer(writefile, delimiter=" ")
            for line in line2write:
                writer.writerow(line)

        ####################################################################
        #OUTPUT_DIR = 'output_list/edge_list_{}.csv'.format(blocknum)
        #print(edge_list)
        #pd.DataFrame(edge_list).to_csv(OUTPUT_DIR)
        #OUTPUT_DIR2 = 'output_list/edge_list2_{}.csv'.format(blocknum)
        #print(edge_list2)
        #pd.DataFrame(edge_list2).to_csv(OUTPUT_DIR2)
