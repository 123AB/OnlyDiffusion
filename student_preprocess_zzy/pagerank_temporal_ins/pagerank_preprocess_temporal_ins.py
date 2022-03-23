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
file_edgew = "pagerank_ins_data/df_pagerank.pickle"
header_list = ["edge_type", " actor_id", "week", "post_id"]
header_list_node = ["index", " user_id", "gender"]


# edge type
byType = ["\"post_comment\"", "\"post_like\"", "\"post_tag\"", "\"uploaded_photos_comment\"",
          "\"uploaded_photos_likes\"", "\"uploaded_photos_tags\"", "\"tagged_photos_comments\"",
          "\"tagged_photos_likes\"", "\"tagged_photos_tags\""]

post_type = ["comment", "like", "tag"]


start = time.time()
df = pd.read_pickle("pagerank_ins_data/df_pagerank.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")

filename = "output_list/output_list_{}.csv"
list = range(1, 999)
filename_pagerank = "pagerank_centrality/pagerank_centrality_list_{}.csv"

for blocknum in list:
    print("this blocknum is:",blocknum)
    if (os.path.exists(filename_pagerank.format(blocknum)) == True):
        df_pagerank = pd.read_csv(filename_pagerank.format(blocknum),index_col=0)
        df_pagerank_T = df_pagerank.transpose()

        df_pagerank_T_modified = df_pagerank_T.reset_index()
        df_pagerank_T_modified.columns = ['user_id','comment','like','unknown','unknown2']

        df_pagerank_T_modified = df_pagerank_T_modified.drop(['unknown'],1)
        df_pagerank_T_modified = df_pagerank_T_modified.drop(['unknown2'],1)
        df_pagerank_T_modified_comment = df_pagerank_T_modified[(df_pagerank_T_modified['comment'].notnull())]
        df_pagerank_T_modified_like = df_pagerank_T_modified[(df_pagerank_T_modified['like'].notnull())]

        df_pagerank_T_modified_comment_sorted = df_pagerank_T_modified_comment.sort_values(by = ['comment'], ascending=False)
        df_pagerank_T_modified_like_sorted = df_pagerank_T_modified_like.sort_values(by = ['like'], ascending=False)


        print("this is comment")
        print(df_pagerank_T_modified_comment_sorted)
        print("\n")

        print("this is like:")
        print(df_pagerank_T_modified_like_sorted)
        print("\n")

        OUTPUT_DIR = 'pagerank_sort/users_pagerank_{}_{}.csv'.format('comment', blocknum)
        pd.DataFrame(df_pagerank_T_modified_comment_sorted).to_csv(OUTPUT_DIR)
        OUTPUT_DIR2 = 'pagerank_sort/users_pagerank_{}_{}.csv'.format('like',blocknum)
        pd.DataFrame(df_pagerank_T_modified_like_sorted).to_csv(OUTPUT_DIR2)
