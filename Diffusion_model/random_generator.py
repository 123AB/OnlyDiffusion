import random

random_float_list = []
# Set a length of the list to 10
for i in range(0, 10):
    # any random float between 0 to 1
    # don't use round() if you need number as it is
    x = round(random.uniform(0.00, 1.00), 2)
    random_float_list.append(x)

print(random_float_list)
