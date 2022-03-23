import math
import os
import numpy as np
from matplotlib import pyplot as plt
from matplotlib.figure import Figure as figure
import pandas as pd
import matplotlib
import seaborn as sns

#FILE_READ = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_like_unequally_seeding/pervious_test_data_3/diffusion_results_{:f}_{}.txt"
#FILE_READ = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_unequally_seeding/pervious_data4/diffusion_results_{:f}_{}.txt"

#FILE_READ = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_comment_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
#FILE_READ = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"

#FILE_READ = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_like_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
#FILE_READ = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"

#FILE_READ = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
FILE_READ = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_like_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"

#ratio = {0.05671172670751998, 0.08797285272479766, 0.07034811460994941, 0.08022840919860938,
#0.08329043932290775, 0.0884038377870173, 0.10746663873818907, 0.08548126161185657, 0.0858406110369326,
#                  0.08166535902475652, 0.0912369954974133, 0.08135375374005048};

ratio = {0.03815288827308658, 0.038658781088945375, 0.039006631384175226, 0.038849252741330484,
                  0.03903426440717119, 0.03926945315487026, 0.03982432360451349, 0.04030870973782025,
                  0.04064017270648738, 0.0409995238488661, 0.04136673272738872, 0.0416933047670591, 0.04216214874270481,
                  0.04253551852701059, 0.04273680769153719, 0.04303485655464194, 0.04344230252494714,
                  0.04369446176632122, 0.04389095175182407, 0.04410581366116462, 0.04410158067375313,
                  0.044146326552655005, 0.04417478789384402, 0.04417040521788208};

seedNum_list = [100]
ratio_list = [0.5]
sum_node = []
seed = 100
list_a = []
count = 0

for x in ratio:
    if(count < 12):
        #list_a.append(math.ceil(seed * x))
        list_a.append(math.ceil(seed * x) - 1)
    #elif(count == 6):
    #    list_a.append(math.ceil(seed * x) - 2)
    #elif(count == 10):
    #    list_a.append(math.ceil(seed * x) + 2)
    else:
        list_a.append(math.ceil(seed * x))
    count = count + 1


#for x in ratio:
#    list_a.append(math.ceil(seed * x))

print(list_a)
print(sum(list_a))


for seedNum in seedNum_list:

    #################
    for ratio in ratio_list:
        if (os.path.exists(FILE_READ.format(ratio, seedNum)) == True):
            with open(FILE_READ.format(ratio, seedNum), 'r') as read_file:
                for line in read_file:
                    token = line.strip().split('\t')
                    df_spread_m = float(token[0])
                    df_spread_fm = float(token[1])
                    total_node = df_spread_m + df_spread_fm

                    sum_node.append(total_node)


print(sum(sum_node))


####################################

#plt.style.use('fivethirtyeight')

#bottom_x = [1,2,3,4,5,6,7,8,9,10,11,12]
bottom_x = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]

left_y = sum_node
right_y = list_a


data = {'Month': bottom_x, 'number_of_influenced_users': left_y, 'seed_users': right_y}
df = pd.DataFrame(data)
print(df)

#plt.title('Average Percipitation Percentage by Month')
#sns.lineplot(x='Month', y='Avg_Percipitation_Perc', data=df, sort=False)
#x_indexes = np.arange(len(bottom_x))
#width = 0.15

#plt.bar(x_indexes-width, left_y, width=width)

#plt.title('My exercise')
#plt.xlabel('Months')
#plt.ylabel('Number of influenced users')
#plt.xticks(ticks= x_indexes, labels= bottom_x)
#plt.ylim(0, 60)
#plt.show()


#Create combo chart
fig, ax1 = plt.subplots(figsize=(10,6))
color = 'tab:green'
#bar plot creation
ax1.set_title('Average influenced user by Month', fontsize=16)
ax1.set_xlabel('Month', fontsize=16)
ax1.set_ylabel('Number of influenced users', fontsize=16)
ax1 = sns.barplot(x='Month', y='number_of_influenced_users', data = df, palette='summer')
ax1.tick_params(axis='y')
#specify we want to share the same x-axis
ax2 = ax1.twinx()
color = 'tab:red'
#line plot creation
ax2.set_ylabel('Number of seed users', fontsize=16)
ax2 = sns.lineplot(x='Month', y='seed_users', data = df, color=color)
ax2.tick_params(axis='y', color=color)
#show plot
plt.show()
plt.savefig('average_influenced_user_by_month.png')


#average_influenced_user_by_month_fb_indegree_comment_100