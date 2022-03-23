# # female_ratio
# fr = 59.7/(59.7+40.3)
# # male_ratio
# mr = 1 - fr
import os

#seeds = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
seeds = [75,125,150,175]

import sys
#seeds = list(map(int, sys.argv[1:]))
gender_dict = {}
#FILE_DIR = '../../../dataset_2015/dataset_remove1interaction/1_stat_user1.csv'
FILE_DIR = '../../../student_preprocess/only_post/students_edges_all.csv';

#FILE_DIR = '../../../student_preprocess/diffusion/netWorkFileHalfYear/comment_{}.csv';


with open(FILE_DIR, 'r') as read_file:
    for line in read_file:
        token = line.strip().split(',')
        senderId = token[0]
        senderGen = int(token[1])
        receiverId = token[2]
        receiverGen = int(token[3])
        if senderId not in gender_dict: gender_dict[senderId] = senderGen
        if receiverId not in gender_dict: gender_dict[receiverId] = receiverGen

#print(gender_dict)

for ratio in range(100):
    # male_ratio
    mr = ratio/100
    # female_ratio
    fr = 1-mr

    for s in seeds:
        #FILE_DIR = '../../dataset/students_indegree_comment_{}.csv'
        #FILE_DIR = '../../../student_preprocess/intensity/students_indegree_sort_{}.csv'
        FILE_DIR = '../../../student_preprocess/intensity/students_intensity_comment_{}.csv'
        #FILE_WRITE = '../../dataset/seed_selection/remove1interaction/diversity/diversity-{}-{}-{}.csv'
        FILE_WRITE = '../../dataset/seed_selection_intensity/diversity-{}-{}-{}-{}.csv'
        for byType in range(999):
            if (os.path.exists(FILE_DIR.format(byType)) == True):

                user_list = []
                fs = round(s * fr, 0)
                ms = round(s * mr, 0)
                with open(FILE_DIR.format(byType), 'r') as read_file:
                    for line in read_file:
                        token = line.strip().split(' ')
                        userId = token[0]
                        #userId = eval(token[0])
                        #userId = "'{}'".format(userId)
                        #print("I come here")
                        #print("token:",token)
                        #print("userID:",userId)
                        #print(type(userId))
                        #print(gender_dict.get('75'))
                        #print(type('75'))
                        #print(gender_dict.get(userId))
                        #print(gender_dict.keys())
                        if userId in gender_dict:
                            userGen = int(gender_dict[userId])
                            if fs or ms:
                                if userGen == 1 and ms:
                                    user_list.append(userId)
                                    ms-=1
                                elif userGen == 2 and fs:
                                    user_list.append(userId)
                                    fs-=1
                                else: pass
                            else: break
                        else:
                            #pass
                            print("missing userId:", userId)
                #if byType == 0: seedfile = 'indegreel'
                #elif byType == 1: seedfile = 'indegreec'
                #elif byType == 2: seedfile = 'indegreet'
                seedfile = 'intensityc'
                with open(FILE_WRITE.format(seedfile, s, ratio/100,byType), 'w+b') as write_file:
                    for user in user_list:
                        toWrite = user+'\n'
                        write_file.write(toWrite.encode('utf-8'))
