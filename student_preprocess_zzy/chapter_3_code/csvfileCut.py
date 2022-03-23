import chardet
import csv
import os
import math
import time

file_name = './dataset_whole/dataset_bothcriteria/action_with_gender_full_sec.csv'

f = open(file_name, 'rb')
lines = f.readline()
file_code = chardet.detect(lines)['encoding']
with open(file_name, 'r', encoding=file_code) as f:
    csv_file = f.readlines()
linesPerFile = 3000000
filecount = 1
print(len(csv_file))
for i in range(0, len(csv_file), linesPerFile):
    with open(file_name[:-4] + '_' + str(filecount) + '.csv', 'w+') as f:
        if filecount > 1:
            f.write(csv_file[0])
            f.writelines(csv_file[i:i+linesPerFile])
        filecount += 1

st = time.time()
et = time.time()
cost_time = et - st
print('处理完成，程序运行时间：{}秒'.format(float('%.2f' % cost_time)))
