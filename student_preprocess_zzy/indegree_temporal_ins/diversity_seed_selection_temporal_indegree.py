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

seeds = [50, 75, 100, 125, 150, 175, 200]
#seeds = [500, 1000]

post_type = ["comment", "like"]

start = time.time()
df = pd.read_pickle("indegree_ins_data/df_indegree.pickle")
df = df.reset_index()

print(f"Done reading from pickle, it took {time.time() - start} seconds.")
#print(df)
for ratio in range(101):
    # male_ratio
    mr = ratio/100
    # female_ratio
    fr = 1-mr

    for s in seeds:
        for types in post_type:
            FILE_DIR = 'indegree_sort/users_indegree_{}_{}.csv';
            FILE_WRITE = 'indegree_diversity_seed/diversity-{}-{}-{}-{}.csv'
            for byType in range(999):
                print("the file number is:",byType)
                if (os.path.exists(FILE_DIR.format(types,byType)) == True):
                    user_list = []
                    fs = round(s * fr, 0)
                    ms = round(s * mr, 0)
                    df_indegree = pd.read_csv(FILE_DIR.format(types,byType), index_col=0)
                    if(types == 'comment'):
                        user_count = 0
                        while (fs !=0 or ms != 0):
                            if (user_count < len(df_indegree)):
                                if df_indegree['user_id'].values[user_count] in df.values:
                                    user_id = df_indegree['user_id'].values[user_count]
                                    if(user_id == 2147483647):
                                        pass
                                    else:
                                        userGen = df.loc[df['user_id'] == user_id, 'gender'].item()
                                        if userGen == 1 and ms:
                                            user_list.append(df_indegree['user_id'].values[user_count])
                                            ms-=1
                                        elif userGen == 2 and fs:
                                            user_list.append(df_indegree['user_id'].values[user_count])
                                            fs-=1
                                    user_count = user_count + 1
                            else:
                                break

                        seedfile = 'indegreec'
                        with open(FILE_WRITE.format(seedfile, s, ratio / 100, byType), 'w+b') as write_file:
                            for user in user_list:
                                toWrite = str(user) + '\n'
                                write_file.write(toWrite.encode('utf-8'))

                    if(types == 'like'):
                        user_count = 0
                        while (fs !=0 or ms != 0):
                            if (user_count < len(df_indegree)):
                                if df_indegree['user_id'].values[user_count] in df.values:
                                    user_id = df_indegree['user_id'].values[user_count]
                                    if(user_id == 2147483647):
                                        pass
                                    else:
                                        userGen = df.loc[df['user_id'] == user_id, 'gender'].item()
                                        if userGen == 1 and ms:
                                            user_list.append(df_indegree['user_id'].values[user_count])
                                            ms-=1
                                        elif userGen == 2 and fs:
                                            user_list.append(df_indegree['user_id'].values[user_count])
                                            fs-=1
                                    user_count = user_count + 1
                            else:
                                break

                        seedfile = 'indegreel'
                        with open(FILE_WRITE.format(seedfile, s, ratio / 100, byType), 'w+b') as write_file:
                            for user in user_list:
                                toWrite = str(user) + '\n'
                                write_file.write(toWrite.encode('utf-8'))




