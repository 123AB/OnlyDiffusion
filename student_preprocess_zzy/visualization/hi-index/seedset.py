import os
import csv
import math
from collections import OrderedDict

def H_index(lst, mr):
    return_dist = {}  
    fr = 1-mr
    
    for user in lst:
        h_index = sum(i < j[1] for i, j in enumerate(sorted(lst[user], reverse=True)))
        male = 0;female = 0
        for line in lst[user]:
            if line[0] == '1': male += line[1]
            elif line[0] == '2': female += line[1]
        gamma = max(
            abs(male/(male+female) - mr),
            abs(female/(male+female) - fr),
        )
        return_dist[user] = h_index * (1-gamma)

    return {k: v for k, v in sorted(return_dist.items(), key=lambda item: item[1], reverse=True)}

# testcases = ['nofilter', 'receivernosend', 'remove1interaction', 'bothcriteria']
testcases = ['remove1interaction']

for testcase in testcases:
    DIR_PATH = '../../../dataset_2015/dataset_{}/task0/user2_split/'
    # like:0, comment:1, interact:2, interact_weight:3
    male_user = [{},{}]
    female_user = [{},{}]
    files = []
    like_dict = {}; comment_dict = {}
    sender_gendict = {}
    for r, d, f in os.walk(DIR_PATH.format(testcase)):
        for file in f:
            files.append(os.path.join(r, file))
    for PATH in files:
        with open(PATH, 'r') as read_file:
            # Create the unique user interaction dict
            for line in read_file:
                token = line.strip().split(',')
                receiver_gender = token[1]
                sender_ID = token[2]
                receiver_ID = token[3]
                interact = token[4]
                if interact == 'like':
                    # From receiver point of view
                    if receiver_ID not in like_dict: like_dict[receiver_ID]=1
                    else: like_dict[receiver_ID]+=1
                    # From sender point of view
                    if sender_ID not in like_dict: like_dict[sender_ID]=1
                    else: like_dict[sender_ID]+=1
                
                elif interact == 'comment':
                    if receiver_ID not in comment_dict: comment_dict[receiver_ID]=1
                    else: comment_dict[receiver_ID]+=1
                    if sender_ID not in comment_dict: comment_dict[sender_ID]=1
                    else: comment_dict[sender_ID]+=1

    for PATH in files:
        with open(PATH, 'r') as read_file:        
            for line in read_file:
                token = line.strip().split(',')
                receiver_gender = token[1]
                sender_ID = token[2]
                receiver_ID = token[3]
                interact = token[4]
                if sender_ID not in sender_gendict: sender_gendict[sender_ID] = token[0]
                if receiver_gender == '1':
                    if interact == 'like':
                        if receiver_ID not in male_user[0]: 
                            male_user[0][receiver_ID] = {}
                            male_user[0][receiver_ID][sender_ID] = like_dict[sender_ID]
                        else:
                            if sender_ID not in male_user[0][receiver_ID]:
                                male_user[0][receiver_ID][sender_ID] = like_dict[sender_ID]
                            else: male_user[0][receiver_ID][sender_ID] = like_dict[sender_ID]
                    
                    elif interact == 'comment':
                        if receiver_ID not in male_user[1]: 
                            male_user[1][receiver_ID] = {}
                            male_user[1][receiver_ID][sender_ID] = comment_dict[sender_ID]
                        else:
                            if sender_ID not in male_user[1][receiver_ID]:
                                male_user[1][receiver_ID][sender_ID] = comment_dict[sender_ID]
                            else: male_user[1][receiver_ID][sender_ID] = comment_dict[sender_ID]
                    
                

                elif receiver_gender == '2':
                    if interact == 'like':
                        if receiver_ID not in female_user[0]: 
                            female_user[0][receiver_ID] = {}
                            female_user[0][receiver_ID][sender_ID] = like_dict[sender_ID]
                        else:
                            if sender_ID not in female_user[0][receiver_ID]:
                                female_user[0][receiver_ID][sender_ID] = like_dict[sender_ID]
                            else: female_user[0][receiver_ID][sender_ID] = like_dict[sender_ID]
                    
                    elif interact == 'comment':
                        if receiver_ID not in female_user[1]: 
                            female_user[1][receiver_ID] = {}
                            female_user[1][receiver_ID][sender_ID] = comment_dict[sender_ID]
                        else:
                            if sender_ID not in female_user[1][receiver_ID]:
                                female_user[1][receiver_ID][sender_ID] = comment_dict[sender_ID]
                            else: female_user[1][receiver_ID][sender_ID] = comment_dict[sender_ID]
                                
    result = [[],[]]
    for byType in range(2):
        for user in male_user[byType]:
            tmp_list = []
            for sender in male_user[byType][user]:
                tmp_list.append((sender_gendict[sender],male_user[byType][user][sender]))
            male_user[byType][user] = tmp_list

        for user in female_user[byType]:
            tmp_list = []
            for sender in female_user[byType][user]:
                tmp_list.append((sender_gendict[sender],female_user[byType][user][sender]))
            female_user[byType][user] = tmp_list

        for ratio in range(11):
            result[byType] = H_index({**female_user[byType], **male_user[byType]}, ratio/10)
            OUTPUT_DIR = '../../dataset/seed_selection/{}/hi-index/HIindex_sort_{}_{}.csv'.format(testcase, byType, ratio/10)
            with open(OUTPUT_DIR, 'w') as writefile:
                writer = csv.writer(writefile)
                for k, v in result[byType].items():
                    writer.writerow([k, v])
