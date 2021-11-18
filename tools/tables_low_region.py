#!/usr/bin/python3

'''
This program will create a file for each region identified in the program identify_low_regions.py and will output a file
that will have a contingency table between the two groups indicated in the columns and in the rows it will have the amount
of genomes that have the genome bases and the amount that don't have those bases.
And as not all the regions may be of interest it will only create a file for the regions that have  
'''

import argparse
import linecache

parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-r", "--regions",dest="regions",required=True) #file of the regions created by "identify_low_region.py"
parser.add_argument("-f", "--first",dest="first",required=True) #first group wig file
parser.add_argument("-s", "--second",dest="second",required=True) #second group wig file
parser.add_argument("-d", "--diff", dest="diff", required=True) #value the difference needs to be bigger than
parser.add_argument("-g", "--gen1", dest="gen1", required=True) #number of genomes of the group1
parser.add_argument("-e", "--gen2", dest="gen2", required=True) #number of genomes of the group2
args = parser.parse_args()

difference=float(args.diff)
first_file_name=args.first
second_file_name=args.second
num_gen1=int(args.gen1)
num_gen2=int(args.gen2)

regions=open(args.regions, "r")
for line in regions:
	line_split=line.rstrip("\n").split("\t")

	if(float(line_split[3])>difference):
		value=int((int(line_split[0])+int(line_split[1]))/2)

		val_first_group=float(linecache.getline(first_file_name, value+2).rstrip("\n").split(" ")[1])
		val_second_group=float(linecache.getline(second_file_name, value+2).rstrip("\n").split(" ")[1])

		first_group_name=first_file_name.split("/")[-1].replace(".wig","")
		second_group_name=second_file_name.split("/")[-1].replace(".wig","")

		resp=open(first_group_name+"_"+second_group_name+"_"+str(value)+".tsv", "w")
		resp.write("\t\""+first_group_name+"\"\t\""+second_group_name+"\"\n")
		resp.write("\"genomes with reference nucleotide\"\t"+str(val_first_group*num_gen1)+"\t"+str(val_second_group*num_gen2)+"\n")
		resp.write("\"genomes with non-reference nucleotide\"\t"+str(num_gen1-(val_first_group*num_gen1))+"\t"+str(num_gen2-(val_second_group*num_gen2))+"\n")
		resp.close()

regions.close()

