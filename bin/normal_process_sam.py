#!/usr/bin/python3

import argparse

'''
Date: 17/Nov/2021
Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
version: 1.0

Program Description:
This program will process the sam file and it will output the id of the kmers were perfectly aligned or 
that were aligned with an N in between the alignment

inputs:
-f input file, the output of the razers3 program alignment
-s size of the kmer, important to check is MD:Z:size_kmer is in the line (a perfect match)
'''

parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-f", "--file",dest="file",required=True) #sam file of the alignment
parser.add_argument("-s", "--size", dest="size", required=True) #size kmer
args = parser.parse_args()

file=open(args.file,"r")

size_kmer=args.size

for line in file:
	if(not "@" in line):
		line_split=line.rstrip("\n").split("\t")
		for elem in line_split:
			if("MD:Z:" in elem):
				md_z=elem
				break
		temp=md_z.split(":")[-1]
		if(temp==size_kmer):
			print(line_split[0])
		elif((set(temp) <= set('1234567890N'))):
			#if the distances are the same then the value must be a number different of size_kmer, which
			#will indicate that there was an insertion or deletion
			if(len(size_kmer)!=len(temp)):
				print(line_split[0])

file.close()
