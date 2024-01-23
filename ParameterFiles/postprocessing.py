import numpy as np
from matplotlib import pyplot as plt
import os
import re

# Specify the directory path
directory_path = './output'

# List all files in the directory
file_names = os.listdir(directory_path)


filtered_files = np.array(['placeholder'] * 52, dtype='U100')

n_exist = np.array([],dtype=int)

for i_f in range (52):
    pattern = r'.*M7.8FL34_0.1Hztopo5km_o3ga5e2c1e1_o3jan18_50s-receiver-000' + str(i_f+1).zfill(2) + r'-.*\.dat$'
    for file in file_names:
        if re.match(pattern, file):
            filtered_files[i_f] = file
            n_exist = np.append(n_exist,i_f)
            print(filtered_files[i_f])

# print(n_exist)

nr = n_exist.size
nt = 5001
nq = 10

timeSeries = np.zeros( [nr, nt, nq+1] )
aveDam = np.zeros( [nr,],dtype=float )

i_incre = 0
for i_r in n_exist:
    timeSeries[i_incre,:,:] = np.genfromtxt('./output/'+filtered_files[i_r], delimiter='  ',skip_header=5)
    aveDam[i_incre] = np.mean(timeSeries[i_incre,:,10])
    i_incre += 1

print(timeSeries.shape)

o_fname = "./out.txt"

np.savetxt(o_fname, aveDam)
print('done writing out.txt')