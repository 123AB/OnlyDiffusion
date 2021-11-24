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

#FILE_READ_EQUALLY_SEED = './diffusion_last_year_month_fb_intensity_like_unequally_seeding/diffusion_results_{:f}_{}.txt'
#FILE_READ_ORIGINAL = './diffusion_last_year_month_fb_intensity_like_original_seeding/diffusion_results_{:f}_{}.txt'
#FILE_READ_UNEQUALLY_SEED = './diffusion_last_year_month_fb_intensity_like_equally_seeding/diffusion_results_{:f}_{}.txt'

#FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
#FILE_READ_ORIGINAL = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"


#FILE_READ_EQUALLY_SEED_ABU_ERROR = './diffusion_last_two_year_intensity/diffusion_last_two_years_fb_like_equally_seeding_abu/diffusion_results_{:f}_{}.txt'
#FILE_READ_ORIGINAL_ABU_ERROR = './diffusion_last_two_year_intensity/diffusion_last_two_years_fb_like_original_abu/diffusion_results_{:f}_{}.txt'
#FILE_READ_UNEQUALLY_SEED_ABU_ERROR = './diffusion_last_two_year_intensity/diffusion_last_two_years_fb_like_unequally_seeding_abu/diffusion_results_{:f}_{}.txt'

FILE_READ_UNEQUALLY_SEED = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_EQUALLY_SEED = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_ORIGINAL = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"

FILE_READ_EQUALLY_SEED_ABU_ERROR = './diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_equally_seeding_abu/diffusion_results_{:f}_{}.txt'
FILE_READ_ORIGINAL_ABU_ERROR = './diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_original_abu/diffusion_results_{:f}_{}.txt'
#FILE_READ_UNEQUALLY_SEED_ABU_ERROR = './diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_unequally_seeding_abu/diffusion_results_{:f}_{}.txt'
FILE_READ_UNEQUALLY_SEED_ABU_ERROR = './diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_unequally_seeding_abu/diffusion_results_{:f}_{}.txt'


# like and comment
male_spread_list = [[], []]
female_spread_list = [[], []]
seed_spread_list = []

target_ratio_list = []
seed_ratio_list = []
seed_ratio_list_abu = []
dif_seed_ratio_list = []

target_ratio_list2 = []
seed_ratio_list2 = []
seed_ratio_list2_abu = []
dif_seed_ratio2_list = []

target_ratio_list3 = []
seed_ratio_list3 = []
seed_ratio_list3_abu = []
dif_seed_ratio3_list = []

male_sum_node = []
female_sum_node = []

male_sum_node2 = []
female_sum_node2 = []

male_sum_node3 = []
female_sum_node3 = []

male_sum_node_abu = []
female_sum_node_abu = []

male_sum_node2_abu = []
female_sum_node2_abu = []

male_sum_node3_abu = []
female_sum_node3_abu = []

total_sum_node = []
total_sum_node2 = []
total_sum_node3 = []
#ratio_list = {0.000000,0.100000,0.200000,0.300000,0.400000,0.500000,0.600000,0.700000,0.800000,0.900000,1.000000}
#ratio_list = {0.000000,0.100000,0.200000,0.300000,0.400000,0.500000,0.600000,0.700000,0.800000,0.900000}
#ratio_list = {0.300000,0.400000,0.500000,0.600000,0.700000,0.800000,0.900000}
ratio_list = {0.300000,0.400000,0.500000,0.600000,0.700000}
#ratio_list_unequally = [0.170000, 0.180000, 0.280000, 0.350000, 0.480000, 0.570000, 0.600000]

#ratio_list_unequally = {0.13, 0.57, 0.18, 0.6, 0.35, 0.86, 0.48, 0.28, 0.17, 0.22}
#ratio_list_unequally = [0.170000, 0.180000, 0.220000, 0.230000, 0.280000, 0.350000, 0.480000, 0.570000, 0.600000, 0.760000]
ratio_list_unequally = [0.170000, 0.180000, 0.220000, 0.230000, 0.280000, 0.350000, 0.480000, 0.570000, 0.600000, 0.760000]

#ratio_list = {0.000000, 0.100000, 0.200000, 0.300000, 0.400000, 0.500000, 0.600000, 0.700000, 0.800000, 0.900000}

#seedNum_list = [5, 10, 20, 50, 100, 200, 500, 1000]
#seedNum_list = [50,75,100,125,150,175,200]
seedNum_list = [50,100,200]
count_loop = 0
def plotting(seed_spread_list,seed_spread_list2,seed_spread_list3,target_ratio_list,seedNum):
    ax = plt.gca()
    #ax.plot(target_ratio_list, seed_spread_list,':r', markersize=4. ,color='red')
    #ax.scatter(target_ratio_list,seed_spread_list)
    target_ratio_list.sort()
    ax.plot(target_ratio_list, seed_spread_list,':r', markersize=4. ,color='red')
    ax.plot(target_ratio_list, seed_spread_list2,':r', markersize=4. ,color='blue')
    ax.plot(target_ratio_list, seed_spread_list3,':r', markersize=4. ,color='yellow')
    #print(seed_spread_list2)
    #ax.plot(seedNum_l ist, total_sum_node2,'o', markersize=4., color = 'blue')
    #ax.plot(seedNum_list, total_sum_node3,'o', markersize=4. ,color = 'yellow')


    ax.get_xaxis().set_minor_locator(mpl.AutoMinorLocator())
    ax.get_yaxis().set_minor_locator(mpl.AutoMinorLocator())
    ax.set_xlabel("Target Ratio(Female)")
    ax.set_ylabel("Absolute Error")

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
            with open(FILE_READ_ORIGINAL.format(ratio, seedNum), 'r') as read_file,  open(FILE_READ_UNEQUALLY_SEED.format(ratio, seedNum), 'r') as read_file_unequally, open(FILE_READ_EQUALLY_SEED.format(ratio, seedNum), 'r') as read_file_equally, \
                 open(FILE_READ_ORIGINAL_ABU_ERROR.format(ratio, seedNum), 'r') as read_file_abu,  open(FILE_READ_UNEQUALLY_SEED_ABU_ERROR.format(ratio_list_unequally[count_loop], seedNum), 'r') as read_file_unequally_abu, open(FILE_READ_EQUALLY_SEED_ABU_ERROR.format(ratio, seedNum), 'r') as read_file_equally_abu:
                for line,line_abu in zip(read_file, read_file_abu):
                    token = line.strip().split('\t')
                    token_abu = line_abu.strip().split('\t')
                    df_spread_m = float(token[0])
                    df_spread_fm = float(token[1])

                    df_spread_m_abu = float(token_abu[0])
                    df_spread_fm_abu = float(token_abu[1])

                    male_sum_node.append(df_spread_m)
                    female_sum_node.append(df_spread_fm)

                    male_sum_node_abu.append(df_spread_m_abu)
                    female_sum_node_abu.append(df_spread_fm_abu)

                for line2,line2_abu in zip(read_file_unequally,read_file_unequally_abu):
                    token2 = line2.strip().split('\t')
                    token2_abu = line2_abu.strip().split('\t')
                    df_spread_m2 = float(token2[0])
                    df_spread_fm2 = float(token2[1])

                    df_spread_m2_abu = float(token2_abu[0])
                    df_spread_fm2_abu = float(token2_abu[1])

                    male_sum_node2.append(df_spread_m2)
                    female_sum_node2.append(df_spread_fm2)

                    male_sum_node2_abu.append(df_spread_m2_abu)
                    female_sum_node2_abu.append(df_spread_fm2_abu)
                    #total_sum = total_sum + df_spread_m + df_spread_fm

                for line3,line3_abu in zip(read_file_equally,read_file_equally_abu):
                    token3 = line3.strip().split('\t')
                    token3_abu = line3_abu.strip().split('\t')
                    df_spread_m3 = float(token3[0])
                    df_spread_fm3 = float(token3[1])

                    df_spread_m3_abu = float(token3_abu[0])
                    df_spread_fm3_abu = float(token3_abu[1])


                    male_sum_node3.append(df_spread_m3)
                    female_sum_node3.append(df_spread_fm3)

                    male_sum_node3_abu.append(df_spread_m3_abu)
                    female_sum_node3_abu.append(df_spread_fm3_abu)
                    #total_sum = total_sum + df_spread_m + df_spread_fm

                seed_ratio = sum(female_sum_node) / (sum(male_sum_node) + sum(female_sum_node))
                seed_ratio_abu = sum(female_sum_node_abu) / (sum(male_sum_node_abu) + sum(female_sum_node_abu))
                dif_seed_ratio = abs(seed_ratio_abu - ratio)

                seed_ratio2 = sum(female_sum_node2) / (sum(male_sum_node2) + sum(female_sum_node2))
                seed_ratio2_abu = sum(female_sum_node2_abu) / (sum(male_sum_node2_abu) + sum(female_sum_node2_abu))
                dif_seed_ratio2 = abs(seed_ratio2_abu - ratio)
                print("seed ratio is:",seed_ratio2_abu)
                print("ratio is:",ratio)
                #print(dif_seed_ratio2)
                #dif_seed_ratio2 = abs(seed_ratio2_abu)

                seed_ratio3 = sum(female_sum_node3) / (sum(male_sum_node3) + sum(female_sum_node3))
                seed_ratio3_abu = sum(female_sum_node3_abu) / (sum(male_sum_node3_abu) + sum(female_sum_node3_abu))
                dif_seed_ratio3 = abs(seed_ratio3_abu - ratio)

                #average_seed_value = sum(seed_ratio_list)/len(seed_ratio_list)
                #seed_ratio_list.append(seed_ratio)
                #seed_ratio_list_abu.append(seed_ratio2_abu)
                dif_seed_ratio_list.append(dif_seed_ratio)

                #seed_ratio_list2.append(seed_ratio2)
                #seed_ratio_list2_abu.append(seed_ratio2_abu)
                dif_seed_ratio2_list.append(dif_seed_ratio2)

                #seed_ratio_list3.append(seed_ratio3)
                #seed_ratio_list3_abu.append(seed_ratio3_abu)
                dif_seed_ratio3_list.append(dif_seed_ratio3)

                target_ratio_list.append(ratio)
                #target_ratio_list2.append(ratio)
                #target_ratio_list3.append(ratio)

                #seed_ratio_list = []
        count_loop = count_loop + 1

    feasibility_dif_seed_ratio_list = [i for i in dif_seed_ratio_list if i  < 0.25]
    print(len(feasibility_dif_seed_ratio_list)/len(dif_seed_ratio_list))
    feasibility_dif_seed_ratio2_list = [i for i in dif_seed_ratio2_list if i < 0.25]
    print(feasibility_dif_seed_ratio2_list)
    print(dif_seed_ratio2_list)
    print(len(feasibility_dif_seed_ratio2_list)/len(dif_seed_ratio2_list))
    feasibility_dif_seed_ratio3_list = [i for i in dif_seed_ratio3_list if i < 0.25]
    print(len(feasibility_dif_seed_ratio3_list)/len(dif_seed_ratio3_list))
    plotting(dif_seed_ratio_list,dif_seed_ratio2_list,dif_seed_ratio3_list,target_ratio_list,seedNum)
    count_loop = 0
    seed_ratio_list = []
    seed_ratio_list2 = []
    seed_ratio_list3 = []
    dif_seed_ratio_list = []
    dif_seed_ratio2_list = []
    dif_seed_ratio3_list = []
    seed_ratio_list_abu = []
    seed_ratio_list2_abu = []
    seed_ratio_list3_abu = []
    target_ratio_list = []




# like and comment
# ratio and spread

