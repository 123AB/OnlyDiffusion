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
file_label = 'pageRank_temporal/students_labels.csv'
#file_label = 'target_hindex_temporal/students_labels.csv'

#post_type = ["post_comment", "post_like" , "post_tag"]
post_type = ['comment', 'like', 'tag', 'interact']

male_pagerank = [[], [], [], []];
female_pagerank = [[], [], [], []];
clustering_cof = [{}, {}, {}, {}]
test_pointer = [{}, {}, {}, {}]

file_node = '../DT_node.csv'

clustering_cofficient_comment = []
clustering_cofficient_like = []

clustering_cofficient_like_cent = []
clustering_cofficient_comment_cent = []

#file_label = 'students_labels.csv'
# build gender dict
with open(file_label, 'r') as read_file:
    for line in read_file:
        token = line.strip().split(' ')
        usr = token[0]
        gender = token[1]
        if usr not in gender_dict: gender_dict[usr] = gender


print('#graph size: ', len(gender_dict))

#filename = "all/students_edges_all_{}.csv"
#filename = "all/twomonth/students_edges_all_{}.csv"
#filename = "all/twoweek/students_edges_all_{}.csv"
filename = "all/oneweek/students_edges_all_{}.csv"
#filename = "all/month/students_edges_all_{}.csv"

#list = range(197,220)
#list = range(432,479) #per two week
#list = range(100,111) #per two month
list = range(862,957) #per week
#OUTPUT_DIR = 'clustering_cofficient_data/clustering_cofficient_{}.csv'
#OUTPUT_DIR_LIK = 'clustering_cofficient_data/clustering_cofficient_{}.csv'
for blocknum in list:
    if (os.path.exists(filename.format(blocknum)) == True):
        for byType in range(2):
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

                G = nx.from_pandas_edgelist(df, 'src', 'dst', edge_attr=weight, create_using=Graphtype)
                test_pointer[byType] = nx.clustering(G, weight=weight)
                if len(test_pointer[byType]) == 0:
                    print("this dictionary is empty")
                else:
                    clustering_cof[byType] = nx.average_clustering(G, weight=weight)
                    clustering_cofficient_comment.append(clustering_cof[byType])


                    OUTPUT_DIR = 'clustering_cofficient_data/clustering_cofficient_{}.csv'.format(weight)

            elif byType == 1:
                weight = 'like'

                G = nx.from_pandas_edgelist(df, 'src', 'dst', edge_attr=weight, create_using=Graphtype)
                test_pointer[byType] = nx.clustering(G, weight=weight)
                if len(test_pointer[byType]) == 0:
                    print("this dictionary is empty")
                else:
                    clustering_cof[byType] = nx.average_clustering(G, weight=weight)
                    clustering_cofficient_like.append(clustering_cof[byType])

                    OUTPUT_DIR_LIK = 'clustering_cofficient_data/clustering_cofficient_{}.csv'.format(weight)



def printer_clustering(OUTPUT_DIR,clustering_cofficient):

    with open(OUTPUT_DIR, 'w', newline='\n') as writefile:
        writer = csv.writer(writefile, delimiter=" ")
        writer.writerow(clustering_cofficient)

clustering_cofficient_like_sum = sum(clustering_cofficient_like)
clustering_cofficient_comment_sum = sum(clustering_cofficient_comment)

for count in clustering_cofficient_like:
    percentage_clustering_cofficient_like = count/clustering_cofficient_like_sum
    clustering_cofficient_like_cent.append(percentage_clustering_cofficient_like)

for count in clustering_cofficient_comment:
    percentage_clustering_cofficient_comment = count/clustering_cofficient_comment_sum
    clustering_cofficient_comment_cent.append(percentage_clustering_cofficient_comment)


printer_clustering(OUTPUT_DIR, clustering_cofficient_comment_cent)
printer_clustering(OUTPUT_DIR_LIK, clustering_cofficient_like_cent)

'''
            for n, c in sorted(clustering_cof[byType].items()):
                n = str(n).strip()
                if gender_dict[str(n)] == '1':
                    male_pagerank[byType].append(c)
                elif gender_dict[str(n)] == '2':
                    female_pagerank[byType].append(c)

            male_pagerank[byType] = sorted(male_pagerank[byType])
            female_pagerank[byType] = sorted(female_pagerank[byType])
'''
            #print(male_pagerank[byType])
