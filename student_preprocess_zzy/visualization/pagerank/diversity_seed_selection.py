# # female_ratio
# fr = 59.7/(59.7+40.3)
# # male_ratio
# mr = 1 - fr
seeds = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
import sys
#seeds = list(map(int, sys.argv[1:]))
gender_dict = {}
FILE_DIR = '../../../student_preprocess/only_post/students_edges_all.csv'

with open(FILE_DIR, 'r') as read_file:
    for line in read_file:
        token = line.strip().split(',')
        senderId = token[0]
        senderGen = int(token[1])
        receiverId = token[2]
        receiverGen = int(token[3])
        if senderId not in gender_dict: gender_dict[senderId] = senderGen
        if receiverId not in gender_dict: gender_dict[receiverId] = receiverGen

for ratio in range(11):
    # male_ratio
    mr = ratio/10
    # female_ratio
    fr = 1-mr
    for s in seeds:
        #FILE_DIR = '../../dataset/seed_selection/remove1interaction/pagerank/Pagerank_sort_{}.csv'

        #commented out by zhiyue zhang this is pagerank
        #FILE_DIR = '../../../student_preprocess/pagerank/students_pagerank_sort_{}.csv' for pagerank
        #FILE_WRITE = '../../dataset/seed_selection_pagerank/diversity-{}-{}-{}.csv' for pagerank


        FILE_DIR = '../../../student_preprocess/gat_based/old_gat_sort_{}.csv'

        #FILE_WRITE = '../../dataset/seed_selection/remove1interaction/diversity/diversity-{}-{}-{}.csv'

        FILE_WRITE = '../../dataset/seed_selection_gat_based/diversity-{}-{}-{}.csv'

        for byType in range(3):
            user_list = []
            fs = round(s * fr, 0)
            ms = round(s * mr, 0)
            with open(FILE_DIR.format(byType), 'r') as read_file:
                for line in read_file:
                    token = line.strip().split(',')
                    userId = token[0]
                    if(userId in gender_dict):
                        userGen = int(gender_dict[userId])
                    else: pass
                    if fs or ms:
                        if userGen == 1 and ms: 
                            user_list.append(userId)
                            ms-=1
                        elif userGen == 2 and fs: 
                            user_list.append(userId)
                            fs-=1
                        else: pass
                    else: break
            if byType == 0: seedfile = 'gat_based_l'
            elif byType == 1: seedfile = 'gat_based_c'
            elif byType == 2: seedfile = 'gat_based_t'
            with open(FILE_WRITE.format(seedfile, s, ratio/10), 'w+b') as write_file:
                for user in user_list:
                    toWrite = user+'\n'
                    write_file.write(toWrite.encode('utf-8'))
            