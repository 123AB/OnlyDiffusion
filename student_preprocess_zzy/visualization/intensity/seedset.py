# retrieving the csv file from task1
# user1_ID, user1_gender, user2_ID, user2_gender, #likes, #comments, #interactions,
# interv_like, interv_comment, interv_interaction\n

import csv
import math
from collections import OrderedDict

FILE = '../../../dataset_2015/dataset_{}/task3/3_stat_user2/3_stat_user2_{}.csv'
# testcases = ['nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria']
testcases = ['remove1interaction']

from os import listdir
from os.path import isfile, join

def process(return_dist):
    return {k: v for k, v in sorted(return_dist.items(), key=lambda item: item[1], reverse=True)}

for testcase in testcases:
    FILEDIR = '../../../dataset_2015/dataset_{}/task3/3_stat_user2'.format(testcase)
    file_length = len([f for f in listdir(FILEDIR) if isfile(join(FILEDIR, f))])
    # like and comment
    result = [[],[]]
    for byType in range(2,4):
        user_dict = {}
        for idx in range(file_length):
            task1_stats = csv.reader(open(FILE.format(testcase, idx)), delimiter=",")
            next(task1_stats, None)
            for line in task1_stats:
                if line[0] not in user_dict: user_dict[line[0]] = line[byType]
        result[byType-2] = process(user_dict)
        OUTPUT_DIR = '../../dataset/seed_selection/{}/intensity/Indegree_sort_{}.csv'.format(testcase, byType-2)
        with open(OUTPUT_DIR, 'w') as writefile:
            writer = csv.writer(writefile)
            for k, v in result[byType-2].items():
                writer.writerow([k, v])
