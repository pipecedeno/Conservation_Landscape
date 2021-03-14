#!/usr/bin/python3

'''
This program will make the wig files that are the output of the flow, this will be done by making
a matrix of counters, were the column 0 is going to be for the principal group and the column 1 
is going to be for the other group, and each row will be the position of the kmer -1, so the first 
kmer will be counted in the row 0. And the differences file is going to be created here too.
'''
import argparse

parser = argparse.ArgumentParser(description="Receives the number of genomes and the size of the kmer")
parser.add_argument("-p", "--psf",dest="psf",required=True) #principal group sam file
parser.add_argument("-o", "--osf",dest="osf",required=True) #other group sam file
parser.add_argument("-r", "--ref", dest="ref", required=True) #reference genome file
parser.add_argument("-d", "--des", dest="des", required=True) #directory where wigs are going to be saved
parser.add_argument("-k", "--nmk", dest="nmk", required=True) #number of kmers
parser.add_argument("-n", "--ngp", dest="ngp", required=True) #number of genomes in principal group
parser.add_argument("-m", "--nog", dest="nog", required=True) #number of genomes in other group
parser.add_argument("-g", "--pgn", dest="pgn", required=True) #principal genomes group name
parser.add_argument("-t", "--ogg", dest="ogg", required=True) #other genomes group name
args = parser.parse_args()

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
list_cont=[]

for cont in range(int(args.nmk)):
	list_cont.append([0, 0])

#Here the count for principal genomes is made
file=open(args.psf, "r")
for line in file:
	pos=int(line.rstrip("\n"))-1
	list_cont[pos][0]+=1

file.close()

#Here the count for other genomes is made
file=open(args.osf, "r")
for line in file:
	pos=int(line.rstrip("\n"))-1
	list_cont[pos][1]+=1

file.close()

#The output files are going to be opened and the header for each one is written
kmer_size=int(args.psf.rstrip(".samfinal").split("/")[-1].split("_")[0])

num_princ_genomes=int(args.ngp)
num_other_genomes=int(args.nog)

princ_file=open(args.des+args.pgn+"_"+str(kmer_size)+".wig", "w")
princ_file.write("variableStep chrom="+header+"\n")

other_file=open(args.des+args.ogg+"_"+str(kmer_size)+".wig", "w")
other_file.write("variableStep chrom="+header+"\n")

diff_file=open(args.des+"diff_"+str(kmer_size)+".wig", "w")
diff_file.write("variableStep chrom="+header+"\n")


for cont in range(len(list_cont)):
	princ_val=list_cont[cont][0]/num_princ_genomes
	other_val=list_cont[cont][1]/num_other_genomes

	princ_file.write(str(cont)+" "+str(princ_val)+"\n")

	other_file.write(str(cont)+" "+str(other_val)+"\n")

	diff_file.write(str(cont)+" "+str(princ_val-other_val)+"\n")


princ_file.close()
other_file.close()
diff_file.close()
