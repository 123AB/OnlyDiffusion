import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict


file_clustering_cofficient_like = 'clustering_cofficient_data/clustering_cofficient_comment.csv'
file_clustering_cofficient_comment = 'clustering_cofficient_data/clustering_cofficient_like.csv'
filename = "clustering_cofficient_data/clustering_cofficient_{}.csv"
filename_graph_size = "graph_size_data/graph_size_data.csv"
# edge type
#post_type = ["like""comment"]
post_type = ["comment"]

token_data_clustering_list = []
token_data_graph_size_list = []


normalize_data_list = []

def normalize_data(total_list):
    for counter in total_list:
        normalize_result = counter / 2
        normalize_data_list.append(normalize_result)
    return normalize_data_list

for file_type in post_type:
    #################
    #print("I come here")
    #print(filename.format(file_type))
    if (os.path.exists(filename.format(file_type)) == True):
        with open(filename.format(file_type), 'r') as read_file_clustering, open(filename_graph_size, 'r') as read_file_graph_size:
            for line in read_file_clustering:
                token = line.strip().split('\t')
                token_data_clustering = float(token[0])
                token_data_clustering_list.append(token_data_clustering)
            for line2 in read_file_graph_size:
                token2 = line2.strip().split('\t')
                token_data_graph_size = float(token2[0])
                token_data_graph_size_list.append(token_data_graph_size)


total_list = []

for count, count2 in zip(token_data_clustering_list,token_data_graph_size_list):
    total_list.append(count+count2)

normalize_data_list = normalize_data(total_list)
print(sum(normalize_data_list))
print(len(normalize_data_list))
print(normalize_data_list)
