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

from matplotlib import pyplot as plt

#FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_ORIGINAL = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"

#FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_ORIGINAL = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"

#FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_ORIGINAL = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"

FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_ORIGINAL = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"


# like and comment
male_spread_list = [[], []]
female_spread_list = [[], []]
seed_spread_list = []

seed_ratio_list_balance_factor = []
seed_ratio_list_balance_factor_original = []
seed_ratio_list_balance_factor_equally = []

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
#ratio_list = {0.000000, 0.100000, 0.200000, 0.300000, 0.400000, 0.500000, 0.600000, 0.700000, 0.800000, 0.900000}
#ratio_list = {0.000000,0.100000, 0.200000, 0.300000, 0.400000, 0.500000, 0.600000, 0.700000, 0.800000, 0.900000,1.000000}
ratio_list = {0.170000,0.180000, 0.220000, 0.230000, 0.280000, 0.350000, 0.400000, 0.480000, 0.570000, 0.600000,0.760000}

#seedNum_list = [5, 10, 20, 50, 100, 200, 500, 1000]
#seedNum_list = [20, 50, 100, 200, 500, 1000]
seedNum_list = [50,75,100, 125, 150, 175, 200]

def plotting(seed_spread_list,seed_spread_list2,seed_spread_list3,target_ratio_list,seedNum):
    ax = plt.gca()
    #ax.plot(target_ratio_list, seed_spread_list,':r', markersize=4. ,color='red')
    #ax.scatter(target_ratio_list,seed_spread_list)
    target_ratio_list.sort()
    ax.plot(target_ratio_list, seed_spread_list,':r', markersize=4. ,color='red')
    ax.plot(target_ratio_list, seed_spread_list2,':r', markersize=4. ,color='blue')
    ax.plot(target_ratio_list, seed_spread_list3,':r', markersize=4. ,color='yellow')

    #ax.plot(seedNum_l ist, total_sum_node2,'o', markersize=4., color = 'blue')
    #ax.plot(seedNum_list, total_sum_node3,'o', markersize=4. ,color = 'yellow')


    ax.get_xaxis().set_minor_locator(mpl.AutoMinorLocator())
    ax.get_yaxis().set_minor_locator(mpl.AutoMinorLocator())
    ax.set_xlabel("Target Ratio")
    ax.set_ylabel("Seeding Ratio")

    ax.grid(b=True, which='major', color='w', linewidth=1.5)
    ax.grid(b=True, which='minor', color='w', linewidth=0.75)
    plt.setp(ax.get_xticklabels(), rotation=30, horizontalalignment='right')
    plt.legend(['original seeding','unequally seeding','equally seeding'],loc = 'upper left')
    plt.savefig('target_ratio_like_{}.png'.format(seedNum))
    plt.show()  # 显示图形


for seedNum in seedNum_list:

    #################
    for ratio in ratio_list:

        if (os.path.exists(FILE_READ_ORIGINAL.format(ratio, seedNum)) == True):
            with open(FILE_READ_ORIGINAL.format(ratio, seedNum), 'r') as read_file,  open(FILE_READ_UNEQUALLY_SEED.format(ratio, seedNum), 'r') as read_file_unequally, open(FILE_READ_EQUALLY_SEED.format(ratio, seedNum), 'r') as read_file_equally:
                for line in read_file:
                    token = line.strip().split('\t')
                    df_spread_m = float(token[0])
                    df_spread_fm = float(token[1])
                    #seed_ratio = df_spread_fm / (df_spread_m + df_spread_fm)
                    #seed_ratio_list.append(seed_ratio)
                    #print("I come here")
                    #print(seed_ratio_list)
                    #seed_spread_l ist[1].append(ratio)

                    # df = pd.read_csv(filename.format(ratio,seedNum),  header = None)
                    # df.columns = ['spreadM','spreadFM']
                    # df_sum_m = df['spreadM'].sum()
                    # df_sum_fm = df['spreadFM'].sum()
                    male_sum_node.append(df_spread_m)
                    female_sum_node.append(df_spread_fm)
                    #total_sum = total_sum + df_spread_m + df_spread_fm

                for line2 in read_file_unequally:
                    token2 = line2.strip().split('\t')
                    df_spread_m2 = float(token2[0])
                    df_spread_fm2 = float(token2[1])

                    #seed_ratio = df_spread_fm / (df_spread_m + df_spread_fm)
                    #seed_ratio_list.append(seed_ratio)
                    #print("I come here")
                    #print(seed_ratio_list)
                    #seed_spread_l ist[1].append(ratio)

                    # df = pd.read_csv(filename.format(ratio,seedNum),  header = None)
                    # df.columns = ['spreadM','spreadFM']
                    # df_sum_m = df['spreadM'].sum()
                    # df_sum_fm = df['spreadFM'].sum()
                    male_sum_node2.append(df_spread_m2)
                    female_sum_node2.append(df_spread_fm2)
                    #total_sum = total_sum + df_spread_m + df_spread_fm

                for line3 in read_file_equally:
                    token3 = line3.strip().split('\t')
                    df_spread_m3 = float(token3[0])
                    df_spread_fm3 = float(token3[1])

                    #seed_ratio = df_spread_fm / (df_spread_m + df_spread_fm)
                    #seed_ratio_list.append(seed_ratio)
                    #print("I come here")
                    #print(seed_ratio_list)
                    #seed_spread_l ist[1].append(ratio)

                    # df = pd.read_csv(filename.format(ratio,seedNum),  header = None)
                    # df.columns = ['spreadM','spreadFM']
                    # df_sum_m = df['spreadM'].sum()
                    # df_sum_fm = df['spreadFM'].sum()
                    male_sum_node3.append(df_spread_m3)
                    female_sum_node3.append(df_spread_fm3)
                    #total_sum = total_sum + df_spread_m + df_spread_fm
                #print("male node is:",male_sum_node)
                #print("female node is:",female_sum_node)
                seed_ratio = sum(female_sum_node) / (sum(male_sum_node) + sum(female_sum_node))

                seed_ratio2 = sum(female_sum_node2) / (sum(male_sum_node2) + sum(female_sum_node2))
                seed_ratio3 = sum(female_sum_node3) / (sum(male_sum_node3) + sum(female_sum_node3))

                #print(sum(female_sum_node2))
                #print(male_sum_node2)
                #seed_ratio = sum(male_sum_node) / (sum(male_sum_node) + sum(female_sum_node))
                #seed_ratio2 = sum(male_sum_node2) / (sum(male_sum_node2) + sum(female_sum_node2))
                #seed_ratio3 = sum(male_sum_node3) / (sum(male_sum_node3) + sum(female_sum_node3))

                #average_seed_value = sum(seed_ratio_list)/len(seed_ratio_list)
                seed_ratio_list.append(seed_ratio)
                seed_ratio_list_balance_factor_original.append(1-seed_ratio)
                seed_ratio_list2.append(seed_ratio2)
                seed_ratio_list_balance_factor.append(1-seed_ratio2)
                seed_ratio_list3.append(seed_ratio3)
                seed_ratio_list_balance_factor_equally.append(1-seed_ratio3)

                female_sum_node = []
                male_sum_node = []
                female_sum_node2 = []
                male_sum_node2 = []
                male_sum_node3 = []
                female_sum_node3 = []

                target_ratio_list.append(ratio)
                #target_ratio_list2.append(ratio)
                #target_ratio_list3.append(ratio)

                #seed_ratio_list = []
    print(seedNum)
    #print(seed_ratio_list)
    #print(seed_ratio_list2)
    #print(seed_ratio_list3)
    print("the original seeding:",seed_ratio_list_balance_factor_original)
    print("the equally seeding:",seed_ratio_list_balance_factor_equally)
    print("the unequally seeding:",seed_ratio_list_balance_factor)
    plotting(seed_ratio_list,seed_ratio_list2,seed_ratio_list3,target_ratio_list,seedNum)
    seed_ratio_list = []
    seed_ratio_list2 = []
    seed_ratio_list3 = []
    target_ratio_list = []
    seed_ratio_list_balance_factor = []
    seed_ratio_list_balance_factor_original = []
    seed_ratio_list_balance_factor_equally = []



# like and comment
# ratio and spread

