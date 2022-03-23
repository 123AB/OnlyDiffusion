import networkx as nx 
import pandas as pd
import csv
import os
import math
import time

gender_dict = {}
# 'nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria'
testcase = 'bothcriteria'
# file = '../../../dataset_2015/dataset_{}/task1/1_stat_user2/1_stat_user2_0.csv'
file = '../../../dataset_2015/dataset_{}/1_stat_user1.csv' 
# 0: like, 1: comment, 2: interact
result = [[],[],[]]; cc_centrality = [{},{},{}]

for byType in range(2):
    with open(file.format(testcase), 'r') as read_file:
        headers = read_file.readline()
        for line in read_file:
            token = line.strip().split(',')
            src = token[0]
            src_g = token[1] 
            dst = token[2] 
            dst_g = token[3] 
            if src not in gender_dict: gender_dict[src] = src_g
            if dst not in gender_dict: gender_dict[dst] = dst_g

    header = ['src','1','dst','2','like','comment','interact','5','6','7','8']
    df = pd.read_csv(file.format(testcase), names=header, skiprows=1)
    cols2dele = [1,3,7,8,9,10]
    df.drop(df.columns[cols2dele],axis=1,inplace=True)
    df.iloc[:,2+byType] = pd.to_numeric(df.iloc[:,2+byType])
    Graphtype = nx.DiGraph()
    if byType == 0: weight = 'like'
    elif byType == 1: weight = 'comment'
    else: weight = 'interact'
    G = nx.from_pandas_edgelist(df,'src', 'dst', edge_attr=weight, create_using=Graphtype)
    cc_centrality[byType] = nx.clustering(G, weight=weight)
    result[byType] = {k: v for k, v in sorted(cc_centrality[byType].items(), key=lambda item: item[1], reverse=True)}
    OUTPUT_DIR = '../../dataset/seed_selection/{}/cluster_coeff/cluster_coeff_sort_{}.csv'.format(testcase, byType)
    with open(OUTPUT_DIR, 'w') as writefile:
        writer = csv.writer(writefile)
        for k, v in result[byType].items():
            writer.writerow([k, v])
