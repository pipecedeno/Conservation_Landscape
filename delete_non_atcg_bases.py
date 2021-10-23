#!/usr/bin/python3

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

