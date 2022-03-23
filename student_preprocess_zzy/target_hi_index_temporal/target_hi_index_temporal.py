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
        degree = degree_list[usr]
        neighbor_degree_list = []
        for i in range(int(degree)):
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

gender_dict = {}
# 'nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria'
# testcase = 'receivernosend'
# file = '../../../dataset_2015/dataset_{}/task1/1_stat_user2/1_stat_user2_0.csv'

#file_degree = './outputdata/fb_degree_{}_{}.csv'
#file_edge_list = './outputdata/fb_edge_list_{}_{}.csv'

#file_degree = './outputdataTwoMonth/fb_degree_{}_{}.csv'
#file_edge_list = './outputdataTwoMonth/fb_edge_list_{}_{}.csv'

#file_degree = './outputdataTwoWeek/fb_degree_{}_{}.csv'
#file_edge_list = './outputdataTwoWeek/fb_edge_list_{}_{}.csv'

file_degree = './outputdataOneWeek/fb_degree_{}_{}.csv'
file_edge_list = './outputdataOneWeek/fb_edge_list_{}_{}.csv'
#file_degree_comment = 'fb_degree_{}_{}.csv'
#file_edge_list_comment = 'fb_edge_list_{}_{}.csv'

degree_list = {}
types = ["like", "comment"]

list = range(1,999)

for type in types:
    for counter in list:

        degree_list = {}
        gender_dict = {}

        if (os.path.exists(file_degree.format(type,counter)) == True):
            with open(file_degree.format(type,counter), 'r') as read_file:
                for line in read_file:
                    token = line.strip().split(" ")
                    usr = token[0]
                    usr_g = token[1]
                    degree = token[2]

                    if usr not in degree_list:
                        degree_list[usr] = degree
                    if usr not in gender_dict:
                        gender_dict[usr] = usr_g

            # for key, value in gender_dict.items():
            #   print(key,'->', value)
            # print(len(gender_dict))
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
                            if gender_dict[edges[counter_edges]] == '2':
                                edge_list_female.append(edges[counter_edges])
                            if gender_dict[edges[counter_edges]] == '1':
                                edge_list_male.append(edges[counter_edges])
                            counter_edges = counter_edges + 1
                        counter_edges = 0
                        edge_list_gender[usr] = edge_list_female
                        edge_list_female = []
                        edge_list_male = []
                    '''
                    if usr not in edge_list_female:
                        if gender_dict[usr] == '2':
                            edge_list_female[usr] = edges
                    if usr not in edge_list_male:
                        if gender_dict[usr] == '1':
                            edge_list_male[usr] = edges
                    '''
        #################
        line2write = []
        # OUTPUT_DIR = 'all/students_labels.csv'

        usr_id = 0
        id_dict = {}
        sorted_usr_list = []
        for usr in gender_dict:
            sorted_usr_list.append(usr)
        sorted_usr_list = sorted(sorted_usr_list)

        for sort_counter in range(len(sorted_usr_list)):
            usr = sorted_usr_list[sort_counter]

            if usr not in id_dict:
                id_dict[usr] = sort_counter

            out = []
            out.append(sort_counter)
            for j in range(len(sorted_usr_list)):
                if j != sort_counter:
                    out.append(0)
                else:
                    out.append(1)
            out.append(gender_dict[usr])
            out_tu = tuple(out)
            line2write.append(out)

#        with open(OUTPUT_DIR, 'w') as writefile:
#            writer = csv.writer(writefile)
#            for line in line2write:
#                writer.writerow(line)
#########################################

        line2write = []
        #OUTPUT_DIR = 'outputNodenumber/hi_index_{}_{}_{}.csv'
        #OUTPUT_DIR = 'outputNodenumberTwoMonth/hi_index_{}_{}_{}.csv'
        #OUTPUT_DIR = 'outputNodenumberTwoWeek/hi_index_{}_{}_{}.csv'
        OUTPUT_DIR = 'outputNodenumberOneWeek/hi_index_{}_{}_{}.csv'


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
                    line2write.append((id_dict[usr], gender_dict[usr], index))

                with open(OUTPUT_DIR.format(type,counter,target_ratio), 'w',newline='\n') as writefile:
                    writer = csv.writer(writefile,delimiter=" ")
                    for line in line2write:
                        writer.writerow(line)

                line2write = []




