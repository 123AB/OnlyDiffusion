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
file_node = '../DT_node.csv'
# file_edge = 'DT_edge.csv'
file_edge = '../dt_edge_new.csv'

# file_edge = 'hindex_temporal/students_edge_all/students_edges_all.csv'

# file_edge = "test.csv"
header_list = ["edge_type", " actor_id", "week", "post_id"]

# edge type
byType = ["\"post_comment\"", "\"post_like\"", "\"post_tag\"", "\"uploaded_photos_comment\"",
          "\"uploaded_photos_likes\"", "\"uploaded_photos_tags\"", "\"tagged_photos_comments\"",
          "\"tagged_photos_likes\"", "\"tagged_photos_tags\""]

post_type = ["post_comment", "post_like", "post_tag"]

# read in profile
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

'''
for key, value in gender_dict.items():
    print(key,'->', value)
print(len(gender_dict))
'''

print("#graph node : ", len(gender_dict))
#print("#graph node : ", gender_dict)

line2write = []
OUTPUT_DIR = 'students_labels.csv'

usr_id = 0
id_dict = {}
id_gender_dict = {}
sorted_usr_list = []
for usr in gender_dict:
    sorted_usr_list.append(usr)
sorted_usr_list = sorted(sorted_usr_list)

for i in range(len(sorted_usr_list)):
    usr = sorted_usr_list[i]

    if usr not in id_dict:
        id_dict[usr] = i
        id_gender_dict[i] = gender_dict[usr]

    out = []
    out.append(i)
    #print(id_gender_dict)
    #print(id_dict)
    #for j in range(len(sorted_usr_list)):
    #    if j != i:
    #        out.append(0)
    #    else:
    #        out.append(1)
    out.append(gender_dict[usr])
    print(out)
    #out_tu = tuple(out)
    line2write.append(out)

with open(OUTPUT_DIR, 'w', newline='\n') as writefile:
    writer = csv.writer(writefile, delimiter=" ")
    for line in line2write:
        writer.writerow(line)