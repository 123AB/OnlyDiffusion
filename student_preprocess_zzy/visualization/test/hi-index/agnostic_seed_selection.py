# seeds = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
seeds = [5000]
for s in seeds:
    FILE_DIR = '../../../dataset/seed_selection/remove1interaction/hi-index_test/HIindex_sort_{}_{}.csv'
    FILE_WRITE = '../../../dataset/seed_selection/remove1interaction/test/agnostic/agnostic-{}-{}-{}.csv'
    for byType in range(2):
        for ratio in range(11):
            user_list = []
            with open(FILE_DIR.format(byType, ratio/10), 'r') as read_file:
                for idx, line in enumerate(read_file):
                    token = line.strip().split(',')
                    userId = token[0]
                    user_list.append(userId)
                    if idx == s-1: break

            if byType == 0: seedfile = 'hiindexl'
            elif byType == 1: seedfile = 'hiindexc'
            with open(FILE_WRITE.format(seedfile, s, ratio/10), 'w+b') as write_file:
                for user in user_list:
                    toWrite = user+'\n'
                    write_file.write(toWrite.encode('utf-8'))
            