 # # female_ratio
# fr = 59.7/(59.7+40.3)
# # male_ratio
# mr = 1 - fr
#seeds = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
#seeds = [75,125,150,175]
#seeds = [50,100,200]
seeds = [100,200]

import os
import sys

#seeds = list(map(int, sys.argv[1:]))
gender_dict = {}
types = ["like", "comment"]

#FILE_DIR = '../../../dataset_2015/dataset_remove1interaction/1_stat_user1.csv'
FILE_DIR = 'students_edge_all/students_edges_all.csv';

with open(FILE_DIR, 'r') as read_file:
    for line in read_file:
        token = line.strip().split(' ')
        senderId = token[0]
        senderGen = int(token[1])
        receiverId = token[2]
        receiverGen = int(token[3])
        if senderId not in gender_dict: gender_dict[senderId] = senderGen
        if receiverId not in gender_dict: gender_dict[receiverId] = receiverGen

#for ratio in range(101):
for ratio in range(11):
    # male_ratio
    #mr = ratio / 100
    mr = ratio / 10
    # female_ratio
    fr = 1 - mr
    for s in seeds:
        #FILE_DIR = 'outputNodenumber_10/hi_index_{}_{}_{}.csv'

        #FILE_DIR = 'outputNodenumber/hi_index_{}_{}_{}.csv'
        #FILE_WRITE = 'diversity_month_hi_index/diversity-{}-{}-{}-{}.csv'


        #FILE_WRITE = 'test/diversity-{}-{}-{}-{}.csv'

        FILE_DIR = 'outputNodenumberTwoMonth/hi_index_{}_{}_{}.csv'
        FILE_WRITE = 'diversity_two_month_hi_index/diversity-{}-{}-{}-{}.csv'

        #FILE_DIR = 'outputNodenumberTwoWeek/hi_index_{}_{}_{}.csv'
        #FILE_WRITE = 'diversity_two_month_hi_index/diversity-{}-{}-{}-{}.csv'

        #FILE_DIR = 'outputNodenumberTwoWeek/hi_index_{}_{}_{}.csv'
        #FILE_WRITE = 'diversity_two_week_hi_index/diversity-{}-{}-{}-{}.csv'

        #FILE_DIR = 'outputNodenumberOneWeek/hi_index_{}_{}_{}.csv'
        #FILE_WRITE = 'diversity_one_week_hi_index/diversity-{}-{}-{}-{}.csv'

        for type in types:
            for byType in range(999):
                if (os.path.exists(FILE_DIR.format(type,byType,mr)) == True):
                    user_list = []
                    fs = round(s * fr, 0)
                    ms = round(s * mr, 0)
                    with open(FILE_DIR.format(type,byType,mr), 'r') as read_file:
                        for line in read_file:
                            token = line.strip().split(' ')
                            userId = token[0]

                            if userId in gender_dict:
                                userGen = int(gender_dict[userId])
                                if fs or ms:
                                    if userGen == 1 and ms:
                                        user_list.append(userId)
                                        ms -= 1
                                    elif userGen == 2 and fs:
                                        user_list.append(userId)
                                        fs -= 1
                                    else:
                                        pass
                                else:
                                    break
                            else:
                                #print("missing userId:", userId)
                                pass

                    if type == 'like':
                        seedfile = 'hindexl'
                    elif type == 'comment':
                        seedfile = 'hindexc'
                    #with open(FILE_WRITE.format(seedfile, s, ratio/100,byType), 'w+b') as write_file:
                    with open(FILE_WRITE.format(seedfile, s, ratio / 10, byType), 'w+b') as write_file:
                        for user in user_list:
                            toWrite = user + '\n'
                            write_file.write(toWrite.encode('utf-8'))
