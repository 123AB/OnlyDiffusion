# seeds = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]
seeds = [5000]
for s in seeds:
    FILE_DIR = '../../dataset/seed_selection/remove1interaction/frequency/Frequency_sort_{}.csv'
    FILE_WRITE = '../../dataset/seed_selection/remove1interaction/agnostic/agnostic-{}-{}.csv'
    for byType in range(2):
        user_list = []
        with open(FILE_DIR.format(byType), 'r') as read_file:
            for idx, line in enumerate(read_file):
                token = line.strip().split(',')
                userId = token[0]
                user_list.append(userId)
                if idx == s-1: break

        if byType == 0: seedfile = 'frequencyl'
        elif byType == 1: seedfile = 'frequencyc'
        with open(FILE_WRITE.format(seedfile, s), 'w+b') as write_file:
            for user in user_list:
                toWrite = user+'\n'
                write_file.write(toWrite.encode('utf-8'))
        