import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict


file_node = '../dt_node_ins_filter.csv'
file_edge = 'dt_edge_ins_filter.csv'
file_edgew = "ins_full_dataset/output_file.csv"
header_list = ["edge_type", " actor_id", "week", "post_id"]
header_list_node = ["index", " user_id", "gender"]
post_type = ["comment", "like"]

# read the pickle back
start = time.time()
df = pd.read_pickle("indegree_temporal_ins/indegree_ins_data/df_indegree.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")



intensity_list = [{}, {}, {}]
output_list = [{}, {}, {}]

com = set()
lik = set()
ta = set()

# indegree matrix
node_num = len(df['user_id'])
#matrix_c = [[0] * node_num for _ in range(node_num)]
#matrix_l = [[0] * node_num for _ in range(node_num)]
#matrix_t = [[0] * node_num for _ in range(node_num)]

matrix_c = {}
matrix_l = {}

#################
filename = "timeweek/{}.csv"
list = range(547, 999)


for weeknum in list:
    #################
    print("the current weeknum is:", weeknum)
    if (os.path.exists(filename.format(weeknum)) == True):

        with open(filename.format(weeknum), 'r') as read_file:
            next(read_file)
            for line in read_file:
                token = line.strip().split(",")
                edge_type = token[1]
                # edge: user1 -> user2
                # user1 likes or comments user2
                # buile edge: user2 -> user1
                usr1 = token[2]
                usr2 = token[4]
                # print(usr1)
                # remove self-loop
                if usr1 != usr2:
                    if edge_type in post_type:

                        if "comment" in edge_type:

                            com.add(edge_type)
                            usr1_temp = usr1
                            usr1_temp = int(usr1_temp)
                            usr2_temp = usr2
                            usr2_temp = int(usr2_temp)
                            if usr1_temp in df.values:
                                if usr2_temp in df.values:

                                    if usr2 not in intensity_list[0]:
                                        intensity_list[0][usr2] = 1
                                    else:
                                        intensity_list[0][usr2] += 1

                                    if (usr2, usr1) not in output_list[0]:
                                        output_list[0][(usr2, usr1)] = 1
                                    else:
                                        output_list[0][(usr2, usr1)] += 1
                                    if int(usr1) == 2147483647 or int(usr2) == 2147483647:
                                        print("The problem user is:", usr1)
                                    else:
                                        if df[df['user_id']==int(usr1)]['user_id'].empty:
                                            print("this user is:", usr)
                                        else:
                                            if (df[df['user_id']==int(usr1)]['user_id'].item(),df[df['user_id']==int(usr2)]['user_id'].item()) in matrix_c:
                                                matrix_c[(df[df['user_id']==int(usr1)]['user_id'].item(),df[df['user_id']==int(usr2)]['user_id'].item())] += 1
                                            else:
                                                matrix_c[(df[df['user_id']==int(usr1)]['user_id'].item(),df[df['user_id']==int(usr2)]['user_id'].item())] = 1

                        elif "like" in edge_type:
                            # print(edge_type)
                            lik.add(edge_type)
                            usr1_temp = usr1
                            usr1_temp = int(usr1_temp)
                            usr2_temp = usr2
                            usr2_temp = int(usr2_temp)
                            if usr1_temp in df.values:
                                if usr2_temp in df.values:

                                    if usr2 not in intensity_list[1]:
                                        intensity_list[1][usr2] = 1
                                    else:
                                        intensity_list[1][usr2] += 1

                                    if (usr2, usr1) not in output_list[1]:
                                        output_list[1][(usr2, usr1)] = 1
                                    else:
                                        output_list[1][(usr2, usr1)] += 1
                                    if int(usr1) == 2147483647 or int(usr2) == 2147483647:
                                        print("The problem user is:", usr1)
                                    else:
                                        if df[df['user_id']==int(usr1)]['user_id'].empty:
                                            print("this user is:", usr1)
                                        else:
                                            if (df[df['user_id']==int(usr1)]['user_id'].item(),df[df['user_id']==int(usr2)]['user_id'].item()) in matrix_l:
                                                matrix_l[df[df['user_id']==int(usr1)]['user_id'].item(),df[df['user_id']==int(usr2)]['user_id'].item()] += 1
                                            else:
                                                matrix_l[(df[df['user_id']==int(usr1)]['user_id'].item(),df[df['user_id']==int(usr2)]['user_id'].item())] = 1

        id_intensity_list = [{}, {}, {}]

        user_list_ins = df['user_id'].tolist()
        for usr in user_list_ins:
            if str(usr) in intensity_list[0]:
                if (usr == 2147483647):
                    pass
                else:
                    if df[df['user_id'] == int(usr)].empty:
                        print("this user is:", usr)
                    else:
                        id_intensity_list[0][df[df['user_id']==int(usr)]['user_id'].item()] = intensity_list[0][str(usr)]
            else:
                if (int(usr) == 2147483647):
                    print("The problem user is:", usr)
                    pass
                else:
                    if df[df['user_id'] == int(usr)].empty:
                        print("this user is:", usr)
                    else:
                        id_intensity_list[0][df[df['user_id']==int(usr)]['user_id'].item()] = 0

            if str(usr) in intensity_list[1]:
                if (usr == 2147483647):
                    pass
                else:
                    if df[df['user_id'] == int(usr)].empty:
                        print("this user is:", usr)
                    else:
                        id_intensity_list[1][df[df['user_id']==int(usr)]['user_id'].item()] = intensity_list[1][str(usr)]
            else:
                if (int(usr) == 2147483647):
                    print("The problem user is:", usr)
                    pass
                else:
                    if df[df['user_id'] == int(usr)].empty:
                        print("this user is:", usr)
                    else:
                        id_intensity_list[1][df[df['user_id']==int(usr)]['user_id'].item()] = 0

        line2write = []
        OUTPUT_DIR = 'diffusion/{}.csv'

        types = ["comment", "like", "tag"]
        comment_set = set(output_list[0].keys())
        like_set = set(output_list[1].keys())
        tag_set = set(output_list[2].keys())
        keys = comment_set.union(like_set, tag_set)

        for key,value in matrix_c.items():
            #print("the matric_c:", matrix_c)
            #print("the key 0 is:",key[0])
            #print("the key 1 is:",key[0])
            #print("the key type is:", type(key))
            #print("the value is:",value)
            #print("the id intensity list is:",id_intensity_list[0][key[0]])
            if value != 0:
                if id_intensity_list[0][key[0]] != 0:
                    #print("i am come here hahaha")
                    prob = value * 1.0 / id_intensity_list[0][key[0]]
                    line2write.append([key[0], df[df['user_id']==int(key[0])]['gender'].item(), key[1], df[df['user_id']==int(key[1])]['gender'].item(), prob])
                if id_intensity_list[0][key[1]] != 0:
                    #print("i am come here hahaha")
                    prob = value * 1.0 / id_intensity_list[0][key[1]]
                    line2write.append([key[0], df[df['user_id']==int(key[0])]['gender'].item(), key[1], df[df['user_id']==int(key[1])]['gender'].item(), prob])

        OUTPUT_DIR = 'diffusion/{}_{}.csv'.format(types[0], weeknum)
        with open(OUTPUT_DIR, 'w', newline='\n') as writefile:
            writer = csv.writer(writefile, delimiter=" ")
            for line in line2write:
                writer.writerow(line)

        line2write = []
        for key,value in matrix_l.items():
            #print("the matric_l:", matrix_l)
            #print("the key 0 is:", key[0])
            #print("the key 1 is:", key[1])
            #print("the id_intensity_list:",id_intensity_list[1][key[0]])
                # print(j)
                # like network
            if value != 0:
                if id_intensity_list[1][key[0]] != 0:
                    prob = value * 1.0 / id_intensity_list[1][key[0]]
                    line2write.append([key[0], df[df['user_id']==int(key[0])]['gender'].item(), key[1], df[df['user_id']==int(key[1])]['gender'].item(), prob])
                if id_intensity_list[1][key[1]] != 0:
                    prob = value * 1.0 / id_intensity_list[1][key[1]]
                    line2write.append([key[0], df[df['user_id']==int(key[0])]['gender'].item(), key[1], df[df['user_id']==int(key[1])]['gender'].item(), prob])

        OUTPUT_DIR = 'diffusion/{}_{}.csv'.format(types[1], weeknum)
        with open(OUTPUT_DIR, 'w', newline='\n') as writefile:
            writer = csv.writer(writefile, delimiter=" ")
            for line in line2write:
                # line = ' '.join(map(str,line))
                writer.writerow(line)

 #################################################