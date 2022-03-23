import math
import os
import numpy as np
from matplotlib import pyplot as plt
from matplotlib.figure import Figure as figure
import pandas as pd
import matplotlib
import seaborn as sns

'''
FILE_READ_uq = "./diffusion_last_two_year_in_index_twomonth/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq = "./diffusion_last_two_year_in_index_twomonth/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o = "./diffusion_last_two_year_in_index_twomonth/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"


FILE_READ_um = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
FILE_READ_em = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_equally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
FILE_READ_om = "./diffusion_last_two_year_in_index/diffusion_last_two_years_fb_comment_original/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"


FILE_READ_uq_tw = "./diffusion_last_two_year_in_index_twoweek/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq_tw = "./diffusion_last_two_year_in_index_twoweek/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o_tw = "./diffusion_last_two_year_in_index_twoweek/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"


FILE_READ_uq_ow = "./diffusion_last_two_year_in_index_week/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq_ow = "./diffusion_last_two_year_in_index_week/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o_ow = "./diffusion_last_two_year_in_index_week/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"
'''

###
'''
FILE_READ_uq = "./diffusion_last_two_year_indegree_twomonth/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq = "./diffusion_last_two_year_indegree_twomonth/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o = "./diffusion_last_two_year_indegree_twomonth/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"


FILE_READ_um = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
FILE_READ_em = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_equally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
FILE_READ_om = "./diffusion_last_two_year_indegree/diffusion_last_two_years_fb_like_original/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"


FILE_READ_uq_tw = "./diffusion_last_two_year_indegree_twoweek/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq_tw = "./diffusion_last_two_year_indegree_twoweek/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o_tw = "./diffusion_last_two_year_indegree_twoweek/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"


FILE_READ_uq_ow = "./diffusion_last_two_year_indegree_week/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq_ow = "./diffusion_last_two_year_indegree_week/diffusion_last_two_years_fb_like_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o_ow = "./diffusion_last_two_year_indegree_week/diffusion_last_two_years_fb_like_original/diffusion_results_{:f}_{}.txt"
'''

#####
'''
FILE_READ_uq = "./diffusion_last_two_year_intensity_twomonth/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq = "./diffusion_last_two_year_intensity_twomonth/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o = "./diffusion_last_two_year_intensity_twomonth/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"


FILE_READ_um = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
FILE_READ_em = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_equally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
FILE_READ_om = "./diffusion_last_two_year_intensity/diffusion_last_two_years_fb_comment_original/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"


FILE_READ_uq_tw = "./diffusion_last_two_year_intensity_twoweek/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq_tw = "./diffusion_last_two_year_intensity_twoweek/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o_tw = "./diffusion_last_two_year_intensity_twoweek/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"


FILE_READ_uq_ow = "./diffusion_last_two_year_intensity_oneweek/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq_ow = "./diffusion_last_two_year_intensity_oneweek/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o_ow = "./diffusion_last_two_year_intensity_oneweek/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"
'''

###
FILE_READ_uq = "./diffusion_last_two_year_pagerank_twomonth/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq = "./diffusion_last_two_year_pagerank_twomonth/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o = "./diffusion_last_two_year_pagerank_twomonth/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"


FILE_READ_um = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_unequally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
FILE_READ_em = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_equally_seeding/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"
FILE_READ_om = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_comment_original/pervious_seeding_ratio/diffusion_results_{:f}_{}.txt"


FILE_READ_uq_tw = "./diffusion_last_two_year_pagerank_twoweek/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq_tw = "./diffusion_last_two_year_pagerank_twoweek/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o_tw = "./diffusion_last_two_year_pagerank_twoweek/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"


FILE_READ_uq_ow = "./diffusion_last_two_year_pagerank_oneweek/diffusion_last_two_years_fb_comment_unequally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_eq_ow = "./diffusion_last_two_year_pagerank_oneweek/diffusion_last_two_years_fb_comment_equally_seeding/diffusion_results_{:f}_{}.txt"
FILE_READ_o_ow = "./diffusion_last_two_year_pagerank_oneweek/diffusion_last_two_years_fb_comment_original/diffusion_results_{:f}_{}.txt"


#ratio = {0.05671172670751998, 0.08797285272479766, 0.07034811460994941, 0.08022840919860938,
#0.08329043932290775, 0.0884038377870173, 0.10746663873818907, 0.08548126161185657, 0.0858406110369326,
#                  0.08166535902475652, 0.0912369954974133, 0.08135375374005048};
twomonthSumUnequally = []
twomonthSumEqually = []
twomonthSumOriginal = []

onemonthSumUnequally = []
onemonthSumEqually = []
onemonthSumOriginal = []

twoweekSumUnequally = []
twoweekSumEqually = []
twoweekSumOriginal = []

oneweekSumUnequally = []
oneweekSumEqually = []
oneweekSumOriginal = []

#ratio_list = {0.000000, 0.100000, 0.200000, 0.300000, 0.400000, 0.500000, 0.600000, 0.700000, 0.800000, 0.900000, 1.000000}
ratio_list = {0.500000}
seedNum_list = {100}
for ratio in ratio_list:
    #################
    for seedNum in seedNum_list:
        if (os.path.exists(FILE_READ_uq.format(ratio, seedNum)) == True):
            df_uq = pd.read_csv(FILE_READ_uq.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])
            df_eq = pd.read_csv(FILE_READ_eq.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])
            df_o = pd.read_csv(FILE_READ_o.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])

            df_uq_tw = pd.read_csv(FILE_READ_uq_tw.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])
            df_eq_tw = pd.read_csv(FILE_READ_eq_tw.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])
            df_o_tw = pd.read_csv(FILE_READ_o_tw.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])

            df_uq_m = pd.read_csv(FILE_READ_um.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])
            df_eq_m = pd.read_csv(FILE_READ_em.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])
            df_o_m = pd.read_csv(FILE_READ_om.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])

            df_uq_ow = pd.read_csv(FILE_READ_uq_ow.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])
            df_eq_ow = pd.read_csv(FILE_READ_eq_ow.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])
            df_o_ow = pd.read_csv(FILE_READ_o_ow.format(ratio, seedNum),sep='\t',names=['num_male','num_female'])

            totalSum_uq = df_uq['num_male'].sum() + df_uq['num_female'].sum()
            totalSum_eq = df_eq['num_male'].sum() + df_eq['num_female'].sum()
            totalSum_o = df_o['num_male'].sum() + df_o['num_female'].sum()

            totalSum_uq_tw = df_uq_tw['num_male'].sum() + df_uq_tw['num_female'].sum()
            totalSum_eq_tw = df_eq_tw['num_male'].sum() + df_eq_tw['num_female'].sum()
            totalSum_o_tw = df_o_tw['num_male'].sum() + df_o_tw['num_female'].sum()

            totalSum_uq_ow = df_uq_ow['num_male'].sum() + df_uq_ow['num_female'].sum()
            totalSum_eq_ow = df_eq_ow['num_male'].sum() + df_eq_ow['num_female'].sum()
            totalSum_o_ow = df_o_ow['num_male'].sum() + df_o_ow['num_female'].sum()

            totalSum_uq_m = df_uq_m['num_male'].sum() + df_uq_m['num_female'].sum()
            totalSum_eq_m = df_eq_m['num_male'].sum() + df_eq_m['num_female'].sum()
            totalSum_o_m = df_o_m['num_male'].sum() + df_o_m['num_female'].sum()

            twomonthSumUnequally.append(totalSum_uq)
            twomonthSumEqually.append(totalSum_eq)
            twomonthSumOriginal.append(totalSum_o)

            twoweekSumUnequally.append(totalSum_uq_tw)
            twoweekSumEqually.append(totalSum_eq_tw)
            twoweekSumOriginal.append(totalSum_o_tw)

            oneweekSumUnequally.append(totalSum_uq_ow)
            oneweekSumEqually.append(totalSum_eq_ow)
            oneweekSumOriginal.append(totalSum_o_ow)

            onemonthSumUnequally.append(totalSum_uq_m)
            onemonthSumEqually.append(totalSum_eq_m)
            onemonthSumOriginal.append(totalSum_o_m)
#column_names = ['unequal diverse seeding','equal diverse seeding','origin diverse seeding']
#data = pd.DataFrame(columns = column_names)

column_names = ['period','total number of influenced users','methods']
data = pd.DataFrame(columns = column_names)

data = data.append({'period':'two months','total number of influenced users': twomonthSumUnequally[0], 'methods':'unequal diverse seeding'},ignore_index=True)
data = data.append({'period':'two months','total number of influenced users': twomonthSumEqually[0],'methods':'equal diverse seeding'},ignore_index=True)
data = data.append({'period':'two months','total number of influenced users': twomonthSumOriginal[0], 'methods':'origin diverse seeding'}, ignore_index=True)

data = data.append({'period':'one month','total number of influenced users': onemonthSumUnequally[0], 'methods':'unequal diverse seeding'},ignore_index=True)
data = data.append({'period':'one month','total number of influenced users': onemonthSumEqually[0],'methods':'equal diverse seeding'},ignore_index=True)
data = data.append({'period':'one month','total number of influenced users': onemonthSumOriginal[0], 'methods':'origin diverse seeding'}, ignore_index=True)


data = data.append({'period':'two weeks','total number of influenced users': twoweekSumUnequally[0], 'methods':'unequal diverse seeding'},ignore_index=True)
data = data.append({'period':'two weeks','total number of influenced users': twoweekSumEqually[0], 'methods':'equal diverse seeding'},ignore_index=True)
data = data.append({'period':'two weeks','total number of influenced users': twoweekSumOriginal[0], 'methods':'origin diverse seeding'},ignore_index=True)

data = data.append({'period':'one week','total number of influenced users': oneweekSumUnequally[0], 'methods':'unequal diverse seeding'}, ignore_index=True)
data = data.append({'period':'one week','total number of influenced users': oneweekSumEqually[0], 'methods':'equal diverse seeding'}, ignore_index=True)
data = data.append({'period':'one week','total number of influenced users': oneweekSumOriginal[0], 'methods':'origin diverse seeding'}, ignore_index=True)


#data = data.append({'period':'one week','unequal diverse seeding': oneweekSumUnequally[0],'equal diverse seeding': oneweekSumEqually[0], 'origin diverse seeding': oneweekSumOriginal[0]},ignore_index=True)
#data = data.append({'period':'two weeks','unequal diverse seeding': twoweekSumUnequally[0],'equal diverse seeding': twoweekSumEqually[0], 'origin diverse seeding': twoweekSumOriginal[0]},ignore_index=True)
#data = data.append({'period':'two months','unequal diverse seeding': twomonthSumUnequally[0], 'equal diverse seeding': twomonthSumEqually[0],'origin diverse seeding': twomonthSumOriginal[0]},ignore_index=True)



print(data)

sns.set_theme(style="whitegrid")

#penguins = sns.load_dataset("penguins")

# Draw a nested barplot by species and sex
g = sns.catplot(
    data=data, kind="bar",
    x="period", y="total number of influenced users", hue="methods",
    ci="sd", palette="dark", alpha=.6, height=6
)
g.despine(left=True)
#g.ylabel('total number of influenced users')

g.set_axis_labels("", "total number of influenced users")
g.legend.set_title("sensitivity analysis")

plt.show()
plt.savefig('st.png')
#df = pd.read_csv(FILE_READ,sep=';',names=['index','user_id','gender'])

