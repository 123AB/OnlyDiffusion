# retrieving the csv file from task1
# user1_ID, user1_gender, user2_ID, user2_gender, #likes, #comments, #interactions,
# interv_like, interv_comment, interv_interaction\n

import csv
import math
from collections import OrderedDict

FILE_DIR = '../../../dataset_2015/dataset_{}/1_stat_user1.csv'
# testcases = ['nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria']
testcases = ['remove1interaction']

for testcase in testcases:
    result = [[],[],[]]
    for byType in [4,5,6]:
        task1_stats = csv.reader(open(FILE_DIR.format(testcase)), delimiter=",")
        percentile_list = [{}, {}]
        sorted_percentile_list = [{}, {}]
        male = {}
        female = {}
        
        for line in task1_stats:
            # check the receiver
            if int(float(line[byType])) == 0 and byType == 10: pass
            else:
                # receiver point of view
                if line[3] == '1': # to male
                    if line[2] not in male: 
                        male[line[2]] = int(float(line[byType]))
                    else: 
                        male[line[2]] += int(float(line[byType]))
                
                elif line[3] == '2': # to female
                    if line[2] not in female:
                        female[line[2]] = int(float(line[byType]))
                    else: 
                        female[line[2]] += int(float(line[byType]))
        
        result[byType-4] = {k: v for k, v in sorted({**male, **female}.items(), key=lambda item: item[1], reverse=True)}
        OUTPUT_DIR = '../../dataset/seed_selection/{}/frequency/Frequency_sort_{}.csv'.format(testcase, byType-4)
        with open(OUTPUT_DIR, 'w') as writefile:
            writer = csv.writer(writefile)
            for k, v in result[byType-4].items():
                writer.writerow([k, v])
        