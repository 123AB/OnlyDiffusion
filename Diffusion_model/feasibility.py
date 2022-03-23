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
import pandas as pd
from matplotlib import pyplot as plt

equally_seeding_feasibility_list = [0.428,0.571,0.571]
unequally_seeding_feasibility_list = [0.714,0.714,0.714]
original_seeding_feasibility_list = [0.571,0.571,0.571]

#data = {'100': {0.428,0.714,0.571}, '200': {0.571, 0.714, 0.571}, '500': {0.571,0.714,0.571}}
data = {'original seeding': {100:0.571,200:0.571,500:0.571}, 'equally seeding': {100:0.428, 200:0.571, 500:0.571}, 'unequally seeding': {100:0.714,200:0.714,500:0.714}}

#seedNum_list = [5, 10, 20, 50, 100, 200, 500, 1000]
#seedNum_list = [20, 50, 100, 200, 500, 1000]
#seedNum_list = [100,200,500]
df = pd.DataFrame(data)

df.plot(kind='bar')
plt.savefig('feasibility_target_hi_index_like.png')
plt.show()

#def plotting(seed_spread_list,seed_spread_list2,seed_spread_list3,seedNum):
    #width = 0.02
    #plt.bar(seedNum[0],seed_spread_list[0], width, label="original seeding", fc = 'y')
    #plt.bar(seedNum[0],seed_spread_list2[0], width, label="unequally seeding",fc = 'r')
    #plt.bar(seedNum[0],seed_spread_list3[0], width, label="equally seeding",fc = 'b')
    #plt.legend()
    #plt.show()

'''
ax = plt.gca()
seedNum.sort()
ax.plot(seedNum, seed_spread_list,':r', markersize=4. ,color='red')

ax.plot(seedNum, seed_spread_list2,':r', markersize=4., color = 'blue')
ax.plot(seedNum, seed_spread_list3,':r', markersize=4. ,color = 'yellow')


ax.get_xaxis().set_minor_locator(mpl.AutoMinorLocator())
ax.get_yaxis().set_minor_locator(mpl.AutoMinorLocator())
ax.set_xlabel("Seed Num")
ax.set_ylabel("feasibility")

ax.grid(b=True, which='major', color='w', linewidth=1.5)
ax.grid(b=True, which='minor', color='w', linewidth=0.75)
plt.setp(ax.get_xticklabels(), rotation=30, horizontalalignment='right')
plt.legend(['original seeding','unequally seeding','equally seeding'],loc = 'upper left')
plt.savefig('feasibility_target_hi_index_like.png')
plt.show()  # 显示图形
'''



#plotting(original_seeding_feasibility_list,unequally_seeding_feasibility_list,equally_seeding_feasibility_list,seedNum_list)





# like and comment
# ratio and spread

