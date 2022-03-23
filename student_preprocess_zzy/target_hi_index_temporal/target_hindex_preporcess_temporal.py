# input line : gender1 gender2 id1 id2 timestamp
# output line : gender1 gender2 id1 id2 #hop #week

import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict


# input is a degree dictionary
def HI_index(degree_list):
    hi_index_list = []
    for i in range(3):
        a = 1


gender_dict = {}
# 'nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria'
# testcase = 'receivernosend'
# file = '../../../dataset_2015/dataset_{}/task1/1_stat_user2/1_stat_user2_0.csv'
file_profile = '../all/students_labels.csv'
#file_relation = '../only_post/students_edges_{}.csv'
file_node = '../DT_node.csv'
#file_relation = '../dt_edge_new.csv'
file_relation = '../students_edges_all/students_edges_all.csv'
file_edgew = "output_test.csv"
#header_list =["edge_type", " actor_id","week","post_id"]

#edge type
byType = ["\"post_comment\"" , "\"post_like\"" , "\"post_tag\"" , "\"uploaded_photos_comment\"" , "\"uploaded_photos_likes\"" , "\"uploaded_photos_tags\"" , "\"tagged_photos_comments\"" , "\"tagged_photos_likes\"" , "\"tagged_photos_tags\""]

post_type = ["post_comment", "post_like" , "post_tag"]
header_list =["edge_type", " actor_id","week","post_id"]

# read in profile
#with open(file_node, 'r') as read_file:
#    for line in read_file:
#        token = line.strip().split(",")
#        if True:
#            usr = token[0]
#            # 1 for male and 2 for female
#            usr_g = token[-1]

#            if usr not in gender_dict:
#                gender_dict[usr] = usr_g

with open(file_node, 'r') as read_file:
    next(read_file)
    for line in read_file:
        token = line.strip().split(",")
        if token[2] == '0' or token[2] == '1':
            usr = eval(token[1])
            # 1 for female and 0 for male
            usr_g = eval(token[2])

            if usr not in gender_dict:
                gender_dict[usr] = str(int(usr_g) + 1)

# for key, value in gender_dict.items():
#   print(key,'->', value)
#print(len(gender_dict))
#print(gender_dict)
edge_list = {}
edge_list2 = {}
degree_list = {}
# compute in-degree(or simply "degree")
types = ['comment', 'like', 'tag']

#filename = "../raw_month_data/{}.csv"
#filename = "../raw_oneWeek_data/{}.csv"
#filename = "../raw_data_twoMonth/{}.csv"
#filename = "../raw_twoWeek_data/{}.csv"
filename = "../raw_oneWeek_data/{}.csv"


list = range(1,999)

for i in list:
    if (os.path.exists(filename.format(i)) == True):
        with open(filename.format(i), 'r') as read_file:
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
                        if usr1 in gender_dict:
                                if usr2 in gender_dict:
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
                        if usr1 in gender_dict:
                            if usr2 in gender_dict:
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
                '''
                        if edge_type in post_type:
                            if "tag" in edge_type:
                                if usr1 in gender_dict:
                                    if usr2 in gender_dict:
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
                '''

#################
        line2write = []
        #OUTPUT_DIR = 'all/students_labels.csv'

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
        #types = ["comment", "like", "tag"]
        #comment_set = set(edge_list[0].keys())
        #like_set = set(edge_list[1].keys())
        #tag_set = set(edge_list[2].keys())
        #keys = comment_set.union(like_set, tag_set)

        #OUTPUT_DIR = './outputdata/fb_degree_comment_{}.csv'.format(i)
        #OUTPUT_DIR_1 = './outputdata/fb_edge_list_comment_{}.csv'.format(i)

        #OUTPUT_DIR_like = './outputdata/fb_degree_like_{}.csv'.format(i)
        #OUTPUT_DIR_1_like = './outputdata/fb_edge_list_like_{}.csv'.format(i)

        #OUTPUT_DIR = './outputdataTwoMonth/fb_degree_comment_{}.csv'.format(i)
        #OUTPUT_DIR_1 = './outputdataTwoMonth/fb_edge_list_comment_{}.csv'.format(i)

        #OUTPUT_DIR_like = './outputdataTwoMonth/fb_degree_like_{}.csv'.format(i)
        #OUTPUT_DIR_1_like = './outputdataTwoMonth/fb_edge_list_like_{}.csv'.format(i)

        #OUTPUT_DIR = './outputdataTwoWeek/fb_degree_comment_{}.csv'.format(i)
        #OUTPUT_DIR_1 = './outputdataTwoWeek/fb_edge_list_comment_{}.csv'.format(i)

        #OUTPUT_DIR_like = './outputdataTwoWeek/fb_degree_like_{}.csv'.format(i)
        #OUTPUT_DIR_1_like = './outputdataTwoWeek/fb_edge_list_like_{}.csv'.format(i)

        OUTPUT_DIR = './outputdataOneWeek/fb_degree_comment_{}.csv'.format(i)
        OUTPUT_DIR_1 = './outputdataOneWeek/fb_edge_list_comment_{}.csv'.format(i)

        OUTPUT_DIR_like = './outputdataOneWeek/fb_degree_like_{}.csv'.format(i)
        OUTPUT_DIR_1_like = './outputdataOneWeek/fb_edge_list_like_{}.csv'.format(i)


        edge_list_sorted = OrderedDict(sorted(edge_list.items(), key=lambda t: int(t[0])))
        sorted_degree_list = sorted(edge_list_sorted.items(), key=lambda d: len(d[1]), reverse=True)

        edge_list_sorted2 = OrderedDict(sorted(edge_list2.items(), key=lambda t: int(t[0])))
        sorted_degree_list2 = sorted(edge_list_sorted2.items(), key=lambda d: len(d[1]), reverse=True)
        # edge_list_sorted = [(usr , edge_list[usr]) for usr in sorted(edge_list.keys())]

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
            #line2write.append((usr, gender_dict[usr], len(degree)))
            line2write.append((usr, gender_dict[usr], len(degree)))

        with open(OUTPUT_DIR,'w',newline='\n') as writefile:
            writer = csv.writer(writefile,delimiter=" ")
            for line in line2write:
                writer.writerow(line)

####################################################################
        line2write2 = []

        for usr, edge in edge_list_sorted2.items():
            line = []
            line.append(usr)
            for edges in edge:
                line.append(edges)
            line_ = tuple(line)
            line2write2.append(line_)

        with open(OUTPUT_DIR_1_like,'w',newline='\n') as writefile:
            writer = csv.writer(writefile,delimiter=" ")
            for line in line2write2:
                writer.writerow(line)

        line2write2 = []

        for pair in sorted_degree_list2:
            usr = pair[0]
            degree = pair[1]
            line2write2.append((usr, gender_dict[usr], len(degree)))

        with open(OUTPUT_DIR_like,'w',newline='\n') as writefile:
            writer = csv.writer(writefile,delimiter=" ")
            for line in line2write2:
                writer.writerow(line)






