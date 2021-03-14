#!/usr/bin/python3
'''
This program is for making the wigs that are the output file of this flow, and this program is made
so that depending of the number of groups that were the input of the flow it is going to be the amount of
wigs produced plus 1 that is because of the differences.
The inputs of this program are:
-fil is the file that has the name and route of the files that have the results of the alignments, which 
are going to be processed to make the counts and the values of the wigs.
-ref is the reference genome that is necessary to obtain the header that is necessary for the wig header.
-des is the directory where the files are going to be saved.
-nmk is the number of kmers that are going to be processed in this program, and this variable is going
to determine the size of the variable list_cont, which is a list of counters.
-nmg is a string that has the number of genomes per group, which is processed and used to make the counts
be from 0 to 1. (This string must be in the format that de name of the group is followed by a ':' and the the
number of genomes, and a comma is separating each group. example: "group1:10,group2:25,group3:3")
'''
import argparse

parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-f", "--fil",dest="fil",required=True) #file that has all the other files
parser.add_argument("-r", "--ref", dest="ref", required=True) #reference genome file
parser.add_argument("-d", "--des", dest="des", required=True) #directory where wigs are going to be saved
parser.add_argument("-k", "--nmk", dest="nmk", required=True) #number of kmers
parser.add_argument("-n", "--nmg", dest="nmg", required=True) #string of the number of genomes for group
args = parser.parse_args()

#This is only for obtaining the header that is necessary for the wigs
file=open(args.ref, "r")
for line in file:
	if(line[0]==">"):
		header=line.rstrip("\n").replace(">","").split(" ")[0]
		break

file.close()

#A dictionary that will link the name of the group and the number of genomes in that group is made
num_per_genome={}
for elem in args.nmg.split(","):
	temp=elem.split(":")
	num_per_genome[temp[0]]=int(temp[1])

#a variable with the amount of groups is saved
number_of_groups=len(num_per_genome)

#Here a list will be created were the counts for the kmers appearances will be done
list_cont=[]
for cont in range(int(args.nmk)):
	list_cont.append([0 for i in range(number_of_groups)])

#the size of the kmers is obtained from the name of the args.file name
kmer_size=int(args.fil.split("/")[-1].split("_")[0])

#Here the count for the genomes is made, each line of the file of args.fil corresponds to a
#file were the results of the alingments for each group was saved, so this file is opened and each
#line is the position of a read that was aligned. group_order is important so that the counts for each group
#don't get mixed
group_order=[]
cont_pos=0
file_files=open(args.fil, "r")
for line in file_files:
	file_name=line.rstrip("\n")

	group=file_name.split("/")[-1].split("_")[1]
	group_order.append(group)
	number_of_genomes=num_per_genome[group]

	file=open(file_name, "r")
	for val in file:
		pos=int(val.rstrip("\n"))-1
		list_cont[pos][cont_pos]+=1

	file.close()

	for i in range(len(list_cont)):
		list_cont[i][cont_pos]=list_cont[i][cont_pos]/number_of_genomes

	cont_pos+=1
file_files.close()

#This part while write the output file for each group
cont_pos=0
for elem in group_order:
	print(args.des+elem+"_"+str(kmer_size)+".wig")
	file=open(args.des+elem+"_"+str(kmer_size)+".wig", "w")
	file.write("variableStep chrom="+header+"\n")
	
	for i in range(len(list_cont)):
		value=list_cont[i][cont_pos]
		file.write(str(i)+" "+str(value)+"\n")

	cont_pos+=1
	file.close()

#Here the file of the differences is going to be made, were the difference that is going to be
#represented in the file is the maximum value minus the minimum value, so the difference is
#always going to be positive
file=open(args.des+"diff_"+str(kmer_size)+".wig", "w")
file.write("variableStep chrom="+header+"\n")
cont=0
for elem in list_cont:
	maximum=max(elem)
	minimum=min(elem)
	file.write(str(cont)+" "+str(maximum-minimum)+"\n")
	cont+=1

file.close()
