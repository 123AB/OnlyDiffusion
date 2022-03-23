import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict

# 'nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria'
# testcase = 'receivernosend'
# file = '../../../dataset_2015/dataset_{}/task1/1_stat_user2/1_stat_user2_0.csv'
#file_node_test = '../dt_node_ins_filter_test.csv'
#file_node = '../dt_node_ins_filter.csv'
file_node = '../dt_node_ins_filter.csv'

# file_edge = 'DT_edge.csv'
file_edge = 'dt_edge_ins_filter.csv'
# file_edge = "test.csv"
file_edgew = "ins_full_dataset/output_file.csv"
header_list = ["edge_type", " actor_id", "week", "post_id"]
header_list_node = ["index", " user_id", "gender"]
post_type = ["comment", "like"]

# read the pickle back
start = time.time()
df_node = pd.read_pickle("pagerank_ins_data/df_pagerank.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")
#print(df_node)

# type: comment / like
# hindex_list = [{},{},{}]
#output_list = [{}, {}, {}]

com = set()
lik = set()
ta = set()

filename = "../edges_all/students_edges_all_{}.csv"
list = range(1, 999)

male_pagerank = [[], [], [], []];
female_pagerank = [[], [], [], []];
pagerank_centrality = [{}, {}, {}, {}]

#print(df_node[df_node['user_id']==1418179390])
#print(df_node[df_node['user_id']==1418179390]['gender'].item())
#if df_node[df_node['user_id']==1418179390]['gender'].item() ==1:
#    print("hahaha")

for blocknum in list:
    print("this blocknum is:", blocknum)
    if (os.path.exists(filename.format(blocknum)) == True):
        for byType in range(2):

            #header = ['src', '1', 'dst', '2', 'comment', 'like', 'tag', 'interact']
            header = ['src', '1', 'dst', '2', 'comment', 'like', 'tag', 'interact']

            #header = ['rownum', 'edge_type', 'src', 'week', 'dst']
            #df = pd.read_csv(file, names=header)
            #df = pd.read_csv(filename.format(blocknum))
            #print(df)
            df = pd.read_csv(filename.format(blocknum), header=None, delim_whitespace=True,names=header)
            #df = pd.read_csv(filename.format(blocknum), names=header)
            #df = pd.read_csv(filename.format(blocknum))

            #print(df)

            #df.columns=['rownum','edge_type','src','week','dst']
            cols2dele = [0, 3]
            #df['like'] = df['edge_type'] == 'like'
            df.iloc[:, 2 + byType] = pd.to_numeric(df.iloc[:, 2 + byType])
            Graphtype = nx.DiGraph()
            if byType == 0:
                weight = 'comment'
            elif byType == 1:
                weight = 'like'
            elif byType == 2:
                weight = 'tag'
            G = nx.from_pandas_edgelist(df, 'src', 'dst', edge_attr=weight, create_using=Graphtype)
            pagerank_centrality[byType] = nx.pagerank(G, weight=weight)
            #print(pagerank_centrality)

            for n, c in sorted(pagerank_centrality[byType].items()):
                n = str(n).strip()
                if df_node[df_node['user_id']==int(n)]['gender'].item() == '1':
                    male_pagerank[byType].append(c)
                elif df_node[df_node['user_id']==int(n)]['gender'].item() == '2':
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

        OUTPUT_DIR = 'male_list/male_list_{}.csv'.format(blocknum)
        pd.DataFrame(male_list).to_csv(OUTPUT_DIR)
        OUTPUT_DIR2 = 'female_list/female_list_{}.csv'.format(blocknum)
        pd.DataFrame(female_list).to_csv(OUTPUT_DIR2)
        OUTPUT_DIR3 = 'pagerank_centrality/pagerank_centrality_list_{}.csv'.format(blocknum)
        pd.DataFrame(pagerank_centrality).to_csv(OUTPUT_DIR3)
