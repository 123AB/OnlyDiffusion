# input line : gender1 gender2 id1 id2 timestamp
# output line : gender1 gender2 id1 id2 #hop #week

import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict
from collections import Counter


# input is a degree dictionary


def count_N(neighbor_degree_list, index):
    count = 0
    for num in neighbor_degree_list:
        if num >= index:
            count += 1
    return count


def HI_index(degree_list, edge_list):
    hi_index_list = {}
    for usr, edges in edge_list.items():
        if usr in degree_list:
            degree = degree_list[usr]
            neighbor_degree_list = []
            for i in range(int(degree)):
                if edges[i] in degree_list:
                    neighbor_degree_list.append(int(degree_list[edges[i]]))
            # from 0 to max_neighbor_degree - 1
            # print(neighbor_degree_list)
            hi_index = 1
            for i in range(int(degree) + 1):
                if (i > 0):
                    # N is the number of neighbor that has degree larger than i
                    N = count_N(neighbor_degree_list, i)
                    if N >= i:
                        hi_index = i
                    else:
                        break

            hi_index_list[usr] = hi_index
    return hi_index_list

def Nf_hi_index(degree_list, edge_list_female):
    Nf_hi_index_list = {}
    for usr, edges in edge_list_female.items():
        #degree = degree_list[usr]
        degree = len(edges)
        neighbor_degree_list = []
        for i in range(int(degree)):
            if edges:
                neighbor_degree_list.append(int(degree_list[edges[i]]))
            else:
                pass
        # from 0 to max_neighbor_degree - 1
        # print(neighbor_degree_list)
        target_hi_index = 1
        if neighbor_degree_list:
            for i in range(int(degree) + 1):
                if (i > 0):
                    # N is the number of neighbor that has degree larger than i
                    N = count_N(neighbor_degree_list, i)
                    if N >= i:
                        target_hi_index = i
                    else:
                        break
        else:
            pass

        Nf_hi_index_list[usr] = target_hi_index
    return Nf_hi_index_list

def TARGET_hi_index(hi_index_list, Nf_hi_index_list,target_ratio):
    target_hi_index_list = {}
    for usr in hi_index_list:
        if(usr in Nf_hi_index_list):
            target_hi_index_list[usr] = (hi_index_list[usr])*(1-abs((Nf_hi_index_list[usr]/hi_index_list[usr]) - target_ratio))

    return target_hi_index_list

# read the pickle back
start = time.time()
df = pd.read_pickle("hindex_ins_data/df_hindex.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")# 'nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria'
header_list = ["edge_type", " actor_id", "week", "post_id"]
header_list_node = ["index", " user_id", "gender"]
post_type = ["comment", "like"]


file_degree = './output_data/fb_degree_{}_{}.csv'
file_edge_list = './output_data/fb_edge_list_{}_{}.csv'

#file_degree_comment = 'fb_degree_{}_{}.csv'
#file_edge_list_comment = 'fb_edge_list_{}_{}.csv'

degree_list = {}
types = ["like", "comment"]
#rangre(533,999)
list = range(1,999)

for type in types:
    for counter in list:
        print("this blocknum is:", counter)

        degree_list = {}

        if (os.path.exists(file_degree.format(type,counter)) == True):
            with open(file_degree.format(type,counter), 'r') as read_file:
                for line in read_file:
                    token = line.strip().split(" ")
                    usr = token[0]
                    usr_g = token[1]
                    degree = token[2]

                    if usr not in degree_list:
                        degree_list[usr] = degree
        edge_list = {}
        edge_list_gender = {}
        edge_list_female = []
        edge_list_male = []

        if (os.path.exists(file_edge_list.format(type,counter)) == True):
        # compute in-degree(or simply "degree")
            with open(file_edge_list.format(type,counter), 'r') as read_file:
                for line in read_file:
                    token = line.strip().split(" ")
                    usr = token[0]
                    # list of edges of usr
                    edges = token[1:]
                    # print(usr1, usr2)
                    if usr not in edge_list:
                        edge_list[usr] = edges


            with open(file_edge_list.format(type,counter), 'r') as read_file:
                for line in read_file:
                    token = line.strip().split(" ")
                    usr = token[0]
                    # list of edges of usr
                    edges = token[1:]
                    # print(usr1, usr2)

                    if usr not in edge_list_gender:
                        counter_edges = 0
                        while counter_edges < len(edges):
                            if (int(edges[counter_edges]) == 2147483647):
                                print("The problem user is:", edges[counter_edges])
                                pass
                            else:
                                if df[df['user_id'] == int(edges[counter_edges])].empty:
                                    print("this user is:", edges[counter_edges])
                                else:
                                    if df[df['user_id']==int(edges[counter_edges])]['gender'].item() == '2':
                                        edge_list_female.append(edges[counter_edges])
                                    if df[df['user_id']==int(edges[counter_edges])]['gender'].item() == '1':
                                        edge_list_male.append(edges[counter_edges])
                            counter_edges = counter_edges + 1
                        counter_edges = 0
                        edge_list_gender[usr] = edge_list_female
                        edge_list_female = []
                        edge_list_male = []


        line2write = []
        OUTPUT_DIR = 'outputNodenumber/hi_index_{}_{}_{}.csv'
        if (os.path.exists(file_edge_list.format(type,counter)) == True and os.path.exists(file_degree.format(type,counter)) == True):
            for ratio in range(101):
                target_ratio = ratio / 100
                hi_index_list = HI_index(degree_list, edge_list)
                nf_hi_index_list = Nf_hi_index(degree_list, edge_list_gender)

                sorted_degree_list = sorted(hi_index_list.items(), key=lambda d: int(d[1]), reverse=True)
                target_hi_index_list = TARGET_hi_index(hi_index_list, nf_hi_index_list, target_ratio)
                target_sorted_degree_list = sorted(target_hi_index_list.items(), key=lambda d: float(d[1]), reverse=True)
                #print("the target_sorted_degree_list started\n")
                #print(counter)
                #print("\n")
                #print(target_sorted_degree_list)
                #print("this is finished\n")

                #for pair in sorted_degree_list:
                for pair in target_sorted_degree_list:
                    usr = pair[0]
                    index = pair[1]
                    line2write.append((df[df['user_id']==int(usr)]['user_id'].item(), df[df['user_id']==int(usr)]['gender'].item(), index))

                with open(OUTPUT_DIR.format(type,counter,target_ratio), 'w',newline='\n') as writefile:
                    writer = csv.writer(writefile,delimiter=" ")
                    for line in line2write:
                        writer.writerow(line)

                line2write = []




