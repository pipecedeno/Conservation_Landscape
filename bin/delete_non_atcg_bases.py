#!/usr/bin/python3

'''
Date: 17/Nov/2021
Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
version: 1.0

Program Description:
This program is used to delete non A,T,C,G or N letters from the genome were the kmers are going to be aligned,
this is important because razers marks an error is any other letter is found in the sequence. The non ATCGN 
letters are passed to N, and a new file is created with the modified genome so the original file isn't modified.

Inputs:
-f genome file to be processed
-o name of the output file (the processed genome) 
'''

import argparse

parser = argparse.ArgumentParser(description="")
parser.add_argument("-f", "--file",dest="file",required=True) #genome file
parser.add_argument("-o", "--output", dest="output", required=True) #output file
args = parser.parse_args()

genome=open(args.file,"r")
resp=open(args.output,"w")

for line in genome:
	if(">" in line):
		resp.write(line)
	else:
		for base in list(line.rstrip("\n")):
			if((set(base) <= set('ATCG'))):
				resp.write(base)
			else:
				resp.write("N")
		resp.write("\n")
genome.close()
resp.close()

