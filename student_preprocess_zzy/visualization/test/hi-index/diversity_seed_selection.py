# # female_ratio
# fr = 59.7/(59.7+40.3)
# # male_ratio
# mr = 1 - fr
# seeds = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
import sys
seeds = list(map(int, sys.argv[1:]))
gender_dict = {}
FILE_DIR = '../../../../dataset_2015/dataset_remove1interaction/1_stat_user1.csv'

with open(FILE_DIR, 'r') as read_file:
    for line in read_file:
        token = line.strip().split(',')
        senderId = token[0]
        senderGen = int(token[1])
        receiverId = token[2]
        receiverGen = int(token[3])
        if senderId not in gender_dict: gender_dict[senderId] = senderGen
        if receiverId not in gender_dict: gender_dict[receiverId] = receiverGen
for s in seeds:
    for byType in range(2):
        mr_list = []
        with open("../../../../fairness/dataset/discount_factor_train/weight/weight_diversity-hiindex_{}_{}.txt".format(byType, s), 'r') as read_file:
            for line in read_file:
                token = line.split(',')
                mr_list.append(token[0])

        for idx, ratio in enumerate(mr_list):
            # male_ratio
            mr = float(ratio)
            # female_ratio
            fr = 1-mr
            FILE_DIR = '../../../dataset/seed_selection/remove1interaction/hi-index_test/HIindex_sort_{}_{}.csv'
            FILE_WRITE = '../../../dataset/seed_selection/remove1interaction/test/diversity/diversity-{}-{}-{}.csv'

            user_list = []
            fs = round((seeds[0]/0.2) * fr, 0)
            ms = round((seeds[0]/0.2) * mr, 0)
            with open(FILE_DIR.format(byType, idx/10), 'r') as read_file:
                for line in read_file:
                    token = line.strip().split(',')
                    userId = token[0]
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
            if byType == 0: seedfile = 'hiindexl'
            elif byType == 1: seedfile = 'hiindexc'
            with open(FILE_WRITE.format(seedfile, s, idx/10), 'w+b') as write_file:
                for user in user_list:
                    toWrite = user+'\n'
                    write_file.write(toWrite.encode('utf-8'))