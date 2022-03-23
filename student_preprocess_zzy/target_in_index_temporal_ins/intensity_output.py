# input line : gender1 gender2 id1 id2 timestamp
# output line : gender1 gender2 id1 id2 #hop #week

import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict
import pickle

# input is a degree dictionary
def HI_index(degree_list):
    hi_index_list = []
    for i in range(3):
        a = 1


gender_dict = {}


file_node = '../dt_node_ins_filter.csv'

file_edge = 'dt_edge_ins_filter.csv'
file_edgew = "hindex_temporal_dataset/output_file.csv"
header_list = ["edge_type", " actor_id", "week", "post_id"]
header_list_node = ["index", " user_id", "gender"]

#edge type
byType = ["\"post_comment\"" , "\"post_like\"" , "\"post_tag\"" , "\"uploaded_photos_comment\"" , "\"uploaded_photos_likes\"" , "\"uploaded_photos_tags\"" , "\"tagged_photos_comments\"" , "\"tagged_photos_likes\"" , "\"tagged_photos_tags\""]

post_type = ["comment", "like"]
header_list = ["edge_type", " actor_id", "week", "post_id"]


# read the pickle back
start = time.time()
df = pd.read_pickle("hindex_ins_data/df_hindex.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")
print(df)
#edge_list = {}
#edge_list2 = {}
#degree_list = {}

edge_list = []
edge_list2 = []
degree_list = []
# compute in-degree(or simply "degree")

types = ['comment', 'like']

filename = "../timeweek/{}.csv"
m = 1

list = range(1,999)

for blocknum in list:
    print("this blocknum is:",blocknum)
    if (os.path.exists(filename.format(blocknum)) == True):
        # indegree_list = [{},{},{}]

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

        #print("this is edgelist:",edge_list)
        #print("this is edge list2",edge_list2)
        OUTPUT_DIR = 'hindex_list/edge_list_{}.pickle'.format(blocknum)
        #pd.DataFrame(edge_list).to_csv(OUTPUT_DIR)
        OUTPUT_DIR2 = 'output_list/edge_list2_{}.pickle'.format(blocknum)



        with open(OUTPUT_DIR, 'wb') as handle:
            pickle.dump(edge_list, handle, protocol=pickle.HIGHEST_PROTOCOL)
        with open(OUTPUT_DIR2, 'wb') as handle:
            pickle.dump(edge_list2, handle, protocol=pickle.HIGHEST_PROTOCOL)
        #OUTPUT_DIR2 = 'output_list/edge_list2_{}.csv'.format(blocknum)
        #pd.DataFrame(edge_list2).to_csv(OUTPUT_DIR2)
