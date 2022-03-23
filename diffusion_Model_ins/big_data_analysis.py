import os
import matplotlib.ticker as mpl
import matplotlib.pyplot as plt

import pandas as pd
import csv

#filename2 = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
#filename = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
#filename_original = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"

#filename2 = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
#filename = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
#filename_original = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"

filename2 = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
filename = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
filename_original = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"

male_sum_node = []
female_sum_node = []
total_sum_node = []
total_sum_node2 = []
total_sum_node3 = []
#ratio_list = {0.000000, 0.100000, 0.200000, 0.300000, 0.400000, 0.500000, 0.600000, 0.700000, 0.800000, 0.900000, 1.000000}
#seedNum_list = {100,125}
seedNum_list = {5000}
#seedNum_list = {50,75,100,125,150,175,200}

ratio_list = {0.500000}
#seedNum_list = {50,75,100}
#seedNum_list = [75]

#month_list = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
month_list = [1,2,3,4,5,6,7,8,9,10,11,12]

#seedNum_list = [5, 10, 20, 50, 100, 200, 500, 1000]

for ratio in ratio_list:
    #################
    for seedNum in seedNum_list:
        total_sum = 0
        total_sum2 = 0
        total_sum3 = 0
        if (os.path.exists(filename.format(ratio, seedNum)) == True):
            with open(filename.format(ratio, seedNum), 'r') as read_file, open(filename2.format(ratio, seedNum), 'r') as read_file_unequally, open(filename_original.format(ratio, seedNum), 'r') as read_file_original:
                for line in read_file:
                    token = line.strip().split('\t')
                    df_sum_m = float(token[0])
                    df_sum_fm = float(token[1])
                    total_sum = total_sum + df_sum_m + df_sum_fm
                    total_sum_node.append(total_sum)
                for line2 in read_file_unequally:
                    token2 = line2.strip().split('\t')
                    df_sum_m2 = float(token2[0])
                    df_sum_fm2 = float(token2[1])
                    total_sum2 = total_sum2 + df_sum_m2 + df_sum_fm2
                    total_sum_node2.append(total_sum2)
                for line3 in read_file_original:
                    token3 = line3.strip().split('\t')
                    df_sum_m3 = float(token3[0])
                    df_sum_fm3 = float(token3[1])
                    total_sum3 = total_sum3 + df_sum_m3 + df_sum_fm3
                    total_sum_node3.append(total_sum3)

        ax = plt.gca()

        #ax.plot(month_list, total_sum_node,color='red')
        #ax.plot(month_list, total_sum_node2,color = 'blue')
        #ax.plot(month_list, total_sum_node3,color = 'yellow')
        #print(total_sum_node)
        #print(total_sum_node2)
        #print(total_sum_node3)
        #ax.plot(month_list,total_sum_node,total_sum_node2,total_sum_node3,colors =['blue', 'orange', 'brown'])
        ax.plot(month_list, total_sum_node,':r', markersize=4. ,color='red')
        ax.plot(month_list, total_sum_node2,':r', markersize=4. ,color='blue')
        ax.plot(month_list, total_sum_node3,':r', markersize=4. ,color='yellow')

        ax.get_xaxis().set_minor_locator(mpl.AutoMinorLocator())
        ax.get_yaxis().set_minor_locator(mpl.AutoMinorLocator())
        ax.set_xlabel("Month")
        ax.set_ylabel("Total outreach")

        #ax.grid(b=True, which='major', color='w', linewidth=1.5)
        #ax.grid(b=True, which='minor', color='w', linewidth=0.75)
        plt.setp(ax.get_xticklabels(), rotation=30, horizontalalignment='right')
        plt.legend(['equally seeding','unequally seeding','original seeding'],loc = 'upper left')
        plt.savefig('temporal_sum_spread_node_ratio_{}_{}.png'.format(ratio,seedNum))
        plt.clf()
        #plt.show()  # 显示图形
        total_sum_node = []
        total_sum_node2 = []
        total_sum_node3 = []
