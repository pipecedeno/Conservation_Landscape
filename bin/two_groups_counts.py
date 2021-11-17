#!/usr/bin/python3

'''
Date: 17/Nov/2021
Author name: Luis Felipe Cedeño Pérez (pipecedeno@gmail.com)
version: 1.0

Program Description:
This program will make the wig files that are the output of the flow, this will be done by making
a matrix of counters, were the column 0 is going to be for the principal group and the column 1 
is going to be for the other group, and each row will be the position of the kmer -1, so the first 
kmer will be counted in the row 0. And the differences file is going to be created here too.

The inputs of this program are:
-psf directory were the output files of the alignments of the principal group are located to be processed
-osf directory were the output files of the alignments of the other group are located to be processed
-pnp directory were the alignment for the conservative track are located for the principal group
-onp directory were the alignment for the conservative track are located for the other group
-ref path to the reference genome
-des directory were the wig files are going to be saved
-nmk value of the amount of kmers in the genome for this size of the kmer
-ngp number of genomes in the principal group
-nog number of genomes in the other group
-pgn the name of the principal group, it's going to be used to name the wig files
-ogg the name of the other group, it's going to be used to name the wig files
-size size of the kmer used
'''
import argparse
from pathlib import Path

parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-p", "--psf",dest="psf",required=True) #principal group perfect alignments directory
parser.add_argument("-o", "--osf",dest="osf",required=True) #other group perfect alignments directory

parser.add_argument("-x", "--pnp",dest="pnp",required=True) #principal group not perfect alignments directory
parser.add_argument("-z", "--onp",dest="onp",required=True) #other group not perfect alignments directory

parser.add_argument("-r", "--ref", dest="ref", required=True) #reference genome file
parser.add_argument("-d", "--des", dest="des", required=True) #directory where wigs are going to be saved
parser.add_argument("-k", "--nmk", dest="nmk", required=True) #number of kmers
parser.add_argument("-n", "--ngp", dest="ngp", required=True) #number of genomes in principal group
parser.add_argument("-m", "--nog", dest="nog", required=True) #number of genomes in other group
parser.add_argument("-g", "--pgn", dest="pgn", required=True) #principal genomes group name
parser.add_argument("-t", "--ogg", dest="ogg", required=True) #other genomes group name
parser.add_argument("-s", "--size", dest="size", required=True) #size of the kmer
args = parser.parse_args()

#function to obtain the files in the desired directory
def files_in_path(path):
	return [path+obj.name for obj in Path(path).iterdir() if obj.is_file()]


def create_list_counts(list_files, number_kmers):
	output_list=[0 for i in range(number_kmers)]
	for file in list_files:
		counts=open(file, "r")
		for line in counts:
			pos=int(line.rstrip("\n"))-1
			output_list[pos]+=1

		counts.close()
	return(output_list)

#This is only for obtaining the header that is necessary for the wigs
file=open(args.ref, "r")
for line in file:
	if(line[0]==">"):
		header=line.rstrip("\n").replace(">","").split(" ")[0]
		break

file.close()

#Here a list will be created were the counts for the kmers appearances will be done, so the size of the 
#list will be of the amount of kmers minus 1, and each position will have a vector of size 2, where position 0 
#is for the count of principal groups genomes alignments, and position 1 is for other group genomes alignments.

#version 3 counts
number_kmers=int(args.nmk)
list_cont_normal=[]

#in the position [0] will be the counts for the principal group and in position [1] the counts of the
#other group
list_cont_normal.append(create_list_counts(files_in_path(args.psf), number_kmers))
list_cont_normal.append(create_list_counts(files_in_path(args.osf), number_kmers))

list_cont_not_perfect=[]
list_cont_not_perfect.append(create_list_counts(files_in_path(args.pnp), number_kmers))
list_cont_not_perfect.append(create_list_counts(files_in_path(args.onp), number_kmers))

#The output files are going to be opened and the header for each one is written
kmer_size=int(args.size)

num_princ_genomes=int(args.ngp)
num_other_genomes=int(args.nog)

#here all the files that are going to be written are opened and the header is added
#Note: the normal files are the ones from the version 2 program were Ns were counted too
princ_file_normal=open(args.des+args.pgn+"_"+str(kmer_size)+"_relaxed.wig", "w")
princ_file_normal.write("variableStep chrom="+header+"\n")

other_file_normal=open(args.des+args.ogg+"_"+str(kmer_size)+"_relaxed.wig", "w")
other_file_normal.write("variableStep chrom="+header+"\n")

diff_file_normal=open(args.des+"diff_"+str(kmer_size)+"_relaxed.wig", "w")
diff_file_normal.write("variableStep chrom="+header+"\n")

#this files are the ones were the output 
princ_file_mismatch=open(args.des+args.pgn+"_"+str(kmer_size)+"_conservative.wig", "w")
princ_file_mismatch.write("variableStep chrom="+header+"\n")

other_file_mismatch=open(args.des+args.ogg+"_"+str(kmer_size)+"_conservative.wig", "w")
other_file_mismatch.write("variableStep chrom="+header+"\n")

diff_file_mismatch=open(args.des+"diff_"+str(kmer_size)+"_conservative.wig", "w")
diff_file_mismatch.write("variableStep chrom="+header+"\n")


#Files of the amount of kmers that have an N
n_princ=open(args.des+args.pgn+"_"+str(kmer_size)+"_n_amounts"+".wig", "w")
n_princ.write("variableStep chrom="+header+"\n")

n_other=open(args.des+args.ogg+"_"+str(kmer_size)+"_n_amounts"+".wig", "w")
n_other.write("variableStep chrom="+header+"\n")

for cont in range(len(list_cont_normal[0])):
	princ_val=list_cont_normal[0][cont]/num_princ_genomes
	other_val=list_cont_normal[1][cont]/num_other_genomes

	princ_val_mismatch=list_cont_not_perfect[0][cont]/num_princ_genomes
	other_val_mismatch=list_cont_not_perfect[1][cont]/num_other_genomes

	princ_file_normal.write(str(cont)+" "+str(princ_val)+"\n")
	other_file_normal.write(str(cont)+" "+str(other_val)+"\n")
	diff_file_normal.write(str(cont)+" "+str(princ_val-other_val)+"\n")

	princ_file_mismatch.write(str(cont)+" "+str(princ_val_mismatch)+"\n")
	other_file_mismatch.write(str(cont)+" "+str(other_val_mismatch)+"\n")
	diff_file_mismatch.write(str(cont)+" "+str(princ_val_mismatch-other_val_mismatch)+"\n")

	#the value reported in the n files is the rest between the value of the mismatch only and the
	#value that only uses perfect matches, because the difference between this 2 values is the
	#amount of N's that are causing a reduction in the value in the second value.
	n_princ.write(str(cont)+" "+str(princ_val_mismatch-princ_val)+"\n")
	n_other.write(str(cont)+" "+str(other_val_mismatch-other_val)+"\n")

princ_file_normal.close()
other_file_normal.close()
diff_file_normal.close()

princ_file_mismatch.close()
other_file_mismatch.close()
diff_file_mismatch.close()
n_princ.close()
n_other.close()
