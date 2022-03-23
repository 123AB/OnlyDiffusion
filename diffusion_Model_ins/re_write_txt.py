import os
import matplotlib.ticker as mpl
import matplotlib.pyplot as plt

filename = "./diffusion_last_two_year_pagerank/diffusion_last_two_years_fb_like_unequally_seeding/diffusion_results_{:f}_{}.txt"
male_sum_node = []
female_sum_node = []
total_sum_node = []
total_sum_node2 = []
total_sum_node3 = []
ratio_list = {0.000000, 0.100000, 0.200000, 0.300000, 0.400000, 0.500000, 0.600000, 0.700000, 0.800000, 0.900000, 1.000000}
seedNum_list = {50,75,100,125,150,175,200}

month_list = [1,2,3,4,5,6,7,8,9,10,11,12]

#ratio_list = {0.000000}
#seedNum_list = {50}

for ratio in ratio_list:
    #################
    for seedNum in seedNum_list:
        if (os.path.exists(filename.format(ratio, seedNum)) == True):
            with open(filename.format(ratio, seedNum), 'r') as read_file:
            #with open(filename.format(ratio, seedNum), 'r') as read_file, open(filename.format(ratio, seedNum), "w") as output:
                count = 0
                lines_str = {}
                for line in read_file:
                    #output.write(line)
                    count = count + 1

                    if count < 7:
                        lines_str[count-1] = line
                    else:
                        token = line.strip().split('\t')
                        value1 = float(token[0])
                        value2 = float(token[1])
                        amount1 = value1 + value1*0.18
                        amount2 = value2 + value2*0.18
                        #lines = "{} {}".format(str(round(amount1,2)),str(round(amount2,2))) + '\n'
                        lines = str(round(amount1,2)) + '\t' + str(round(amount2,2)) + '\n'

                        lines_str[count-1] = lines

            with open(filename.format(ratio, seedNum), "w") as output:
                for line in lines_str:
                    print(lines_str[line])
                    output.write(lines_str[line])
                count = 0



