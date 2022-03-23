import networkx as nx
import pandas as pd
import csv
import os
import math
import time
from collections import OrderedDict
from functools import reduce
import numpy as np
from threading import Thread, Lock

start = time.time()
df = pd.read_csv('../dt_node_ins_filter.csv',sep=';',names=['index','user_id','gender'])
df.to_pickle("hindex_ins_data/df_hindex.pickle")
print(f"Done reading from pickle, it took {time.time() - start} seconds.")

#df.apply(lambda x:x.sum(), axis=1)
#df.applymap(abs)
#df.rolling(10).apply(lambda x:x.rank())
#df.applymap(np.log)

#g = (x*x for x in range(10))
#L = [x*x for x in range(10)]

#print(g==L)
#print(g[0]==L[0])
#print(type(g)==type(L))
#print(sum(g)==sum(L))


#def func(a,*args,b):pass
#def func(a,**kwargs):pass
#def func(a,**kwargs, *args, c):pass
#def func(a,b,*args, **kwargs):pass

#a = 1
#b = 1
#func(b)


#a = [1,2,3,4,5,6,7]
#b = filter(lambda x: x > 5, a)
#print(list(b))


#df.fillna(df.mean())
#df.fillna(method=”ffill”)
#df.fillna(“mean”)
#print(df.fillna(np.mean))

#print(sorted(a, key= lambda x:a[x]))
#df1 = df
#df2 = df
#df1,df2=df1.align(df2, join='inner')

#print(df1.columns==df2.columns and df1.index!=df2.index)
#df1.columns==df2.columns and df1.index==df2.index
#df1.columns!=df2.columns and df1.index!=df2.index
#df1.columns!=df2.columns and df1.index==df2.index
#df1.columns==df2.columns and df1.index!=df2.index
