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

start = time.time()
df = pd.read_pickle("hindex_ins_data/df_hindex.pickle")
df = df.reset_index()
print(df)
print(f"Done reading from pickle, it took {time.time() - start} seconds.")

#for ratio in range(101):
for ratio in ratio_list:
    print("the ratio is:",ratio)
    # male_ratio
    mr = ratio / 100
    # female_ratio
    fr = 1 - mr
    for s in seeds:
        #FILE_DIR = 'outputNodenumber_10/hi_index_{}_{}_{}.csv'
        FILE_DIR = 'outputNodenumber/hi_index_{}_{}_{}.csv'
        #FILE_WRITE = 'diversity_month_hi_index_ins/diversity-{}-{}-{}-{}.csv'
        FILE_WRITE = 'test/diversity-{}-{}-{}-{}.csv'

        for type in types:
            for byType in range(999):
                if (os.path.exists(FILE_DIR.format(type,byType,mr)) == True):
                    user_list = []
                    fs = round(s * fr, 0)
                    ms = round(s * mr, 0)
                    with open(FILE_DIR.format(type,byType,mr), 'r') as read_file:
                        for line in read_file:
                            token = line.strip().split(' ')
                            userId = token[0]
                            if int(userId) in df.values:
                                if (userId == 2147483647):
                                    pass
                                else:
                                    if df[df['user_id'] == int(userId)].empty:
                                        print("this user is:", userId)
                                    else:
                                        userGen = int(df[df['user_id']==int(userId)]['gender'].item())
                                        if fs or ms:
                                            if userGen == 1 and ms:
                                                user_list.append(userId)
                                                ms -= 1
                                            elif userGen == 2 and fs:
                                                user_list.append(userId)
                                                fs -= 1
                                            else:
                                                pass
                                        else:
                                            break
                            else:
                                #print("missing userId:", userId)
                                pass

                    if type == 'like':
                        seedfile = 'hindexl'
                    elif type == 'comment':
                        seedfile = 'hindexc'
                    with open(FILE_WRITE.format(seedfile, s, ratio/100,byType), 'w+b') as write_file:
                        for user in user_list:
                            toWrite = user + '\n'
                            write_file.write(toWrite.encode('utf-8'))
