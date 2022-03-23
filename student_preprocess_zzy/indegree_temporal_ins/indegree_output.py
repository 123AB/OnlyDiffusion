import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict

# 'nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria'
# testcase = 'receivernosend'
# file = '../../../dataset_2015/dataset_{}/task1/1_stat_user2/1_stat_user2_0.csv'
#file_node_test = '../dt_node_ins_filter_test.csv'
#file_node = '../dt_node_ins_filter.csv'
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
df = pd.read_pickle("indegree_ins_data/df_indegree.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")

# type: comment / like
# hindex_list = [{},{},{}]
#output_list = [{}, {}, {}]

com = set()
lik = set()
ta = set()

filename = "../timeweek/{}.csv"
list = range(1, 999)

for blocknum in list:
    print("this blocknum is:", blocknum)
    if (os.path.exists(filename.format(blocknum)) == True):
        # hindex_list = [{}, {}, {}]
        # indegree_list = [{},{},{}]
        output_list = [{}, {}, {}]
        indegree_list = [{}, {}, {}]
        edge_list = [{}, {}, {}]

        com = set()
        lik = set()
        ta = set()
        with open(filename.format(blocknum), 'r') as read_file:
            next(read_file)
            for line in read_file:
                token = line.strip().split(",")
                edge_type = token[1]
                # usr2 = actor
                # usr1 = person
                usr1 = token[4]
                usr2 = token[2]

                if edge_type in post_type:
                    if "comment" in edge_type:
                        com.add(edge_type)

                        usr1_temp = usr1
                        usr1_temp = int(usr1_temp)
                        usr2_temp = usr2
                        usr2_temp = int(usr2_temp)
                        if usr1_temp in df.values:
                            if usr2_temp in df.values:

                                if usr1 not in edge_list[0]:
                                    edge_list[0][usr1] = [usr2]
                                    indegree_list[0][usr1] = 1
                                    #print("I am:",indegree_list[0])
                                else:
                                    if usr2 not in edge_list[0][usr1]:
                                        edge_list[0][usr1].append(usr2)
                                        #print("this user1 is:",usr1)
                                        #print(indegree_list[0])
                                        indegree_list[0][usr1] += 1

                                if (usr1, usr2) not in output_list[0]:
                                    output_list[0][(usr1, usr2)] = 1
                                else:
                                    output_list[0][(usr1, usr2)] += 1


                    elif "like" in edge_type:
                        # print(edge_type)
                        lik.add(edge_type)
                        usr1_temp = usr1
                        usr1_temp = int(usr1_temp)
                        usr2_temp = usr2
                        usr2_temp = int(usr2_temp)
                        if usr1_temp in df.values:
                            if usr2_temp in df.values:

                                if usr1 not in edge_list[1]:
                                    edge_list[1][usr1] = [usr2]
                                    indegree_list[1][usr1] = 1
                                else:
                                    if usr2 not in edge_list[1][usr1]:
                                        edge_list[1][usr1].append(usr2)
                                        indegree_list[1][usr1] += 1

                                if (usr1, usr2) not in output_list[1]:
                                    output_list[1][(usr1, usr2)] = 1
                                else:
                                    output_list[1][(usr1, usr2)] += 1

        OUTPUT_DIR = 'indegree_list/indegree_list_{}.csv'.format(blocknum)
        pd.DataFrame(indegree_list).to_csv(OUTPUT_DIR)
        OUTPUT_DIR2 = 'output_list/output_list_{}.csv'.format(blocknum)
        pd.DataFrame(output_list).to_csv(OUTPUT_DIR2)

