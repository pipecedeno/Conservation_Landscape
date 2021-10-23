#!/usr/bin/python3

import argparse

'''
This program will process the sam file and it will output the id of the kmers were perfectly aligned or 
that were aligned with an N in between the alignment
For this program if there are two kmers that were aligned that had an N and there are some kmers in between
that are missing, those ids are going to be printed as well as if those were aligned too.

'''

parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-f", "--file",dest="file",required=True) #sam file of the alignment
parser.add_argument("-s", "--size", dest="size", required=True) #size kmer
args = parser.parse_args()

file=open(args.file,"r")

size_kmer=args.size

def get_mdz_prefix(line_split):
	for elem in line_split:
		if("MD:Z:" in elem):
			md_z=elem
			break
	return(md_z.split(":")[-1])

line=file.readline()

temp_line=[]
check_repeated_id=False
last_line_has_N=False
for line in file:
	if(not "@" in line):
		normal_process=True
		line_split=line.rstrip("\n").split("\t")
		temp=get_mdz_prefix(line_split)
		#para ver si hay una linea repetida que no sea mismatch
		if(not temp_line):
			if(temp==size_kmer):
				print(line_split[0])
				last_line_has_N=False
			#if the distances are the same then the value must be a number different of size_kmer, which
			#will indicate that there was an insertion or deletion (necesito checar esto)
			elif((set(temp) <= set('1234567890N')) and len(size_kmer)!=len(temp)):
				print(line_split[0])
				last_line_has_N=True
		else:
			if(check_repeated_id):
				if(line_split[0]==temp_line[0]):
					if((set(temp) <= set('1234567890N')) and len(size_kmer)!=len(temp)):
						for i in range(int(temp_line[0])+1,int(line_split[0])+1):
							print(i)
						normal_process=False
						last_line_has_N=True
						#temp_line=[]
				else:
					check_repeated_id=False
					last_line_has_N=False
					#temp_line=[]
			#para ver si existe un gap
			elif(last_line_has_N):
				if(int(line_split[0])>(int(temp_line[0])+1)):
					if(temp==size_kmer):
						print(line_split[0])
						last_line_has_N=False
						#temp_line=[]
					elif((set(temp) <= set('1234567890N')) and len(size_kmer)!=len(temp)):
						for i in range(int(temp_line[0])+1,int(line_split[0])+1):
							print(i)
						last_line_has_N=True
						#temp_line=[]
					else:
						#como no es un match, no hace falta que se procese abajo, pero tampoco hay que borrar temp_line
						#porque podria haber otra linea con id repetido
						check_repeated_id=True
					normal_process=False #the line was processed already so the step below must not be done

			if(normal_process):
				if(temp==size_kmer):
					print(line_split[0])
					last_line_has_N=False
				#if the distances are the same then the value must be a number different of size_kmer, which
				#will indicate that there was an insertion or deletion (necesito checar esto)
				elif((set(temp) <= set('1234567890N')) and len(size_kmer)!=len(temp)):
					print(line_split[0])
					last_line_has_N=True
			
		temp_line=line_split

file.close()


