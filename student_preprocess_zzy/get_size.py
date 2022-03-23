import os
# get the size of file


list = range(535,547)
filename = "timeweek/{}.csv"
size_sum = []

for blocknum in list:
    print("the blocknum is:",blocknum)
    if (os.path.exists(filename.format(blocknum)) == True):
        size = os.path.getsize(filename.format(blocknum))
        size_sum.append(size)
        #print('Size of file is', size, 'bytes')


#print("the sum size is:", sum(size_sum))
for counts in size_sum:
    results = counts / sum(size_sum)
    print('ratio of file is', results, 'bytes')
