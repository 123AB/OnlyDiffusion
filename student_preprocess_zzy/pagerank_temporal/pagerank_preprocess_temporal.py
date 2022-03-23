import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict

gender_dict = {}
# 'nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria'
# testcase = 'receivernosend'
# file = '../../../dataset_2015/dataset_{}/task1/1_stat_user2/1_stat_user2_0.csv'
file = 'only_post/students_edges_all.csv'

# edge type
byType = ["\"post_comment\"", "\"post_like\"", "\"post_tag\""]

post_type = ['comment', 'like', 'tag', 'interact']
#file_label = '../all/students_labels.csv'
file_label = 'students_labels.csv'

#post_type = ["post_comment", "post_like" , "post_tag"]
post_type = ['comment', 'like', 'tag', 'interact']

male_pagerank = [[], [], [], []];
female_pagerank = [[], [], [], []];
pagerank_centrality = [{}, {}, {}, {}]
file_node = '../DT_node.csv'

#file_label = 'students_labels.csv'
# build gender dict
with open(file_label, 'r') as read_file:
    for line in read_file:
        token = line.strip().split(' ')
        usr = token[0]
        gender = token[1]
        if usr not in gender_dict: gender_dict[usr] = gender

#with open(file_label, 'r') as read_file:
#    next(read_file)
#    for line in read_file:
#        token = line.strip().split(' ')
#        if token[1] == '0' or token[1] == '1':
#            usr = eval(token[0])
            # 1 for female and 0 for male
#            usr_g = eval(token[1])

#            if usr not in gender_dict:
#                gender_dict[usr] = str(int(usr_g) + 1)

#with open(file_node, 'r') as read_file:
#    next(read_file)
#    for line in read_file:
#        token = line.strip().split(",")
#        if token[2] == '0' or token[2] == '1':
#            usr = eval(token[1])
            # 1 for female and 0 for male
#            usr_g = eval(token[2])

#            if usr not in gender_dict:
#                gender_dict[usr] = str(int(usr_g) + 1)

print('#graph size: ', len(gender_dict))
#print('#graph: ', gender_dict)


#filename = "../all/students_edges_all_{}.csv"

#filename = "../all/oneweek/students_edges_all_{}.csv"
#filename = "../all/twoweek/students_edges_all_{}.csv"
filename = "../all/twomonth/students_edges_all_{}.csv"
#filename = "../all/month/students_edges_all_{}.csv"


list = range(1,999)

for blocknum in list:
    if (os.path.exists(filename.format(blocknum)) == True):
        for byType in range(3):

            header = ['src', '1', 'dst', '2', 'comment', 'like', 'tag', 'interact']
            #header = ['rownum', 'edge_type', 'src', 'week', 'dst']
            #df = pd.read_csv(file, names=header)
            df = pd.read_csv(filename.format(blocknum), names=header)
            #df = pd.read_csv(filename.format(blocknum), skiprows=1, header=None)
            #df.columns=['rownum','edge_type','src','week','dst']
            cols2dele = [1, 3]
            #cols2dele = [0, 3]
            df.drop(df.columns[cols2dele], axis=1, inplace=True)
            df.iloc[:, 2 + byType] = pd.to_numeric(df.iloc[:, 2 + byType])
            Graphtype = nx.DiGraph()

            if byType == 0:
                weight = 'comment'
            elif byType == 1:
                weight = 'like'
            elif byType == 2:
                weight = 'tag'
            else:
                weight = 'interact'
            G = nx.from_pandas_edgelist(df, 'src', 'dst', edge_attr=weight, create_using=Graphtype)
            pagerank_centrality[byType] = nx.pagerank(G, weight=weight)
            #print(pagerank_centrality)

            for n, c in sorted(pagerank_centrality[byType].items()):
                n = str(n).strip()
                if gender_dict[str(n)] == '1':
                    male_pagerank[byType].append(c)
                elif gender_dict[str(n)] == '2':
                    female_pagerank[byType].append(c)

            male_pagerank[byType] = sorted(male_pagerank[byType])
            female_pagerank[byType] = sorted(female_pagerank[byType])

            male_list = {}
            female_list = {}
            for value in male_pagerank[byType]:
                if value not in male_list:
                    male_list[value] = 1
                else:
                    male_list[value] += 1
            for value in female_pagerank[byType]:
                if value not in female_list:
                    female_list[value] = 1
                else:
                    female_list[value] += 1
            # print(male_list)
            male_list_sorted = [(val, male_list[val]) for val in sorted(male_list.keys())]
            female_list_sorted = [(val, female_list[val]) for val in sorted(female_list.keys())]
            #print(male_list_sorted)
            #print(female_list_sorted)
            # print(pagerank_centrality[0])
            s = [0, 0]

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

            # sorted output file
            line2write = []
            for i in range(4):
                pagerank_centrality_sorted = sorted(pagerank_centrality[i].items(), key=lambda x: x[1], reverse=True)
                for pair in pagerank_centrality_sorted:
                    usr = pair[0]
                    value = pair[1]
                    usr = str(usr).strip()
                    #usr = '{1}{0}{1}'.format(usr,"'")
                    #print(usr)
                    #print(value)
                    #print(gender_dict)
                    if (usr in gender_dict):
                        #print("I am come here")
                        line2write.append((id_dict[usr], gender_dict[str(usr)], value))
                    else:
                        pass

                #OUTPUT_DIR = 'pagerank/{}_{}.csv'.format(post_type[i],blocknum)

                #OUTPUT_DIR = 'pagerank_oneweek/{}_{}.csv'.format(post_type[i],blocknum)
                #OUTPUT_DIR = 'pagerank_twoweek/{}_{}.csv'.format(post_type[i],blocknum)
                OUTPUT_DIR = 'pagerank_twomonth/{}_{}.csv'.format(post_type[i],blocknum)
                #OUTPUT_DIR = 'pagerank/{}_{}.csv'.format(post_type[i],blocknum)

                with open(OUTPUT_DIR, 'w', newline='\n') as writefile:
                    writer = csv.writer(writefile, delimiter=" ")
                    for line in line2write:
                        writer.writerow(line)

                line2write = []

            #male_pagerank = [[], [], [], []];
            #female_pagerank = [[], [], [], []];
            #pagerank_centrality = [{}, {}, {}, {}]

'''

    for i in pagerank_centrality[byType].keys():
        line2write.append((i, gender_dict[str(i)], pagerank_centrality[byType][i]))
    OUTPUT_DIR = 'pagerank/pagerank_{}.csv'.format(post_type[byType])
    with open(OUTPUT_DIR, 'w') as writefile:
        writer = csv.writer(writefile)
        for line in line2write:
            writer.writerow(line)
'''

# print(pagerank_centrality[0])

'''
    line2write = []
    OUTPUT_DIR = 'pagerank/pagerank_{}_{}.csv'.format(gender, byType)
    with open(OUTPUT_DIR, 'w') as writefile:
        writer = csv.writer(writefile)
        for line in line2write:
            writer.writerow(line)

    for gender, lst in enumerate([male_list_sorted, female_list_sorted]):
        sum = 0
        tmp_line2write = []
        for k, v in lst:
            sum = sum + v
            tmp_line2write.append([k, sum])
        s[gender] = s[gender] + sum

    # CCDF Calculation
    for gender, lst in enumerate([male_list_sorted, female_list_sorted]):
        sum = 0
        line2write = []
        for k, v in lst:
            line2write.append([k, 1 - float(sum+v)/float(s[gender])])
            sum = sum + v
        OUTPUT_DIR = 'pagerank/pagerank_{}_{}.csv'.format(gender, byType)
        with open(OUTPUT_DIR, 'w') as writefile:
            writer = csv.writer(writefile)
            for line in line2write:
                writer.writerow(line)

'''










