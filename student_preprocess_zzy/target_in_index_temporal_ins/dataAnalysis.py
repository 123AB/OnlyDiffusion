# # female_ratio
# fr = 59.7/(59.7+40.3)
# # male_ratio
# mr = 1 - fr
import os
import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict

from pandas import value_counts

#seeds = [50, 75, 100, 125, 150, 175, 200]
seeds = [5000]
ratio_list = {50}
types = ["comment", "like"]

ratio_list = {0.5}
#FILE_DIR = 'outputNodenumber/hi_index_{}_{}_{}.csv'
FILE_DIR = '../diffusion/ins_month/{}_{}.csv' #like_487.csv

#ratio_list = {0.500000}
#ratio_list = {0.100000}

#seedNum_list = [5, 10, 20, 50, 100, 200, 500, 1000]
#seedNum_list = [20, 50, 100, 200, 500, 1000]
#seedNum_list = [200]
time_period_list = [535,536,537,538,539,540,541,542,543,544,545]
#seedNum_list = [50,75,100, 125,150,175,200]
merge_df = dict()
count = 1
for time_period in time_period_list:

    #################
    for ratio in ratio_list:
        total_sum = 0
        total_sum2 = 0
        total_sum3 = 0
        #print(FILE_DIR.format(types[1],time_period, ratio))
        if (os.path.exists(FILE_DIR.format(types[0],time_period)) == True):
            df = pd.read_csv(FILE_DIR.format(types[0],time_period),sep=' ',names=['gender_source','gender_target','source_id','target_id','poss_degree'])
            print("the count number is:", count)
            if(count == 1):
                merge_df = df
            else:
                merge_df = {**merge_df, **df}

            count = count + 1
            print(merge_df)
            uniques_value = merge_df['source_id']
            #print(uniques_value)
            print("Unique count of keys : " , len(uniques_value))
            print('\n')


