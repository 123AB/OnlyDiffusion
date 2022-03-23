import networkx as nx 
import pandas as pd
import csv
import os
import math
import time
# # Network ratio
# # female_ratio
# fr = 59.7/(59.7+40.3)
# # male_ratio
# mr = 1 - fr

gender_dict = {}
testcase = 'remove1interaction'
# 'nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria'
file = '../../../dataset_2015/dataset_{}/1_stat_user1.csv' 
with open(file.format(testcase), 'r') as read_file:
    headers = read_file.readline()
    for line in read_file:
        token = line.strip().split(',')
        src = token[0]
        src_g = int(token[1])
        dst = token[2] 
        dst_g = int(token[3])
        if src not in gender_dict: gender_dict[src] = src_g
        if dst not in gender_dict: gender_dict[dst] = dst_g



# 0: like, 1: comment, 2: interact
result = [[],[]]; pagerank_centrality = [{},{}]; transition_matrix = [{},{}]; 

for ratio in range(11):
    # female_ratio
    mr = ratio / 10
    # male_ratio
    fr = 1 - mr

    for byType in range(2):
        node_attr = {}
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
        pagerank_centrality[byType], node_attr = nx.pagerank(G, weight=weight)
        
        for k,v in node_attr.items():
            male_spread = 0
            female_spread = 0 
            for ki, vi in v.items():

                if gender_dict[str(ki)] == 1: # is male
                    for vis in vi.values():
                        male_spread += vis
                elif gender_dict[str(ki)] == 2: # is female
                    for vis in vi.values():
                        female_spread += vis
            print(male_spread, female_spread)
            if male_spread or female_spread:
                penality = max(
                abs(male_spread/(male_spread+female_spread)-mr),
                abs(female_spread/(male_spread+female_spread)-fr)
                )
                #math.sqrt() 
            else: penality = 0
            TPR = math.exp((-1)*penality) * (male_spread+female_spread)
            pagerank_centrality[byType][k] = TPR
        
        result[byType] = {k: v for k, v in sorted(pagerank_centrality[byType].items(), key=lambda item: item[1], reverse=True)}
        OUTPUT_DIR = '../../dataset/seed_selection/{}/targetpagerank/diffratio-exp/Targetpagerank_sort_{}_{}.csv'.format(testcase, byType, ratio)
        with open(OUTPUT_DIR, 'w') as writefile:
            writer = csv.writer(writefile)
            for k, v in result[byType].items():
                writer.writerow([k, v])