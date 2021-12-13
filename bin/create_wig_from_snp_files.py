#!/usr/bin/python3

'''
Date: 13/Dec/2021
Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
version: 1.0

Program Description:
This program will make the wig files that are the output of the flow, this will be done by making
a matrix of counters, were the column 0 is going to be for the principal group and the column 1 
is going to be for the other group, and each row will be the position of the kmer -1, so the first 
kmer will be counted in the row 0. And the differences file is going to be created here too.

The inputs of this program are:
-k (optional) is the size of the kmer that is going to be used to simulate the conservation landscapes
	if not given is going to be 1 and it will be a landscape of base conservation
-l list of directories that have the .snps file to process
	Note:
		-only files that finish with .snps are going to be used by the program.
-o output directory were the files are going to be saved (if it doesn't exist the program will create it)
-r reference genome (it's used to know the length of the genome and the get the header that is going to be
	used for the wig files)
'''

import argparse
import os
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("-k", "--kmer", dest="kmer") #Kmer size
parser.add_argument("-l","--list", nargs="+", required=True) #list of directories of the snps files for the different groups
parser.add_argument("-o", "--output", dest="output",required=True) #output directory
parser.add_argument("-r", "--reference", dest="reference",required=True) #reference genome
args = parser.parse_args()

#function to obtain the files in the desired directory
def files_in_path(path):
	if(path[-1]!="/"):
		path+="/"
	return [path+obj.name for obj in Path(path).iterdir() if obj.is_file()]

#returns a new list of the sum of 2 lists
#this is used so the count of each file are saved in the list of interest that has the sum of the files from
#the same directory
def sum_lists(list1,list2):
	return([a + b for a, b in zip(list1, list2)])

#this function will process each of the .snps files found in each of the directories, file_name is the name 
#of the snp file, kmer_size is the size of the kmer used to simulate the snps, genome_size is used to know the
#size that the list should be.
#the idea of this function is to start with a list of only ones, and depending of the numbers that are in the 
#file (the snps) the program will pass those positions to zero.
def process_snp_file(file_name, kmer_size, genome_size):
	resp_vec=[1 for i in range(genome_size)]
	snp_file=open(file_name)
	for line in snp_file:
		if("\t" in line and not "[" in line):
			line_split=line.rstrip("\n").split("\t")
			pos=int(line_split[0])
			for i in range(pos-kmer_size,pos):
				resp_vec[i]=0
	snp_file.close()
	return(resp_vec)



#if the kmer variable was given then kmer_size will have that value, if not then the value is going to be 1
#and the program will get the conservation per base landscape
if(args.kmer):
	kmer_size=int(args.kmer)
else:
	kmer_size=1

#this if checks if at least two directories were used, if no directories were given then the program while 
#be stopped because at least 2 directories are needed to make the differential landscape.
if(len(args.list)<2):
	print("Error at least two directories should be provided in -l/--list option.")
	exit()

#create the output directory if it doesnt exist
if(not os.path.exists(args.output)):
    os.mkdir(args.output)

#to obtain reference genome size and header for the wig file
file=open(args.reference,"r")
genome_size=0
for line in file:
	if(not ">" in line):
		genome_size+=len(line.rstrip("\n"))
	else:
		header=line.rstrip("\n").replace(">","").split(" ")[0]
file.close()

#here the counts are made
#count_per_directory is a list of lists that will saved the
count_per_directory=[]
total_files=[]
for directory in args.list:
	count_per_directory.append([0 for i in range(genome_size)])
	total_files.append(0)
	for file_name in files_in_path(directory):
		if(".snps" in file_name):
			temp_vec=process_snp_file(file_name,kmer_size,genome_size)
			#the list of the counts of that directory is saved after making the sum of the two lists.
			count_per_directory[-1]=sum_lists(count_per_directory[-1],temp_vec)
			total_files[-1]+=1

#this adds the "/" to the output directory name if it doesn't have it
if(args.output[-1]=="/"):
	output_dir=args.output
else:
	output_dir=args.output+"/"

#a list of output files is opened and the header of the wig file is written
resp_list=[]
for elem in args.list:
	for direc in elem.split("/"):
		if(len(direc)>0):
			group_name=direc
	resp_list.append(open(output_dir+group_name+"_"+str(kmer_size)+".wig","w"))
	resp_list[-1].write("variableStep chrom="+header+"\n")

#differential landscape file
dif_file=open(output_dir+"diff_"+str(kmer_size)+".wig","w")
dif_file.write("variableStep chrom="+header+"\n")

#to write each of the values of the conservation landscapes and the differential landscape
#first it will iterate for the amount of bases of the reference genome and the for the amount 
#of directories procesed
for i in range(genome_size):
	list_temp=[]
	for j in range(len(count_per_directory)):
		temp=count_per_directory[j][i]/total_files[j]
		resp_list[j].write(str(i)+" "+str(temp)+"\n")
		list_temp.append(temp)
	#depending of the amount of directories that were the input is how the differential landscape
	#is going to be done
	if(len(list_temp)==2):
		dif_file.write(str(i)+" "+str(list_temp[0]-list_temp[1])+"\n")
	else:
		dif_file.write(str(i)+" "+str(max(list_temp)-min(list_temp))+"\n")

#the file needs to be closed for each element in the list
for i in range(len(resp_list)):
	resp_list[i].close()

dif_file.close()
