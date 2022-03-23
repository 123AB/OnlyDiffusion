import os
import matplotlib.pyplot as plt
import matplotlib.ticker as mpl


import pandas as pd
import csv

filename = "diffusion_results_{:f}_{}.txt"
male_sum_node = []
female_sum_node = []
total_sum_node = []
ratio_list = {0.000000,0.100000,0.200000,0.300000,0.400000,0.500000,0.600000,0.700000,0.800000,0.900000}
seedNum_list = [5,10,20,50,100,200,500,1000]

for ratio in ratio_list:
    #################
    for seedNum in seedNum_list:
        total_sum = 0
        if (os.path.exists(filename.format(ratio,seedNum)) == True):
            with open(filename.format(ratio,seedNum), 'r') as read_file:
                for line in read_file:
                    token = line.strip().split('\t')
                    df_sum_m = float(token[0])
                    df_sum_fm = float(token[1])
                    #df = pd.read_csv(filename.format(ratio,seedNum),  header = None)
                    #df.columns = ['spreadM','spreadFM']
                    #df_sum_m = df['spreadM'].sum()
                    #df_sum_fm = df['spreadFM'].sum()
                    #male_sum_node.append(df_sum_m)
                    #female_sum_node.append(df_sum_fm)
                    total_sum = total_sum + df_sum_m + df_sum_fm

            total_sum_node.append(total_sum)
    print(total_sum_node)


    ax = plt.gca()
    ax.plot(seedNum_list, total_sum_node)

    ax.get_xaxis().set_minor_locator(mpl.AutoMinorLocator())
    ax.get_yaxis().set_minor_locator(mpl.AutoMinorLocator())
    ax.set_xlabel("Seedset Size")
    ax.set_ylabel("Total outreach")

    ax.grid(b=True, which='major', color='w', linewidth=1.5)
    ax.grid(b=True, which='minor', color='w', linewidth=0.75)
    plt.setp(ax.get_xticklabels(), rotation=30, horizontalalignment='right')
    plt.show() # 显示图形
    total_sum_node = []
'''
    plt.plot(seedNum_list, total_sum_node, '.-', label='equallySeedingStrategy')

    plt.xticks(seedNum_list)  # 设置横坐标刻度为给定的年份
    plt.xticks(rotation=15)
    plt.xlabel('seedsize') # 设置横坐标轴标题
    plt.tight_layout()
    plt.legend() # 显示图例，即每条线对应 label 中的内容
    plt.show() # 显示图形
    total_sum_node = []
    plt.savefig('sum_spread_node_ratio_{}.png'.format(ratio))
'''

'''
for ratio in ratio_list:
    #################
    for seedNum in seedNum_list:
        if (os.path.exists(filename.format(ratio,seedNum)) == True):
            df = pd.read_csv(filename.format(ratio,seedNum),  header = None)
            df.columns = ['spreadM','spreadFM']
            df_sum_m = df['spreadM'].sum()
            df_sum_fm = df['spreadFM'].sum()
            #male_sum_node.append(df_sum_m)
            #female_sum_node.append(df_sum_fm)
            total_sum = df_sum_m + df_sum_fm
            total_sum_node.append(total_sum)

    plt.plot(seedNum_list, total_sum_node, '.-', label='equallySeedingStrategy')

    plt.xticks(seedNum_list)  # 设置横坐标刻度为给定的年份
    plt.xlabel('seedsize') # 设置横坐标轴标题
    plt.legend() # 显示图例，即每条线对应 label 中的内容
    plt.show() # 显示图形
'''

'''         
            OUTPUT_DIR = 'diffusion/{}_{}.csv'.format(types[0], weeknum)
            with open(OUTPUT_DIR, 'w', newline='\n') as writefile:
                writer = csv.writer(writefile, delimiter=" ")
                for line in line2write:
                    writer.writerow(line)
'''
'''
     comment out the following code

       with open(filename.format(weeknum), 'r') as read_file:
           next(read_file)
           for line in read_file:
               token = line.strip().split(",")
               male_node[weeknum] = token[1]
               female_node[weeknum] = token[2]
        
                # print(usr1)
                # remove self-loop
        '''