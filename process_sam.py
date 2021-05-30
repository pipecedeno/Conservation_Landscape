#!/usr/bin/python3

import argparse
#import re
#from datetime import datetime

'''
This program will process the sam file (that is the output of the alignment of the reference kmers to the
genome of interest) and it will output the id of the kmers were perfectly aligned or that were aligned with an
N in between the alignment

Note: maybe the set or the way the md_z is obtained can be optimized and that could lead to a reduction of the
execution time of the program
'''

parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-f", "--file",dest="file",required=True) #sam file of the alignment
parser.add_argument("-o", "--output", dest="output", required=True) #output file
parser.add_argument("-s", "--size", dest="size", required=True) #size kmer
args = parser.parse_args()

#startTime = datetime.now()

file=open(args.file,"r")
resp=open(args.output,"w")

size_kmer=args.size

for line in file:
	line_split=line.rstrip("\n").split("\t")
	#this line doent work all the time because for some reason in some cases the MD:Z: is not always in the column 18
	#(which is the 17 for python), so its better to do a for to get the element that has the MD:Z: 
	#md_z=line_split[17]
	md_z="".join([elem for elem in line_split if "MD:Z:" in line_split])
	temp=md_z.split(":")[-1]
	if(temp==size_kmer):
		resp.write(str(line_split[0])+"\n")
	elif((set(temp) <= set('1234567890N'))):
		resp.write(str(line_split[0])+"\n")
	else:
		continue

file.close()
resp.close()

#print(datetime.now() - startTime)