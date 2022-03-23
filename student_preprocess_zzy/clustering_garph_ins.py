import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict

# edge type
byType = ["\"post_comment\"", "\"post_like\"", "\"post_tag\""]

header_list = ["edge_type", " actor_id", "week", "post_id"]
header_list_node = ["index", " user_id", "gender"]
post_type = ["comment", "like"]


#post_type = ["post_comment", "post_like" , "post_tag"]
#post_type = ['comment', 'like', 'tag', 'interact']

male_pagerank = [[], [], [], []];
female_pagerank = [[], [], [], []];
clustering_cof = [{}, {}, {}, {}]
test_pointer = [{}, {}, {}, {}]

file_node = '../DT_node.csv'

clustering_cofficient_comment = []
clustering_cofficient_like = []

clustering_cofficient_like_cent = []
clustering_cofficient_comment_cent = []

#OUTPUT_DIR = 'clustering_cofficient_data_ins/clustering_cofficient_{}.csv'
#OUTPUT_DIR_LIK = 'clustering_cofficient_data_ins/clustering_cofficient_{}.csv'

start = time.time()
df_data = pd.read_pickle("target_hindex_temporal_ins/hindex_ins_data/df_hindex.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")

filename = "edges_all/students_edges_all_{}.csv"
list = range(535,547)

for blocknum in list:
    print("the blocknum is:",blocknum)
    if (os.path.exists(filename.format(blocknum)) == True):
        for byType in range(2):

            header = ['src', '1', 'dst', '2', 'comment', 'like', 'tag', 'interact']
            #header = ['rownum', 'edge_type', 'src', 'week', 'dst']
            #df = pd.read_csv(file, names=header)
            #df = pd.read_csv(filename.format(blocknum), names=header)
            df = pd.read_csv(filename.format(blocknum), header=None, delim_whitespace=True,names=header)

            #df = pd.read_csv(filename.format(blocknum), skiprows=1, header=None)
            #df.columns=['rownum','edge_type','src','week','dst']
            #print(df)
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

                    OUTPUT_DIR = 'clustering_cofficient_data_ins/clustering_cofficient_{}.csv'.format(weight)

            elif byType == 1:
                weight = 'like'
                G = nx.from_pandas_edgelist(df, 'src', 'dst', edge_attr=weight, create_using=Graphtype)
                test_pointer[byType] = nx.clustering(G, weight=weight)
                if len(test_pointer[byType]) == 0:
                    print("this dictionary is empty")
                else:
                    clustering_cof[byType] = nx.average_clustering(G, weight=weight)
                    clustering_cofficient_like.append(clustering_cof[byType])

                    OUTPUT_DIR_LIK = 'clustering_cofficient_data_ins/clustering_cofficient_{}.csv'.format(weight)



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


