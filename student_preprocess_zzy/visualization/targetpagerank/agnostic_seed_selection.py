seeds = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
gender_dict = {}

for ratio in range(11):
    for s in seeds:
        FILE_DIR = '../../dataset/seed_selection/remove1interaction/targetpagerank/diffratio-exp/Targetpagerank_sort_{}_{}.csv'
        FILE_WRITE = '../../dataset/seed_selection/remove1interaction/targetpagerank/diffratio-exp/seed_select/{}-{}-{}.csv'
        for byType in range(2):
            user_list = []
            with open(FILE_DIR.format(byType, ratio), 'r') as read_file:
                for idx, line in enumerate(read_file):
                    token = line.strip().split(',')
                    userId = token[0]
                    user_list.append(userId)
                    if idx == s-1: break

            if byType == 0: seedfile = 'tprl'
            elif byType == 1: seedfile = 'tprc'
            with open(FILE_WRITE.format(seedfile, s, ratio/10), 'w+b') as write_file:
                for user in user_list:
                    toWrite = user+'\n'
                    write_file.write(toWrite.encode('utf-8'))
            