import sys
import math
from math import log
import numpy as np
from bokeh.io import curdoc, export_svgs
from bokeh.layouts import row, column
from bokeh.models import Legend, ColumnDataSource
import matplotlib.ticker as mpl
import matplotlib.pyplot as plt
from bokeh.plotting import figure, show, output_file
from bokeh.models.markers import Circle
import os
import statistics

from matplotlib import pyplot as plt

FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_ORIGINAL = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"

#FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_ORIGINAL = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"

#FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_ORIGINAL = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"

#FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_ORIGINAL = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"


# like and comment
male_spread_list = [[], []]
female_spread_list = [[], []]
seed_spread_list = []

seed_ratio_list_balance_factor = []

target_ratio_list = []
seed_ratio_list = []

target_ratio_list2 = []
seed_ratio_list2 = []

target_ratio_list3 = []
seed_ratio_list3 = []

male_sum_node = []
female_sum_node = []

male_sum_node2 = []
female_sum_node2 = []

male_sum_node3 = []
female_sum_node3 = []

total_sum_node = []
total_sum_node2 = []
total_sum_node3 = []
ratio_list = {0.000000, 0.100000, 0.200000, 0.300000, 0.400000, 0.500000, 0.600000, 0.700000, 0.800000, 0.900000,1.000000}
#ratio_list = {0.000000}

#seedNum_list = [5, 10, 20, 50, 100, 200, 500, 1000]
#seedNum_list = [20, 50, 100, 200, 500, 1000]
#seedNum_list = [200]
seedNum_list = [100]

for seedNum in seedNum_list:

    #################
    for ratio in ratio_list:
        total_sum = 0
        total_sum2 = 0
        total_sum3 = 0
        if (os.path.exists(FILE_READ_ORIGINAL.format(ratio, seedNum)) == True):
            with open(FILE_READ_ORIGINAL.format(ratio, seedNum), 'r') as read_file,  open(FILE_READ_UNEQUALLY_SEED.format(ratio, seedNum), 'r') as read_file_unequally, open(FILE_READ_EQUALLY_SEED.format(ratio, seedNum), 'r') as read_file_equally:
                for line in read_file:
                    token = line.strip().split('\t')
                    df_sum_m = float(token[0])
                    df_sum_fm = float(token[1])
                    total_sum = total_sum + df_sum_m + df_sum_fm

                for line2 in read_file_unequally:
                    token2 = line2.strip().split('\t')
                    df_sum_m2 = float(token2[0])
                    df_sum_fm2 = float(token2[1])
                    total_sum2 = total_sum2 + df_sum_m2 + df_sum_fm2

                for line3 in read_file_equally:
                    token3 = line3.strip().split('\t')
                    df_sum_m3 = float(token3[0])
                    df_sum_fm3 = float(token3[1])
                    total_sum3 = total_sum3 + df_sum_m3 + df_sum_fm3

            total_sum_node.append(total_sum)
            total_sum_node2.append(total_sum2)
            total_sum_node3.append(total_sum3)

            sum_basedline = statistics.mean(total_sum_node)
            sum_unequally_seeding = statistics.mean(total_sum_node2)
            sum_equally_seeding = statistics.mean(total_sum_node3)

            #print(total_sum_node)
            #print(total_sum_node2)
            #print(total_sum_node3)
            print("The ratio is:", ratio)
            print(sum_basedline)
            print(sum_equally_seeding)
            print(sum_unequally_seeding)
            print('\n')


