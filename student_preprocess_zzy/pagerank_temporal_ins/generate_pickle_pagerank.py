import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict

start = time.time()
df = pd.read_csv('../dt_node_ins_filter.csv',sep=';',names=['index','user_id','gender'])
df.to_pickle("pagerank_ins_data/df_pagerank.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")
