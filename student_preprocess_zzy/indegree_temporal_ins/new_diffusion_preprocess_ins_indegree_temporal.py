import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict

gender_dict = {}

file_edge = '../dt_edge_ins_filter.csv'
# file_edge = "test.csv"
file_edgew = "indegree_ins_data/df_indegree.pickle"
header_list = ["edge_type", " actor_id", "week", "post_id"]
header_list_node = ["index", " user_id", "gender"]


# edge type
byType = ["\"post_comment\"", "\"post_like\"", "\"post_tag\"", "\"uploaded_photos_comment\"",
          "\"uploaded_photos_likes\"", "\"uploaded_photos_tags\"", "\"tagged_photos_comments\"",
          "\"tagged_photos_likes\"", "\"tagged_photos_tags\""]

post_type = ["comment", "like", "tag"]


start = time.time()
df = pd.read_pickle("indegree_ins_data/df_indegree.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")

filename = "output_list/output_list_{}.csv"
list = range(1, 999)
filename_indegree = "indegree_list/indegree_list_{}.csv"

for blocknum in list:
    print("this blocknum is:",blocknum)
    if (os.path.exists(filename_indegree.format(blocknum)) == True):
        df_indegree = pd.read_csv(filename_indegree.format(blocknum),index_col=0)
        df_indegree_T = df_indegree.transpose()

        df_indegree_T_modified = df_indegree_T.reset_index()
        df_indegree_T_modified.columns = ['user_id','comment','like','unknown']
        df_indegree_T_modified = df_indegree_T_modified.drop(['unknown'],1)
        df_indegree_T_modified_comment = df_indegree_T_modified[(df_indegree_T_modified['comment'].notnull())]
        df_indegree_T_modified_like = df_indegree_T_modified[(df_indegree_T_modified['like'].notnull())]

        df_indegree_T_modified_comment_sorted = df_indegree_T_modified_comment.sort_values(by = ['comment'], ascending=False)
        df_indegree_T_modified_like_sorted = df_indegree_T_modified_like.sort_values(by = ['like'], ascending=False)


        print("this is comment")
        print(df_indegree_T_modified_comment_sorted)
        print("\n")

        print("this is like:")
        print(df_indegree_T_modified_like_sorted)
        print("\n")

        OUTPUT_DIR = 'indegree_sort/users_indegree_{}_{}.csv'.format('comment', blocknum)
        pd.DataFrame(df_indegree_T_modified_comment_sorted).to_csv(OUTPUT_DIR)
        OUTPUT_DIR2 = 'indegree_sort/users_indegree_{}_{}.csv'.format('like',blocknum)
        pd.DataFrame(df_indegree_T_modified_like_sorted).to_csv(OUTPUT_DIR2)
