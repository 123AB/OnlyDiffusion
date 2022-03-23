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
file_node = 'dt_node_ins_filter.csv'
# file_edge = 'DT_edge.csv'
file_edge = 'dt_edge_ins_filter.csv'
# file_edge = "test.csv"
file_edgew = "output_test.csv"
header_list = ["edge_type", " actor_id", "week", "post_id"]

# edge type
byType = ["\"post_comment\"", "\"post_like\"", "\"post_tag\"", "\"uploaded_photos_comment\"",
          "\"uploaded_photos_likes\"", "\"uploaded_photos_tags\"", "\"tagged_photos_comments\"",
          "\"tagged_photos_likes\"", "\"tagged_photos_tags\""]

post_type = ["comment", "like", "tag"]

# read in profile
with open(file_node, 'r') as read_file:
    #next(read_file)
    for line in read_file:
        token = line.strip().split(";")
        if eval(token[2]) == '1' or eval(token[2]) == '2':
            usr = eval(token[1])
            # 2 for female and 1 for male
            usr_g = eval(token[2])

            if usr not in gender_dict:
                gender_dict[usr] = str(int(usr_g) + 1)

'''
for key, value in gender_dict.items():
    print(key,'->', value)
print(len(gender_dict))
'''

print("#graph node : ", len(gender_dict))

line2write = []
OUTPUT_DIR = 'all/students_labels.csv'

usr_id = 0
id_dict = {}
id_gender_dict = {}
sorted_usr_list = []
for usr in gender_dict:
    sorted_usr_list.append(usr)
sorted_usr_list = sorted(sorted_usr_list)

for i in range(len(sorted_usr_list)):
    print(i)
    usr = sorted_usr_list[i]

    if usr not in id_dict:
        id_dict[usr] = i
        id_gender_dict[i] = gender_dict[usr]

    out = []
    out.append(i)
    for j in range(len(sorted_usr_list)):
        if j != i:
            out.append(0)
        else:
            out.append(1)
    out.append(gender_dict[usr])
    out_tu = tuple(out)
    line2write.append(out)
'''
with open(OUTPUT_DIR, 'w') as writefile:
    writer = csv.writer(writefile)
    for line in line2write:
        writer.writerow(line)
'''

# usr:[in-neighbor1, in-neighbor2,...]

# type: comment / like / tag
# edge_list = [{},{},{}]
intensity_list = [{}, {}, {}]
# indegree_list = [{},{},{}]
output_list = [{}, {}, {}]

com = set()
lik = set()
ta = set()

# indegree matrix
node_num = len(gender_dict)
matrix_c = [[0] * node_num for _ in range(node_num)]
matrix_l = [[0] * node_num for _ in range(node_num)]
matrix_t = [[0] * node_num for _ in range(node_num)]

####

with open(file_edge, 'r') as read_file:
    #next(read_file)
    line2write = []
    for line in read_file:
        token = line.strip().split(";")
        row_num = eval(token[0])
        edge_type = eval(token[1])
        usr1 = eval(token[2])
        token[3] = eval(token[3])
        # timeStamp = math.ceil(int(token[3])/604800) -1464  ##this is per week
        timeStamp = math.ceil(int(token[3]) / 2629743) ## this is per month
        # timeStamp = math.ceil(int(token[3]) / 5259486) - 168 ## this is per twomonth
        # timeStamp = math.ceil(int(token[3]) / 7889229) - 112  ## this is per season
        # timeStamp = math.ceil(int(token[3]) / 31556926) - 28 ## this is per year
        #timeStamp = math.ceil(int(token[3]) / 15778463) - 56  ## this is per half year
        usr2 = eval(token[4])

        line2write.append((edge_type, usr1, timeStamp, usr2))

    OUTPUT_DIR = 'output_test.csv'
    with open(OUTPUT_DIR, 'w') as writefile:
        # writer = csv.writer(writefile,delimiter=" ")
        writer = csv.writer(writefile, lineterminator="\n")
        for wline in line2write:
            writer.writerow(wline)

####

####

# with open(file_edgew, 'r') as read_file:
#    next(read_file)
df = pd.read_csv(file_edgew, names=header_list)
for timeweek, data in df.groupby('week'):
    data.to_csv("{}.csv".format(timeweek))
# print(df)
# next(read_file)
# for line in read_file:
#    with open("output_test2.csv",'w') as writefile:
#        writer = csv.writer(writefile,delimiter=" ")
#        writer.writerow(line)


####












