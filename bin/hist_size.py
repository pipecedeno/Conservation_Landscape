#!/usr/bin/python3

'''
Date: 17/Nov/2021
Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
version: 1.0

Program Description:
This program is for creating the histogram of sizes for the genomes of one group,
and it will process a file where the size of the genomes was saved in a list and then the 
histogram will be done using matplotlib

Inputs:
-nam name of the input file
-des name of the output file (the .png file with the histogram)
'''

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import argparse
parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-n", "--nam", dest="nam", required=True) #name of the input file
parser.add_argument("-d", "--des", dest="des", required=True) #name of the output file
args = parser.parse_args()

file=open(args.nam, "r")

val=[]
for line in file:
	val.append(int(line.rstrip("\n")))

file.close()

plt.hist(val)
plt.xlabel("Genome size")
plt.ylabel("Frequency")
plt.savefig(args.des, dpi=300)